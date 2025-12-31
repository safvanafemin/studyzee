// import 'package:flutter/material.dart';

// class Trtimetable extends StatefulWidget {
//   const Trtimetable({super.key});

//   @override
//   State<Trtimetable> createState() => _TeacherTimetableScreenState();
// }

// class _TeacherTimetableScreenState extends State<Trtimetable>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String selectedDay = "Monday";
//   final List<String> days = [
//     "Monday",
//     "Tuesday",
//     "Wednesday",
//     "Thursday",
//     "Friday",
//     "Saturday",
//     "Sunday"
//   ];

//   // Teacher's schedule data
//   final Map<String, List<Map<String, String>>> schedule = {
//     "Monday": [
//       {
//         "time": "09:00 AM - 10:00 AM",
//         "subject": "Mathematics",
//         "class": "Class 10 - A",
//         "batch": "Batch A",
//         "room": "Room 101",
//         "students": "45"
//       },
//       {
//         "time": "10:30 AM - 11:30 AM",
//         "subject": "Mathematics",
//         "class": "Class 10 - B",
//         "batch": "Batch B",
//         "room": "Room 102",
//         "students": "42"
//       },
//       {
//         "time": "12:00 PM - 01:00 PM",
//         "subject": "Mathematics",
//         "class": "Class 9 - A",
//         "batch": "Batch A",
//         "room": "Room 103",
//         "students": "38"
//       },
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Mathematics",
//         "class": "Class 10 - A",
//         "batch": "Batch C",
//         "room": "Room 101",
//         "students": "40"
//       },
//     ],
//     "Tuesday": [
//       {
//         "time": "09:00 AM - 10:00 AM",
//         "subject": "Mathematics",
//         "class": "Class 9 - B",
//         "batch": "Batch B",
//         "room": "Room 104",
//         "students": "35"
//       },
//       {
//         "time": "10:30 AM - 11:30 AM",
//         "subject": "Mathematics",
//         "class": "Class 8 - A",
//         "batch": "Batch A",
//         "room": "Room 101",
//         "students": "40"
//       },
//       {
//         "time": "02:00 PM - 03:00 PM",
//         "subject": "Mathematics",
//         "class": "Class 10 - B",
//         "batch": "Batch A",
//         "room": "Room 102",
//         "students": "42"
//       },
//     ],
//     "Wednesday": [
//       {
//         "time": "09:00 AM - 10:00 AM",
//         "subject": "Mathematics",
//         "class": "Class 10 - A",
//         "batch": "Batch A",
//         "room": "Room 101",
//         "students": "45"
//       },
//       {
//         "time": "11:00 AM - 12:00 PM",
//         "subject": "Mathematics",
//         "class": "Class 9 - A",
//         "batch": "Batch B",
//         "room": "Room 103",
//         "students": "38"
//       },
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Mathematics",
//         "class": "Class 10 - B",
//         "batch": "Batch C",
//         "room": "Room 102",
//         "students": "42"
//       },
//     ],
//     "Thursday": [
//       {
//         "time": "09:00 AM - 10:00 AM",
//         "subject": "Mathematics",
//         "class": "Class 8 - B",
//         "batch": "Batch A",
//         "room": "Room 105",
//         "students": "37"
//       },
//       {
//         "time": "10:30 AM - 11:30 AM",
//         "subject": "Mathematics",
//         "class": "Class 10 - A",
//         "batch": "Batch B",
//         "room": "Room 101",
//         "students": "45"
//       },
//       {
//         "time": "02:00 PM - 03:00 PM",
//         "subject": "Mathematics",
//         "class": "Class 9 - C",
//         "batch": "Batch C",
//         "room": "Room 106",
//         "students": "39"
//       },
//     ],
//     "Friday": [
//       {
//         "time": "09:00 AM - 10:00 AM",
//         "subject": "Mathematics",
//         "class": "Class 10 - B",
//         "batch": "Batch A",
//         "room": "Room 102",
//         "students": "42"
//       },
//       {
//         "time": "11:00 AM - 12:00 PM",
//         "subject": "Mathematics",
//         "class": "Class 9 - A",
//         "batch": "Batch A",
//         "room": "Room 103",
//         "students": "38"
//       },
//     ],
//     "Saturday": [
//       {
//         "time": "09:00 AM - 10:00 AM",
//         "subject": "Test Series",
//         "class": "Class 10 - All",
//         "batch": "All Batches",
//         "room": "Hall A",
//         "students": "130"
//       },
//       {
//         "time": "11:00 AM - 12:30 PM",
//         "subject": "Doubt Session",
//         "class": "Class 10",
//         "batch": "Open",
//         "room": "Room 101",
//         "students": "25"
//       },
//     ],
//     "Sunday": [
//       {
//         "time": "10:00 AM - 11:00 AM",
//         "subject": "Assignment Review",
//         "class": "Class 10 - A",
//         "batch": "Batch A",
//         "room": "Room 101",
//         "students": "45"
//       },
//       {
//         "time": "02:00 PM - 03:00 PM",
//         "subject": "Project Guidance",
//         "class": "Class 9 - A",
//         "batch": "Batch B",
//         "room": "Room 103",
//         "students": "38"
//       },
//     ],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: const Text(
//           "My Schedule",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF2563EB),
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: "Weekly"),
//             Tab(text: "Summary"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildWeeklyView(),
//           _buildSummaryView(),
//         ],
//       ),
//     );
//   }

//   Widget _buildWeeklyView() {
//     return Column(
//       children: [
//         // Header with teacher info
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: const BoxDecoration(
//             color: Color(0xFF2563EB),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//           ),
//           child: Column(
//             children: [
//               const Text(
//                 "Mr. Rajesh Kumar",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Mathematics Teacher",
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Day Selection
//         Container(
//           height: 50,
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: days.length,
//             itemBuilder: (context, index) {
//               bool isSelected = selectedDay == days[index];
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedDay = days[index];
//                   });
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 12),
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0xFF2563EB)
//                         : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       days[index].substring(0, 3),
//                       style: TextStyle(
//                         color:
//                             isSelected ? Colors.white : Colors.grey.shade700,
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.w500,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 )
//               );
//             },
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Classes List
//         Expanded(
//           child: schedule[selectedDay] != null &&
//                   schedule[selectedDay]!.isNotEmpty
//               ? ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: schedule[selectedDay]!.length,
//                   itemBuilder: (context, index) {
//                     final classData = schedule[selectedDay]![index];
//                     return TeacherClassCard(
//                       time: classData["time"]!,
//                       subject: classData["subject"]!,
//                       className: classData["class"]!,
//                       batch: classData["batch"]!,
//                       room: classData["room"]!,
//                       students: classData["students"]!,
//                       color: _getSubjectColor(classData["subject"]!),
//                     );
//                   },
//                 )
//               : Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.event_busy,
//                         size: 80,
//                         color: Colors.grey.shade300,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "No classes scheduled",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryView() {
//     int totalClasses = 0;
//     int totalStudents = 0;
//     Map<String, int> classCounts = {};

//     schedule.forEach((day, classes) {
//       totalClasses += classes.length;
//       for (var classData in classes) {
//         totalStudents += int.parse(classData["students"]!);
//         String className = classData["class"]!;
//         classCounts[className] = (classCounts[className] ?? 0) + 1;
//       }
//     });

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Weekly Statistics
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF2563EB),
//                   const Color(0xFF1E40AF),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 const Text(
//                   'Weekly Summary',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatBox('Total Classes', '$totalClasses', Colors.white),
//                     _buildStatBox(
//                         'Total Students', '$totalStudents', Colors.white),
//                     _buildStatBox(
//                         'Avg Class Size',
//                         '${(totalStudents / totalClasses).toStringAsFixed(0)}',
//                         Colors.white),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Classes by day
//           const Text(
//             'Schedule Breakdown',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...days.map((day) {
//             final dayClasses = schedule[day] ?? [];
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         day,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${dayClasses.length} class${dayClasses.length != 1 ? 'es' : ''}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF2563EB).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       dayClasses.isNotEmpty
//                           ? '${dayClasses.first["time"]!.split(' ')[0]} onwards'
//                           : 'Off',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF2563EB),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatBox(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: color.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getSubjectColor(String subject) {
//     switch (subject.toLowerCase()) {
//       case "mathematics":
//         return const Color(0xFF3B82F6);
//       case "test series":
//         return const Color(0xFFEF4444);
//       case "doubt session":
//         return const Color(0xFF8B5CF6);
//       case "assignment review":
//         return const Color(0xFF10B981);
//       case "project guidance":
//         return const Color(0xFFF59E0B);
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
// }

// class TeacherClassCard extends StatelessWidget {
//   final String time;
//   final String subject;
//   final String className;
//   final String batch;
//   final String room;
//   final String students;
//   final Color color;

//   const TeacherClassCard({
//     super.key,
//     required this.time,
//     required this.subject,
//     required this.className,
//     required this.batch,
//     required this.room,
//     required this.students,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Color indicator
//           Container(
//             width: 6,
//             height: 140,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 bottomLeft: Radius.circular(16),
//               ),
//             ),
//           ),

//           // Content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           subject,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey.shade800,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           batch,
//                           style: TextStyle(
//                             color: color,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     className,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Icon(Icons.access_time,
//                           size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 6),
//                       Text(
//                         time,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Icon(Icons.meeting_room_outlined,
//                           size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 6),
//                       Text(
//                         room,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Icon(Icons.people_outline,
//                           size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 6),
//                       Text(
//                         students,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherTimetableViewScreen extends StatefulWidget {
  const TeacherTimetableViewScreen({super.key});

  @override
  State<TeacherTimetableViewScreen> createState() =>
      _TeacherTimetableViewScreenState();
}

class _TeacherTimetableViewScreenState
    extends State<TeacherTimetableViewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _timetableEntries = [];
  bool _isLoading = true;
  String? _teacherName;
  Map<String, List<Map<String, dynamic>>> _groupedByDay = {};

  @override
  void initState() {
    super.initState();
    _loadTeacherTimetable();
  }

  Future<void> _loadTeacherTimetable() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // First get teacher info
      final teacherDoc = await _firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (teacherDoc.docs.isNotEmpty) {
        final teacherData = teacherDoc.docs.first.data();
        _teacherName = teacherData['name'] ?? 'Teacher';
      }

      // Load teacher's timetable
      final querySnapshot = await _firestore
          .collection('teacher_timetable')
          .where('teacherId', isEqualTo: user.uid)
          // .orderBy('day')
          // .orderBy('startTime')
          .get();

      final List<Map<String, dynamic>> entries = [];
      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final entry = {'id': doc.id, ...data};
        entries.add(entry);

        // Group by day
        final day = data['day'] ?? 'Unknown';
        if (!grouped.containsKey(day)) {
          grouped[day] = [];
        }
        grouped[day]!.add(entry);
      }

      // Sort days in order
      final dayOrder = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
      };

      final sortedGrouped = Map.fromEntries(
        grouped.entries.toList()..sort(
          (a, b) => (dayOrder[a.key] ?? 8).compareTo(dayOrder[b.key] ?? 8),
        ),
      );

      setState(() {
        _timetableEntries = entries;
        _groupedByDay = sortedGrouped;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading teacher timetable: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading timetable');
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

  void _refreshTimetable() {
    setState(() {
      _isLoading = true;
      _timetableEntries = [];
      _groupedByDay = {};
    });
    _loadTeacherTimetable();
  }

  String _getDayAbbreviation(String day) {
    return day.substring(0, 3);
  }

  Color _getDayColor(String day) {
    final colors = {
      'Monday': Colors.blue,
      'Tuesday': Colors.green,
      'Wednesday': Colors.orange,
      'Thursday': Colors.purple,
      'Friday': Colors.red,
      'Saturday': Colors.teal,
      'Sunday': Colors.pink,
    };
    return colors[day] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTimetable,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _timetableEntries.isEmpty
          ? _buildEmptyState()
          : _buildTimetableContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No timetable assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your timetable will appear here once assigned by the admin',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshTimetable,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableContent() {
    return Column(
      children: [
        // Teacher Info Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _teacherName ?? 'Teacher',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Classes: ${_timetableEntries.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Days Navigation
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _groupedByDay.keys.map((day) {
              final isSelected = true; // For teacher view, all days are shown
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: isSelected ? _getDayColor(day) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _getDayColor(day).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayAbbreviation(day),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_groupedByDay[day]!.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Timetable List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _groupedByDay.entries.map((entry) {
              final day = entry.key;
              final entries = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getDayColor(day),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getDayAbbreviation(day),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${entries.length} classes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Classes for the day
                  ...entries.map((entry) {
                    return _buildClassCard(entry);
                  }).toList(),

                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> entry) {
    final startTime = entry['startTime'] ?? '';
    final endTime = entry['endTime'] ?? '';
    final subject = entry['subject'] ?? 'Unknown Subject';
    final className = entry['className'] ?? 'Unknown Class';
    final room = entry['room'] ?? '';

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
                // Time Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$startTime - $endTime',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (room.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Subject
            Text(
              subject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            // Class Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.class_, size: 16, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    className,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            // Additional Info
            if (entry['teacherName'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry['teacherName']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
