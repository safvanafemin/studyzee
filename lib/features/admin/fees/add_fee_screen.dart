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
  bool _isLoading = false;

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

  Future<void> _createFee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('FeeStructures').add({
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'description': _descriptionController.text.trim(),
        'classId': _selectedClassId,
        'className': _selectedClassName,
        'dueDate': Timestamp.fromDate(_dueDate),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fee structure created successfully')),
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
                value: _selectedClassId,
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
                },
                validator: (value) {
                  if (value == null) return 'Please select a class';
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
                        'CREATE FEE',
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
