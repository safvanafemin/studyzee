import 'package:flutter/material.dart';
import 'package:studyzee/features/admin/home/time_table_manage.dart';
import 'package:studyzee/features/student/timetable/timetable_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const StudentsTab(),
    const TeachersTab(),
    const ParentsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        actions: [
          // 🚀 SEND NOTIFICATION BUTTON
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
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Teachers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Parents',
          ),
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
                  child: Icon(Icons.admin_panel_settings,
                      size: 35, color: Color.fromARGB(255, 2, 18, 69)),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
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
                  builder: (context) => const PaymentsScreen(),
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
        content: const Text('Are you sure you want to logout from the admin panel?'),
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
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              _performLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // Show logout success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Here you would typically:
    // 1. Clear user session
    // 2. Clear any stored tokens
    // 3. Navigate to login screen
    // For now, we'll just show a success message
    
    // Example of navigation to login screen (uncomment if you have a login screen):
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    //   (route) => false,
    // );
  }
}

// -----------------------------------------------------------------------------
// PAYMENTS SCREEN
// -----------------------------------------------------------------------------

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Map<String, dynamic>> payments = [
    {
      'student': 'John Doe',
      'amount': '5000',
      'date': '2024-01-15',
      'status': 'Paid',
      'method': 'UPI'
    },
    {
      'student': 'Sarah Smith',
      'amount': '4500',
      'date': '2024-01-14',
      'status': 'Paid',
      'method': 'Cash'
    },
    {
      'student': 'Mike Johnson',
      'amount': '5000',
      'date': '2024-01-10',
      'status': 'Pending',
      'method': 'Bank Transfer'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments Management'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Collected',
                    '₹9,500',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    '₹5,000',
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by student name...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: payment['status'] == 'Paid'
                          ? Colors.green
                          : Colors.orange,
                      child: Icon(
                        payment['status'] == 'Paid'
                            ? Icons.check_circle
                            : Icons.pending,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(payment['student'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${payment['date']}'),
                        Text('Method: ${payment['method']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${payment['amount']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: payment['status'] == 'Paid'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payment['status'],
                            style: TextStyle(
                              color: payment['status'] == 'Paid'
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showPaymentDetails(context, payment),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
        onPressed: () => _showAddPaymentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Student', payment['student']),
            _buildDetailRow('Amount', '₹${payment['amount']}'),
            _buildDetailRow('Date', payment['date']),
            _buildDetailRow('Status', payment['status']),
            _buildDetailRow('Method', payment['method']),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    final studentController = TextEditingController();
    final amountController = TextEditingController();
    String selectedMethod = 'Cash';
    String selectedStatus = 'Paid';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentController,
                  decoration: const InputDecoration(
                      labelText: 'Student Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(),
                      prefixText: '₹'),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMethod,
                  items: ['Cash', 'UPI', 'Bank Transfer', 'Card']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        selectedMethod = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedStatus,
                  items: ['Paid', 'Pending'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        selectedStatus = newValue;
                      });
                    }
                  },
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
                if (studentController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    payments.add({
                      'student': studentController.text,
                      'amount': amountController.text,
                      'date': DateTime.now().toString().split(' ')[0],
                      'status': selectedStatus,
                      'method': selectedMethod,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment added successfully!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NEW SCREEN: Send Notification Screen
// -----------------------------------------------------------------------------

class SendNotificationScreen extends StatelessWidget {
  const SendNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy controllers for the text fields
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

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
                  color: Color.fromARGB(255, 2, 18, 69)),
            ),
            const Divider(height: 30),

            // Target Selection (e.g., All Users, Students, Teachers)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group, color: Colors.blueGrey),
              ),
              value: 'All Users',
              items: ['All Users', 'Students', 'Teachers', 'Parents', 'Class 10']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Logic to update target
              },
            ),
            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title (e.g., Important Notice)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),

            // Body Field
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Send Button
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label:
                  const Text('Send Notification Now', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 40, 167, 69), // Green for sending
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Dummy sending logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Notification sent successfully! (Placeholder)')),
                );
                Navigator.pop(context); // Go back to Admin Home
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB WIDGETS
// -----------------------------------------------------------------------------

// Dashboard Tab
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
              _buildStatCard(
                  'Parents', '120', Icons.family_restroom, Colors.orange),
              _buildStatCard('Classes', '30', Icons.class_, Colors.purple),
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
          _buildActivityItem('Payment received from Parent', '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String count, IconData icon, Color color) {
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
                fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
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
        subtitle:
            Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ),
    );
  }
}

// Students Tab
class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  List<Map<String, dynamic>> students = [
    {
      'name': 'John Doe',
      'class': 'Class 10',
      'email': 'john@example.com',
      'phone': '1234567890'
    },
    {
      'name': 'Sarah Smith',
      'class': 'Class 9',
      'email': 'sarah@example.com',
      'phone': '0987654321'
    },
    {
      'name': 'Mike Johnson',
      'class': 'Class 10',
      'email': 'mike@example.com',
      'phone': '5551234567'
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
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
            itemCount: students.length,
            itemBuilder: (context, index) {
              return _buildUserCard(
                context,
                students[index],
                index,
                'Student',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(
      BuildContext context, Map<String, dynamic> user, int index, String role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 2, 18, 69),
          child: Text(
            user['name'][0],
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user['name'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['class'] ?? user['subject'] ?? ''),
            Text(user['email'],
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showAddEditDialog(context, user: user, index: index);
            } else if (value == 'delete') {
              _showDeleteDialog(context, index);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context,
      {Map<String, dynamic>? user, int? index}) {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final classController = TextEditingController(text: user?['class'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add Student' : 'Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: classController,
                decoration: const InputDecoration(
                    labelText: 'Class', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder()),
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
              setState(() {
                if (index != null) {
                  students[index] = {
                    'name': nameController.text,
                    'class': classController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  };
                } else {
                  students.add({
                    'name': nameController.text,
                    'class': classController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  });
                }
              });
              Navigator.pop(context);
            },
            child: Text(user == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                students.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Teachers Tab
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
      'phone': '1231231234'
    },
    {
      'name': 'Ms. Emily Davis',
      'subject': 'Science',
      'email': 'emily@example.com',
      'phone': '4564564567'
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
                        borderRadius: BorderRadius.circular(10)),
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
                    child: Text(teacher['name'][0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(teacher['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacher['subject']),
                      Text(teacher['email'],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(context,
                            teacher: teacher, index: index);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, index);
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

  void _showAddEditDialog(BuildContext context,
      {Map<String, dynamic>? teacher, int? index}) {
    final nameController = TextEditingController(text: teacher?['name'] ?? '');
    final subjectController =
        TextEditingController(text: teacher?['subject'] ?? '');
    final emailController = TextEditingController(text: teacher?['email'] ?? '');
    final phoneController = TextEditingController(text: teacher?['phone'] ?? '');

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
                    labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                    labelText: 'Subject', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder()),
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
              setState(() {
                if (index != null) {
                  teachers[index] = {
                    'name': nameController.text,
                    'subject': subjectController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  };
                } else {
                  teachers.add({
                    'name': nameController.text,
                    'subject': subjectController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  });
                }
              });
              Navigator.pop(context);
            },
            child: Text(teacher == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                teachers.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Parents Tab
class ParentsTab extends StatefulWidget {
  const ParentsTab({super.key});

  @override
  State<ParentsTab> createState() => _ParentsTabState();
}

class _ParentsTabState extends State<ParentsTab> {
  List<Map<String, dynamic>> parents = [
    {
      'name': 'Mr. David Wilson',
      'student': 'John Doe',
      'email': 'david@example.com',
      'phone': '7897897890'
    },
    {
      'name': 'Mrs. Lisa Brown',
      'student': 'Sarah Smith',
      'email': 'lisa@example.com',
      'phone': '3213213210'
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
                    hintText: 'Search parents...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
            itemCount: parents.length,
            itemBuilder: (context, index) {
              final parent = parents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(parent['name'][0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(parent['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student: ${parent['student']}'),
                      Text(parent['email'],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(context,
                            parent: parent, index: index);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, index);
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

  void _showAddEditDialog(BuildContext context,
      {Map<String, dynamic>? parent, int? index}) {
    final nameController = TextEditingController(text: parent?['name'] ?? '');
    final studentController =
        TextEditingController(text: parent?['student'] ?? '');
    final emailController = TextEditingController(text: parent?['email'] ?? '');
    final phoneController = TextEditingController(text: parent?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parent == null ? 'Add Parent' : 'Edit Parent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: studentController,
                decoration: const InputDecoration(
                    labelText: 'Student Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder()),
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
              setState(() {
                if (index != null) {
                  parents[index] = {
                    'name': nameController.text,
                    'student': studentController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  };
                } else {
                  parents.add({
                    'name': nameController.text,
                    'student': studentController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  });
                }
              });
              Navigator.pop(context);
            },
            child: Text(parent == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parent'),
        content: const Text('Are you sure you want to delete this parent?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                parents.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
