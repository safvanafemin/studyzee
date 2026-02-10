import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:studyzee/features/teacher/trexam/exam_submission_screen.dart';
import 'package:studyzee/features/teacher/trexam/upload_mcq_question.dart';

class TeacherExamsListScreen extends StatefulWidget {
  const TeacherExamsListScreen({super.key});

  @override
  State<TeacherExamsListScreen> createState() => _TeacherExamsListScreenState();
}

class _TeacherExamsListScreenState extends State<TeacherExamsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedFilter = 'all'; // all, upcoming

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateExamWithQuestionsScreen(),
                ),
              );
            },
          ),

          // PopupMenuButton<String>(
          //   onSelected: (value) {
          //     setState(() {
          //       _selectedFilter = value;
          //     });
          //   },
          //   itemBuilder: (context) => [
          //     const PopupMenuItem(value: 'all', child: Text('All Exams')),
          //     // const PopupMenuItem(value: 'upcoming', child: Text('Upcoming')),
          //   ],
          // ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getExamsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var exams =
              snapshot.data?.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList() ??
              [];

          // Filter exams based on selection
          if (_selectedFilter != 'all') {
            final now = DateTime.now();
            exams = exams.where((exam) {
              final scheduledAt = (exam['scheduledAt'] as Timestamp?)?.toDate();
              if (scheduledAt == null) return false;

              if (_selectedFilter == 'upcoming') {
                return scheduledAt.isAfter(now);
              }
              return true;
            }).toList();
          }

          if (exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'all'
                        ? 'No exams created yet'
                        : 'No $_selectedFilter exams found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedFilter == 'all' || _selectedFilter == 'upcoming')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateExamWithQuestionsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Your First Exam'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return _buildExamCard(exam);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getExamsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('exams')
        .where('teacherId', isEqualTo: user.uid)
        .orderBy('scheduledAt', descending: true)
        .snapshots();
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final scheduledAt = (exam['scheduledAt'] as Timestamp?)?.toDate();
    final dateStr = scheduledAt != null
        ? DateFormat('MMM d, yyyy hh:mm a').format(scheduledAt)
        : 'Date not set';

    String? rawStatus = exam['status']?.toString();
    final statusFromFirestore = rawStatus?.toLowerCase();

    bool isUpcoming =
        scheduledAt != null && scheduledAt.isAfter(DateTime.now());
    bool isCompleted =
        scheduledAt != null && scheduledAt.isBefore(DateTime.now());

    String statusText;
    String capitalize(String s) =>
        s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

    if (statusFromFirestore != null && statusFromFirestore.isNotEmpty) {
      if (statusFromFirestore == 'upcoming' ||
          statusFromFirestore == 'scheduled' ||
          statusFromFirestore == 'published') {
        isUpcoming = true;
        isCompleted = false;
      } else if (statusFromFirestore == 'completed' ||
          statusFromFirestore == 'done') {
        isCompleted = true;
        isUpcoming = false;
      } else if (statusFromFirestore == 'draft' ||
          statusFromFirestore == 'saved') {
        isUpcoming = false;
        isCompleted = false;
      }
      statusText = capitalize(statusFromFirestore);
    } else {
      statusText = isUpcoming
          ? 'Upcoming'
          : isCompleted
          ? 'Completed'
          : 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? Colors.blue.shade50
                        : isCompleted
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: isUpcoming
                        ? Colors.blue
                        : isCompleted
                        ? Colors.green
                        : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam['title'] ?? 'Untitled Exam',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exam['subject'] ?? 'Subject'} • ${exam['className'] ?? 'Class'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: isUpcoming
                //         ? Colors.blue.shade100
                //         : isCompleted
                //         ? Colors.green.shade100
                //         : Colors.grey.shade200,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     statusText,
                //     style: TextStyle(
                //       color: isUpcoming
                //           ? Colors.blue.shade800
                //           : isCompleted
                //           ? Colors.green.shade800
                //           : Colors.grey.shade800,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${exam['duration'] ?? 0} min',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${exam['totalQuestions'] ?? 0} Questions',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExamSubmissionsScreen(
                            examId: exam['id'],
                            examTitle: exam['title'] ?? 'Exam',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Submissions'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade600),
                      foregroundColor: Colors.blue.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _deleteExam(exam['id']);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteExam(String examId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('exams').doc(examId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exam deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting exam: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting exam: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
