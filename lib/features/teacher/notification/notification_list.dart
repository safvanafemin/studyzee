import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyzee/features/admin/home/home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedFilter = 0; // 0: All, 1: Today, 2: Class, 3: Student, 4: Parent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendNotificationScreen(),
                ),
              );
            },
            tooltip: 'Send New Notification',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          const SizedBox(height: 8),
          
          // Notifications List
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 0),
            const SizedBox(width: 8),
            _buildFilterChip('Today', 1),
            const SizedBox(width: 8),
            _buildFilterChip('Class', 2),
            const SizedBox(width: 8),
            _buildFilterChip('Student', 3),
            const SizedBox(width: 8),
            _buildFilterChip('Parent', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == index,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? index : 0;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color.fromARGB(255, 2, 18, 69),
      labelStyle: TextStyle(
        color: _selectedFilter == index ? Colors.white : Colors.black,
      ),
      side: BorderSide(
        color: _selectedFilter == index
            ? const Color.fromARGB(255, 2, 18, 69)
            : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildNotificationsList() {
    Query query = _firestore.collection('Notifications').orderBy('createdAt', descending: true);

    // Apply filters
    if (_selectedFilter == 1) {
      // Today's notifications
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      query = query.where('createdAt', isGreaterThanOrEqualTo: startOfDay);
    } else if (_selectedFilter == 2) {
      // Class notifications
      query = query.where('targetType', whereIn: ['class', 'all_classes']);
    } else if (_selectedFilter == 3) {
      // Student notifications
      query = query.where('targetType', whereIn: ['student', 'all_students']);
    } else if (_selectedFilter == 4) {
      // Parent notifications
      query = query.where('targetType', whereIn: ['parent', 'all_parents']);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data?.docs ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = notifications[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildNotificationCard(data);
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    final title = data['title'] ?? 'No Title';
    final message = data['message'] ?? '';
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    final targetType = data['targetType'] ?? 'general';
    final targetName = data['targetName'] ?? '';
    
    // Get icon based on target type
    IconData icon;
    Color iconColor;
    
    switch (targetType) {
      case 'class':
      case 'all_classes':
        icon = Icons.class_;
        iconColor = Colors.blue;
        break;
      case 'student':
      case 'all_students':
        icon = Icons.school;
        iconColor = Colors.green;
        break;
      case 'parent':
      case 'all_parents':
        icon = Icons.family_restroom;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.purple;
    }

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getTargetLabel(targetType, targetName),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTargetLabel(String targetType, String targetName) {
    switch (targetType) {
      case 'class':
        return 'Class: $targetName';
      case 'all_classes':
        return 'All Classes';
      case 'student':
        return 'Student: $targetName';
      case 'all_students':
        return 'All Students';
      case 'parent':
        return 'Parent: $targetName';
      case 'all_parents':
        return 'All Parents';
      default:
        return 'General';
    }
  }
}