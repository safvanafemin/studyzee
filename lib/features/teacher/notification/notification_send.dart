import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  // For recipient selection
  String _recipientType = 'class'; // 'class', 'student', 'parent', 'all'
  String? _selectedClassId;
  String? _selectedClassName;
  String? _selectedStudentId;
  String? _selectedStudentName;
  String? _selectedParentId;
  String? _selectedParentName;
  
  // Lists for dropdowns
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _parents = [];
  
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadStudents();
    _loadParents();
  }

  Future<void> _loadClasses() async {
    try {
      final snapshot = await _firestore
          .collection('Classes')
          .where('status', isEqualTo: 1)
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

  Future<void> _loadStudents() async {
    try {
      final snapshot = await _firestore
          .collection('Students')
          .where('status', isEqualTo: 1)
          .orderBy('studentName')
          .get();

      setState(() {
        _students = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['studentName'] ?? '',
            'classId': data['classId'],
            'className': data['className'],
            'parentId': data['parentId'],
            'parentName': data['parentName'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> _loadParents() async {
    try {
      final snapshot = await _firestore
          .collection('Parents')
          .where('status', isEqualTo: 1)
          .orderBy('parentName')
          .get();

      setState(() {
        _parents = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['parentName'] ?? '',
            'email': data['parentEmail'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading parents: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    if (_selectedClassId == null) return _students;
    return _students.where((student) => student['classId'] == _selectedClassId).toList();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_recipientType == 'class' && _selectedClassId == null) {
      _showError('Please select a class');
      return;
    }

    if (_recipientType == 'student' && _selectedStudentId == null) {
      _showError('Please select a student');
      return;
    }

    if (_recipientType == 'parent' && _selectedParentId == null) {
      _showError('Please select a parent');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      String targetType = '';
      String targetName = '';
      List<String> recipientIds = [];

      // Prepare notification data based on recipient type
      switch (_recipientType) {
        case 'class':
          targetType = 'class';
          targetName = _selectedClassName ?? '';
          
          // Get all students in the selected class
          final classStudents = _students
              .where((student) => student['classId'] == _selectedClassId)
              .toList();
          
          for (var student in classStudents) {
            // Add student
            recipientIds.add('student_${student['id']}');
            // Add parent if exists
            if (student['parentId'] != null) {
              recipientIds.add('parent_${student['parentId']}');
            }
          }
          break;

        case 'all_classes':
          targetType = 'all_classes';
          targetName = 'All Classes';
          
          // Add all students and parents
          for (var student in _students) {
            recipientIds.add('student_${student['id']}');
            if (student['parentId'] != null) {
              recipientIds.add('parent_${student['parentId']}');
            }
          }
          break;

        case 'student':
          targetType = 'student';
          targetName = _selectedStudentName ?? '';
          
          // Add selected student
          recipientIds.add('student_$_selectedStudentId');
          
          // Add their parent if exists
          final student = _students.firstWhere(
            (s) => s['id'] == _selectedStudentId,
            orElse: () => {},
          );
          
          if (student.isNotEmpty && student['parentId'] != null) {
            recipientIds.add('parent_${student['parentId']}');
          }
          break;

        case 'all_students':
          targetType = 'all_students';
          targetName = 'All Students';
          
          // Add all students
          for (var student in _students) {
            recipientIds.add('student_${student['id']}');
          }
          break;

        case 'parent':
          targetType = 'parent';
          targetName = _selectedParentName ?? '';
          
          // Add selected parent
          recipientIds.add('parent_$_selectedParentId');
          break;

        case 'all_parents':
          targetType = 'all_parents';
          targetName = 'All Parents';
          
          // Add all parents
          for (var parent in _parents) {
            recipientIds.add('parent_${parent['id']}');
          }
          break;
      }

      // Create notification document
      final notificationData = {
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'targetType': targetType,
        'targetName': targetName,
        'recipientIds': recipientIds,
        'recipientCount': recipientIds.length,
        'createdAt': DateTime.now(),
        'status': 'sent',
      };

      await _firestore.collection('Notifications').add(notificationData);

      // Also create individual notification records for each recipient
      for (var recipientId in recipientIds) {
        final individualNotification = {
          'notificationTitle': _titleController.text.trim(),
          'notificationMessage': _messageController.text.trim(),
          'recipientId': recipientId,
          'isRead': false,
          'createdAt': DateTime.now(),
          'sentAt': DateTime.now(),
        };
        
        await _firestore.collection('UserNotifications').add(individualNotification);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _titleController.clear();
      _messageController.clear();
      
      // Navigate back after delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      _showError('Failed to send notification: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          if (_isSending)
            const Padding(
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
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Recipient Type Selection
            _buildRecipientTypeSection(),
            const SizedBox(height: 20),

            // Recipient Selection based on type
            _buildRecipientSelection(),
            const SizedBox(height: 20),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Message Field
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Send Button
            ElevatedButton(
              onPressed: _isSending ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'SEND NOTIFICATION',
                      style: TextStyle(
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

  Widget _buildRecipientTypeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Recipient Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 18, 69),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRecipientTypeChip('Class', 'class', Icons.class_),
                _buildRecipientTypeChip('All Classes', 'all_classes', Icons.all_inclusive),
                _buildRecipientTypeChip('Student', 'student', Icons.school),
                _buildRecipientTypeChip('All Students', 'all_students', Icons.people),
                _buildRecipientTypeChip('Parent', 'parent', Icons.family_restroom),
                _buildRecipientTypeChip('All Parents', 'all_parents', Icons.groups),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientTypeChip(String label, String type, IconData icon) {
    bool isSelected = _recipientType == type;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _recipientType = type;
          // Clear selections when changing type
          _selectedClassId = null;
          _selectedStudentId = null;
          _selectedParentId = null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color.fromARGB(255, 2, 18, 69),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      side: BorderSide(
        color: isSelected
            ? const Color.fromARGB(255, 2, 18, 69)
            : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildRecipientSelection() {
    switch (_recipientType) {
      case 'class':
        return _buildClassDropdown();
      case 'student':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassDropdown(),
            const SizedBox(height: 16),
            _buildStudentDropdown(),
          ],
        );
      case 'parent':
        return _buildParentDropdown();
      default:
        return Container(); // No selection needed for "all" types
    }
  }

  Widget _buildClassDropdown() {
    if (_isLoading) {
      return const LinearProgressIndicator();
    }

    return DropdownButtonFormField<String>(
      value: _selectedClassId,
      decoration: InputDecoration(
        labelText: 'Select Class',
        prefixIcon: const Icon(Icons.class_),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select a class'),
        ),
        ..._classes.map((classData) {
          return DropdownMenuItem<String>(
            value: classData['id'],
            child: Text(classData['name']),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedClassId = value;
          if (value != null) {
            _selectedClassName = _classes
                .firstWhere((c) => c['id'] == value)['name'];
            // Clear student selection when class changes
            _selectedStudentId = null;
            _selectedStudentName = null;
          }
        });
      },
      validator: (value) {
        if (_recipientType == 'class' && (value == null || value.isEmpty)) {
          return 'Please select a class';
        }
        return null;
      },
    );
  }

  Widget _buildStudentDropdown() {
    final filteredStudents = _getFilteredStudents();
    
    return DropdownButtonFormField<String>(
      value: _selectedStudentId,
      decoration: InputDecoration(
        labelText: 'Select Student',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabled: _selectedClassId != null,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select a student'),
        ),
        ...filteredStudents.map((student) {
          return DropdownMenuItem<String>(
            value: student['id'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name']),
                Text(
                  student['className'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
      onChanged: _selectedClassId != null
          ? (value) {
              setState(() {
                _selectedStudentId = value;
                if (value != null) {
                  _selectedStudentName = filteredStudents
                      .firstWhere((s) => s['id'] == value)['name'];
                }
              });
            }
          : null,
      validator: (value) {
        if (_recipientType == 'student' && (value == null || value.isEmpty)) {
          return 'Please select a student';
        }
        return null;
      },
    );
  }

  Widget _buildParentDropdown() {
    if (_isLoading) {
      return const LinearProgressIndicator();
    }

    return DropdownButtonFormField<String>(
      value: _selectedParentId,
      decoration: InputDecoration(
        labelText: 'Select Parent',
        prefixIcon: const Icon(Icons.family_restroom),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select a parent'),
        ),
        ..._parents.map((parent) {
          return DropdownMenuItem<String>(
            value: parent['id'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parent['name']),
                Text(
                  parent['email'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedParentId = value;
          if (value != null) {
            _selectedParentName = _parents
                .firstWhere((p) => p['id'] == value)['name'];
          }
        });
      },
      validator: (value) {
        if (_recipientType == 'parent' && (value == null || value.isEmpty)) {
          return 'Please select a parent';
        }
        return null;
      },
    );
  }
}