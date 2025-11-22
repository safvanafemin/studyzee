import 'package:flutter/material.dart';

// Main App with Drawer
class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.blue.shade300),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Timetable Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Use the menu to navigate'),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.school, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
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
                  builder: (_) => const AdminTimetableScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              // Add navigation to dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.pop(context);
              // Add navigation to user management
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Add navigation to settings
            },
          ),
        ],
      ),
    );
  }
}

class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({super.key});

  @override
  State<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
  // --- Sample Timetable Data ---
  List<Map<String, String>> studentTimetable = [
    {'day': 'Monday', 'subject': 'Math', 'time': '09:00 AM - 10:00 AM', 'class': 'Class 10A'},
    {'day': 'Tuesday', 'subject': 'English', 'time': '10:00 AM - 11:00 AM', 'class': 'Class 10A'},
  ];

  List<Map<String, String>> teacherTimetable = [
    {'day': 'Monday', 'subject': 'Math', 'time': '09:00 AM - 10:00 AM', 'teacher': 'Mr. Smith', 'class': 'Class 10A'},
    {'day': 'Wednesday', 'subject': 'Physics', 'time': '11:00 AM - 12:00 PM', 'teacher': 'Mr. Smith', 'class': 'Class 9A'},
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Student Timetable" : "Teacher Timetable"),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Teachers',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTimetableScreen(
                isStudent: _selectedIndex == 0,
              ),
            ),
          );

          if (newItem != null) {
            setState(() {
              if (_selectedIndex == 0) {
                studentTimetable.add(newItem);
              } else {
                teacherTimetable.add(newItem);
              }
            });
          }
        },
      ),

      body: _selectedIndex == 0
          ? _buildTimetableList(studentTimetable, true)
          : _buildTimetableList(teacherTimetable, false),
    );
  }

  Widget _buildTimetableList(List<Map<String, String>> timetable, bool isStudent) {
    if (timetable.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isStudent ? Icons.school_outlined : Icons.person_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isStudent ? "student" : "teacher"} timetable entries',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: timetable.length,
      itemBuilder: (context, index) {
        final item = timetable[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                isStudent ? Icons.book : Icons.person,
                color: Colors.blue.shade700,
              ),
            ),
            title: Text(
              item['subject']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("${item['day']} • ${item['time']}"),
                if (item['class'] != null)
                  Text(
                    item['class']!,
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                    ),
                  ),
                if (!isStudent && item['teacher'] != null)
                  Text(
                    item['teacher']!,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final updatedItem = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTimetableScreen(
                          data: item,
                          isStudent: isStudent,
                        ),
                      ),
                    );

                    if (updatedItem != null) {
                      setState(() {
                        timetable[index] = updatedItem;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, timetable, index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, List<Map<String, String>> timetable, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this timetable entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  timetable.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class AddTimetableScreen extends StatefulWidget {
  final bool isStudent;

  const AddTimetableScreen({super.key, required this.isStudent});

  @override
  State<AddTimetableScreen> createState() => _AddTimetableScreenState();
}

class _AddTimetableScreenState extends State<AddTimetableScreen> {
  final dayController = TextEditingController();
  final subjectController = TextEditingController();
  final timeController = TextEditingController();
  final teacherController = TextEditingController();
  final classController = TextEditingController();

  String? selectedDay;
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add ${widget.isStudent ? 'Student' : 'Teacher'} Timetable",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(
                labelText: "Day",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                  dayController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Time (e.g., 09:00 AM - 10:00 AM)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 16),
            // Class field (for both student and teacher)
            TextField(
              controller: classController,
              decoration: const InputDecoration(
                labelText: "Class (e.g., Class 10A)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.class_),
              ),
            ),
            const SizedBox(height: 16),
            // Teacher field (only for teacher timetable)
            if (!widget.isStudent)
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: "Teacher Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (dayController.text.isEmpty ||
                    subjectController.text.isEmpty ||
                    timeController.text.isEmpty ||
                    classController.text.isEmpty ||
                    (!widget.isStudent && teacherController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final Map<String, String> newEntry = {
                  'day': dayController.text,
                  'subject': subjectController.text,
                  'time': timeController.text,
                  'class': classController.text,
                };

                if (!widget.isStudent) {
                  newEntry['teacher'] = teacherController.text;
                }

                Navigator.pop(context, newEntry);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Entry"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTimetableScreen extends StatefulWidget {
  final Map<String, String> data;
  final bool isStudent;

  const EditTimetableScreen({
    super.key,
    required this.data,
    required this.isStudent,
  });

  @override
  State<EditTimetableScreen> createState() => _EditTimetableScreenState();
}

class _EditTimetableScreenState extends State<EditTimetableScreen> {
  late TextEditingController dayController;
  late TextEditingController subjectController;
  late TextEditingController timeController;
  late TextEditingController teacherController;
  late TextEditingController classController;

  String? selectedDay;
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    dayController = TextEditingController(text: widget.data['day']);
    subjectController = TextEditingController(text: widget.data['subject']);
    timeController = TextEditingController(text: widget.data['time']);
    classController = TextEditingController(text: widget.data['class'] ?? '');
    teacherController = TextEditingController(text: widget.data['teacher'] ?? '');
    selectedDay = widget.data['day'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit ${widget.isStudent ? 'Student' : 'Teacher'} Timetable",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(
                labelText: "Day",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                  dayController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Time (e.g., 09:00 AM - 10:00 AM)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 16),
            // Class field (for both student and teacher)
            TextField(
              controller: classController,
              decoration: const InputDecoration(
                labelText: "Class (e.g., Class 10A)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.class_),
              ),
            ),
            const SizedBox(height: 16),
            // Teacher field (only for teacher timetable)
            if (!widget.isStudent)
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: "Teacher Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (dayController.text.isEmpty ||
                    subjectController.text.isEmpty ||
                    timeController.text.isEmpty ||
                    classController.text.isEmpty ||
                    (!widget.isStudent && teacherController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final Map<String, String> updatedEntry = {
                  'day': dayController.text,
                  'subject': subjectController.text,
                  'time': timeController.text,
                  'class': classController.text,
                };

                if (!widget.isStudent) {
                  updatedEntry['teacher'] = teacherController.text;
                }

                Navigator.pop(context, updatedEntry);
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}