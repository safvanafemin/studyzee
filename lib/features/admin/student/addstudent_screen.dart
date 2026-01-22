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
  String? _selectedParentId;
  bool _showParentFields = false;

  // For parent selection
  List<Map<String, dynamic>> _parentsList = [];
  Map<String, dynamic>? _selectedParent;

  @override
  void initState() {
    super.initState();
    if (widget.studentData != null) {
      _loadStudentData();
    }
    _loadParents();
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
    _selectedParentId = data['parentId'];

    // If parentId exists, it means we're using an existing parent
    if (_selectedParentId != null && _selectedParentId!.isNotEmpty) {
      _showParentFields = false;
    } else {
      _showParentFields = true;
    }
  }

  Future<void> _loadParents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Parents')
          .where('status', isEqualTo: 1)
          .orderBy('name')
          .get();

      final parents = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['parentName'] ?? data['name'] ?? '',
          'email': data['parentEmail'] ?? data['email'] ?? '',
          'phone': data['parentPhone'] ?? data['phone'] ?? '',
          'address': data['parentAddress'] ?? data['address'] ?? '',
        };
      }).toList();

      setState(() {
        _parentsList = parents;
      });
    } catch (e) {
      print('Error loading parents: $e');
    }
  }

  void _clearParentFields() {
    _parentNameController.clear();
    _parentEmailController.clear();
    _parentPasswordController.clear();
    _selectedParent = null;
    _selectedParentId = null;
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

    // If not showing parent fields, parent must be selected
    if (!_showParentFields && _selectedParent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a parent or add new parent'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If showing parent fields, validate parent details
    if (_showParentFields) {
      if (_parentNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter parent name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_parentEmailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter parent email'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_parentPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter parent password'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? parentId;
      String parentName = '';
      String parentEmail = '';
      String parentPassword = '';

      if (_showParentFields) {
        // Add new parent to Parents collection
        final newParentData = {
          'parentName': _parentNameController.text.trim(),
          'parentEmail': _parentEmailController.text.trim(),
          'parentPassword': _parentPasswordController.text,
          'createdAt': DateTime.now(),
          'status': 1,
        };

        final parentDocRef = await FirebaseFirestore.instance
            .collection('Parents')
            .add(newParentData);

        await parentDocRef.update({'id': parentDocRef.id});

        parentId = parentDocRef.id;
        parentName = _parentNameController.text.trim();
        parentEmail = _parentEmailController.text.trim();
        parentPassword = _parentPasswordController.text;
      } else {
        // Use existing parent
        parentId = _selectedParent?['id'];
        parentName = _selectedParent?['name'] ?? '';
        parentEmail = _selectedParent?['email'] ?? '';
        // Don't include password for existing parent
      }

      final studentData = {
        'studentName': _studentNameController.text.trim(),
        'studentEmail': _studentEmailController.text.trim(),
        'studentPassword': _studentPasswordController.text,
        'studentAddress': _studentAddressController.text.trim(),
        'parentName': parentName,
        'parentEmail': parentEmail,
        'parentId': parentId,
        'classId': _selectedClassId,
        'className': _selectedClassName,
        'status': 1,
        'updatedAt': DateTime.now(),
      };

      // Only add password for new parent
      if (_showParentFields) {
        studentData['parentPassword'] = parentPassword;
      }

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

            // Parent Selection Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Parent Option',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(255, 2, 18, 69),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showParentFields = false;
                                _clearParentFields();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: !_showParentFields
                                  ? const Color.fromARGB(255, 2, 18, 69)
                                  : Colors.white,
                              foregroundColor: !_showParentFields
                                  ? Colors.white
                                  : const Color.fromARGB(255, 2, 18, 69),
                              side: BorderSide(
                                color: const Color.fromARGB(255, 2, 18, 69),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search, size: 18),
                                SizedBox(width: 8),
                                Text('Select Existing Parent'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showParentFields = true;
                                _selectedParent = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _showParentFields
                                  ? const Color.fromARGB(255, 2, 18, 69)
                                  : Colors.white,
                              foregroundColor: _showParentFields
                                  ? Colors.white
                                  : const Color.fromARGB(255, 2, 18, 69),
                              side: BorderSide(
                                color: const Color.fromARGB(255, 2, 18, 69),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, size: 18),
                                SizedBox(width: 8),
                                Text('Add New Parent'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _showParentFields
                          ? 'Enter new parent details below'
                          : 'Select parent from the list below',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (!_showParentFields) ...[
              // Parent Dropdown
              _buildParentDropdown(),
              const SizedBox(height: 16),
            ],

            if (_showParentFields) ...[
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
                    _showParentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
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
              const SizedBox(height: 16),
            ],

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

  Widget _buildParentDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedParent,
      decoration: InputDecoration(
        labelText: 'Select Parent',
        prefixIcon: const Icon(Icons.person_search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: _selectedParent != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedParent = null;
                  });
                },
              )
            : null,
      ),
      items: _parentsList.map((parent) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: parent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                parent['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                parent['email'],
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (parent['phone'] != null && parent['phone'].isNotEmpty)
                Text(
                  'Phone: ${parent['phone']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedParent = value;
          if (value != null) {
            _parentNameController.text = value['name'];
            _parentEmailController.text = value['email'];
          }
        });
      },
      validator: (value) {
        if (!_showParentFields && value == null) {
          return 'Please select a parent';
        }
        return null;
      },
      isExpanded: true,
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
