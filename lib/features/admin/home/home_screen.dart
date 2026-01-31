import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyzee/features/admin/home/fee_management_screen.dart';
import 'package:studyzee/features/admin/home/student_payment_screen.dart';
import 'package:studyzee/features/admin/home/teacher_manage_section.dart';
import 'package:studyzee/features/admin/home/time_table_manage.dart';
import 'package:studyzee/features/auth/login_screen.dart';
import '../class/classmanage_screen.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/app_notification.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    ClassWiseStudentsScreen(),
    AdminTeachersScreen(),
    const ClassSectionsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined),
            tooltip: 'Send Notification',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendNotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 2, 18, 69),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 2, 18, 69),
                  Color.fromARGB(143, 21, 77, 160),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 35,
                    color: Color.fromARGB(255, 2, 18, 69),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeeManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Manage Timetable'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminTimetableScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from the admin panel?',
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
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
              _performLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// SEND NOTIFICATION SCREEN (Keep existing)
// -----------------------------------------------------------------------------

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
  List<Map<String, dynamic>> _classes = [];
  bool _isSending = false;
  final NotificationService _notificationService = NotificationService();

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
          return {'id': doc.id, 'name': data['name'] ?? 'Unnamed Class'};
        }).toList();
      });
    } catch (e) {
      print('Error loading classes: $e');
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
              value: _selectedTarget,
              items: ['All Users', 'Parents Only', 'Individual Classes'].map((
                String value,
              ) {
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
                  });
                }
              },
            ),
            if (_selectedTarget == 'Individual Classes') ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_, color: Colors.blueGrey),
                ),
                value: _selectedClassId,
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

// -----------------------------------------------------------------------------
// TAB WIDGETS (Keep existing DashboardTab, StudentsTab, TeachersTab)
// -----------------------------------------------------------------------------

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Students', '150', Icons.school, Colors.blue),
              _buildStatCard('Teachers', '25', Icons.person, Colors.green),
              _buildStatCard('Classes', '12', Icons.class_, Colors.purple),
              _buildStatCard('Payments', '₹95K', Icons.payment, Colors.orange),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildActivityItem('New student enrolled: John Doe', '2 hours ago'),
          _buildActivityItem('Teacher updated: Jane Smith', '5 hours ago'),
          _buildActivityItem('New class created: Class 10-A', '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.notifications_active, size: 20),
        ),
        title: Text(activity),
        subtitle: Text(
          time,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }
}

class TeachersTab extends StatefulWidget {
  const TeachersTab({super.key});

  @override
  State<TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  List<Map<String, dynamic>> teachers = [
    {
      'name': 'Dr. Robert Brown',
      'subject': 'Mathematics',
      'email': 'robert@example.com',
      'phone': '1231231234',
    },
    {
      'name': 'Ms. Emily Davis',
      'subject': 'Science',
      'email': 'emily@example.com',
      'phone': '4564564567',
    },
  ];

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
                  decoration: InputDecoration(
                    hintText: 'Search teachers...',
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      teacher['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    teacher['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacher['subject']),
                      Text(
                        teacher['email'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(
                          context,
                          teacher: teacher,
                          index: index,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEditDialog(
    BuildContext context, {
    Map<String, dynamic>? teacher,
    int? index,
  }) {
    final nameController = TextEditingController(text: teacher?['name'] ?? '');
    final subjectController = TextEditingController(
      text: teacher?['subject'] ?? '',
    );
    final emailController = TextEditingController(
      text: teacher?['email'] ?? '',
    );
    final phoneController = TextEditingController(
      text: teacher?['phone'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(teacher == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
