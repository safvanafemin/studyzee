import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEditStudentScreen extends StatefulWidget {
  final String? studentId;
  final Map<String, dynamic>? studentData;

  const AddEditStudentScreen({super.key, this.studentId, this.studentData});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showStudentPassword = false;
  bool _showParentPassword = false;

  // Controllers
  final _studentNameController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  final _studentAddressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPasswordController = TextEditingController();

  String? _selectedClassId;
  String? _selectedClassName;

  @override
  void initState() {
    super.initState();
    if (widget.studentData != null) {
      _loadStudentData();
    }
  }

  void _loadStudentData() {
    final data = widget.studentData!;
    _studentNameController.text = data['studentName'] ?? '';
    _studentEmailController.text = data['studentEmail'] ?? '';
    _studentPasswordController.text = data['studentPassword'] ?? '';
    _studentAddressController.text = data['studentAddress'] ?? '';
    _parentNameController.text = data['parentName'] ?? '';
    _parentEmailController.text = data['parentEmail'] ?? '';
    _parentPasswordController.text = data['parentPassword'] ?? '';
    _selectedClassId = data['classId'];
    _selectedClassName = data['className'];
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    _studentAddressController.dispose();
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final studentData = {
        'studentName': _studentNameController.text.trim(),
        'studentEmail': _studentEmailController.text.trim(),
        'studentPassword': _studentPasswordController.text,
        'studentAddress': _studentAddressController.text.trim(),
        'parentName': _parentNameController.text.trim(),
        'parentEmail': _parentEmailController.text.trim(),
        'parentPassword': _parentPasswordController.text,
        'classId': _selectedClassId,
        'className': _selectedClassName,
        'status': 1,
      };

      if (widget.studentId != null) {
        // Update existing student
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(widget.studentId)
            .update(studentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('STUDENT UPDATED SUCCESSFULLY'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new student
        studentData['createdAt'] = DateTime.now();

        final docRef = await FirebaseFirestore.instance
            .collection('Students')
            .add(studentData);

        await docRef.update({'id': docRef.id});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('STUDENT ADDED SUCCESSFULLY'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Add Student'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveStudent,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Student Details Section
            _buildSectionHeader('Student Details'),
            const SizedBox(height: 16),

            // Class Dropdown
            _buildClassDropdown(),
            const SizedBox(height: 16),

            // Student Name
            _buildTextField(
              controller: _studentNameController,
              label: 'Student Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Student Email
            _buildTextField(
              controller: _studentEmailController,
              label: 'Student Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Student Password
            _buildTextField(
              controller: _studentPasswordController,
              label: 'Student Password',
              icon: Icons.lock,
              obscureText: !_showStudentPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showStudentPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showStudentPassword = !_showStudentPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Student Address
            _buildTextField(
              controller: _studentAddressController,
              label: 'Student Address',
              icon: Icons.home,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student address';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Parent Details Section
            _buildSectionHeader('Parent/Guardian Details'),
            const SizedBox(height: 16),

            // Parent Name
            _buildTextField(
              controller: _parentNameController,
              label: 'Parent Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter parent name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Parent Email
            _buildTextField(
              controller: _parentEmailController,
              label: 'Parent Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter parent email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Parent Password
            _buildTextField(
              controller: _parentPasswordController,
              label: 'Parent Password',
              icon: Icons.lock_outline,
              obscureText: !_showParentPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showParentPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showParentPassword = !_showParentPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter parent password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'UPDATE STUDENT' : 'ADD STUDENT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 2, 18, 69),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Classes')
          .where('status', isEqualTo: 1)
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final classes = snapshot.data?.docs ?? [];

        return DropdownButtonFormField<String>(
          value: _selectedClassId,
          decoration: InputDecoration(
            labelText: 'Select Class',
            prefixIcon: const Icon(Icons.class_),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: classes.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final className = data['name'] ?? '';
            final section = data['section'] ?? '';
            final displayName = section.isNotEmpty
                ? '$className - Section $section'
                : className;

            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClassId = value;
              if (value != null) {
                final selectedDoc = classes.firstWhere(
                  (doc) => doc.id == value,
                );
                final data = selectedDoc.data() as Map<String, dynamic>;
                final className = data['name'] ?? '';
                final section = data['section'] ?? '';
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
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
