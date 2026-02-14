import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddFeeScreen extends StatefulWidget {
  const AddFeeScreen({super.key});

  @override
  State<AddFeeScreen> createState() => _AddFeeScreenState();
}

class _AddFeeScreenState extends State<AddFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  String? _selectedClassId;
  String? _selectedClassName;
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];
  final Set<String> _selectedStudentIds = {};
  bool _isLoading = false;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Classes')
          .orderBy('name')
          .get();

      setState(() {
        _classes = snapshot.docs.map((doc) {
          final data = doc.data();
          final className = data['name'] ?? '';
          final section = data['section'] ?? '';
          return {
            'id': doc.id,
            'name': section.isNotEmpty ? '$className - $section' : className,
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadStudents(String classId) async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('classId', isEqualTo: classId)
          .orderBy('name')
          .get();

      setState(() {
        _students = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'rollNumber': data['rollNumber'] ?? '',
          };
        }).toList();
        _selectedStudentIds.clear();
        _selectAll = false;
      });
    } catch (e) {
      print('Error loading students: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createFee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create the Fee Structure (as a reference)
      final feeStructureDoc = await FirebaseFirestore.instance
          .collection('FeeStructures')
          .add({
            'title': _titleController.text.trim(),
            'amount': double.parse(_amountController.text.trim()),
            'description': _descriptionController.text.trim(),
            'classId': _selectedClassId,
            'className': _selectedClassName,
            'dueDate': Timestamp.fromDate(_dueDate),
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

      // 2. Create pending FeePayments for each selected student
      final batch = FirebaseFirestore.instance.batch();
      final amount = double.parse(_amountController.text.trim());
      final title = _titleController.text.trim();

      for (var studentId in _selectedStudentIds) {
        final student = _students.firstWhere((s) => s['id'] == studentId);
        final paymentRef = FirebaseFirestore.instance
            .collection('FeePayments')
            .doc();
        batch.set(paymentRef, {
          'feeId': feeStructureDoc.id,
          'studentId': studentId,
          'studentName': student['name'],
          'classId': _selectedClassId,
          'className': _selectedClassName,
          'amount': amount,
          'title': title,
          'status': 'pending',
          'dueDate': Timestamp.fromDate(_dueDate),
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'custom',
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fee assigned successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating fee: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Fee'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Fee Title (e.g., Lab Fee, Exam Fee)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                initialValue: _selectedClassId,
                items: _classes.map((cls) {
                  return DropdownMenuItem<String>(
                    value: cls['id'],
                    child: Text(cls['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                    _selectedClassName = _classes.firstWhere(
                      (c) => c['id'] == value,
                    )['name'];
                  });
                  if (value != null) {
                    _loadStudents(value);
                  }
                },
                validator: (value) {
                  if (value == null) return 'Please select a class';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_selectedClassId != null) ...[
                const Text(
                  'Select Students',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text(
                          'Select All Students',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            _selectAll = value ?? false;
                            if (_selectAll) {
                              _selectedStudentIds.addAll(
                                _students.map((s) => s['id'] as String),
                              );
                            } else {
                              _selectedStudentIds.clear();
                            }
                          });
                        },
                      ),
                      const Divider(height: 1),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_students.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No students found in this class'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final id = student['id'] as String;
                            return CheckboxListTile(
                              title: Text(student['name']),
                              subtitle: Text('Roll: ${student['rollNumber']}'),
                              value: _selectedStudentIds.contains(id),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedStudentIds.add(id);
                                  } else {
                                    _selectedStudentIds.remove(id);
                                    _selectAll = false;
                                  }
                                });
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_dueDate)),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _createFee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'ASSIGN FEE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
