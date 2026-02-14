import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyzee/features/admin/home/fee_management_screen.dart';
import 'package:studyzee/features/admin/home/student_payment_screen.dart';
import 'package:studyzee/features/admin/home/teacher_manage_section.dart';
import 'package:studyzee/features/admin/home/time_table_manage.dart';
import 'package:studyzee/features/auth/login_screen.dart';
import '../class/classmanage_screen.dart';

import 'package:studyzee/features/admin/fees/fees_manage_screen.dart';
import 'notification_send.dart';

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
            title: const Text('Fee Management'),
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
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
                if (context.mounted) _performLogout(context);
              } catch (e) {
                print('Error signing out: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
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

// -----------------------------------------------------------------------------
// TAB WIDGETS (Keep existing DashboardTab, StudentsTab, TeachersTab)
// -----------------------------------------------------------------------------

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  int _studentCount = 0;
  int _teacherCount = 0;
  int _classCount = 0;
  double _totalPayments = 0.0;
  List<Map<String, String>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Run queries in parallel
      final results = await Future.wait([
        _firestore
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .count()
            .get(),
        _firestore
            .collection('users')
            .where('role', isEqualTo: 'Teacher')
            .count()
            .get(),
        _firestore.collection('Classes').count().get(),
        _firestore.collection('FeePayments').get(), // Need to sum amounts
        _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get(), // Recent users
      ]);

      int studentCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
      int teacherCount = (results[1] as AggregateQuerySnapshot).count ?? 0;
      int classCount = (results[2] as AggregateQuerySnapshot).count ?? 0;

      // Calculate total payments
      double totalPayments = 0.0;
      final paymentDocs = (results[3] as QuerySnapshot).docs;
      for (var doc in paymentDocs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPayments += (data['amount'] ?? 0.0) as double;
      }

      // Process recent activities
      List<Map<String, String>> activities = [];
      final recentUsers = (results[4] as QuerySnapshot).docs;

      for (var doc in recentUsers) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown User';
        final role = data['role'] ?? 'User';
        final createdAt = data['createdAt'] as Timestamp?;
        final timeStr = createdAt != null
            ? _getTimeAgo(createdAt.toDate())
            : 'Recently';

        activities.add({'title': 'New $role joined: $name', 'time': timeStr});
      }

      if (mounted) {
        setState(() {
          _studentCount = studentCount;
          _teacherCount = teacherCount;
          _classCount = classCount;
          _totalPayments = totalPayments;
          _recentActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 0,
      ).format(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
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
                _buildStatCard(
                  'Students',
                  _studentCount.toString(),
                  Icons.school,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Teachers',
                  _teacherCount.toString(),
                  Icons.person,
                  Colors.green,
                ),
                _buildStatCard(
                  'Classes',
                  _classCount.toString(),
                  Icons.class_,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Payments',
                  _formatCurrency(_totalPayments),
                  Icons.payment,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (_recentActivities.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No recent activities')),
                ),
              )
            else
              ..._recentActivities.map(
                (activity) =>
                    _buildActivityItem(activity['title']!, activity['time']!),
              ),
          ],
        ),
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
