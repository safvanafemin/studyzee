// features/parent/fee_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> _children = [];
  Map<String, List<Map<String, dynamic>>> _childPayments = {};
  Map<String, double> _childMonthlyFees = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParentData();
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
          await _loadChildPayments(childId.toString(), monthlyFee);
        }
      }
    } catch (e) {
      print('Error loading children data: $e');
    }
  }

  Future<void> _loadChildPayments(String childId, double monthlyFee) async {
    try {
      final currentYear = DateTime.now().year;
      final paymentsQuery = await _firestore
          .collection('FeePayments')
          .where('studentId', isEqualTo: childId)
          .where('year', isEqualTo: currentYear)
          .get();

      // Initialize 12 months with unpaid status
      List<Map<String, dynamic>> months = [];
      for (int month = 1; month <= 12; month++) {
        months.add({
          'month': month,
          'monthName': _getMonthName(month),
          'year': currentYear,
          'amount': monthlyFee,
          'status': 'unpaid', // default
          'paymentData': null,
        });
      }

      // Mark paid months
      for (var doc in paymentsQuery.docs) {
        final data = doc.data();
        final month = data['month'];
        final status = data['status'];

        if (month != null && (status == 'paid' || status == 'completed')) {
          // Update the month's status
          int index = month - 1;
          if (index >= 0 && index < 12) {
            months[index]['status'] = 'paid';
            months[index]['paymentData'] = {
              'id': doc.id,
              ...data,
              'paymentDate': data['paymentDate']?.toDate(),
            };
          }
        }
      }

      _childPayments[childId] = months;
    } catch (e) {
      print('Error loading payments for child $childId: $e');
    }
  }

  Future<void> _makePayment(String childId, int month, double amount) async {
    final currentYear = DateTime.now().year;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay ${_getMonthName(month)} Fee'),
        content: ParentPaymentDialogContent(
          childName: _children.firstWhere((c) => c['id'] == childId)['name'],
          month: _getMonthName(month),
          year: currentYear,
          amount: amount,
          onConfirm: (paymentMethod, notes) async {
            try {
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
                month: month,
                year: currentYear,
                amount: amount,
                paymentMethod: paymentMethod,
                notes: notes,
              );

              // Close dialog
              Navigator.pop(context);

              // Refresh data
              if (mounted) {
                setState(() {
                  _childPayments.clear();
                });
                for (var child in _children) {
                  await _loadChildPayments(
                    child['id'],
                    _childMonthlyFees[child['id']]!,
                  );
                }
                if (mounted) {
                  setState(() {});
                }
              }

              // Show success message
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(
                    '${_getMonthName(month)} $currentYear marked as paid',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
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
                final month = monthData['month'];
                final monthName = monthData['monthName'];
                final status = monthData['status'];
                final isPaid = status == 'paid';

                return GestureDetector(
                  onTap: () {
                    if (!isPaid) {
                      _makePayment(childId, month, monthlyFee);
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
                    child['id'],
                    _childMonthlyFees[child['id']]!,
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
            value: _selectedPaymentMethod,
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
