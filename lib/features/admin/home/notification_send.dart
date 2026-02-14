import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/app_notification.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedTarget = 'All Users';
  String? _selectedClassId;
  String? _selectedTeacherId;
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _teachers = [];
  bool _isSending = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadTeachers();
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
          return {'id': doc.id, 'name': data['name'] ?? 'Unnamed Class'};
        }).toList();
      });
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadTeachers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Teacher')
          .get();
      setState(() {
        _teachers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {'id': doc.id, 'name': data['name'] ?? 'Unnamed Teacher'};
        }).toList();
      });
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_selectedTarget == 'Individual Classes' && _selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }

    if (_selectedTarget == 'Individual Teachers' &&
        _selectedTeacherId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a teacher')));
      return;
    }

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final senderId = user?.uid ?? 'admin';

      switch (_selectedTarget) {
        case 'All Users':
          await _notificationService.sendRoleNotification(
            role: 'Both',
            title: _titleController.text.trim(),
            message: _bodyController.text.trim(),
            type: NotificationType.announcement,
            senderId: senderId,
            senderName: 'Admin',
          );
          break;
        case 'Students Only':
          await _notificationService.sendRoleNotification(
            role: 'Student',
            title: _titleController.text.trim(),
            message: _bodyController.text.trim(),
            type: NotificationType.announcement,
            senderId: senderId,
            senderName: 'Admin',
          );
          break;
        case 'Parents Only':
          await _notificationService.sendRoleNotification(
            role: 'Parent',
            title: _titleController.text.trim(),
            message: _bodyController.text.trim(),
            type: NotificationType.announcement,
            senderId: senderId,
            senderName: 'Admin',
          );
          break;
        case 'Individual Teachers':
          if (_selectedTeacherId != null) {
            await _notificationService.sendIndividualNotification(
              recipientId: _selectedTeacherId!,
              title: _titleController.text.trim(),
              message: _bodyController.text.trim(),
              type: NotificationType.announcement,
              senderId: senderId,
              senderName: 'Admin',
            );
          }
          break;
        case 'Teachers Only':
          await _notificationService.sendRoleNotification(
            role: 'Teacher',
            title: _titleController.text.trim(),
            message: _bodyController.text.trim(),
            type: NotificationType.announcement,
            senderId: senderId,
            senderName: 'Admin',
          );
          break;
        case 'Individual Classes':
          if (_selectedClassId != null) {
            await _notificationService.sendClassNotification(
              classId: _selectedClassId!,
              title: _titleController.text.trim(),
              message: _bodyController.text.trim(),
              type: NotificationType.announcement,
              senderId: senderId,
              senderName: 'Admin',
            );
          }
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error sending notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send New Notification'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Compose Message',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 18, 69),
              ),
            ),
            const Divider(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group, color: Colors.blueGrey),
              ),
              initialValue: _selectedTarget,
              items:
                  [
                    'All Users',
                    'Students Only',
                    'Parents Only',
                    'Teachers Only',
                    'Individual Teachers',
                    'Individual Classes',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTarget = newValue;
                    if (newValue != 'Individual Classes') {
                      _selectedClassId = null;
                    }
                    if (newValue != 'Individual Teachers') {
                      _selectedTeacherId = null;
                    }
                  });
                }
              },
            ),
            if (_selectedTarget == 'Individual Teachers') ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Teacher',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.blueGrey),
                ),
                initialValue: _selectedTeacherId,
                items: _teachers.map((t) {
                  return DropdownMenuItem<String>(
                    value: t['id'],
                    child: Text(t['name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedTeacherId = newValue);
                },
              ),
            ],
            if (_selectedTarget == 'Individual Classes') ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_, color: Colors.blueGrey),
                ),
                initialValue: _selectedClassId,
                items: _classes.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'],
                    child: Text(c['name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedClassId = newValue);
                },
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title (e.g., Important Notice)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSending ? 'Sending...' : 'Send Notification Now',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 40, 167, 69),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isSending ? null : _sendNotification,
            ),
          ],
        ),
      ),
    );
  }
}
