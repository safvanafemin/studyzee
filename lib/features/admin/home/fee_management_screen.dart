import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _feeStructures = [];
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;
  double _monthlyFee = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load classes
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

      // Load fee structures
      final feeSnapshot = await _firestore
          .collection('FeeStructures')
          .orderBy('createdAt', descending: true)
          .get();

      _feeStructures = feeSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'createdAt': data['createdAt']?.toDate(),
        };
      }).toList();

      // Get current monthly fee
      final settingsDoc = await _firestore
          .collection('Settings')
          .doc('monthlyFee')
          .get();
      
      if (settingsDoc.exists) {
        setState(() {
          _monthlyFee = (settingsDoc.data()?['amount'] ?? 0.0).toDouble();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMonthlyFee() async {
    if (_monthlyFee <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid fee amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('Settings').doc('monthlyFee').set({
        'amount': _monthlyFee,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Apply to all active classes
      for (var classData in _classes) {
        await _firestore
            .collection('Classes')
            .doc(classData['id'])
            .update({
          'monthlyFee': _monthlyFee,
          'feeUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Record fee structure change
      await _firestore.collection('FeeStructures').add({
        'type': 'monthly',
        'amount': _monthlyFee,
        'appliedToClasses': _classes.length,
        'createdBy': 'Admin',
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'Updated monthly fee for all classes',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monthly fee updated to \$$_monthlyFee'),
          backgroundColor: Colors.green,
        ),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _applyFeeToSpecificClass(
    String classId,
    String className,
    double feeAmount,
  ) async {
    try {
      await _firestore.collection('Classes').doc(classId).update({
        'monthlyFee': feeAmount,
        'feeUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Record fee structure change
      await _firestore.collection('FeeStructures').add({
        'type': 'monthly',
        'amount': feeAmount,
        'classId': classId,
        'className': className,
        'createdBy': 'Admin',
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'Updated fee for specific class',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fee updated for $className'),
          backgroundColor: Colors.green,
        ),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Global Monthly Fee Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Global Monthly Fee',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 2, 18, 69),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This fee will be applied to all classes and students',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Monthly Fee Amount',
                                    prefixIcon: const Icon(Icons.attach_money),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  initialValue: _monthlyFee.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _monthlyFee =
                                          double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _updateMonthlyFee,
                                icon: const Icon(Icons.save),
                                label: const Text('Apply to All'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 2, 18, 69),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Applied to ${_classes.length} active classes',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Classes with Custom Fees
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Class-wise Fee Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 2, 18, 69),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set individual fees for specific classes',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ..._classes.map((classData) {
                            final className = classData['name'] ?? '';
                            final section = classData['section'] ?? '';
                            final displayName = section.isNotEmpty
                                ? '$className - Section $section'
                                : className;
                            final currentFee = (classData['monthlyFee'] ?? 0.0)
                                .toDouble();
                            final TextEditingController _feeController =
                                TextEditingController(
                                    text: currentFee.toString());

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Current: \$$currentFee',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 120,
                                    child: TextFormField(
                                      controller: _feeController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: InputDecoration(
                                        hintText: 'Amount',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () {
                                      final newFee = double.tryParse(
                                              _feeController.text) ??
                                          0.0;
                                      if (newFee > 0) {
                                        _applyFeeToSpecificClass(
                                          classData['id'],
                                          displayName,
                                          newFee,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.check),
                                    color: Colors.green,
                                    tooltip: 'Apply to this class',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fee Structure History
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fee Structure History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 2, 18, 69),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Recent changes to fee structure',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          if (_feeStructures.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  'No fee structure changes yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ..._feeStructures.map((feeStructure) {
                              final amount = feeStructure['amount'];
                              final type = feeStructure['type'];
                              final note = feeStructure['note'] ?? '';
                              final createdAt = feeStructure['createdAt'];
                              final className = feeStructure['className'];

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[50],
                                  child: Icon(
                                    type == 'monthly'
                                        ? Icons.calendar_today
                                        : Icons.school,
                                    color: const Color.fromARGB(255, 2, 18, 69),
                                  ),
                                ),
                                title: Text(
                                  '\$$amount ${className != null ? 'for $className' : 'for all classes'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (note.isNotEmpty) Text(note),
                                    Text(
                                      _formatDate(createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  type == 'monthly' ? 'Monthly' : 'One-time',
                                  style: TextStyle(
                                    color: type == 'monthly'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}