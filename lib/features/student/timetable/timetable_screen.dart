// import 'package:flutter/material.dart';

// class TimetableScreen extends StatefulWidget {
//   const TimetableScreen({super.key});

//   @override
//   State<TimetableScreen> createState() => _TimetableScreenState();
// }

// class _TimetableScreenState extends State<TimetableScreen> {
//   String selectedDay = "Monday";
//   final List<String> days = [
//     "Monday",
//     "Tuesday",
//     "Wednesday",
//     "Thursday",
//     "Friday",
//     "Saturday",
//     "Sunday",
//   ];

//   // Sample timetable data
//   final Map<String, List<Map<String, String>>> schedule = {
//     "Monday": [
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Mathematics",
//         "teacher": "Mr. Rajesh Kumar",
//         "batch": "Batch A",
//         "room": "Room 101",
//       },
//       {
//         "time": "06:00 PM - 07:30 PM",
//         "subject": "Physics",
//         "teacher": "Dr. Priya Sharma",
//         "batch": "Batch A",
//         "room": "Room 102",
//       },
//     ],
//     "Tuesday": [
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Chemistry",
//         "teacher": "Mrs. Anjali Verma",
//         "batch": "Batch A",
//         "room": "Room 103",
//       },
//       {
//         "time": "06:00 PM - 07:30 PM",
//         "subject": "Biology",
//         "teacher": "Dr. Amit Patel",
//         "batch": "Batch A",
//         "room": "Room 104",
//       },
//     ],
//     "Wednesday": [
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "English",
//         "teacher": "Ms. Kavita Das",
//         "batch": "Batch A",
//         "room": "Room 101",
//       },
//       {
//         "time": "06:00 PM - 07:30 PM",
//         "subject": "Mathematics",
//         "teacher": "Mr. Rajesh Kumar",
//         "batch": "Batch A",
//         "room": "Room 101",
//       },
//     ],
//     "Thursday": [
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Physics",
//         "teacher": "Dr. Priya Sharma",
//         "batch": "Batch A",
//         "room": "Room 102",
//       },
//       {
//         "time": "06:00 PM - 07:30 PM",
//         "subject": "Chemistry",
//         "teacher": "Mrs. Anjali Verma",
//         "batch": "Batch A",
//         "room": "Room 103",
//       },
//     ],
//     "Friday": [
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Biology",
//         "teacher": "Dr. Amit Patel",
//         "batch": "Batch A",
//         "room": "Room 104",
//       },
//       {
//         "time": "06:00 PM - 07:30 PM",
//         "subject": "English",
//         "teacher": "Ms. Kavita Das",
//         "batch": "Batch A",
//         "room": "Room 101",
//       },
//     ],
//     "Saturday": [
//       {
//         "time": "09:00 AM - 10:30 AM",
//         "subject": "Mathematics",
//         "teacher": "Mr. Rajesh Kumar",
//         "batch": "Batch A",
//         "room": "Room 101",
//       },
//       {
//         "time": "11:00 AM - 12:30 PM",
//         "subject": "Physics",
//         "teacher": "Dr. Priya Sharma",
//         "batch": "Batch A",
//         "room": "Room 102",
//       },
//       {
//         "time": "02:00 PM - 03:30 PM",
//         "subject": "Chemistry",
//         "teacher": "Mrs. Anjali Verma",
//         "batch": "Batch A",
//         "room": "Room 103",
//       },
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Biology",
//         "teacher": "Dr. Amit Patel",
//         "batch": "Batch A",
//         "room": "Room 104",
//       },
//     ],
//     "Sunday": [
//       {
//         "time": "09:00 AM - 10:30 AM",
//         "subject": "Mathematics",
//         "teacher": "Mr. Rajesh Kumar",
//         "batch": "Batch B",
//         "room": "Room 101",
//       },
//       {
//         "time": "11:00 AM - 12:30 PM",
//         "subject": "English",
//         "teacher": "Ms. Kavita Das",
//         "batch": "Batch B",
//         "room": "Room 101",
//       },
//       {
//         "time": "02:00 PM - 03:30 PM",
//         "subject": "Physics",
//         "teacher": "Dr. Priya Sharma",
//         "batch": "Batch C",
//         "room": "Room 102",
//       },
//       {
//         "time": "04:00 PM - 05:30 PM",
//         "subject": "Test Series",
//         "teacher": "All Teachers",
//         "batch": "All Batches",
//         "room": "Hall A",
//       },
//     ],
//   };

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
//           "Class Schedule",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF2563EB),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Header with current batch info
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: const BoxDecoration(
//               color: Color(0xFF2563EB),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               children: [
//                 const Text(
//                   "Your Batch: Batch A",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Grade 10 - Science Stream",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Day Selection
//           Container(
//             height: 50,
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: days.length,
//               itemBuilder: (context, index) {
//                 bool isSelected = selectedDay == days[index];
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedDay = days[index];
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 12),
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(0xFF2563EB)
//                           : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         days[index].substring(0, 3),
//                         style: TextStyle(
//                           color: isSelected
//                               ? Colors.white
//                               : Colors.grey.shade700,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Classes List
//           Expanded(
//             child:
//                 schedule[selectedDay] != null &&
//                     schedule[selectedDay]!.isNotEmpty
//                 ? ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: schedule[selectedDay]!.length,
//                     itemBuilder: (context, index) {
//                       final classData = schedule[selectedDay]![index];
//                       return ClassCard(
//                         time: classData["time"]!,
//                         subject: classData["subject"]!,
//                         teacher: classData["teacher"]!,
//                         batch: classData["batch"]!,
//                         room: classData["room"]!,
//                         color: _getSubjectColor(classData["subject"]!),
//                       );
//                     },
//                   )
//                 : Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.event_busy,
//                           size: 80,
//                           color: Colors.grey.shade300,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           "No classes scheduled",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade600,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getSubjectColor(String subject) {
//     switch (subject.toLowerCase()) {
//       case "mathematics":
//         return const Color(0xFF3B82F6);
//       case "physics":
//         return const Color(0xFF8B5CF6);
//       case "chemistry":
//         return const Color(0xFFEC4899);
//       case "biology":
//         return const Color(0xFF10B981);
//       case "english":
//         return const Color(0xFFF59E0B);
//       case "test series":
//         return const Color(0xFFEF4444);
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
// }

// class ClassCard extends StatelessWidget {
//   final String time;
//   final String subject;
//   final String teacher;
//   final String batch;
//   final String room;
//   final Color color;

//   const ClassCard({
//     super.key,
//     required this.time,
//     required this.subject,
//     required this.teacher,
//     required this.batch,
//     required this.room,
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
//             height: 120,
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
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.access_time,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         time,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.person_outline,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           teacher,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.meeting_room_outlined,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         room,
//                         style: TextStyle(
//                           fontSize: 14,
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentTimetableViewScreen extends StatefulWidget {
  final String? studentId; // Pass the logged-in student's user ID
  final String? classId; // Pass the student's class ID

  const StudentTimetableViewScreen({super.key, this.studentId, this.classId});

  @override
  State<StudentTimetableViewScreen> createState() =>
      _StudentTimetableViewScreenState();
}

class _StudentTimetableViewScreenState
    extends State<StudentTimetableViewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String _selectedDay = 'Monday';
  Map<String, dynamic>? _classInfo;
  String? _actualClassId;
  bool _isLoadingClass = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Set selected day to current day
    _selectedDay = _getCurrentDay();
  }

  Future<void> _initializeData() async {
    // If classId is provided, use it. Otherwise, fetch from user document
    if (widget.classId != null && widget.classId!.isNotEmpty) {
      setState(() {
        _actualClassId = widget.classId;
      });
      await _loadClassInfo();
    } else {
      await _fetchUserClassId();
    }
  }

  Future<void> _fetchUserClassId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoadingClass = false);
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _actualClassId = userData['classId'];
        });
        if (_actualClassId != null) {
          await _loadClassInfo();
        } else {
          setState(() => _isLoadingClass = false);
        }
      } else {
        setState(() => _isLoadingClass = false);
      }
    } catch (e) {
      print('Error fetching user class ID: $e');
      setState(() => _isLoadingClass = false);
    }
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1, Sunday = 7
    if (weekday >= 1 && weekday <= 6) {
      return _days[weekday - 1];
    }
    return 'Monday'; // Default to Monday if Sunday
  }

  Future<void> _loadClassInfo() async {
    try {
      if (_actualClassId == null) {
        setState(() => _isLoadingClass = false);
        return;
      }

      final classDoc = await _firestore
          .collection('Classes')
          .doc(_actualClassId)
          .get();

      if (classDoc.exists) {
        setState(() {
          _classInfo = classDoc.data();
          _isLoadingClass = false;
        });
      } else {
        setState(() => _isLoadingClass = false);
      }
    } catch (e) {
      print('Error loading class info: $e');
      setState(() => _isLoadingClass = false);
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  List<QueryDocumentSnapshot> _sortTimetableEntries(
    List<QueryDocumentSnapshot> entries,
  ) {
    entries.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aTime = aData['startTime'] ?? '00:00';
      final bTime = bData['startTime'] ?? '00:00';

      return aTime.compareTo(bTime);
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingClass) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Timetable'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_actualClassId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Timetable'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 20),
              const Text(
                'No Class Assigned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please contact your administrator',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final className = _classInfo != null
        ? '${_classInfo!['name']}${_classInfo!['section']?.isNotEmpty == true ? ' - ${_classInfo!['section']}' : ''}'
        : 'Loading...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with class info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Class',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            className,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Day Selection Tabs
          Container(
            height: 60,
            color: Colors.grey[100],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final isSelected = day == _selectedDay;
                final isToday = day == _getCurrentDay();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isToday
                            ? Colors.blue
                            : (isSelected ? Colors.blue : Colors.grey[300]!),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.substring(0, 3),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Timetable Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('student_timetable')
                  .where('classId', isEqualTo: _actualClassId)
                  .where('day', isEqualTo: _selectedDay)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading timetable',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final entries = snapshot.data?.docs ?? [];
                final sortedEntries = _sortTimetableEntries(entries);

                if (sortedEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No classes on $_selectedDay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enjoy your day off!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final data = entry.data() as Map<String, dynamic>;

                    return _buildTimetableCard(data, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(Map<String, dynamic> data, int index) {
    final subject = data['subject'] ?? 'Unknown Subject';
    final startTime = data['startTime'] ?? '00:00';
    final endTime = data['endTime'] ?? '00:00';
    final room = data['room'] ?? '';

    // Color scheme based on index
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    final color = colors[index % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showClassDetails(context, data);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time indicator
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Time column
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(startTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, width: 40, color: Colors.grey[300]),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(endTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              // Subject details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (room.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Room: $room',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Subject
              Text(
                data['subject'] ?? 'Unknown Subject',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Details
              _buildDetailRow(
                Icons.access_time,
                'Time',
                '${_formatTime(data['startTime'] ?? '00:00')} - ${_formatTime(data['endTime'] ?? '00:00')}',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.calendar_today,
                'Day',
                data['day'] ?? 'Unknown',
              ),
              const SizedBox(height: 12),
              if (data['room'] != null && data['room'].isNotEmpty)
                _buildDetailRow(Icons.location_on, 'Room', data['room']),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
