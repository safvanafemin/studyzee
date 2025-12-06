import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils/helper/helper_snackbar.dart';

class ClassSectionsTab extends StatefulWidget {
  const ClassSectionsTab({super.key});

  @override
  State<ClassSectionsTab> createState() => _ClassSectionsTabState();
}

class _ClassSectionsTabState extends State<ClassSectionsTab> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchQuery = '';
  String? _selectedClassId;
  Map<String, List<Map<String, dynamic>>> _classStudents = {};

  @override
  void initState() {
    super.initState();
    _fetchAllStudents();
  }

  Future<void> _fetchAllStudents() async {
    try {
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      Map<String, List<Map<String, dynamic>>> tempMap = {};

      for (var doc in studentsSnapshot.docs) {
        final studentData = doc.data();
        final classId = studentData['classId'];

        if (classId != null) {
          if (!tempMap.containsKey(classId)) {
            tempMap[classId] = [];
          }
          tempMap[classId]!.add({...studentData, 'id': doc.id});
        }
      }

      setState(() {
        _classStudents = tempMap;
      });
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search classes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                onPressed: () => _showAddEditDialog(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Classes')
                .orderBy('createat', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No classes found. Add one to get started!'),
                );
              }

              // Filter documents based on search query
              final filteredDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final section = (data['section'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(_searchQuery) ||
                    section.contains(_searchQuery);
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Text('No classes match your search.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final className = data['name'] ?? 'Unknown';
                  final section = data['section'] ?? '';
                  final docId = doc.id;
                  final studentCount = _classStudents[docId]?.length ?? 0;

                  // Extract class number for avatar (e.g., "10" from "Class 10")
                  final classNumber = className.replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          classNumber.isNotEmpty ? classNumber : className[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '$className${section.isNotEmpty ? " - Section $section" : ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Students: $studentCount • Tap to expand',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'add_student',
                            child: Row(
                              children: [
                                Icon(Icons.person_add, size: 20),
                                SizedBox(width: 8),
                                Text('Add Student'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit Class'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Class'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'add_student') {
                            _showAddStudentDialog(
                              context,
                              docId,
                              className,
                              section,
                            );
                          } else if (value == 'edit') {
                            _showAddEditDialog(
                              context,
                              docId: docId,
                              className: className,
                              section: section,
                            );
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, docId, className);
                          }
                        },
                      ),
                      children: [
                        if (_classStudents.containsKey(docId) &&
                            _classStudents[docId]!.isNotEmpty)
                          ..._classStudents[docId]!
                              .map(
                                (student) => _buildStudentTile(student, docId),
                              )
                              .toList()
                        else
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No students in this class yet. Add some students!',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student, String classId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              student['name']?[0] ?? 'S',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Roll: ${student['rollNumber'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditStudentDialog(context, student, classId);
              } else if (value == 'delete') {
                _showDeleteStudentDialog(
                  context,
                  student['id'],
                  student['name'],
                );
              } else if (value == 'parent') {
                _showParentDialog(context, student);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'parent',
                child: Row(
                  children: [
                    Icon(Icons.family_restroom, size: 18),
                    SizedBox(width: 8),
                    Text('Parent Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(
    BuildContext context,
    String classId,
    String className,
    String section,
  ) {
    final nameController = TextEditingController();
    final rollController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentEmailController = TextEditingController();
    final parentPhoneController = TextEditingController();
    final parentPasswordController = TextEditingController();

    bool isLoading = false;
    bool addParent = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Student to Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Class:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$className - Section $section'),
                    const Divider(height: 20),

                    // Student Information
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Student Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Full Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: rollController,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Student Email *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password *',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                    // Parent Information
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add Parent Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Switch(
                          value: addParent,
                          onChanged: (value) =>
                              setState(() => addParent = value),
                        ),
                      ],
                    ),

                    if (addParent) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: parentNameController,
                        decoration: const InputDecoration(
                          labelText: 'Parent Full Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: parentEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Parent Email *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: parentPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Parent Phone *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: parentPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Parent Password *',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Validate inputs
                          if (nameController.text.isEmpty ||
                              rollController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            CustomSnackBar.show(
                              context,
                              message:
                                  "Please fill all required student fields",
                              status: SnackBarStatus.error,
                            );
                            return;
                          }

                          if (addParent &&
                              (parentNameController.text.isEmpty ||
                                  parentEmailController.text.isEmpty ||
                                  parentPhoneController.text.isEmpty ||
                                  parentPasswordController.text.isEmpty)) {
                            CustomSnackBar.show(
                              context,
                              message: "Please fill all parent fields",
                              status: SnackBarStatus.error,
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // Create Student Account
                            final studentCredential = await _auth
                                .createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                            // Save Student Data
                            await _firestore
                                .collection('users')
                                .doc(studentCredential.user!.uid)
                                .set({
                                  'uid': studentCredential.user!.uid,
                                  'name': nameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'role': 'Student',
                                  'classId': classId,
                                  'className': className,
                                  'section': section,
                                  'rollNumber': rollController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            String? parentId;

                            // Create Parent Account if requested
                            if (addParent) {
                              final parentCredential = await _auth
                                  .createUserWithEmailAndPassword(
                                    email: parentEmailController.text.trim(),
                                    password: parentPasswordController.text
                                        .trim(),
                                  );

                              parentId = parentCredential.user!.uid;

                              // Save Parent Data
                              await _firestore
                                  .collection('users')
                                  .doc(parentId)
                                  .set({
                                    'uid': parentId,
                                    'name': parentNameController.text.trim(),
                                    'email': parentEmailController.text.trim(),
                                    'phone': parentPhoneController.text.trim(),
                                    'role': 'Parent',
                                    'children': [studentCredential.user!.uid],
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                              // Update Student with Parent Info
                              await _firestore
                                  .collection('users')
                                  .doc(studentCredential.user!.uid)
                                  .update({
                                    'parentId': parentId,
                                    'parentName': parentNameController.text
                                        .trim(),
                                    'parentEmail': parentEmailController.text
                                        .trim(),
                                    'parentPhone': parentPhoneController.text
                                        .trim(),
                                  });
                            }

                            // Update local state
                            if (_classStudents.containsKey(classId)) {
                              _classStudents[classId]!.add({
                                'id': studentCredential.user!.uid,
                                'name': nameController.text.trim(),
                                'rollNumber': rollController.text.trim(),
                                'parentId': parentId,
                                'parentName': parentNameController.text.trim(),
                              });
                            } else {
                              _classStudents[classId] = [
                                {
                                  'id': studentCredential.user!.uid,
                                  'name': nameController.text.trim(),
                                  'rollNumber': rollController.text.trim(),
                                  'parentId': parentId,
                                  'parentName': parentNameController.text
                                      .trim(),
                                },
                              ];
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              CustomSnackBar.show(
                                context,
                                message: "STUDENT ADDED SUCCESSFULLY",
                                status: SnackBarStatus.success,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              CustomSnackBar.show(
                                context,
                                message: "ERROR: ${e.toString()}",
                                status: SnackBarStatus.error,
                              );
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Add Student'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditStudentDialog(
    BuildContext context,
    Map<String, dynamic> student,
    String classId,
  ) {
    final nameController = TextEditingController(text: student['name'] ?? '');
    final rollController = TextEditingController(
      text: student['rollNumber'] ?? '',
    );
    final parentNameController = TextEditingController(
      text: student['parentName'] ?? '',
    );
    final parentPhoneController = TextEditingController(
      text: student['parentPhone'] ?? '',
    );

    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Student'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: rollController,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number *',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Parent Information',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: parentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: parentPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              rollController.text.isEmpty) {
                            CustomSnackBar.show(
                              context,
                              message: "Name and roll number are required",
                              status: SnackBarStatus.error,
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // Update Student Data
                            await _firestore
                                .collection('users')
                                .doc(student['id'])
                                .update({
                                  'name': nameController.text.trim(),
                                  'rollNumber': rollController.text.trim(),
                                  'parentName': parentNameController.text
                                      .trim(),
                                  'parentPhone': parentPhoneController.text
                                      .trim(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });

                            // Update Parent Data if exists
                            if (student['parentId'] != null) {
                              await _firestore
                                  .collection('users')
                                  .doc(student['parentId'])
                                  .update({
                                    'name': parentNameController.text.trim(),
                                    'phone': parentPhoneController.text.trim(),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });
                            }

                            // Update local state
                            final index = _classStudents[classId]?.indexWhere(
                              (s) => s['id'] == student['id'],
                            );
                            if (index != null && index != -1) {
                              _classStudents[classId]![index] = {
                                ..._classStudents[classId]![index],
                                'name': nameController.text.trim(),
                                'rollNumber': rollController.text.trim(),
                                'parentName': parentNameController.text.trim(),
                                'parentPhone': parentPhoneController.text
                                    .trim(),
                              };

                              setState(() {}); // Trigger UI update
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              CustomSnackBar.show(
                                context,
                                message: "STUDENT UPDATED SUCCESSFULLY",
                                status: SnackBarStatus.success,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              CustomSnackBar.show(
                                context,
                                message: "ERROR: ${e.toString()}",
                                status: SnackBarStatus.error,
                              );
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showParentDialog(BuildContext context, Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Parent Details - ${student['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParentDetailItem(
              'Parent Name',
              student['parentName'] ?? 'N/A',
            ),
            _buildParentDetailItem(
              'Parent Email',
              student['parentEmail'] ?? 'N/A',
            ),
            _buildParentDetailItem(
              'Parent Phone',
              student['parentPhone'] ?? 'N/A',
            ),
            if (student['parentId'] == null)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'No parent account linked',
                  style: TextStyle(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
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

  Widget _buildParentDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteStudentDialog(
    BuildContext context,
    String studentId,
    String studentName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete "$studentName"? This will also delete their parent account if linked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                // Get student data first
                final studentDoc = await _firestore
                    .collection('users')
                    .doc(studentId)
                    .get();
                final studentData = studentDoc.data();
                final parentId = studentData?['parentId'];
                final classId = studentData?['classId'];

                // Delete student
                await _firestore.collection('users').doc(studentId).delete();

                // Delete parent if exists
                if (parentId != null) {
                  await _firestore.collection('users').doc(parentId).delete();
                }

                // Remove from local state
                if (classId != null && _classStudents.containsKey(classId)) {
                  _classStudents[classId]!.removeWhere(
                    (student) => student['id'] == studentId,
                  );
                  setState(() {});
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackBar.show(
                    context,
                    message: "STUDENT DELETED SUCCESSFULLY",
                    status: SnackBarStatus.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackBar.show(
                    context,
                    message: "ERROR DELETING STUDENT: ${e.toString()}",
                    status: SnackBarStatus.error,
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context, {
    String? docId,
    String? className,
    String? section,
  }) {
    final classNameController = TextEditingController(text: className ?? '');
    final sectionController = TextEditingController(text: section ?? '');
    final isEditing = docId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Class Section' : 'Add Class Section'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: classNameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name (e.g., Class 10)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section (e.g., A, B, C)',
                  border: OutlineInputBorder(),
                ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 18, 69),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (classNameController.text.isEmpty) {
                CustomSnackBar.show(
                  context,
                  message: "CLASS NAME IS REQUIRED",
                  status: SnackBarStatus.error,
                );
                return;
              }

              try {
                final data = {
                  'name': classNameController.text.trim(),
                  'section': sectionController.text.trim(),
                  'status': 1,
                };

                if (isEditing) {
                  // Update existing document
                  await FirebaseFirestore.instance
                      .collection('Classes')
                      .doc(docId)
                      .update(data);

                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomSnackBar.show(
                      context,
                      message: "CLASS UPDATED SUCCESSFULLY",
                      status: SnackBarStatus.success,
                    );
                  }
                } else {
                  // Add new document
                  data['createat'] = DateTime.now();

                  final docRef = await FirebaseFirestore.instance
                      .collection('Classes')
                      .add(data);

                  await docRef.update({'id': docRef.id});

                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomSnackBar.show(
                      context,
                      message: "CLASS ADDED SUCCESSFULLY",
                      status: SnackBarStatus.success,
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  CustomSnackBar.show(
                    context,
                    message: "ERROR: ${e.toString()}",
                    status: SnackBarStatus.error,
                  );
                }
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class Section'),
        content: Text(
          'Are you sure you want to delete "$className"? This will also remove all students from this class.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                // First, unlink all students from this class
                final studentsInClass = await _firestore
                    .collection('users')
                    .where('classId', isEqualTo: docId)
                    .get();

                for (var student in studentsInClass.docs) {
                  await student.reference.update({
                    'classId': FieldValue.delete(),
                    'className': FieldValue.delete(),
                    'section': FieldValue.delete(),
                  });
                }

                // Then delete the class
                await FirebaseFirestore.instance
                    .collection('Classes')
                    .doc(docId)
                    .delete();

                // Remove from local state
                _classStudents.remove(docId);
                setState(() {});

                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackBar.show(
                    context,
                    message: "CLASS DELETED SUCCESSFULLY",
                    status: SnackBarStatus.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackBar.show(
                    context,
                    message: "ERROR DELETING CLASS: ${e.toString()}",
                    status: SnackBarStatus.error,
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
