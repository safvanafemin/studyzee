// features/parent/fee_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/payment_service.dart';

class ParentFeeScreen extends StatefulWidget {
  const ParentFeeScreen({super.key});

  @override
  State<ParentFeeScreen> createState() => _ParentFeeScreenState();
}

class _ParentFeeScreenState extends State<ParentFeeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Parent data
  Map<String, dynamic>? _parentData;
  final List<Map<String, dynamic>> _children = [];
  final Map<String, List<Map<String, dynamic>>> _childPayments = {};
  final Map<String, double> _childMonthlyFees = {};
  late PaymentService _paymentService;
  Map<String, dynamic>? _processingPaymentData;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.onSuccess = _handleRazorpaySuccess;
    _paymentService.onError = _handleRazorpayError;
    _loadParentData();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    if (_processingPaymentData != null) {
      setState(() => _isLoading = true);
      try {
        await _paymentService.savePaymentToFirestore(
          paymentId: response.paymentId ?? 'N/A',
          paymentDetails: _processingPaymentData!,
        );
        _showSnackBar('Payment successful!', isError: false);

        // Refresh data
        _childPayments.clear();
        await _loadParentData();
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

  void _showSnackBar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _loadParentData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load parent document
      final parentDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (parentDoc.exists) {
        _parentData = parentDoc.data() as Map<String, dynamic>;
        await _loadChildrenData();
      }
    } catch (e) {
      print('Error loading parent data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadChildrenData() async {
    try {
      final children = _parentData?['children'] as List<dynamic>? ?? [];

      for (var childId in children) {
        // Load child details
        final childDoc = await _firestore
            .collection('users')
            .doc(childId.toString())
            .get();
        if (childDoc.exists) {
          final childData = childDoc.data() as Map<String, dynamic>;
          final classId = childData['classId'];

          // Get class monthly fee
          double monthlyFee = 0.0;
          if (classId != null) {
            final classDoc = await _firestore
                .collection('Classes')
                .doc(classId.toString())
                .get();
            if (classDoc.exists) {
              final classData = classDoc.data() as Map<String, dynamic>;
              monthlyFee = (classData['monthlyFee'] ?? 0.0).toDouble();
            }
          }

          final child = {
            'id': childId,
            'name': childData['name'] ?? 'Unknown',
            'class': childData['className'] ?? 'Unknown',
            'rollNumber': childData['rollNumber'] ?? '',
            'classId': classId,
          };

          _children.add(child);
          _childMonthlyFees[childId] = monthlyFee;

          // Load payment status for this child
          await _loadChildPayments(
            childId.toString(),
            monthlyFee,
            classId?.toString(),
          );
        }
      }
    } catch (e) {
      print('Error loading children data: $e');
    }
  }

  Future<void> _loadChildPayments(
    String childId,
    double monthlyFee,
    String? classId,
  ) async {
    try {
      final currentYear = DateTime.now().year;
      List<Map<String, dynamic>> allMonths = [];

      // 1. Standard Monthly Fees
      final paymentsQuery = await _firestore
          .collection('FeePayments')
          .where('studentId', isEqualTo: childId)
          .where('year', isEqualTo: currentYear)
          .where('type', isEqualTo: 'monthly') // Only fetch monthly ones here
          .get();

      for (int month = 1; month <= 12; month++) {
        final paymentDoc = paymentsQuery.docs
            .where((doc) => doc['month'] == month)
            .firstOrNull;
        final isPaid = paymentDoc != null;

        allMonths.add({
          'id': 'monthly_$month',
          'title': '${_getMonthName(month)} $currentYear',
          'type': 'monthly',
          'month': month,
          'monthName': _getMonthName(month),
          'year': currentYear,
          'amount': monthlyFee,
          'status': isPaid ? 'paid' : 'unpaid',
          'dueDate': DateTime(currentYear, month, 10),
          'paymentData': isPaid
              ? {
                  'id': paymentDoc.id,
                  ...paymentDoc.data(),
                  'paymentDate': paymentDoc.data()['paymentDate']?.toDate(),
                }
              : null,
        });
      }

      // 2. Custom Fees (FeeStructures)
      if (classId != null) {
        final feeStructuresQuery = await _firestore
            .collection('FeeStructures')
            .where('classId', isEqualTo: classId)
            .get();

        for (var doc in feeStructuresQuery.docs) {
          final data = doc.data();
          final feeId = doc.id;
          if (!(data['isActive'] ?? true)) continue;

          // Check if paid
          final paymentQuery = await _firestore
              .collection('FeePayments')
              .where('studentId', isEqualTo: childId)
              .where('feeId', isEqualTo: feeId)
              .get();

          final isPaid = paymentQuery.docs.isNotEmpty;
          final dueDate = (data['dueDate'] as Timestamp).toDate();

          allMonths.add({
            'id': feeId,
            'title': data['title'] ?? 'Unknown Fee',
            'type': 'custom',
            'amount': (data['amount'] ?? 0.0).toDouble(),
            'status': isPaid ? 'paid' : 'unpaid',
            'dueDate': dueDate,
            'description': data['description'],
            'paymentData': isPaid
                ? {
                    'id': paymentQuery.docs.first.id,
                    ...paymentQuery.docs.first.data(),
                    'paymentDate': paymentQuery.docs.first
                        .data()['paymentDate']
                        ?.toDate(),
                  }
                : null,
          });
        }
      }

      // Sort by due date
      allMonths.sort(
        (a, b) =>
            (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime),
      );

      _childPayments[childId] = allMonths;
    } catch (e) {
      print('Error loading payments for child $childId: $e');
    }
  }

  void _initiatePayment(String childId, Map<String, dynamic> payment) {
    final child = _children.firstWhere((c) => c['id'] == childId);

    _processingPaymentData = {
      'amount': payment['amount'],
      'month': payment['month'],
      'monthName': payment['monthName'],
      'year': payment['year'],
      'feeId': payment['type'] == 'custom' ? payment['id'] : null,
      'title': payment['title'],
      'type': payment['type'],
      'studentId': childId,
      'studentName': child['name'],
      'classId': child['classId'],
      'className': child['class'],
      'paidBy': 'Parent',
      'parentId': _auth.currentUser?.uid,
    };

    _paymentService.startPayment(
      amount: payment['amount'],
      name: 'College Fees',
      description: payment['title'],
      email: _auth.currentUser?.email ?? 'parent@college.edu',
      contact: _parentData?['phoneNumber'] ?? '9999999999',
    );
  }

  Future<void> _makePayment(
    String childId,
    Map<String, dynamic> payment,
  ) async {
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
              'Pay Fee - ${payment['title']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const Divider(height: 32),
            _buildAmountRow(
              'Student',
              _children.firstWhere((c) => c['id'] == childId)['name'],
            ),
            _buildAmountRow(
              'Amount',
              '₹${payment['amount'].toStringAsFixed(2)}',
            ),
            if (payment['description'] != null &&
                payment['description'].toString().isNotEmpty)
              _buildAmountRow('Description', payment['description']),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initiatePayment(childId, payment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Pay with Razorpay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value) {
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
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recordPayment({
    required String studentId,
    required String studentName,
    required String? classId,
    required String className,
    required int month,
    required int year,
    required double amount,
    required String paymentMethod,
    String notes = '',
  }) async {
    await _firestore.collection('FeePayments').add({
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
      'month': month,
      'year': year,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': FieldValue.serverTimestamp(),
      'dueDate': Timestamp.fromDate(DateTime(year, month, 10)),
      'status': 'paid',
      'collectedBy': 'Parent',
      'receiptNumber': 'RCPT${DateTime.now().millisecondsSinceEpoch}',
      'notes': notes,
    });
  }

  String _getMonthName(int month) {
    return [
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
    ][month - 1];
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    final childId = child['id'];
    final childName = child['name'];
    final className = child['class'];
    final rollNumber = child['rollNumber'];
    final monthlyFee = _childMonthlyFees[childId] ?? 0.0;
    final payments = _childPayments[childId] ?? [];

    // Calculate paid and pending months
    int paidMonths = 0;
    int pendingMonths = 0;
    double totalPaid = 0.0;
    double totalPending = 0.0;

    for (var payment in payments) {
      if (payment['status'] == 'paid') {
        paidMonths++;
        totalPaid += monthlyFee;
      } else {
        pendingMonths++;
        totalPending += monthlyFee;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Text(
                    childName[0],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        childName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$className • Roll: $rollNumber',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Monthly Fee: \$${monthlyFee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Paid', '$paidMonths months', Colors.green),
                _buildStatCard(
                  'Pending',
                  '$pendingMonths months',
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Paid',
                  '\$${totalPaid.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Monthly Payment Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final monthData = payments[index];
                final monthName = monthData['monthName'];
                final status = monthData['status'];
                final isPaid = status == 'paid';

                return GestureDetector(
                  onTap: () {
                    if (!isPaid) {
                      _makePayment(childId, monthData);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPaid ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          monthName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPaid
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                        Text(
                          isPaid ? 'Paid' : 'Pay',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPaid
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (pendingMonths > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pay all pending months
                    _showPayAllDialog(childId, monthlyFee, payments);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pay All Pending Months'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPayAllDialog(
    String childId,
    double monthlyFee,
    List<Map<String, dynamic>> payments,
  ) {
    final pendingMonths = payments
        .where((p) => p['status'] == 'unpaid')
        .toList();
    final totalAmount = pendingMonths.length * monthlyFee;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay All Pending Months'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payments, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Total Pending: ${pendingMonths.length} months',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to pay for all pending months?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Mark each pending month as paid
              for (var monthData in pendingMonths) {
                await _recordPayment(
                  studentId: childId,
                  studentName: _children.firstWhere(
                    (c) => c['id'] == childId,
                  )['name'],
                  classId: _children.firstWhere(
                    (c) => c['id'] == childId,
                  )['classId'],
                  className: _children.firstWhere(
                    (c) => c['id'] == childId,
                  )['class'],
                  month: monthData['month'],
                  year: DateTime.now().year,
                  amount: monthlyFee,
                  paymentMethod: 'Online',
                  notes: 'Bulk payment for all pending months',
                );
              }

              // Refresh data
              if (mounted) {
                setState(() {
                  _childPayments.clear();
                });
                for (var child in _children) {
                  await _loadChildPayments(
                    child['id']?.toString() ?? '',
                    _childMonthlyFees[child['id']]!,
                    child['classId']?.toString(),
                  );
                }
                if (mounted) {
                  setState(() {});
                }
              }

              _scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('All pending months paid successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fee Payments'),
          backgroundColor: const Color.fromARGB(255, 2, 18, 69),
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _children.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No children found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please contact your school administrator',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: _children
                      .map((child) => _buildChildCard(child))
                      .toList(),
                ),
              ),
      ),
    );
  }
}

// Parent Payment Dialog Content
class ParentPaymentDialogContent extends StatefulWidget {
  final String childName;
  final String month;
  final int year;
  final double amount;
  final Function(String paymentMethod, String notes) onConfirm;

  const ParentPaymentDialogContent({
    super.key,
    required this.childName,
    required this.month,
    required this.year,
    required this.amount,
    required this.onConfirm,
  });

  @override
  State<ParentPaymentDialogContent> createState() =>
      _ParentPaymentDialogContentState();
}

class _ParentPaymentDialogContentState
    extends State<ParentPaymentDialogContent> {
  String _selectedPaymentMethod = 'Online';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.childName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('${widget.month} ${widget.year}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Method:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedPaymentMethod,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ['Online', 'Bank Transfer', 'Cash', 'Cheque']
                .map(
                  (method) =>
                      DropdownMenuItem(value: method, child: Text(method)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Notes (Optional):',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Enter any notes...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(
                      _selectedPaymentMethod,
                      _notesController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Make Payment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
