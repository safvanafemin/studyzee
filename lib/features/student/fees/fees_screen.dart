import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/payment_service.dart';

class StudentFeePaymentScreen extends StatefulWidget {
  const StudentFeePaymentScreen({super.key});

  @override
  State<StudentFeePaymentScreen> createState() =>
      _StudentFeePaymentScreenState();
}

class _StudentFeePaymentScreenState extends State<StudentFeePaymentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late PaymentService _paymentService;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _classInfo;
  List<Map<String, dynamic>> _allPayments = [];
  List<Map<String, dynamic>> _pendingPayments = [];
  List<Map<String, dynamic>> _paidPayments = [];
  bool _isLoading = true;
  double _totalDue = 0.0;
  double _monthlyFee = 0.0;
  double _totalPaid = 0.0;

  final int _currentYear = DateTime.now().year;
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _loadData();

    // Listen to Razorpay signals
    _paymentService.onSuccess = _handleRazorpaySuccess;
    _paymentService.onError = _handleRazorpayError;
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    // This is called when payment is successful
    if (_processingPaymentData != null) {
      setState(() => _isLoading = true);
      try {
        await _paymentService.savePaymentToFirestore(
          paymentId: response.paymentId ?? 'N/A',
          paymentDetails: _processingPaymentData!,
        );
        _showSnackBar('Payment successful and recorded!', isError: false);
        _loadData();
      } catch (e) {
        _showSnackBar('Error recording payment: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
        _processingPaymentData = null;
      }
    }
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.message}', isError: true);
    _processingPaymentData = null;
  }

  Map<String, dynamic>? _processingPaymentData;

  Future<void> _loadData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        final classId = _userData?['classId'];
        if (classId != null && classId.isNotEmpty) {
          final classDoc = await _firestore
              .collection('Classes')
              .doc(classId)
              .get();
          if (classDoc.exists) {
            _classInfo = {'id': classDoc.id, ...classDoc.data()!};
            _monthlyFee = (classDoc.data()!['monthlyFee'] ?? 0.0).toDouble();
          }
        }
        await _loadAllPayments();
      }
    } catch (e) {
      print('Error loading fee data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllPayments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _allPayments.clear();
      _pendingPayments.clear();
      _paidPayments.clear();
      _totalDue = 0.0;
      _totalPaid = 0.0;

      for (int month = 1; month <= 12; month++) {
        final monthName = _months[month - 1];
        final dueDate = DateTime(_currentYear, month, 10);
        final isOverdue =
            DateTime.now().isAfter(dueDate) && DateTime.now().month >= month;
        final isCurrentMonth = month == DateTime.now().month;

        final paymentDoc = await _getPaymentForMonth(month, _currentYear);

        if (paymentDoc != null && paymentDoc['status'] == 'paid') {
          final paymentData = {
            'month': month,
            'monthName': monthName,
            'year': _currentYear,
            'amount': _monthlyFee,
            'dueDate': dueDate,
            'paymentDate': paymentDoc['paymentDate'],
            'status': 'paid',
            'receiptNumber': paymentDoc['receiptNumber'] ?? 'N/A',
            'paymentMethod': paymentDoc['paymentMethod'] ?? 'Razorpay',
            'isCurrentMonth': isCurrentMonth,
          };
          _allPayments.add(paymentData);
          _paidPayments.add(paymentData);
          _totalPaid += _monthlyFee;
        } else {
          final paymentData = {
            'month': month,
            'monthName': monthName,
            'year': _currentYear,
            'amount': _monthlyFee,
            'dueDate': dueDate,
            'status': 'pending',
            'isOverdue': isOverdue,
            'isCurrentMonth': isCurrentMonth,
          };
          _allPayments.add(paymentData);
          _pendingPayments.add(paymentData);
          if (DateTime.now().month >= month) {
            _totalDue += _monthlyFee;
          }
        }
      }
      _allPayments.sort((a, b) => a['month'].compareTo(b['month']));
      _pendingPayments.sort((a, b) => a['month'].compareTo(b['month']));
      _paidPayments.sort((a, b) => b['month'].compareTo(a['month']));
    } catch (e) {
      print('Error loading payments: $e');
    }
  }

  Future<Map<String, dynamic>?> _getPaymentForMonth(int month, int year) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _firestore
          .collection('FeePayments')
          .where('studentId', isEqualTo: user.uid)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return {
          ...data,
          'paymentDate': (data['paymentDate'] as Timestamp?)?.toDate(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _initiatePayment(Map<String, dynamic> payment) {
    _processingPaymentData = {
      'amount': payment['amount'],
      'month': payment['month'],
      'monthName': payment['monthName'],
      'year': payment['year'],
      'studentName': _userData?['name'] ?? 'Student',
      'classId': _userData?['classId'] ?? '',
      'className': _userData?['className'] ?? '',
    };

    _paymentService.startPayment(
      amount: payment['amount'],
      name: 'College Fees',
      description: '${payment['monthName']} ${payment['year']} Payment',
      email: _auth.currentUser?.email ?? 'student@college.edu',
      contact: _userData?['phoneNumber'] ?? '9999999999',
    );
  }

  void _showPaymentDialog(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pay Fees - ${payment['monthName']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const Divider(height: 32),
            _buildDetailRow(
              'Amount',
              '₹${payment['amount'].toStringAsFixed(2)}',
            ),
            _buildDetailRow('Month', payment['monthName']),
            _buildDetailRow('Year', payment['year'].toString()),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initiatePayment(payment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Pay with Razorpay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showOfflinePaymentInstructions();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Offline Instructions',
                  style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOfflinePaymentInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Offline Payment'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Visit college accounts office.'),
            Text('2. Provide your Name & Roll No.'),
            Text('3. Pay via Cash/Cheque.'),
            SizedBox(height: 16),
            Text(
              'Bank Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A/C: 1234567890'),
            Text('IFSC: STZE0001234'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${payment['monthName']} Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Status', 'PAID', color: Colors.green),
            _buildDetailRow(
              'Amount',
              '₹${payment['amount'].toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Date',
              DateFormat('dd MMM yyyy').format(payment['paymentDate']),
            ),
            _buildDetailRow('Method', payment['paymentMethod'] ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Fee Payment',
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.blue[600],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue[600],
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Pending'),
              Tab(text: 'Paid'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue[600]))
            : TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildPendingTab(),
                  _buildPaidTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          const Text(
            'All Months',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._allPayments.map((p) => _buildPaymentCard(p)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Due', '₹${_totalDue.toStringAsFixed(0)}'),
          _buildSummaryItem('Paid', '₹${_totalPaid.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    final pending = _allPayments
        .where((p) => p['status'] == 'pending')
        .toList();
    if (pending.isEmpty)
      return const Center(child: Text('No pending payments'));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildPaymentCard(pending[index]),
    );
  }

  Widget _buildPaidTab() {
    final paid = _allPayments.where((p) => p['status'] == 'paid').toList();
    if (paid.isEmpty) return const Center(child: Text('No paid payments yet'));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: paid.length,
      itemBuilder: (context, index) => _buildPaymentCard(paid[index]),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final bool isPaid = payment['status'] == 'paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(
          '${payment['monthName']} ${payment['year']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Due: ${DateFormat('dd MMM').format(payment['dueDate'])}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${payment['amount'].toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.blue,
              ),
            ),
            Text(
              isPaid ? 'PAID' : 'PENDING',
              style: TextStyle(
                fontSize: 10,
                color: isPaid ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
        onTap: () =>
            isPaid ? _showPaymentDetails(payment) : _showPaymentDialog(payment),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}
