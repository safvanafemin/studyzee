import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClassWiseStudentsScreen extends StatefulWidget {
  const ClassWiseStudentsScreen({super.key});

  @override
  State<ClassWiseStudentsScreen> createState() => _ClassWiseStudentsScreenState();
}

class _ClassWiseStudentsScreenState extends State<ClassWiseStudentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _classes = [];
  Map<String, List<Map<String, dynamic>>> _classStudents = {};
  Map<String, Map<String, dynamic>> _classSummary = {};
  bool _isLoading = true;
  String? _selectedClassId;
  Map<String, bool> _expandedClasses = {};
  Map<String, Map<int, bool>> _studentPaymentStatus = {};
  Map<String, double> _classMonthlyFees = {};

  // Add a GlobalKey for ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Safe method to show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      // Load all active classes
      final classSnapshot = await _firestore
          .collection('Classes')
          .where('status', isEqualTo: 1)
          .get();

      _classes = classSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      // Load all active students
      final studentSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      // Organize students by class
      _classStudents.clear();
      _classSummary.clear();

      // Initialize with all classes
      for (var classData in _classes) {
        final classId = classData['id'];
        _classStudents[classId] = [];
        _classSummary[classId] = {
          'totalStudents': 0,
          'paidStudents': 0,
          'pendingStudents': 0,
          'totalFeesCollected': 0.0,
          'totalFeesPending': 0.0,
        };
        
        // Get class monthly fee
        _classMonthlyFees[classId] = (classData['monthlyFee'] ?? 0.0).toDouble();
      }

      // Group students by class
      for (var doc in studentSnapshot.docs) {
        final studentData = doc.data();
        final classId = studentData['classId'];
        
        if (classId != null && _classStudents.containsKey(classId)) {
          final student = {
            'id': doc.id,
            'name': studentData['name'] ?? 'Unknown',
            'email': studentData['email'] ?? '',
            'parentId': studentData['parentId'],
            'parentName': studentData['parentName'] ?? '',
            'parentEmail': studentData['parentEmail'] ?? '',
            'parentPhone': studentData['parentPhone'] ?? '',
            'rollNumber': studentData['rollNumber'] ?? 'N/A',
          };
          
          _classStudents[classId]!.add(student);
          
          // Update class summary
          final summary = _classSummary[classId]!;
          summary['totalStudents'] = summary['totalStudents']! + 1;
        }
      }

      // Load fee payments for each student
      await _loadPaymentStatus();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPaymentStatus() async {
    try {
      // Load all fee payments for current year
      final currentYear = DateTime.now().year;
      final paymentSnapshot = await _firestore
          .collection('FeePayments')
          .where('year', isEqualTo: currentYear)
          .get();

      // Initialize payment status for all students
      for (var classStudents in _classStudents.values) {
        for (var student in classStudents) {
          final studentId = student['id'];
          _studentPaymentStatus[studentId] = {};
          
          // Initialize all months as unpaid
          for (int month = 1; month <= 12; month++) {
            _studentPaymentStatus[studentId]![month] = false;
          }
        }
      }

      // Mark paid months
      for (var doc in paymentSnapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'];
        final month = data['month'];
        final status = data['status'];
        
        if (studentId != null && 
            month != null && 
            (status == 'paid' || status == 'completed') &&
            _studentPaymentStatus.containsKey(studentId)) {
          _studentPaymentStatus[studentId]![month] = true;
        }
      }

      // Update class summaries
      for (var classId in _classStudents.keys) {
        final students = _classStudents[classId]!;
        final monthlyFee = _classMonthlyFees[classId] ?? 0.0;
        
        int paidStudents = 0;
        int pendingStudents = 0;
        double totalCollected = 0.0;
        double totalPending = 0.0;

        for (var student in students) {
          final studentId = student['id'];
          final paymentStatus = _studentPaymentStatus[studentId];
          
          // Check if current month is paid
          final currentMonth = DateTime.now().month;
          final isCurrentMonthPaid = paymentStatus?[currentMonth] ?? false;
          
          if (isCurrentMonthPaid) {
            paidStudents++;
            totalCollected += monthlyFee;
          } else {
            pendingStudents++;
            totalPending += monthlyFee;
          }
        }

        _classSummary[classId] = {
          'totalStudents': students.length,
          'paidStudents': paidStudents,
          'pendingStudents': pendingStudents,
          'totalFeesCollected': totalCollected,
          'totalFeesPending': totalPending,
          'monthlyFee': monthlyFee,
        };
      }
    } catch (e) {
      print('Error loading payment status: $e');
    }
  }

  void _filterByClass(String? classId) {
    setState(() {
      _selectedClassId = classId;
    });
  }

  List<Map<String, dynamic>> get _filteredClasses {
    if (_selectedClassId == null) return _classes;
    return _classes.where((c) => c['id'] == _selectedClassId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Class-wise Students & Fees'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () {
              _showSetMonthlyFeeDialog();
            },
            icon: const Icon(Icons.attach_money),
            tooltip: 'Set Monthly Fee',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedClassId,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Class',
                        border: InputBorder.none,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Classes'),
                        ),
                        ..._classes.map((classData) {
                          final name = classData['name'] ?? '';
                          final section = classData['section'] ?? '';
                          final displayName = section.isNotEmpty
                              ? '$name - Section $section'
                              : name;
                          return DropdownMenuItem(
                            value: classData['id'],
                            child: Text(displayName),
                          );
                        }),
                      ],
                      onChanged: _filterByClass,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Summary Cards
          if (!_isLoading && _classSummary.isNotEmpty)
            _buildSummaryCards(),

          // Classes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClasses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.class_, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No classes found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredClasses.length,
                        itemBuilder: (context, index) {
                          final classData = _filteredClasses[index];
                          final classId = classData['id'];
                          final students = _classStudents[classId] ?? [];
                          final summary = _classSummary[classId] ?? {};
                          final isExpanded = _expandedClasses[classId] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            child: ExpansionTile(
                              key: Key(classId),
                              initiallyExpanded: isExpanded,
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _expandedClasses[classId] = expanded;
                                });
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[50],
                                child: Text(
                                  (classData['name'] ?? 'C')[0],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                _getClassName(classData),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${students.length} students • \$${summary['monthlyFee'] ?? 0} monthly',
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Paid: ${summary['paidStudents']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Pending: ${summary['pendingStudents']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$${summary['totalFeesCollected']?.toStringAsFixed(0) ?? '0'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Collected',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                if (students.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        'No students in this class',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  ...students.map((student) => 
                                      _buildStudentTile(student, classData)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalClasses = _filteredClasses.length;
    int totalStudents = _filteredClasses.fold(0, (sum, classData) {
      final classId = classData['id'];
      return sum + (_classStudents[classId]?.length ?? 0);
    });
    double totalCollected = _filteredClasses.fold(0.0, (sum, classData) {
      final classId = classData['id'];
      final summary = _classSummary[classId];
      return sum + (summary?['totalFeesCollected'] ?? 0.0);
    });
    double totalPending = _filteredClasses.fold(0.0, (sum, classData) {
      final classId = classData['id'];
      final summary = _classSummary[classId];
      return sum + (summary?['totalFeesPending'] ?? 0.0);
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniSummaryCard('Classes', totalClasses.toString(), Icons.class_, Colors.blue),
          _buildMiniSummaryCard('Students', totalStudents.toString(), Icons.people, Colors.purple),
          _buildMiniSummaryCard('Collected', '\$${totalCollected.toInt()}', Icons.attach_money, Colors.green),
          _buildMiniSummaryCard('Pending', '\$${totalPending.toInt()}', Icons.pending, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student, Map<String, dynamic> classData) {
    final studentName = student['name'] ?? 'Unknown';
    final studentEmail = student['email'] ?? '';
    final rollNumber = student['rollNumber'] ?? 'N/A';
    final classId = classData['id'];
    final monthlyFee = _classMonthlyFees[classId] ?? 0.0;

    // Check current month payment status
    final currentMonth = DateTime.now().month;
    final isCurrentMonthPaid = _studentPaymentStatus[student['id']]?[currentMonth] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentMonthPaid ? Colors.green[50] : Colors.orange[50],
          child: Icon(
            isCurrentMonthPaid ? Icons.check : Icons.pending,
            color: isCurrentMonthPaid ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          studentName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roll: $rollNumber • $studentEmail'),
            Text(
              'Fee: \$$monthlyFee/month',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentMonthPaid ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isCurrentMonthPaid ? 'PAID' : 'PENDING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isCurrentMonthPaid ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pay_current',
                  child: Row(
                    children: [
                      Icon(Icons.attach_money, size: 18),
                      SizedBox(width: 8),
                      Text('Pay Current Month'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pay_all',
                  child: Row(
                    children: [
                      Icon(Icons.payments, size: 18),
                      SizedBox(width: 8),
                      Text('View/Edit All Payments'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 18),
                      SizedBox(width: 8),
                      Text('Payment History'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'receipt',
                  child: Row(
                    children: [
                      Icon(Icons.receipt, size: 18),
                      SizedBox(width: 8),
                      Text('Generate Receipt'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'pay_current') {
                  _showPaymentDialog(student, classData, monthlyFee);
                } else if (value == 'pay_all') {
                  _showAllMonthsPayment(student, classData, monthlyFee);
                } else if (value == 'history') {
                  _showPaymentHistory(student['id']);
                } else if (value == 'receipt') {
                  _generateReceipt(student, classData, monthlyFee);
                }
              },
            ),
          ],
        ),
        onTap: () {
          _showStudentDetails(student, classData);
        },
      ),
    );
  }

  String _getClassName(Map<String, dynamic> classData) {
    final name = classData['name'] ?? '';
    final section = classData['section'] ?? '';
    return section.isNotEmpty ? '$name - Section $section' : name;
  }

  void _showStudentDetails(Map<String, dynamic> student, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Student Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', student['name'] ?? ''),
              _buildDetailRow('Email', student['email'] ?? ''),
              _buildDetailRow('Roll Number', student['rollNumber'] ?? ''),
              _buildDetailRow('Class', _getClassName(classData)),
              _buildDetailRow('Parent Name', student['parentName'] ?? ''),
              _buildDetailRow('Parent Email', student['parentEmail'] ?? ''),
              _buildDetailRow('Parent Phone', student['parentPhone'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentDialog(student, classData, _classMonthlyFees[classData['id']] ?? 0.0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 18, 69),
              foregroundColor: Colors.white,
            ),
            child: const Text('Make Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : 'N/A')),
        ],
      ),
    );
  }

  void _showPaymentDialog(Map<String, dynamic> student, Map<String, dynamic> classData, double monthlyFee) {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final monthName = _getMonthName(currentMonth);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay ${_getMonthName(currentMonth)} Fee'),
        content: PaymentDialogContent(
          studentName: student['name'] ?? 'Student',
          month: monthName,
          year: currentYear,
          amount: monthlyFee,
          className: _getClassName(classData),
          onConfirm: (paymentMethod, notes) async {
            try {
              await _recordPayment(
                studentId: student['id'],
                studentName: student['name'],
                classId: classData['id'],
                className: _getClassName(classData),
                month: currentMonth,
                year: currentYear,
                amount: monthlyFee,
                paymentMethod: paymentMethod,
                notes: notes,
              );

              // Close dialog first, then show snackbar
              if (context.mounted) {
                Navigator.pop(context);
                _showSnackBar('$monthName $currentYear marked as paid');
              }

              // Refresh data
              _loadData();
            } catch (e) {
              // Close dialog on error
              if (context.mounted) {
                Navigator.pop(context);
                _showSnackBar('Error: $e', isError: true);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _recordPayment({
    required String studentId,
    required String studentName,
    required String classId,
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
      'collectedBy': 'Admin',
      'receiptNumber': 'RCPT${DateTime.now().millisecondsSinceEpoch}',
      'notes': notes,
    });
  }

  void _showAllMonthsPayment(Map<String, dynamic> student, Map<String, dynamic> classData, double monthlyFee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentMonthlyPaymentScreen(
          studentId: student['id'],
          studentName: student['name'],
          className: _getClassName(classData),
          monthlyFee: monthlyFee,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _showPaymentHistory(String studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentPaymentHistoryScreen(studentId: studentId),
      ),
    );
  }

  void _generateReceipt(Map<String, dynamic> student, Map<String, dynamic> classData, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Receipt will be generated for:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              student['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Class: ${_getClassName(classData)}'),
            Text('Amount: \$$amount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Receipt generated successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 18, 69),
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showSetMonthlyFeeDialog() {
    final TextEditingController feeController = TextEditingController();
    String? selectedClassId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set Monthly Fee'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedClassId,
                    decoration: const InputDecoration(
                      labelText: 'Select Class (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Classes'),
                      ),
                      ..._classes.map((classData) {
                        final name = classData['name'] ?? '';
                        final section = classData['section'] ?? '';
                        final displayName = section.isNotEmpty
                            ? '$name - Section $section'
                            : name;
                        return DropdownMenuItem(
                          value: classData['id'],
                          child: Text(displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: feeController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Fee Amount',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter fee amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final fee = double.tryParse(feeController.text);
                  if (fee == null || fee <= 0) {
                    _showSnackBar('Please enter a valid fee amount', isError: true);
                    return;
                  }

                  try {
                    if (selectedClassId == null) {
                      // Apply to all classes
                      for (var classData in _classes) {
                        await _firestore
                            .collection('Classes')
                            .doc(classData['id'])
                            .update({
                          'monthlyFee': fee,
                          'feeUpdatedAt': FieldValue.serverTimestamp(),
                        });
                      }
                      
                      _showSnackBar('Fee set to \$$fee for all classes');
                    } else {
                      // Apply to specific class
                      await _firestore
                          .collection('Classes')
                          .doc(selectedClassId)
                          .update({
                        'monthlyFee': fee,
                        'feeUpdatedAt': FieldValue.serverTimestamp(),
                      });
                      
                      final className = _classes
                          .firstWhere((c) => c['id'] == selectedClassId)['name'];
                      
                      _showSnackBar('Fee set to \$$fee for $className');
                    }

                    Navigator.pop(context);
                    _loadData();
                  } catch (e) {
                    _showSnackBar('Error: $e', isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Set Fee'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    return [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][month - 1];
  }
}

// Separated Payment Dialog Content Widget
class PaymentDialogContent extends StatefulWidget {
  final String studentName;
  final String month;
  final int year;
  final double amount;
  final String className;
  final Function(String paymentMethod, String notes) onConfirm;

  const PaymentDialogContent({
    super.key,
    required this.studentName,
    required this.month,
    required this.year,
    required this.amount,
    required this.className,
    required this.onConfirm,
  });

  @override
  State<PaymentDialogContent> createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<PaymentDialogContent> {
  String _selectedPaymentMethod = 'Cash';
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info
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
                  widget.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(widget.className),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Month:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${widget.month} ${widget.year}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '\$${widget.amount}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Payment Method
          const Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: ['Cash', 'Bank Transfer', 'Cheque', 'Online Payment', 'Card']
                .map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Notes
          const Text('Notes (Optional):', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: 'Enter any notes about this payment...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_selectedPaymentMethod, _notesController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Confirm Payment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// The rest of your StudentMonthlyPaymentScreen and StudentPaymentHistoryScreen classes remain the same
// (you can keep them as they were in your original code)

class StudentMonthlyPaymentScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String className;
  final double monthlyFee;

  const StudentMonthlyPaymentScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.monthlyFee,
  });

  @override
  State<StudentMonthlyPaymentScreen> createState() =>
      _StudentMonthlyPaymentScreenState();
}

class _StudentMonthlyPaymentScreenState
    extends State<StudentMonthlyPaymentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _currentYear = DateTime.now().year;
  Map<int, Map<String, dynamic>> _monthPayments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    try {
      // Load payments for current year
      final paymentSnapshot = await _firestore
          .collection('FeePayments')
          .where('studentId', isEqualTo: widget.studentId)
          .where('year', isEqualTo: _currentYear)
          .get();

      // Initialize all months
      for (int month = 1; month <= 12; month++) {
        _monthPayments[month] = {'isPaid': false, 'paymentData': null};
      }

      // Mark paid months
      for (var doc in paymentSnapshot.docs) {
        final data = doc.data();
        final month = data['month'];
        final status = data['status'];

        if (month != null && (status == 'paid' || status == 'completed')) {
          _monthPayments[month] = {
            'isPaid': true,
            'paymentData': {
              'id': doc.id,
              ...data,
              'paymentDate': data['paymentDate']?.toDate(),
            },
          };
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payment data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleMonthPayment(int month) async {
    final currentStatus = _monthPayments[month]!;

    if (currentStatus['isPaid'] == true) {
      // Unmark as paid
      final paymentData = currentStatus['paymentData'];
      if (paymentData != null && paymentData['id'] != null) {
        await _firestore
            .collection('FeePayments')
            .doc(paymentData['id'])
            .update({
              'status': 'cancelled',
              'cancelledAt': FieldValue.serverTimestamp(),
            });
      }
    } else {
      // Mark as paid
      await _firestore.collection('FeePayments').add({
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'className': widget.className,
        'month': month,
        'year': _currentYear,
        'amount': widget.monthlyFee,
        'paymentMethod': 'Cash',
        'paymentDate': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(DateTime(_currentYear, month, 10)),
        'status': 'paid',
        'collectedBy': 'Admin',
        'receiptNumber': 'RCPT${DateTime.now().millisecondsSinceEpoch}',
        'notes': 'Marked as paid by admin',
      });
    }

    await _loadPaymentData();
  }

  Future<void> _editPaymentDetails(int month) async {
    final paymentData = _monthPayments[month]!['paymentData'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Payment - ${_getMonthName(month)}'),
        content: const Text(
          'Payment details editing will be implemented here.',
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

  @override
  Widget build(BuildContext context) {
    final paidMonths = _monthPayments.entries
        .where((entry) => entry.value['isPaid'] == true)
        .length;
    final totalAmount = paidMonths * widget.monthlyFee;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.studentName} - Monthly Payments'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[50],
                              child: Text(
                                widget.studentName[0],
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
                                    widget.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    widget.className,
                                    style: const TextStyle(color: Colors.grey),
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
                            _buildSummaryItem(
                              'Monthly Fee',
                              '\$${widget.monthlyFee}',
                            ),
                            _buildSummaryItem('Paid Months', '$paidMonths/12'),
                            _buildSummaryItem('Total Paid', '\$$totalAmount'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Months Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final monthData = _monthPayments[month]!;
                      final isPaid = monthData['isPaid'];
                      final paymentData = monthData['paymentData'];

                      return GestureDetector(
                        onTap: () => _toggleMonthPayment(month),
                        onLongPress: isPaid
                            ? () => _editPaymentDetails(month)
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green[50] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPaid
                                  ? Colors.green
                                  : Colors.grey[300] ?? Colors.grey,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getMonthName(month),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isPaid
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${widget.monthlyFee}',
                                style: TextStyle(
                                  color: isPaid
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                isPaid
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isPaid ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                              if (paymentData != null &&
                                  paymentData['paymentDate'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat(
                                      'dd/MM',
                                    ).format(paymentData['paymentDate']),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 2, 18, 69),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }
}

class StudentPaymentHistoryScreen extends StatefulWidget {
  final String studentId;

  const StudentPaymentHistoryScreen({super.key, required this.studentId});

  @override
  State<StudentPaymentHistoryScreen> createState() =>
      _StudentPaymentHistoryScreenState();
}

class _StudentPaymentHistoryScreenState
    extends State<StudentPaymentHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final paymentSnapshot = await _firestore
          .collection('FeePayments')
          .where('studentId', isEqualTo: widget.studentId)
          .get();

      _payments = paymentSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'paymentDate': data['paymentDate']?.toDate(),
          'dueDate': data['dueDate']?.toDate(),
        };
      }).toList();

      _totalPaid = _payments
          .where((p) => p['status'] == 'paid')
          .fold(0.0, (sum, p) => sum + (p['amount'] ?? 0.0));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Payments',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '\$${_totalPaid.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 2, 18, 69),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Records',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '${_payments.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Payments List
                Expanded(
                  child: _payments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No payment history found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _payments.length,
                          itemBuilder: (context, index) {
                            final payment = _payments[index];
                            final amount = payment['amount'] ?? 0.0;
                            final month = payment['month'];
                            final year = payment['year'];
                            final status = payment['status'];
                            final method = payment['paymentMethod'];
                            final receipt = payment['receiptNumber'];
                            final paymentDate = payment['paymentDate'];
                            final notes = payment['notes'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: status == 'paid'
                                      ? Colors.green[50]
                                      : status == 'cancelled'
                                      ? Colors.red[50]
                                      : Colors.orange[50],
                                  child: Icon(
                                    status == 'paid'
                                        ? Icons.check
                                        : status == 'cancelled'
                                        ? Icons.close
                                        : Icons.pending,
                                    color: status == 'paid'
                                        ? Colors.green
                                        : status == 'cancelled'
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  '${_getMonthName(month)} $year - \$${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$method • $receipt'),
                                    if (paymentDate != null)
                                      Text(
                                        'Paid on: ${DateFormat('dd/MM/yyyy HH:mm').format(paymentDate)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (notes != null && notes.isNotEmpty)
                                      Text(
                                        'Notes: $notes',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _showPaymentDetails(payment);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details - ${payment['receiptNumber']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Student', payment['studentName']),
              _buildDetailItem('Class', payment['className']),
              _buildDetailItem(
                'Month',
                '${_getMonthName(payment['month'])} ${payment['year']}',
              ),
              _buildDetailItem('Amount', '\$${payment['amount']}'),
              _buildDetailItem('Payment Method', payment['paymentMethod']),
              _buildDetailItem('Status', payment['status']),
              _buildDetailItem('Receipt No.', payment['receiptNumber']),
              _buildDetailItem('Collected By', payment['collectedBy']),
              if (payment['paymentDate'] != null)
                _buildDetailItem(
                  'Payment Date',
                  DateFormat('dd/MM/yyyy HH:mm').format(payment['paymentDate']),
                ),
              if (payment['notes'] != null)
                _buildDetailItem('Notes', payment['notes']),
            ],
          ),
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

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}
