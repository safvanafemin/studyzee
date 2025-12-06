// features/teacher/student_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyzee/teacher/students_parent/add_student_parent.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedClassId;
  List<DocumentSnapshot> _classes = [];
  List<String> _classOptions = ['All'];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final querySnapshot = await _firestore
          .collection('Classes')
          .orderBy('name')
          .get();

      setState(() {
        _classes = querySnapshot.docs;
        _classOptions = ['All'];
        _classOptions.addAll(
          _classes.map<String>((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final className = data['name'] ?? 'Unknown';
            final section = data['section'] ?? '';
            return section.isNotEmpty ? '$className - $section' : className;
          }).toList(),
        );
      });
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Management')),
      body: Column(
        children: [
          // Class Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedClassId,
              decoration: InputDecoration(
                labelText: 'Filter by Class',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.filter_list),
              ),
              items: _classOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value == 'All' ? null : _getClassId(value),
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
            ),
          ),

          // Students List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getStudentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Get and sort students
                final students = snapshot.data!.docs;
                List<QueryDocumentSnapshot> sortedStudents = List.from(
                  students,
                );
                sortedStudents.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aName = aData['name'] ?? '';
                  final bName = bData['name'] ?? '';
                  return aName.compareTo(bName);
                });

                return RefreshIndicator(
                  onRefresh: () async {
                    await _loadClasses();
                  },
                  child: ListView.builder(
                    itemCount: sortedStudents.length,
                    itemBuilder: (context, index) {
                      final student = sortedStudents[index];
                      final studentData =
                          student.data() as Map<String, dynamic>;

                      return _buildStudentCard(student.id, studentData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          ).then((value) {
            if (value == true) {
              // Refresh after adding student
              setState(() {});
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            _selectedClassId == null
                ? 'No students found'
                : 'No students in this class',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add students to get started!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getStudentsStream() {
    if (_selectedClassId == null) {
      // Simple query without orderBy to avoid index requirement
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .snapshots();
    } else {
      // Query with class filter
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('classId', isEqualTo: _selectedClassId)
          .snapshots();
    }
  }

  String? _getClassId(String displayName) {
    for (var classDoc in _classes) {
      final data = classDoc.data() as Map<String, dynamic>;
      final className = data['name'] ?? 'Unknown';
      final section = data['section'] ?? '';
      final formattedName = section.isNotEmpty
          ? '$className - $section'
          : className;

      if (formattedName == displayName) {
        return classDoc.id;
      }
    }
    return null;
  }

  String _getClassName(String? classId) {
    if (classId == null) return 'Not Assigned';

    for (var classDoc in _classes) {
      if (classDoc.id == classId) {
        final data = classDoc.data() as Map<String, dynamic>;
        final className = data['name'] ?? 'Unknown';
        final section = data['section'] ?? '';
        return section.isNotEmpty ? '$className - $section' : className;
      }
    }
    return 'Class Not Found';
  }

  Widget _buildStudentCard(String studentId, Map<String, dynamic> studentData) {
    final className = _getClassName(studentData['classId']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 2, 18, 69),
          child: Text(
            studentData['name']?[0].toUpperCase() ?? 'S',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          studentData['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.class_, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    className,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.numbers, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Roll: ${studentData['rollNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            if (studentData['parentName'] != null) const SizedBox(height: 2),
            if (studentData['parentName'] != null)
              Row(
                children: [
                  const Icon(
                    Icons.family_restroom,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Parent: ${studentData['parentName']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editStudent(studentId, studentData);
            } else if (value == 'delete') {
              _deleteStudent(studentId, studentData['name'] ?? 'Student');
            } else if (value == 'view_parent') {
              _viewParentDetails(studentData);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (studentData['parentId'] != null)
              const PopupMenuItem(
                value: 'view_parent',
                child: Row(
                  children: [
                    Icon(Icons.family_restroom, size: 20),
                    SizedBox(width: 8),
                    Text('View Parent'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _showStudentDetails(studentId, studentData, className);
        },
      ),
    );
  }

  void _editStudent(String studentId, Map<String, dynamic> studentData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditStudentScreen(studentId: studentId, studentData: studentData),
      ),
    ).then((value) {
      if (value == true) {
        // Refresh after editing student
        setState(() {});
      }
    });
  }

  Future<void> _deleteStudent(String studentId, String studentName) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete "$studentName"? This will also delete the associated parent account if it exists.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final studentDoc = await _firestore
            .collection('users')
            .doc(studentId)
            .get();
        final studentData = studentDoc.data();
        final parentId = studentData?['parentId'];

        // Delete student
        await _firestore.collection('users').doc(studentId).delete();

        // Delete parent if exists
        if (parentId != null && parentId.isNotEmpty) {
          await _firestore.collection('users').doc(parentId).delete();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$studentName deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting student: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewParentDetails(Map<String, dynamic> studentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parent Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParentDetailItem(
                'Name',
                studentData['parentName'] ?? 'N/A',
              ),
              _buildParentDetailItem(
                'Email',
                studentData['parentEmail'] ?? 'N/A',
              ),
              _buildParentDetailItem(
                'Phone',
                studentData['parentPhone'] ?? 'N/A',
              ),
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

  Widget _buildParentDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStudentDetails(
    String studentId,
    Map<String, dynamic> studentData,
    String className,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                    radius: 40,
                    child: Text(
                      studentData['name']?[0].toUpperCase() ?? 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    studentData['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Roll: ${studentData['rollNumber'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailSection('Student Information', [
                  _buildDetailRow(Icons.class_, 'Class', className),
                  _buildDetailRow(
                    Icons.email,
                    'Email',
                    studentData['email'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Joined',
                    studentData['createdAt'] != null
                        ? _formatDate(studentData['createdAt'])
                        : 'N/A',
                  ),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('Parent Information', [
                  _buildDetailRow(
                    Icons.person_outline,
                    'Name',
                    studentData['parentName'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.email_outlined,
                    'Email',
                    studentData['parentEmail'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.phone,
                    'Phone',
                    studentData['parentPhone'] ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editStudent(studentId, studentData);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteStudent(studentId, studentData['name'] ?? '');
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 2, 18, 69),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate().toString().split(' ')[0];
    }
    return date.toString();
  }
}
