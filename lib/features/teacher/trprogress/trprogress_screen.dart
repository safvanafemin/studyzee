import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TrprogressScreen extends StatefulWidget {
  const TrprogressScreen({super.key});

  @override
  State<TrprogressScreen> createState() => _TeacherProgressScreenState();
}

class _TeacherProgressScreenState extends State<TrprogressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedClassId;
  String? _selectedClassName;
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
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
          };
        }).toList();

        // Auto-select first class if available
        if (_classes.isNotEmpty && _selectedClassId == null) {
          _selectedClassId = _classes.first['id'];
          final section = _classes.first['section'];
          _selectedClassName = section.isNotEmpty
              ? '${_classes.first['name']} - ${_classes.first['section']}'
              : _classes.first['name'];
        }
      });
    } catch (e) {
      print('Error loading classes: $e');
      _showError('Error loading classes');
    } finally {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9ff),
      appBar: AppBar(
        title: const Text(
          'Student Progress Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue.shade600,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Class Analytics'),
            Tab(text: 'Individual Student'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildClassAnalyticsTab(),
                _buildIndividualStudentTab(),
              ],
            ),
    );
  }

  Widget _buildClassAnalyticsTab() {
    if (_classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No classes found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add classes to view analytics',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Selection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.class_, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedClassId,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _classes.map((classData) {
                      final displayName = classData['section'].isNotEmpty
                          ? '${classData['name']} - ${classData['section']}'
                          : classData['name'];
                      return DropdownMenuItem<String>(
                        value: classData['id'],
                        child: Text(displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                        final selectedClass = _classes.firstWhere(
                          (c) => c['id'] == value,
                        );
                        final section = selectedClass['section'];
                        _selectedClassName = section.isNotEmpty
                            ? '${selectedClass['name']} - ${selectedClass['section']}'
                            : selectedClass['name'];
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Load class analytics data
          if (_selectedClassId != null)
            FutureBuilder<Map<String, dynamic>>(
              future: _getClassAnalytics(_selectedClassId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final analytics = snapshot.data ?? {};
                return _buildAnalyticsContent(analytics);
              },
            ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getClassAnalytics(String classId) async {
    try {
      // Get all students in the class
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('classId', isEqualTo: classId)
          .get();

      final totalStudents = studentsSnapshot.docs.length;

      if (totalStudents == 0) {
        return {
          'totalStudents': 0,
          'avgScore': 0.0,
          'passingRate': 0.0,
          'avgAttendance': 0.0,
          'assignmentRate': 0.0,
          'subjectPerformance': <Map<String, dynamic>>[],
        };
      }

      // Calculate attendance
      double totalAttendance = 0;
      int attendanceCount = 0;

      // Get recent attendance records (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final startDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

      final attendanceSnapshot = await _firestore
          .collection('Attendance')
          .doc(classId)
          .collection('daily_records')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .get();

      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final present = data['present'] ?? 0;
        final total = data['totalStudents'] ?? 0;
        if (total > 0) {
          totalAttendance += (present / total) * 100;
          attendanceCount++;
        }
      }

      final avgAttendance = attendanceCount > 0
          ? totalAttendance / attendanceCount
          : 0.0;

      // Calculate assignment submission rate
      final assignmentsSnapshot = await _firestore
          .collection('assignments')
          .where('classId', isEqualTo: classId)
          .get();

      double totalSubmissionRate = 0;
      int assignmentCount = 0;

      for (var assignmentDoc in assignmentsSnapshot.docs) {
        final submissionsSnapshot = await _firestore
            .collection('assignment_submissions')
            .where('assignmentId', isEqualTo: assignmentDoc.id)
            .get();

        final submissions = submissionsSnapshot.docs.length;
        if (totalStudents > 0) {
          totalSubmissionRate += (submissions / totalStudents) * 100;
          assignmentCount++;
        }
      }

      final avgAssignmentRate = assignmentCount > 0
          ? totalSubmissionRate / assignmentCount
          : 0.0;

      // Get subject performance from assignments
      Map<String, Map<String, dynamic>> subjectData = {};

      for (var assignmentDoc in assignmentsSnapshot.docs) {
        final assignmentData = assignmentDoc.data();
        final subject = assignmentData['subject'] ?? 'General';
        final totalMarks = assignmentData['totalMarks'] ?? 100;

        final submissionsSnapshot = await _firestore
            .collection('assignment_submissions')
            .where('assignmentId', isEqualTo: assignmentDoc.id)
            .where('status', isEqualTo: 'graded')
            .get();

        for (var subDoc in submissionsSnapshot.docs) {
          final subData = subDoc.data();
          final marks = subData['marks'] ?? 0;

          if (!subjectData.containsKey(subject)) {
            subjectData[subject] = {
              'totalMarks': 0.0,
              'totalPossible': 0.0,
              'count': 0,
            };
          }

          subjectData[subject]!['totalMarks'] =
              (subjectData[subject]!['totalMarks'] ?? 0.0) + marks;
          subjectData[subject]!['totalPossible'] =
              (subjectData[subject]!['totalPossible'] ?? 0.0) + totalMarks;
          subjectData[subject]!['count'] =
              (subjectData[subject]!['count'] ?? 0) + 1;
        }
      }

      // Calculate subject averages
      List<Map<String, dynamic>> subjectPerformance = [];
      double totalScore = 0;
      int scoreCount = 0;

      final subjectColors = {
        'Mathematics': Colors.blue,
        'Science': Colors.green,
        'English': Colors.orange,
        'History': Colors.red,
        'Physics': Colors.purple,
        'Chemistry': Colors.teal,
        'Biology': Colors.lightGreen,
        'Geography': Colors.brown,
        'Computer Science': Colors.indigo,
        'Economics': Colors.amber,
      };

      subjectData.forEach((subject, data) {
        final total = data['totalMarks'] as double;
        final possible = data['totalPossible'] as double;
        final count = data['count'] as int;

        if (possible > 0) {
          final percentage = (total / possible) * 100;
          subjectPerformance.add({
            'name': subject,
            'score': percentage,
            'color': subjectColors[subject] ?? Colors.grey,
          });
          totalScore += percentage;
          scoreCount++;
        }
      });

      final avgScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;
      final passingRate = avgScore >= 40 ? 95.0 : (avgScore / 40 * 95);

      return {
        'totalStudents': totalStudents,
        'avgScore': avgScore,
        'passingRate': passingRate,
        'avgAttendance': avgAttendance,
        'assignmentRate': avgAssignmentRate,
        'subjectPerformance': subjectPerformance,
      };
    } catch (e) {
      print('Error getting class analytics: $e');
      return {
        'totalStudents': 0,
        'avgScore': 0.0,
        'passingRate': 0.0,
        'avgAttendance': 0.0,
        'assignmentRate': 0.0,
        'subjectPerformance': <Map<String, dynamic>>[],
      };
    }
  }

  Widget _buildAnalyticsContent(Map<String, dynamic> analytics) {
    final totalStudents = analytics['totalStudents'] ?? 0;
    final avgScore = analytics['avgScore'] ?? 0.0;
    final passingRate = analytics['passingRate'] ?? 0.0;
    final avgAttendance = analytics['avgAttendance'] ?? 0.0;
    final assignmentRate = analytics['assignmentRate'] ?? 0.0;
    final subjectPerformance =
        analytics['subjectPerformance'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Statistics Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Class Performance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBox(
                    'Total Students',
                    totalStudents.toString(),
                    Colors.white,
                  ),
                  _buildStatBox(
                    'Avg Score',
                    '${avgScore.toStringAsFixed(1)}%',
                    Colors.white,
                  ),
                  _buildStatBox(
                    'Passing Rate',
                    '${passingRate.toStringAsFixed(1)}%',
                    Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Subject-wise Performance
        if (subjectPerformance.isNotEmpty) ...[
          const Text(
            'Subject-wise Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubjectPerformanceChart(subjectPerformance),
          const SizedBox(height: 24),
        ],

        // Class Performance Metrics
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Attendance',
                '${avgAttendance.toStringAsFixed(1)}%',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Assignment Rate',
                '${assignmentRate.toStringAsFixed(1)}%',
                Colors.blue,
                Icons.assignment,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Test Avg',
                '${avgScore.toStringAsFixed(1)}%',
                Colors.orange,
                Icons.assessment,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Participation',
                '${((avgAttendance + assignmentRate) / 2).toStringAsFixed(1)}%',
                Colors.purple,
                Icons.people,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndividualStudentTab() {
    if (_selectedClassId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Select a class to view students',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getStudentProgress(_selectedClassId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No students found in this class',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _buildStudentCard(
              name: student['name'] as String,
              avgScore: student['avgScore'] as double,
              attendance: student['attendance'] as int,
              trend: student['trend'] as String,
              performance: student['performance'] as String,
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getStudentProgress(String classId) async {
    try {
      // Get all students in the class
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('classId', isEqualTo: classId)
          .get();

      List<Map<String, dynamic>> studentProgress = [];

      for (var studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final studentId = studentDoc.id;
        final name = studentData['name'] ?? 'Unknown';

        // Calculate attendance
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final startDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

        final attendanceSnapshot = await _firestore
            .collection('users')
            .doc(studentId)
            .collection('attendance')
            .where('date', isGreaterThanOrEqualTo: startDate)
            .get();

        int presentCount = 0;
        int totalDays = attendanceSnapshot.docs.length;

        for (var doc in attendanceSnapshot.docs) {
          final data = doc.data();
          if (data['status'] == 'Present') {
            presentCount++;
          }
        }

        final attendance = totalDays > 0
            ? ((presentCount / totalDays) * 100).round()
            : 0;

        // Calculate average score from graded assignments
        final submissionsSnapshot = await _firestore
            .collection('assignment_submissions')
            .where('studentId', isEqualTo: studentId)
            .where('status', isEqualTo: 'graded')
            .get();

        double totalScore = 0;
        int scoreCount = 0;

        for (var subDoc in submissionsSnapshot.docs) {
          final subData = subDoc.data();
          final marks = subData['marks'] ?? 0;

          // Get assignment total marks
          final assignmentId = subData['assignmentId'];
          final assignmentDoc = await _firestore
              .collection('assignments')
              .doc(assignmentId)
              .get();

          if (assignmentDoc.exists) {
            final assignmentData = assignmentDoc.data();
            final totalMarks = assignmentData?['totalMarks'] ?? 100;
            if (totalMarks > 0) {
              totalScore += (marks / totalMarks) * 100;
              scoreCount++;
            }
          }
        }

        final avgScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

        // Determine trend (comparing recent vs older performance)
        String trend = 'flat';
        if (scoreCount >= 2) {
          // Compare last assignment to average
          final recentSubmissions = submissionsSnapshot.docs
            ..sort((a, b) {
              final aTime = a.data()['submittedAt'] as Timestamp?;
              final bTime = b.data()['submittedAt'] as Timestamp?;
              return (bTime?.compareTo(aTime ?? Timestamp.now()) ?? 0);
            });

          if (recentSubmissions.isNotEmpty) {
            final recentData = recentSubmissions.first.data();
            final recentMarks = recentData['marks'] ?? 0;
            final assignmentDoc = await _firestore
                .collection('assignments')
                .doc(recentData['assignmentId'])
                .get();

            if (assignmentDoc.exists) {
              final totalMarks = assignmentDoc.data()?['totalMarks'] ?? 100;
              final recentPercentage = (recentMarks / totalMarks) * 100;

              if (recentPercentage > avgScore + 5) {
                trend = 'up';
              } else if (recentPercentage < avgScore - 5) {
                trend = 'down';
              }
            }
          }
        }

        // Determine performance level
        String performance;
        if (avgScore >= 85) {
          performance = 'Excellent';
        } else if (avgScore >= 75) {
          performance = 'Good';
        } else if (avgScore >= 60) {
          performance = 'Average';
        } else {
          performance = 'Needs Improvement';
        }

        studentProgress.add({
          'name': name,
          'avgScore': avgScore,
          'attendance': attendance,
          'trend': trend,
          'performance': performance,
        });
      }

      // Sort by average score (descending)
      studentProgress.sort(
        (a, b) => (b['avgScore'] as double).compareTo(a['avgScore'] as double),
      );

      return studentProgress;
    } catch (e) {
      print('Error getting student progress: $e');
      return [];
    }
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformanceChart(List<Map<String, dynamic>> subjects) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subjects.map((subject) {
          final score = subject['score'] as double;
          final color = subject['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard({
    required String name,
    required double avgScore,
    required int attendance,
    required String trend,
    required String performance,
  }) {
    Color performanceColor;
    if (avgScore >= 85) {
      performanceColor = Colors.green;
    } else if (avgScore >= 75) {
      performanceColor = Colors.orange;
    } else {
      performanceColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      performance,
                      style: TextStyle(
                        fontSize: 12,
                        color: performanceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${avgScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: performanceColor,
                    ),
                  ),
                  Icon(
                    trend == 'up'
                        ? Icons.trending_up
                        : trend == 'down'
                        ? Icons.trending_down
                        : Icons.trending_flat,
                    color: trend == 'up'
                        ? Colors.green
                        : trend == 'down'
                        ? Colors.red
                        : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$attendance%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: attendance / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    attendance >= 90 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
