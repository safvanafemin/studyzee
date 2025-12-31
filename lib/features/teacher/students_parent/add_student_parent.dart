// features/teacher/add_student_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

// features/teacher/add_student_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Student Fields
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _studentPasswordController =
      TextEditingController();

  // Parent Fields
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _parentPasswordController =
      TextEditingController();

  String? _selectedClassId;
  String? _selectedClassName;
  List<DocumentSnapshot<Map<String, dynamic>>> _classes = [];

  bool _isLoading = false;
  bool _addParent = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _rollNumberController.dispose();
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    _parentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    try {
      final querySnapshot = await _firestore
          .collection('Classes')
          .orderBy('name')
          .get();

      setState(() {
        _classes = querySnapshot.docs;
      });
    } catch (e) {
      print('Error loading classes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading classes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Section
              _buildSectionHeader('Student Information'),

              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Student Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _rollNumberController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter roll number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Class Dropdown from Firestore
              _buildClassDropdown(),
              const SizedBox(height: 15),

              TextFormField(
                controller: _studentEmailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _studentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Student Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Parent Section Toggle
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text(
                    'Add Parent Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: _addParent,
                    onChanged: (value) {
                      setState(() {
                        _addParent = value;
                      });
                    },
                  ),
                ],
              ),

              if (_addParent) ...[
                _buildSectionHeader('Parent Information'),

                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Full Name',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  validator: _addParent
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter parent name';
                          }
                          return null;
                        }
                      : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _parentEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _addParent
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        }
                      : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _addParent
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        }
                      : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _parentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: _addParent
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        }
                      : null,
                ),
              ],

              // Submit Button
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addStudentAndParent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Student',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    if (_classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No classes found. Please add classes first.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedClassId,
      decoration: const InputDecoration(
        labelText: 'Class',
        prefixIcon: Icon(Icons.school),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select a class'),
        ),
        ..._classes.map((classDoc) {
          final classData = classDoc.data() as Map<String, dynamic>;
          final className = classData['name'] ?? 'Unknown';
          final section = classData['section'] ?? '';
          final displayName = section.isNotEmpty
              ? '$className - Section $section'
              : className;

          return DropdownMenuItem<String>(
            value: classDoc.id,
            child: Text(displayName),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedClassId = value;
          if (value != null) {
            final selectedClass = _classes.firstWhere((doc) => doc.id == value);
            final classData = selectedClass.data() as Map<String, dynamic>;
            final className = classData['name'] ?? 'Unknown';
            final section = classData['section'] ?? '';
            _selectedClassName = section.isNotEmpty
                ? '$className - Section $section'
                : className;
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a class';
        }
        return null;
      },
    );
  }

  Future<void> _addStudentAndParent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Student Account
      final studentCredential = await _auth.createUserWithEmailAndPassword(
        email: _studentEmailController.text.trim(),
        password: _studentPasswordController.text.trim(),
      );

      // Save Student Data
      await _firestore
          .collection('users')
          .doc(studentCredential.user!.uid)
          .set({
            'uid': studentCredential.user!.uid,
            'name': _studentNameController.text.trim(),
            'email': _studentEmailController.text.trim(),
            'role': 'Student',
            'classId': _selectedClassId,
            'className': _selectedClassName,
            'rollNumber': _rollNumberController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      String? parentId;

      // Create Parent Account if requested
      if (_addParent) {
        final parentCredential = await _auth.createUserWithEmailAndPassword(
          email: _parentEmailController.text.trim(),
          password: _parentPasswordController.text.trim(),
        );

        parentId = parentCredential.user!.uid;

        // Save Parent Data
        await _firestore.collection('users').doc(parentId).set({
          'uid': parentId,
          'name': _parentNameController.text.trim(),
          'email': _parentEmailController.text.trim(),
          'phone': _parentPhoneController.text.trim(),
          'role': 'Parent',
          'children': [studentCredential.user!.uid], // Link to child
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update Student with Parent Info
        await _firestore
            .collection('users')
            .doc(studentCredential.user!.uid)
            .update({
              'parentId': parentId,
              'parentName': _parentNameController.text.trim(),
              'parentEmail': _parentEmailController.text.trim(),
              'parentPhone': _parentPhoneController.text.trim(),
            });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _selectedClassId = null;
        _selectedClassName = null;
      });
      _studentNameController.clear();
      _rollNumberController.clear();
      _studentEmailController.clear();
      _studentPasswordController.clear();
      _parentNameController.clear();
      _parentEmailController.clear();
      _parentPhoneController.clear();
      _parentPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error creating account';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already in use';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
// features/teacher/edit_student_screen.dart

// features/teacher/edit_student_screen.dart

class EditStudentScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const EditStudentScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();

  String? _selectedClassId;
  String? _selectedClassName;
  List<DocumentSnapshot<Map<String, dynamic>>> _classes = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _loadClasses();
  }

  void _loadStudentData() {
    _nameController.text = widget.studentData['name'] ?? '';
    _rollNumberController.text = widget.studentData['rollNumber'] ?? '';
    _emailController.text = widget.studentData['email'] ?? '';
    _selectedClassId = widget.studentData['classId'];
    _selectedClassName = widget.studentData['className'];

    _parentNameController.text = widget.studentData['parentName'] ?? '';
    _parentEmailController.text = widget.studentData['parentEmail'] ?? '';
    _parentPhoneController.text = widget.studentData['parentPhone'] ?? '';
  }

  Future<void> _loadClasses() async {
    try {
      final querySnapshot = await _firestore
          .collection('Classes')
          .orderBy('name')
          .get();

      setState(() {
        _classes = querySnapshot.docs;
      });
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
        actions: [
          IconButton(
            onPressed: _isEditing
                ? null
                : () {
                    setState(() => _isEditing = true);
                  },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Student Info
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person),
                ),
                readOnly: !_isEditing,
                validator: _isEditing
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter student name';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _rollNumberController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                readOnly: !_isEditing,
                validator: _isEditing
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter roll number';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: 15),

              // Class Dropdown from Firestore
              _buildClassDropdown(),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true, // Email cannot be changed
              ),

              // Parent Info
              const SizedBox(height: 30),
              const Text(
                'Parent Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'Parent Name',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _parentEmailController,
                decoration: const InputDecoration(
                  labelText: 'Parent Email',
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _parentPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Parent Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                readOnly: !_isEditing,
              ),

              // Buttons
              if (_isEditing) ...[
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _cancelEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    if (_classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Loading classes...',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedClassId,
      decoration: InputDecoration(
        labelText: 'Class',
        prefixIcon: const Icon(Icons.school),
        border: const OutlineInputBorder(),
        filled: !_isEditing,
        fillColor: !_isEditing ? Colors.grey[200] : null,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select a class'),
        ),
        ..._classes.map((classDoc) {
          final classData = classDoc.data() as Map<String, dynamic>;
          final className = classData['name'] ?? 'Unknown';
          final section = classData['section'] ?? '';
          final displayName = section.isNotEmpty
              ? '$className - Section $section'
              : className;

          return DropdownMenuItem<String>(
            value: classDoc.id,
            child: Text(displayName),
          );
        }).toList(),
      ],
      onChanged: _isEditing
          ? (value) {
              setState(() {
                _selectedClassId = value;
                if (value != null) {
                  final selectedClass = _classes.firstWhere(
                    (doc) => doc.id == value,
                  );
                  final classData =
                      selectedClass.data() as Map<String, dynamic>;
                  final className = classData['name'] ?? 'Unknown';
                  final section = classData['section'] ?? '';
                  _selectedClassName = section.isNotEmpty
                      ? '$className - Section $section'
                      : className;
                }
              });
            }
          : null,
      validator: _isEditing
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a class';
              }
              return null;
            }
          : null,
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _loadStudentData(); // Reset to original values
    });
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update Student Data
      final updateData = {
        'name': _nameController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only update class if changed
      if (_selectedClassId != widget.studentData['classId']) {
        updateData['classId'] = _selectedClassId!;
        updateData['className'] = _selectedClassName!;
      }

      await _firestore
          .collection('users')
          .doc(widget.studentId)
          .update(updateData);

      // Update Parent Data if parentId exists
      final parentId = widget.studentData['parentId'];
      if (parentId != null && parentId.isNotEmpty) {
        await _firestore.collection('users').doc(parentId).update({
          'name': _parentNameController.text.trim(),
          'phone': _parentPhoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Also update parent info in student document
        await _firestore.collection('users').doc(widget.studentId).update({
          'parentName': _parentNameController.text.trim(),
          'parentPhone': _parentPhoneController.text.trim(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
