import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class StudentFeePaymentScreen extends StatefulWidget {
  const StudentFeePaymentScreen({super.key});

  @override
  State<StudentFeePaymentScreen> createState() =>
      _StudentFeePaymentScreenState();
}

class _StudentFeePaymentScreenState extends State<StudentFeePaymentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Razorpay _razorpay = Razorpay();

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _classInfo;
  List<Map<String, dynamic>> _allPayments =
      []; // All payments (pending and paid)
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
    _initializeRazorpay();
    _loadData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data();

        // Load class info
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

        // Load all payments for current year
        await _loadAllPayments();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading fee data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllPayments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Reset all lists
      _allPayments.clear();
      _pendingPayments.clear();
      _paidPayments.clear();
      _totalDue = 0.0;
      _totalPaid = 0.0;

      // Load all months for current year
      for (int month = 1; month <= 12; month++) {
        final monthName = _months[month - 1];
        final dueDate = DateTime(_currentYear, month, 10);
        final isOverdue =
            DateTime.now().isAfter(dueDate) && DateTime.now().month >= month;
        final isCurrentMonth = month == DateTime.now().month;

        // Check if payment exists
        final paymentDoc = await _getPaymentForMonth(month, _currentYear);

        if (paymentDoc != null && paymentDoc['status'] == 'paid') {
          // Paid payment
          final paymentData = {
            'month': month,
            'monthName': monthName,
            'year': _currentYear,
            'amount': _monthlyFee,
            'dueDate': dueDate,
            'paymentDate': paymentDoc['paymentDate']?.toDate(),
            'status': 'paid',
            'receiptNumber': paymentDoc['receiptNumber'] ?? 'N/A',
            'paymentMethod': paymentDoc['paymentMethod'] ?? 'Unknown',
            'isCurrentMonth': isCurrentMonth,
          };

          _allPayments.add(paymentData);
          _paidPayments.add(paymentData);
          _totalPaid += _monthlyFee;
        } else {
          // Pending payment
          final paymentData = {
            'month': month,
            'monthName': monthName,
            'year': _currentYear,
            'amount': _monthlyFee,
            'dueDate': dueDate,
            'status': 'pending',
            'isOverdue': isOverdue && DateTime.now().month >= month,
            'isCurrentMonth': isCurrentMonth,
          };

          _allPayments.add(paymentData);
          _pendingPayments.add(paymentData);
          if (DateTime.now().month >= month) {
            // Only count due months
            _totalDue += _monthlyFee;
          }
        }
      }

      // Sort payments by month
      _allPayments.sort((a, b) => a['month'].compareTo(b['month']));
      _pendingPayments.sort((a, b) => a['month'].compareTo(b['month']));
      _paidPayments.sort(
        (a, b) => b['month'].compareTo(a['month']),
      ); // Show recent paid first
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
          // .where('month', isEqualTo: month)
          // .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return {...data, 'paymentDate': data['paymentDate']?.toDate()};
      }
      return null;
    } catch (e) {
      print('Error getting payment for month: $e');
      return null;
    }
  }

  void _showPaymentDialog(Map<String, dynamic> payment) {
    final month = payment['month'];
    final year = payment['year'];
    final amount = payment['amount'];
    final monthName = payment['monthName'];
    final dueDate = payment['dueDate'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentDialog(
        monthName: monthName,
        year: year,
        amount: amount,
        dueDate: dueDate,
        onPayNow: () => _initiateRazorpayPayment(payment),
        onViewDetails: () => _showPaymentDetails(payment),
      ),
    );
  }

  void _initiateRazorpayPayment(Map<String, dynamic> payment) {
    final month = payment['month'];
    final year = payment['year'];
    final amountInPaise = (payment['amount'] * 100).toInt();
    final monthName = payment['monthName'];
    final user = _auth.currentUser;

    // Generate a unique order ID
    final orderId =
        'ORD_${user?.uid}_${year}${month.toString().padLeft(2, '0')}_${DateTime.now().millisecondsSinceEpoch}';

    final options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with your Razorpay API Key
      'amount': amountInPaise.toString(),
      'name': 'School Fee Payment',
      'description': 'Fee for $monthName $year',
      'order_id': orderId,
      'prefill': {
        'contact': _userData?['phone'] ?? '+919999999999',
        'email': user?.email ?? '',
        'name': _userData?['name'] ?? 'Student',
      },
      'notes': {
        'studentId': user?.uid,
        'studentName': _userData?['name'],
        'month': month,
        'year': year,
        'classId': _classInfo?['id'],
        'className': _classInfo?['name'] ?? '',
      },
      'theme': {'color': '#60a5fa'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar('Error initiating payment: ${e.toString()}', isError: true);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final pendingPayment = _pendingPayments.firstWhere(
      (p) => p['isCurrentMonth'] == true,
      orElse: () => _pendingPayments.first,
    );

    final month = pendingPayment['month'];
    final year = pendingPayment['year'];
    final amount = pendingPayment['amount'];

    _recordPayment(
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
      month: month,
      year: year,
      amount: amount,
    );

    _showSnackBar('Payment successful! Receipt will be generated.');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.message}', isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External wallet selected: ${response.walletName}');
  }

  Future<void> _recordPayment({
    required String? paymentId,
    required String? orderId,
    required String? signature,
    required int month,
    required int year,
    required double amount,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('FeePayments').add({
        'studentId': user.uid,
        'studentName': _userData?['name'] ?? '',
        'studentEmail': user.email ?? '',
        'classId': _classInfo?['id'],
        'className': _classInfo?['name'] ?? '',
        'month': month,
        'year': year,
        'amount': amount,
        'paymentMethod': 'Razorpay',
        'paymentGateway': 'razorpay',
        'paymentId': paymentId,
        'orderId': orderId,
        'signature': signature,
        'paymentDate': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(DateTime(year, month, 10)),
        'status': 'paid',
        'verified': true,
        'receiptNumber': 'RCPT${DateTime.now().millisecondsSinceEpoch}',
        'notes': 'Paid via Razorpay by student',
        'parentPhone': _userData?['parentContact'],
        'parentEmail': _userData?['parentEmail'],
      });

      // Reload data
      await _loadData();
    } catch (e) {
      print('Error recording payment: $e');
      _showSnackBar('Error saving payment record', isError: true);
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => PaymentDetailsDialog(
        payment: payment,
        studentName: _userData?['name'] ?? 'Student',
        className: _classInfo?['name'] ?? '',
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f4ff),
        appBar: AppBar(
          backgroundColor: const Color(0xFF60a5fa),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Fee Payment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Paid'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // All Tab
                  _buildAllPaymentsTab(),
                  // Pending Tab
                  _buildPendingTab(),
                  // Paid Tab
                  _buildPaidTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildAllPaymentsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Monthly Fee',
                    '\$${_monthlyFee.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Due',
                    '\$${_totalDue.toStringAsFixed(2)}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Paid',
                    '\$${_totalPaid.toStringAsFixed(2)}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Year Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF60a5fa).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF60a5fa).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFF60a5fa),
                ),
                const SizedBox(width: 8),
                Text(
                  'Fee Status for $_currentYear',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1e3a8a),
                  ),
                ),
              ],
            ),
          ),

          // All Payments List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Fee Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e3a8a),
                  ),
                ),
                const SizedBox(height: 12),
                ..._allPayments.map((payment) => _buildPaymentItem(payment)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return _pendingPayments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'All Fees Paid!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have no pending payments',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                // Due Summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${_totalDue.toStringAsFixed(2)} Due',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_pendingPayments.length} pending payment${_pendingPayments.length > 1 ? 's' : ''}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      if (_pendingPayments.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            final paymentToPay = _pendingPayments.firstWhere(
                              (p) => p['isOverdue'],
                              orElse: () => _pendingPayments.firstWhere(
                                (p) => p['isCurrentMonth'],
                                orElse: () => _pendingPayments.first,
                              ),
                            );
                            _showPaymentDialog(paymentToPay);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pay Now'),
                        ),
                    ],
                  ),
                ),

                // Pending Payments List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Payments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._pendingPayments.map(
                        (payment) => _buildPendingPaymentCard(payment),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildPaidTab() {
    return _paidPayments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Payment History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have no paid fees yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                // Paid Summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${_totalPaid.toStringAsFixed(2)} Paid',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_paidPayments.length} payment${_paidPayments.length > 1 ? 's' : ''} completed',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Paid Payments List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._paidPayments.map(
                        (payment) => _buildPaidPaymentCard(payment),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final isPaid = payment['status'] == 'paid';
    final monthName = payment['monthName'];
    final year = payment['year'];
    final amount = payment['amount'];
    final dueDate = payment['dueDate'];
    final isOverdue = payment['isOverdue'] ?? false;
    final isCurrentMonth = payment['isCurrentMonth'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isPaid ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? Colors.green : Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          '$monthName $year',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Due: ${DateFormat('dd MMM yyyy').format(dueDate)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (payment['paymentDate'] != null)
              Text(
                'Paid: ${DateFormat('dd MMM yyyy').format(payment['paymentDate'])}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            if (isCurrentMonth)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CURRENT MONTH',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPaid ? 'PAID' : 'PENDING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showPaymentDetails(payment),
      ),
    );
  }

  Widget _buildPendingPaymentCard(Map<String, dynamic> payment) {
    final monthName = payment['monthName'];
    final year = payment['year'];
    final amount = payment['amount'];
    final dueDate = payment['dueDate'];
    final isOverdue = payment['isOverdue'] ?? false;
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? Colors.red[100]! : Colors.orange[100]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isOverdue ? Colors.red[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            isOverdue ? Icons.warning : Icons.pending,
            color: isOverdue ? Colors.red : Colors.orange,
            size: 24,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '$monthName $year',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Due: ${DateFormat('dd MMM yyyy').format(dueDate)}',
              style: TextStyle(
                color: isOverdue ? Colors.red : Colors.grey,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (daysRemaining >= 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$daysRemaining days remaining',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
          ],
        ),
        trailing: SizedBox(
          height: 60, // Fixed height for trailing
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 28, // Fixed height for button
                child: ElevatedButton(
                  onPressed: () => _showPaymentDialog(payment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue
                        ? Colors.red
                        : const Color(0xFF60a5fa),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: const Size(60, 0),
                  ),
                  child: const Text('Pay', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaidPaymentCard(Map<String, dynamic> payment) {
    final monthName = payment['monthName'];
    final year = payment['year'];
    final amount = payment['amount'];
    final paymentDate = payment['paymentDate'];
    final receiptNumber = payment['receiptNumber'] ?? 'N/A';
    final paymentMethod = payment['paymentMethod'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ),
        title: Text(
          '$monthName $year',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Paid: ${DateFormat('dd MMM yyyy, hh:mm a').format(paymentDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
            Text(
              'Receipt: $receiptNumber',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Method: $paymentMethod',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PAID',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentDialog extends StatelessWidget {
  final String monthName;
  final int year;
  final double amount;
  final DateTime dueDate;
  final VoidCallback onPayNow;
  final VoidCallback onViewDetails;

  const PaymentDialog({
    super.key,
    required this.monthName,
    required this.year,
    required this.amount,
    required this.dueDate,
    required this.onPayNow,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fee Payment - $monthName $year',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e3a8a),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Amount', '\$${amount.toStringAsFixed(2)}'),
          _buildDetailRow(
            'Due Date',
            DateFormat('dd MMMM yyyy').format(dueDate),
          ),
          _buildDetailRow(
            'Status',
            DateTime.now().isAfter(dueDate) ? 'Overdue' : 'Pending',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPayNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF60a5fa),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pay with Razorpay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View Details'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class PaymentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> payment;
  final String studentName;
  final String className;

  const PaymentDetailsDialog({
    super.key,
    required this.payment,
    required this.studentName,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = payment['status'] == 'paid';
    final monthName = payment['monthName'];
    final year = payment['year'];
    final amount = payment['amount'];
    final dueDate = payment['dueDate'];
    final paymentDate = payment['paymentDate'];
    final receiptNumber = payment['receiptNumber'] ?? 'N/A';
    final paymentMethod = payment['paymentMethod'] ?? 'Unknown';
    final isOverdue = payment['isOverdue'] ?? false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle : Icons.pending,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '$monthName $year Fee',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e3a8a),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Student', studentName),
              _buildDetailRow('Class', className),
              _buildDetailRow('Amount', '\$${amount.toStringAsFixed(2)}'),
              _buildDetailRow(
                'Due Date',
                DateFormat('dd MMMM yyyy').format(dueDate),
              ),

              if (isPaid) ...[
                _buildDetailRow('Status', 'Paid'),
                _buildDetailRow(
                  'Payment Date',
                  DateFormat('dd MMMM yyyy, hh:mm a').format(paymentDate),
                ),
                _buildDetailRow('Receipt No.', receiptNumber),
                _buildDetailRow('Payment Method', paymentMethod),
              ] else ...[
                _buildDetailRow('Status', isOverdue ? 'Overdue' : 'Pending'),
                if (isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'This payment is overdue. Please pay immediately.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60a5fa),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
