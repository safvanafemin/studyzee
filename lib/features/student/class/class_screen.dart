// import 'package:flutter/material.dart';

// class ClassScreen extends StatefulWidget {
//   const ClassScreen({super.key});

//   @override
//   State<ClassScreen> createState() => _ClassScreenState();
// }

// class _ClassScreenState extends State<ClassScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

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
//           "Classes",
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
//           indicatorWeight: 3,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           labelStyle: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           tabs: const [
//             Tab(text: "Recorded Classes"),
//             Tab(text: "Live Classes"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           RecordedClassesTab(),
//           LiveClassesTab(),
//         ],
//       ),
//     );
//   }
// }

// // Live Classes Tab
// class LiveClassesTab extends StatelessWidget {
//   const LiveClassesTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final liveClasses = [
//       {
//         "subject": "Mathematics",
//         "teacher": "Mr. Rajesh Kumar",
//         "time": "4:00 PM - 5:30 PM",
//         "batch": "Batch A",
//         "status": "live",
//         "participants": 45,
//         "topic": "Quadratic Equations",
//       },
//       {
//         "subject": "Physics",
//         "teacher": "Dr. Priya Sharma",
//         "time": "6:00 PM - 7:30 PM",
//         "batch": "Batch A",
//         "status": "upcoming",
//         "participants": 0,
//         "topic": "Newton's Laws of Motion",
//       },
//       {
//         "subject": "Chemistry",
//         "teacher": "Mrs. Anjali Verma",
//         "time": "7:45 PM - 9:15 PM",
//         "batch": "Batch B",
//         "status": "upcoming",
//         "participants": 0,
//         "topic": "Chemical Bonding",
//       },
//     ];

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: liveClasses.length,
//       itemBuilder: (context, index) {
//         final classData = liveClasses[index];
//         return LiveClassCard(
//           subject: classData["subject"] as String,
//           teacher: classData["teacher"] as String,
//           time: classData["time"] as String,
//           batch: classData["batch"] as String,
//           status: classData["status"] as String,
//           participants: classData["participants"] as int,
//           topic: classData["topic"] as String,
//         );
//       },
//     );
//   }
// }

// // Recorded Classes Tab
// class RecordedClassesTab extends StatefulWidget {
//   const RecordedClassesTab({super.key});

//   @override
//   State<RecordedClassesTab> createState() => _RecordedClassesTabState();
// }

// class _RecordedClassesTabState extends State<RecordedClassesTab> {
//   String selectedSubject = "All";
//   final List<String> subjects = [
//     "All",
//     "Mathematics",
//     "Physics",
//     "Chemistry",
//     "Biology",
//     "English"
//   ];

//   final List<Map<String, dynamic>> recordedClasses = [
//     {
//       "subject": "Mathematics",
//       "teacher": "Mr. Rajesh Kumar",
//       "date": "Oct 03, 2025",
//       "duration": "1h 30m",
//       "topic": "Trigonometry - Part 2",
//       "views": 128,
//       "thumbnail": "math",
//     },
//     {
//       "subject": "Physics",
//       "teacher": "Dr. Priya Sharma",
//       "date": "Oct 02, 2025",
//       "duration": "1h 45m",
//       "topic": "Electromagnetic Induction",
//       "views": 95,
//       "thumbnail": "physics",
//     },
//     {
//       "subject": "Chemistry",
//       "teacher": "Mrs. Anjali Verma",
//       "date": "Oct 01, 2025",
//       "duration": "1h 20m",
//       "topic": "Organic Chemistry Basics",
//       "views": 142,
//       "thumbnail": "chemistry",
//     },
//     {
//       "subject": "Biology",
//       "teacher": "Dr. Amit Patel",
//       "date": "Sep 30, 2025",
//       "duration": "1h 15m",
//       "topic": "Cell Division - Mitosis",
//       "views": 87,
//       "thumbnail": "biology",
//     },
//     {
//       "subject": "English",
//       "teacher": "Ms. Kavita Das",
//       "date": "Sep 29, 2025",
//       "duration": "1h 00m",
//       "topic": "Essay Writing Techniques",
//       "views": 63,
//       "thumbnail": "english",
//     },
//     {
//       "subject": "Mathematics",
//       "teacher": "Mr. Rajesh Kumar",
//       "date": "Sep 28, 2025",
//       "duration": "1h 25m",
//       "topic": "Calculus - Derivatives",
//       "views": 156,
//       "thumbnail": "math",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final filteredClasses = selectedSubject == "All"
//         ? recordedClasses
//         : recordedClasses
//             .where((cls) => cls["subject"] == selectedSubject)
//             .toList();

//     return Column(
//       children: [
//         // Subject Filter
//         Container(
//           height: 60,
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: subjects.length,
//             itemBuilder: (context, index) {
//               bool isSelected = selectedSubject == subjects[index];
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedSubject = subjects[index];
//                   });
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 12),
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0xFF2563EB)
//                         : Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       subjects[index],
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.grey.shade700,
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.w500,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         // Recorded Classes List
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: filteredClasses.length,
//             itemBuilder: (context, index) {
//               final classData = filteredClasses[index];
//               return RecordedClassCard(
//                 subject: classData["subject"] as String,
//                 teacher: classData["teacher"] as String,
//                 date: classData["date"] as String,
//                 duration: classData["duration"] as String,
//                 topic: classData["topic"] as String,
//                 views: classData["views"] as int,
//                 thumbnail: classData["thumbnail"] as String,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Live Class Card Widget
// class LiveClassCard extends StatelessWidget {
//   final String subject;
//   final String teacher;
//   final String time;
//   final String batch;
//   final String status;
//   final int participants;
//   final String topic;

//   const LiveClassCard({
//     super.key,
//     required this.subject,
//     required this.teacher,
//     required this.time,
//     required this.batch,
//     required this.status,
//     required this.participants,
//     required this.topic,
//   });

//   @override
//   Widget build(BuildContext context) {
//     bool isLive = status == "live";
//     Color subjectColor = _getSubjectColor(subject);

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
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         subject,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: subjectColor,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isLive
//                             ? Colors.red.shade50
//                             : Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: isLive ? Colors.red : Colors.orange,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             isLive ? "LIVE" : "UPCOMING",
//                             style: TextStyle(
//                               color: isLive ? Colors.red : Colors.orange,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   topic,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Icon(Icons.person_outline,
//                         size: 16, color: Colors.grey.shade600),
//                     const SizedBox(width: 6),
//                     Text(
//                       teacher,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.access_time,
//                         size: 16, color: Colors.grey.shade600),
//                     const SizedBox(width: 6),
//                     Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Icon(Icons.group_outlined,
//                         size: 16, color: Colors.grey.shade600),
//                     const SizedBox(width: 6),
//                     Text(
//                       batch,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (isLive) ...[
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.people,
//                           size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 6),
//                       Text(
//                         "$participants students watching",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isLive ? Colors.red : subjectColor,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: InkWell(
//               onTap: () {
//                 print("Join class: $subject");
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     isLive ? Icons.play_circle_filled : Icons.schedule,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     isLive ? "Join Now" : "Set Reminder",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
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
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
// }

// // Recorded Class Card Widget
// class RecordedClassCard extends StatelessWidget {
//   final String subject;
//   final String teacher;
//   final String date;
//   final String duration;
//   final String topic;
//   final int views;
//   final String thumbnail;

//   const RecordedClassCard({
//     super.key,
//     required this.subject,
//     required this.teacher,
//     required this.date,
//     required this.duration,
//     required this.topic,
//     required this.views,
//     required this.thumbnail,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Color subjectColor = _getSubjectColor(subject);

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
//       child: InkWell(
//         onTap: () {
//           print("Play recorded class: $topic");
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Column(
//           children: [
//             // Thumbnail
//             Container(
//               height: 180,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     subjectColor,
//                     subjectColor.withOpacity(0.7),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   Center(
//                     child: Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.play_arrow_rounded,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         duration,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Details
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     topic,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: subjectColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           subject,
//                           style: TextStyle(
//                             color: subjectColor,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Icon(Icons.person_outline,
//                           size: 16, color: Colors.grey.shade600),
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
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today,
//                               size: 14, color: Colors.grey.shade600),
//                           const SizedBox(width: 6),
//                           Text(
//                             date,
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.visibility,
//                               size: 14, color: Colors.grey.shade600),
//                           const SizedBox(width: 6),
//                           Text(
//                             "$views views",
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
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
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
// }
// features/student/class/class_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedSubject = 'All';
  String? _studentClassId;
  String? _className;

  List<String> _subjects = ['All'];
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() => _isLoading = true);

      // Get student data
      final studentDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _studentClassId = studentData['classId'];
          _className = studentData['className'] ?? 'Your Class';
        });

        await _loadSubjects();
        await _loadClasses();
      }
    } catch (e) {
      print('Error loading student data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubjects() async {
    try {
      Query query = _firestore.collection('recorded_classes');

      if (_studentClassId != null) {
        query = query.where('classId', isEqualTo: _studentClassId);
      }

      final querySnapshot = await query.get();

      final subjectSet = <String>{'All'};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data?['subject'] != null) {
          subjectSet.add(data!['subject']);
        }
      }

      setState(() {
        _subjects = subjectSet.toList()..sort();
      });
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  Future<void> _loadClasses() async {
    try {
      setState(() => _isLoading = true);

      Query query = _firestore.collection('recorded_classes');
      // .orderBy('createdAt', descending: true);

      // Filter by class if student is in a specific class
      if (_studentClassId != null) {
        query = query.where('classId', isEqualTo: _studentClassId);
      }

      // Apply subject filter
      if (_selectedSubject != null && _selectedSubject != 'All') {
        query = query.where('subject', isEqualTo: _selectedSubject);
      }

      final querySnapshot = await query.limit(100).get();

      setState(() {
        _classes = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...?data} as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      print('Error loading classes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredClasses() {
    List<Map<String, dynamic>> filtered = _classes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cls) {
        final title = (cls['title'] ?? '').toString().toLowerCase();
        final description = (cls['description'] ?? '').toString().toLowerCase();
        final subject = (cls['subject'] ?? '').toString().toLowerCase();
        final teacher = (cls['teacherName'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            description.contains(query) ||
            subject.contains(query) ||
            teacher.contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    final videoId = classData['videoId'] ?? '';
    final thumbnailUrl =
        classData['thumbnailUrl'] ??
        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    final isRecentlyAdded = _isRecentlyAdded(classData['createdAt']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentVideoPlayerScreen(classData: classData),
          ),
        ).then((_) {
          // Refresh when returning from video
          _loadClasses();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF4A90E2),
                              const Color(0xFF2962FF),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Play button overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF2962FF),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                // Status badges
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(classData['subject']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      classData['subject'] ?? 'General',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (isRecentlyAdded)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.new_releases,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Duration badge
                if (classData['duration'] != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        classData['duration'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Class details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData['title'] ?? 'Untitled Class',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Teacher info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(
                          0xFF2962FF,
                        ).withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: const Color(0xFF2962FF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData['teacherName'] ?? 'Teacher',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Teacher',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stats and date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(classData['createdAt']),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${classData['views'] ?? 0} views',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.thumb_up, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${classData['likes'] ?? 0}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  // Description preview
                  if (classData['description'] != null &&
                      classData['description'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          classData['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String? subject) {
    final colors = {
      'Mathematics': const Color(0xFF4CAF50),
      'Science': const Color(0xFF2196F3),
      'English': const Color(0xFF9C27B0),
      'History': const Color(0xFFFF9800),
      'Physics': const Color(0xFFF44336),
      'Chemistry': const Color(0xFF9C27B0),
      'Biology': const Color(0xFF4CAF50),
      'Geography': const Color(0xFFFF9800),
      'Computer Science': const Color(0xFF2196F3),
      'Economics': const Color(0xFF795548),
    };
    return colors[subject] ?? const Color(0xFF2962FF);
  }

  bool _isRecentlyAdded(dynamic timestamp) {
    if (timestamp == null) return false;
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(date);
      return difference.inDays < 7; // New if less than 7 days old
    } catch (e) {
      return false;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2962FF), Color(0xFF4A90E2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              if (_className != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _className!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recorded Classes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watch classes anytime, anywhere',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search classes...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectFilters() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final isSelected = _selectedSubject == subject;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubject = subject;
              });
              _loadClasses();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? _getSubjectColor(subject == 'All' ? null : subject)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? _getSubjectColor(subject == 'All' ? null : subject)
                      : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  subject,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No classes available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedSubject != 'All'
                ? 'No classes found for ${_selectedSubject}'
                : 'Your teacher hasn\'t uploaded any classes yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              // textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedSubject != 'All')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSubject = 'All';
                });
                _loadClasses();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
              ),
              child: const Text('Show all classes'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredClasses = _getFilteredClasses();

    return Scaffold(
      backgroundColor: const Color(0xFFf5f7fa),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2962FF)),
              ),
            )
          : Column(
              children: [
                // Header
                _buildHeader(),

                // Search Bar
                _buildSearchBar(),

                // Subject Filters
                _buildSubjectFilters(),

                const SizedBox(height: 8),

                // Results count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${filteredClasses.length} classes found',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: Text(
                            'Clear search',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF2962FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Classes List
                Expanded(
                  child: filteredClasses.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadClasses,
                          color: const Color(0xFF2962FF),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredClasses.length,
                            itemBuilder: (context, index) {
                              return _buildClassCard(filteredClasses[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// Student Video Player Screen
class StudentVideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const StudentVideoPlayerScreen({super.key, required this.classData});

  @override
  State<StudentVideoPlayerScreen> createState() =>
      _StudentVideoPlayerScreenState();
}

class _StudentVideoPlayerScreenState extends State<StudentVideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isLiked = false;
  int _likeCount = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _incrementViews();
    _loadLikeStatus();
  }

  void _initializePlayer() {
    String videoId = widget.classData['videoId'] ?? '';

    // Clean the video ID
    videoId = _cleanVideoId(videoId);

    // Try to extract from URL if needed
    if (videoId.isEmpty && widget.classData['youtubeUrl'] != null) {
      videoId = _extractVideoId(widget.classData['youtubeUrl']) ?? '';
    }

    if (videoId.isEmpty || videoId.length != 11) {
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        forceHD: false,
        loop: false,
      ),
    )..addListener(_listener);
  }

  String _cleanVideoId(String videoId) {
    if (videoId.isEmpty) return '';
    return videoId.split('?')[0].split('&')[0];
  }

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;

    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  Future<void> _incrementViews() async {
    try {
      final docId = widget.classData['id'];
      if (docId != null) {
        await _firestore.collection('recorded_classes').doc(docId).update({
          'views': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  Future<void> _loadLikeStatus() async {
    try {
      final user = _auth.currentUser;
      final docId = widget.classData['id'];

      if (user == null || docId == null) return;

      // Check if user has liked this video
      final likeDoc = await _firestore
          .collection('recorded_classes')
          .doc(docId)
          .collection('likes')
          .doc(user.uid)
          .get();

      setState(() {
        _isLiked = likeDoc.exists;
        _likeCount = widget.classData['likes'] ?? 0;
      });
    } catch (e) {
      print('Error loading like status: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final user = _auth.currentUser;
      final docId = widget.classData['id'];

      if (user == null || docId == null) return;

      final batch = _firestore.batch();
      final likeRef = _firestore
          .collection('recorded_classes')
          .doc(docId)
          .collection('likes')
          .doc(user.uid);

      if (_isLiked) {
        // Unlike
        batch.delete(likeRef);
        batch.update(_firestore.collection('recorded_classes').doc(docId), {
          'likes': FieldValue.increment(-1),
        });
        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        // Like
        batch.set(likeRef, {
          'userId': user.uid,
          'likedAt': FieldValue.serverTimestamp(),
        });
        batch.update(_firestore.collection('recorded_classes').doc(docId), {
          'likes': FieldValue.increment(1),
        });
        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have a valid video ID
    String videoId = widget.classData['videoId'] ?? '';
    videoId = _cleanVideoId(videoId);

    if (videoId.isEmpty && widget.classData['youtubeUrl'] != null) {
      videoId = _extractVideoId(widget.classData['youtubeUrl']) ?? '';
    }

    if (videoId.isEmpty || videoId.length != 11) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2962FF),
          title: const Text('Video Player'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Invalid Video',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Could not load video.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Video Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF2962FF),
            onReady: () {
              _isPlayerReady = true;
            },
            bottomActions: [
              CurrentPosition(),
              ProgressBar(isExpanded: true),
              RemainingDuration(),
              PlaybackSpeedButton(),
              FullScreenButton(),
            ],
          ),

          // Video Details
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and like button
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.classData['title'] ?? 'Untitled Class',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _toggleLike,
                            icon: Icon(
                              _isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: _isLiked
                                  ? const Color(0xFF2962FF)
                                  : Colors.grey,
                              size: 28,
                            ),
                          ),
                          Text(
                            _likeCount.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Subject and class badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getSubjectColor(
                                widget.classData['subject'],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.classData['subject'] ?? 'General',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (widget.classData['className'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.classData['className'],
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Teacher info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(
                              0xFF2962FF,
                            ).withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF2962FF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.classData['teacherName'] ?? 'Teacher',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Teacher',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.remove_red_eye,
                              'Views',
                              '${widget.classData['views'] ?? 0}',
                            ),
                            _buildStatItem(
                              Icons.thumb_up,
                              'Likes',
                              _likeCount.toString(),
                            ),
                            _buildStatItem(
                              Icons.access_time,
                              'Duration',
                              widget.classData['duration'] ?? 'N/A',
                            ),
                            _buildStatItem(
                              Icons.calendar_today,
                              'Uploaded',
                              _formatDate(widget.classData['createdAt']),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      if (widget.classData['description'] != null &&
                          widget.classData['description'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.classData['description'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String? subject) {
    final colors = {
      'Mathematics': const Color(0xFF4CAF50),
      'Science': const Color(0xFF2196F3),
      'English': const Color(0xFF9C27B0),
      'History': const Color(0xFFFF9800),
      'Physics': const Color(0xFFF44336),
      'Chemistry': const Color(0xFF9C27B0),
      'Biology': const Color(0xFF4CAF50),
      'Geography': const Color(0xFFFF9800),
      'Computer Science': const Color(0xFF2196F3),
      'Economics': const Color(0xFF795548),
    };
    return colors[subject] ?? const Color(0xFF2962FF);
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2962FF), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Recently';
    }
  }
}
