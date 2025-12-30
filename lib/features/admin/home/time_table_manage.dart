// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       drawer: AppDrawer(),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.school, size: 100, color: Colors.blue.shade300),
//             const SizedBox(height: 20),
//             const Text(
//               'Welcome to Timetable Management',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             const Text('Use the menu to navigate'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: const [
//                 Icon(Icons.school, size: 50, color: Colors.white),
//                 SizedBox(height: 10),
//                 Text(
//                   'Admin Panel',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text('Home'),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.schedule),
//             title: const Text('Manage Timetable'),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const AdminTimetableScreen(),
//                 ),
//               );
//             },
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.dashboard),
//             title: const Text('Dashboard'),
//             onTap: () {
//               Navigator.pop(context);
//               // Add navigation to dashboard
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.people),
//             title: const Text('Manage Users'),
//             onTap: () {
//               Navigator.pop(context);
//               // Add navigation to user management
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () {
//               Navigator.pop(context);
//               // Add navigation to settings
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AdminTimetableScreen extends StatefulWidget {
//   const AdminTimetableScreen({super.key});

//   @override
//   State<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
// }

// class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
//   // --- Sample Timetable Data ---
//   List<Map<String, String>> studentTimetable = [
//     {'day': 'Monday', 'subject': 'Math', 'time': '09:00 AM - 10:00 AM', 'class': 'Class 10A'},
//     {'day': 'Tuesday', 'subject': 'English', 'time': '10:00 AM - 11:00 AM', 'class': 'Class 10A'},
//   ];

//   List<Map<String, String>> teacherTimetable = [
//     {'day': 'Monday', 'subject': 'Math', 'time': '09:00 AM - 10:00 AM', 'teacher': 'Mr. Smith', 'class': 'Class 10A'},
//     {'day': 'Wednesday', 'subject': 'Physics', 'time': '11:00 AM - 12:00 PM', 'teacher': 'Mr. Smith', 'class': 'Class 9A'},
//   ];

//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_selectedIndex == 0 ? "Student Timetable" : "Teacher Timetable"),
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.school),
//             label: 'Students',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Teachers',
//           ),
//         ],
//       ),

//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () async {
//           final newItem = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => AddTimetableScreen(
//                 isStudent: _selectedIndex == 0,
//               ),
//             ),
//           );

//           if (newItem != null) {
//             setState(() {
//               if (_selectedIndex == 0) {
//                 studentTimetable.add(newItem);
//               } else {
//                 teacherTimetable.add(newItem);
//               }
//             });
//           }
//         },
//       ),

//       body: _selectedIndex == 0
//           ? _buildTimetableList(studentTimetable, true)
//           : _buildTimetableList(teacherTimetable, false),
//     );
//   }

//   Widget _buildTimetableList(List<Map<String, String>> timetable, bool isStudent) {
//     if (timetable.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isStudent ? Icons.school_outlined : Icons.person_outline,
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No ${isStudent ? "student" : "teacher"} timetable entries',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: timetable.length,
//       itemBuilder: (context, index) {
//         final item = timetable[index];

//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           elevation: 2,
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue.shade100,
//               child: Icon(
//                 isStudent ? Icons.book : Icons.person,
//                 color: Colors.blue.shade700,
//               ),
//             ),
//             title: Text(
//               item['subject']!,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 4),
//                 Text("${item['day']} • ${item['time']}"),
//                 if (item['class'] != null)
//                   Text(
//                     item['class']!,
//                     style: TextStyle(
//                       color: Colors.blue.shade600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 if (!isStudent && item['teacher'] != null)
//                   Text(
//                     item['teacher']!,
//                     style: TextStyle(
//                       color: Colors.green.shade600,
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () async {
//                     final updatedItem = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => EditTimetableScreen(
//                           data: item,
//                           isStudent: isStudent,
//                         ),
//                       ),
//                     );

//                     if (updatedItem != null) {
//                       setState(() {
//                         timetable[index] = updatedItem;
//                       });
//                     }
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () {
//                     _showDeleteConfirmation(context, timetable, index);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showDeleteConfirmation(
//       BuildContext context, List<Map<String, String>> timetable, int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Entry'),
//           content: const Text('Are you sure you want to delete this timetable entry?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   timetable.removeAt(index);
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class AddTimetableScreen extends StatefulWidget {
//   final bool isStudent;

//   const AddTimetableScreen({super.key, required this.isStudent});

//   @override
//   State<AddTimetableScreen> createState() => _AddTimetableScreenState();
// }

// class _AddTimetableScreenState extends State<AddTimetableScreen> {
//   final dayController = TextEditingController();
//   final subjectController = TextEditingController();
//   final timeController = TextEditingController();
//   final teacherController = TextEditingController();
//   final classController = TextEditingController();

//   String? selectedDay;
//   final List<String> days = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Add ${widget.isStudent ? 'Student' : 'Teacher'} Timetable",
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DropdownButtonFormField<String>(
//               value: selectedDay,
//               decoration: const InputDecoration(
//                 labelText: "Day",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.calendar_today),
//               ),
//               items: days.map((day) {
//                 return DropdownMenuItem(
//                   value: day,
//                   child: Text(day),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedDay = value;
//                   dayController.text = value ?? '';
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: subjectController,
//               decoration: const InputDecoration(
//                 labelText: "Subject",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.book),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: timeController,
//               decoration: const InputDecoration(
//                 labelText: "Time (e.g., 09:00 AM - 10:00 AM)",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.access_time),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Class field (for both student and teacher)
//             TextField(
//               controller: classController,
//               decoration: const InputDecoration(
//                 labelText: "Class (e.g., Class 10A)",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.class_),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Teacher field (only for teacher timetable)
//             if (!widget.isStudent)
//               TextField(
//                 controller: teacherController,
//                 decoration: const InputDecoration(
//                   labelText: "Teacher Name",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 if (dayController.text.isEmpty ||
//                     subjectController.text.isEmpty ||
//                     timeController.text.isEmpty ||
//                     classController.text.isEmpty ||
//                     (!widget.isStudent && teacherController.text.isEmpty)) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please fill in all required fields'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }

//                 final Map<String, String> newEntry = {
//                   'day': dayController.text,
//                   'subject': subjectController.text,
//                   'time': timeController.text,
//                   'class': classController.text,
//                 };

//                 if (!widget.isStudent) {
//                   newEntry['teacher'] = teacherController.text;
//                 }

//                 Navigator.pop(context, newEntry);
//               },
//               icon: const Icon(Icons.add),
//               label: const Text("Add Entry"),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class EditTimetableScreen extends StatefulWidget {
//   final Map<String, String> data;
//   final bool isStudent;

//   const EditTimetableScreen({
//     super.key,
//     required this.data,
//     required this.isStudent,
//   });

//   @override
//   State<EditTimetableScreen> createState() => _EditTimetableScreenState();
// }

// class _EditTimetableScreenState extends State<EditTimetableScreen> {
//   late TextEditingController dayController;
//   late TextEditingController subjectController;
//   late TextEditingController timeController;
//   late TextEditingController teacherController;
//   late TextEditingController classController;

//   String? selectedDay;
//   final List<String> days = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     dayController = TextEditingController(text: widget.data['day']);
//     subjectController = TextEditingController(text: widget.data['subject']);
//     timeController = TextEditingController(text: widget.data['time']);
//     classController = TextEditingController(text: widget.data['class'] ?? '');
//     teacherController = TextEditingController(text: widget.data['teacher'] ?? '');
//     selectedDay = widget.data['day'];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Edit ${widget.isStudent ? 'Student' : 'Teacher'} Timetable",
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DropdownButtonFormField<String>(
//               value: selectedDay,
//               decoration: const InputDecoration(
//                 labelText: "Day",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.calendar_today),
//               ),
//               items: days.map((day) {
//                 return DropdownMenuItem(
//                   value: day,
//                   child: Text(day),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedDay = value;
//                   dayController.text = value ?? '';
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: subjectController,
//               decoration: const InputDecoration(
//                 labelText: "Subject",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.book),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: timeController,
//               decoration: const InputDecoration(
//                 labelText: "Time (e.g., 09:00 AM - 10:00 AM)",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.access_time),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Class field (for both student and teacher)
//             TextField(
//               controller: classController,
//               decoration: const InputDecoration(
//                 labelText: "Class (e.g., Class 10A)",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.class_),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Teacher field (only for teacher timetable)
//             if (!widget.isStudent)
//               TextField(
//                 controller: teacherController,
//                 decoration: const InputDecoration(
//                   labelText: "Teacher Name",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 if (dayController.text.isEmpty ||
//                     subjectController.text.isEmpty ||
//                     timeController.text.isEmpty ||
//                     classController.text.isEmpty ||
//                     (!widget.isStudent && teacherController.text.isEmpty)) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please fill in all required fields'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }

//                 final Map<String, String> updatedEntry = {
//                   'day': dayController.text,
//                   'subject': subjectController.text,
//                   'time': timeController.text,
//                   'class': classController.text,
//                 };

//                 if (!widget.isStudent) {
//                   updatedEntry['teacher'] = teacherController.text;
//                 }

//                 Navigator.pop(context, updatedEntry);
//               },
//               icon: const Icon(Icons.save),
//               label: const Text("Save Changes"),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({super.key});

  @override
  State<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  bool _isLoading = false;

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
        _classes = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'section': data['section'] ?? '',
            'grade': data['grade'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading classes: $e');
      _showError('Error loading classes');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Student Timetable" : "Teacher Timetable",
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // Class Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Class',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedClassId,
                    hint: const Text('Select a class'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'All Classes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ..._classes.map((classData) {
                        final displayName = classData['section'].isNotEmpty
                            ? '${classData['name']} - ${classData['section']}'
                            : classData['name'];
                        return DropdownMenuItem<String>(
                          value: classData['id'],
                          child: Text(displayName),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    index: 0,
                    label: 'Students',
                    icon: Icons.school,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    index: 1,
                    label: 'Teachers',
                    icon: Icons.person,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedClassId == null
                ? _buildSelectClassPrompt()
                : _buildTimetableContent(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: _selectedClassId == null
            ? null
            : () async {
                final newItem = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTimetableScreen(
                      isStudent: _selectedIndex == 0,
                      classId: _selectedClassId!,
                      classes: _classes,
                    ),
                  ),
                );

                if (newItem != null) {
                  await _addTimetableEntry(newItem);
                }
              },
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectClassPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            'Select a class to view timetable',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choose a class from the dropdown above',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedIndex == 0
          ? _firestore
                .collection('student_timetable')
                .where('classId', isEqualTo: _selectedClassId)
                // .orderBy('day')
                // .orderBy('startTime')
                .snapshots()
          : _firestore
                .collection('teacher_timetable')
                .where('classId', isEqualTo: _selectedClassId)
                // .orderBy('day')
                // .orderBy('startTime')
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final entries = snapshot.data?.docs ?? [];

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedIndex == 0 ? Icons.school : Icons.person,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                Text(
                  'No ${_selectedIndex == 0 ? 'student' : 'teacher'} timetable entries',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add entries using the + button',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final data = entry.data() as Map<String, dynamic>;

            return _buildTimetableCard(
              entryId: entry.id,
              data: data,
              isStudent: _selectedIndex == 0,
            );
          },
        );
      },
    );
  }

  Widget _buildTimetableCard({
    required String entryId,
    required Map<String, dynamic> data,
    required bool isStudent,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isStudent ? Icons.book : Icons.person,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['subject'] ?? 'No Subject',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['day'] ?? 'No Day',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data['startTime']} - ${data['endTime']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editTimetableEntry(entryId, data, isStudent);
                    } else if (value == 'delete') {
                      _deleteTimetableEntry(entryId, isStudent);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
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

            const SizedBox(height: 12),

            Row(
              children: [
                Chip(
                  label: Text(
                    data['className'] ?? 'Unknown Class',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (!isStudent && data['teacherName'] != null)
                  Chip(
                    label: Text(
                      data['teacherName']!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTimetableEntry(Map<String, dynamic> data) async {
    try {
      final collection = _selectedIndex == 0
          ? 'student_timetable'
          : 'teacher_timetable';

      await _firestore.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSuccess('Timetable entry added successfully!');
    } catch (e) {
      print('Error adding timetable entry: $e');
      _showError('Error adding timetable entry');
    }
  }

  Future<void> _editTimetableEntry(
    String entryId,
    Map<String, dynamic> data,
    bool isStudent,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTimetableScreen(
          entryId: entryId,
          data: data,
          isStudent: isStudent,
          classId: _selectedClassId!,
          classes: _classes,
        ),
      ),
    );

    if (result == true) {
      _showSuccess('Timetable entry updated successfully!');
    }
  }

  Future<void> _deleteTimetableEntry(String entryId, bool isStudent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this timetable entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final collection = isStudent
            ? 'student_timetable'
            : 'teacher_timetable';

        await _firestore.collection(collection).doc(entryId).delete();
        _showSuccess('Timetable entry deleted successfully!');
      } catch (e) {
        print('Error deleting timetable entry: $e');
        _showError('Error deleting timetable entry');
      }
    }
  }
}

class AddTimetableScreen extends StatefulWidget {
  final bool isStudent;
  final String classId;
  final List<Map<String, dynamic>> classes;

  const AddTimetableScreen({
    super.key,
    required this.isStudent,
    required this.classId,
    required this.classes,
  });

  @override
  State<AddTimetableScreen> createState() => _AddTimetableScreenState();
}

class _AddTimetableScreenState extends State<AddTimetableScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedDay;
  String? selectedTeacherId;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<Map<String, dynamic>> _teachers = [];
  bool _isLoadingTeachers = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isStudent) {
      _loadTeachers();
    }
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoadingTeachers = true;
    });

    try {
      // Query teachers from 'users' collection where role = 'Teacher'
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Teacher')
          // .orderBy('name')
          .get();

      setState(() {
        _teachers = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading teachers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading teachers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingTeachers = false;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final initialTime = isStartTime
        ? selectedStartTime ?? const TimeOfDay(hour: 9, minute: 0)
        : selectedEndTime ?? const TimeOfDay(hour: 10, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = pickedTime;
        } else {
          selectedEndTime = pickedTime;
        }
      });
    }
  }

  Future<void> _saveTimetable() async {
    // Validation
    if (selectedDay == null) {
      _showError('Please select a day');
      return;
    }

    if (subjectController.text.isEmpty) {
      _showError('Please enter subject');
      return;
    }

    if (selectedStartTime == null || selectedEndTime == null) {
      _showError('Please select both start and end time');
      return;
    }

    if (!widget.isStudent && selectedTeacherId == null) {
      _showError('Please select a teacher');
      return;
    }

    final selectedClass = widget.classes.firstWhere(
      (cls) => cls['id'] == widget.classId,
    );

    final data = {
      'classId': widget.classId,
      'className':
          '${selectedClass['name']}${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}',
      'day': selectedDay!,
      'subject': subjectController.text.trim(),
      'startTime':
          '${selectedStartTime!.hour}:${selectedStartTime!.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${selectedEndTime!.hour}:${selectedEndTime!.minute.toString().padLeft(2, '0')}',
      'room': roomController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (!widget.isStudent) {
      final selectedTeacher = _teachers.firstWhere(
        (teacher) => teacher['id'] == selectedTeacherId,
      );
      data['teacherId'] = selectedTeacherId ?? '';
      data['teacherName'] = selectedTeacher['name'];
      data['teacherEmail'] = selectedTeacher['email'];
    }

    Navigator.pop(context, data);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = widget.classes.firstWhere(
      (cls) => cls['id'] == widget.classId,
    );
    final className =
        '${selectedClass['name']}${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add ${widget.isStudent ? 'Student' : 'Teacher'} Timetable',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.class_, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'Class: $className',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Day Selection
            const Text(
              'Day *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedDay,
                hint: const Text('Select Day'),
                isExpanded: true,
                underline: const SizedBox(),
                items: days.map((day) {
                  return DropdownMenuItem<String>(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Subject
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 20),

            // Time Selection
            const Text(
              'Time *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedStartTime != null
                                  ? selectedStartTime!.format(context)
                                  : 'Start Time',
                              style: TextStyle(
                                color: selectedStartTime != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('to', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedEndTime != null
                                  ? selectedEndTime!.format(context)
                                  : 'End Time',
                              style: TextStyle(
                                color: selectedEndTime != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Teacher Selection (for teacher timetable only)
            if (!widget.isStudent) ...[
              const Text(
                'Teacher *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingTeachers
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButton<String>(
                        value: selectedTeacherId,
                        hint: const Text('Select Teacher'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select Teacher'),
                          ),
                          ..._teachers.map((teacher) {
                            return DropdownMenuItem<String>(
                              value: teacher['id'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teacher['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (teacher['email'] != null &&
                                      teacher['email'].isNotEmpty)
                                    Text(
                                      teacher['email'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedTeacherId = value;
                          });
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],

            // Room
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Room (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTimetable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Timetable Entry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTimetableScreen extends StatefulWidget {
  final String entryId;
  final Map<String, dynamic> data;
  final bool isStudent;
  final String classId;
  final List<Map<String, dynamic>> classes;

  const EditTimetableScreen({
    super.key,
    required this.entryId,
    required this.data,
    required this.isStudent,
    required this.classId,
    required this.classes,
  });

  @override
  State<EditTimetableScreen> createState() => _EditTimetableScreenState();
}

class _EditTimetableScreenState extends State<EditTimetableScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedDay;
  String? selectedTeacherId;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<Map<String, dynamic>> _teachers = [];
  bool _isLoadingTeachers = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing data
    selectedDay = widget.data['day'];
    subjectController.text = widget.data['subject'] ?? '';
    roomController.text = widget.data['room'] ?? '';

    // Parse times
    if (widget.data['startTime'] != null) {
      final startParts = widget.data['startTime'].split(':');
      selectedStartTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
    }

    if (widget.data['endTime'] != null) {
      final endParts = widget.data['endTime'].split(':');
      selectedEndTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    }

    if (!widget.isStudent) {
      selectedTeacherId = widget.data['teacherId'];
      _loadTeachers();
    }
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoadingTeachers = true;
    });

    try {
      // Query teachers from 'users' collection where role = 'Teacher'
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Teacher')
          .orderBy('name')
          .get();

      setState(() {
        _teachers = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading teachers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading teachers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingTeachers = false;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final initialTime = isStartTime
        ? selectedStartTime ?? const TimeOfDay(hour: 9, minute: 0)
        : selectedEndTime ?? const TimeOfDay(hour: 10, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = pickedTime;
        } else {
          selectedEndTime = pickedTime;
        }
      });
    }
  }

  Future<void> _updateTimetable() async {
    // Validation
    if (selectedDay == null) {
      _showError('Please select a day');
      return;
    }

    if (subjectController.text.isEmpty) {
      _showError('Please enter subject');
      return;
    }

    if (selectedStartTime == null || selectedEndTime == null) {
      _showError('Please select both start and end time');
      return;
    }

    if (!widget.isStudent && selectedTeacherId == null) {
      _showError('Please select a teacher');
      return;
    }

    final selectedClass = widget.classes.firstWhere(
      (cls) => cls['id'] == widget.classId,
    );

    final data = {
      'classId': widget.classId,
      'className':
          '${selectedClass['name']}${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}',
      'day': selectedDay!,
      'subject': subjectController.text.trim(),
      'startTime':
          '${selectedStartTime!.hour}:${selectedStartTime!.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${selectedEndTime!.hour}:${selectedEndTime!.minute.toString().padLeft(2, '0')}',
      'room': roomController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!widget.isStudent) {
      final selectedTeacher = _teachers.firstWhere(
        (teacher) => teacher['id'] == selectedTeacherId,
      );
      data['teacherId'] = selectedTeacherId ?? '';
      data['teacherName'] = selectedTeacher['name'];
      data['teacherEmail'] = selectedTeacher['email'];
    }

    try {
      final collection = widget.isStudent
          ? 'student_timetable'
          : 'teacher_timetable';

      await _firestore.collection(collection).doc(widget.entryId).update(data);
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating timetable: $e');
      _showError('Error updating timetable');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = widget.classes.firstWhere(
      (cls) => cls['id'] == widget.classId,
    );
    final className =
        '${selectedClass['name']}${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.isStudent ? 'Student' : 'Teacher'} Timetable',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.class_, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'Class: $className',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Day Selection
            const Text(
              'Day *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedDay,
                hint: const Text('Select Day'),
                isExpanded: true,
                underline: const SizedBox(),
                items: days.map((day) {
                  return DropdownMenuItem<String>(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Subject
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 20),

            // Time Selection
            const Text(
              'Time *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedStartTime != null
                                  ? selectedStartTime!.format(context)
                                  : 'Start Time',
                              style: TextStyle(
                                color: selectedStartTime != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('to', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedEndTime != null
                                  ? selectedEndTime!.format(context)
                                  : 'End Time',
                              style: TextStyle(
                                color: selectedEndTime != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Teacher Selection (for teacher timetable only)
            if (!widget.isStudent) ...[
              const Text(
                'Teacher *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingTeachers
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButton<String>(
                        value: selectedTeacherId,
                        hint: const Text('Select Teacher'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select Teacher'),
                          ),
                          ..._teachers.map((teacher) {
                            return DropdownMenuItem<String>(
                              value: teacher['id'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teacher['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (teacher['email'] != null &&
                                      teacher['email'].isNotEmpty)
                                    Text(
                                      teacher['email'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedTeacherId = value;
                          });
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],

            // Room
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Room (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 30),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateTimetable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Timetable Entry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
