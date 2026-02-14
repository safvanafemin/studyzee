import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyzee/core/services/notification_service.dart';
import 'package:studyzee/core/models/app_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _teacherName = 'Teacher';

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
  NotificationType _notificationType = NotificationType.announcement;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    _loadClasses();
    _loadStudents();
    _loadParents();
  }

  Future<void> _loadTeacherData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _teacherName = doc.data()?['name'] ?? 'Teacher';
          });
        }
      }
    } catch (e) {
      print('Error loading teacher data: $e');
    }
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      setState(() {
        _students = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'classId': data['classId'],
            'className': data['className'],
            'parentId': data['parentId'],
            'parentName': data['parentName'],
          };
        }).toList();
        // Sort manually to avoid index issues
        _students.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
      });
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> _loadParents() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Parent')
          .get();

      setState(() {
        _parents = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
          };
        }).toList();
        // Sort manually
        _parents.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
      });
    } catch (e) {
      print('Error loading parents: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    if (_selectedClassId == null) return _students;
    return _students
        .where((student) => student['classId'] == _selectedClassId)
        .toList();
  }

  List<Map<String, dynamic>> _getFilteredParents() {
    if (_selectedClassId == null) return _parents;

    // Get unique parent IDs for students in the selected class
    final parentIdsInClass = _students
        .where((s) => s['classId'] == _selectedClassId && s['parentId'] != null)
        .map((s) => s['parentId'] as String)
        .toSet();

    return _parents
        .where((parent) => parentIdsInClass.contains(parent['id']))
        .toList();
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
      final notificationService = NotificationService();
      final user = FirebaseAuth.instance.currentUser;
      final senderId = user?.uid ?? 'unknown';
      final senderName = _teacherName;

      switch (_recipientType) {
        case 'class':
          await notificationService.sendClassNotification(
            classId: _selectedClassId!,
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _notificationType,
            senderId: senderId,
            senderName: senderName,
          );
          break;

        case 'student':
          await notificationService.sendIndividualNotification(
            recipientId: _selectedStudentId!,
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _notificationType,
            senderId: senderId,
            senderName: senderName,
          );
          break;

        case 'parent':
          await notificationService.sendIndividualNotification(
            recipientId: _selectedParentId!,
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _notificationType,
            senderId: senderId,
            senderName: senderName,
          );
          break;

        case 'all_students':
          await notificationService.sendRoleNotification(
            role: 'Student',
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _notificationType,
            senderId: senderId,
            senderName: senderName,
          );
          break;

        case 'all_parents':
          await notificationService.sendRoleNotification(
            role: 'Parent',
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _notificationType,
            senderId: senderId,
            senderName: senderName,
          );
          break;

        case 'all_classes':
          await notificationService.sendRoleNotification(
            role: 'Both',
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _notificationType,
            senderId: senderId,
            senderName: senderName,
          );
          break;
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
      print('Failed to send notification: $e');
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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

            // Category Selection
            _buildCategoryDropdown(),
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
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSending ? 'SENDING...' : 'SEND NOTIFICATION',
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
                _buildRecipientTypeChip(
                  'All Classes',
                  'all_classes',
                  Icons.all_inclusive,
                ),
                _buildRecipientTypeChip('Student', 'student', Icons.school),
                _buildRecipientTypeChip(
                  'All Students',
                  'all_students',
                  Icons.people,
                ),
                _buildRecipientTypeChip(
                  'Parent',
                  'parent',
                  Icons.family_restroom,
                ),
                _buildRecipientTypeChip(
                  'All Parents',
                  'all_parents',
                  Icons.groups,
                ),
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
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
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
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassDropdown(),
            const SizedBox(height: 16),
            _buildParentDropdown(),
          ],
        );
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
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedClassId = value;
          if (value != null) {
            _selectedClassName = _classes.firstWhere(
              (c) => c['id'] == value,
            )['name'];
            // Clear student and parent selection when class changes
            _selectedStudentId = null;
            _selectedStudentName = null;
            _selectedParentId = null;
            _selectedParentName = null;
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${student['name']} '),
                Text(
                  student['className'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: _selectedClassId != null
          ? (value) {
              setState(() {
                _selectedStudentId = value;
                if (value != null) {
                  _selectedStudentName = filteredStudents.firstWhere(
                    (s) => s['id'] == value,
                  )['name'];
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

    final filteredParents = _getFilteredParents();

    return DropdownButtonFormField<String>(
      value: _selectedParentId,
      decoration: InputDecoration(
        labelText: 'Select Parent',
        prefixIcon: const Icon(Icons.family_restroom),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabled: _selectedClassId != null,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select a parent'),
        ),
        ...filteredParents.map((parent) {
          return DropdownMenuItem<String>(
            value: parent['id'],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${parent['name']} '),
                Text(
                  parent['email'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: _selectedClassId != null
          ? (value) {
              setState(() {
                _selectedParentId = value;
                if (value != null) {
                  _selectedParentName = filteredParents.firstWhere(
                    (p) => p['id'] == value,
                  )['name'];
                }
              });
            }
          : null,
      validator: (value) {
        if (_recipientType == 'parent' && (value == null || value.isEmpty)) {
          return 'Please select a parent';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<NotificationType>(
      value: _notificationType,
      decoration: InputDecoration(
        labelText: 'Notification Category',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: NotificationType.values.map((type) {
        return DropdownMenuItem<NotificationType>(
          value: type,
          child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _notificationType = value;
          });
        }
      },
    );
  }
}
