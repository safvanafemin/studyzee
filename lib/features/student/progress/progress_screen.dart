import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  Map<String, dynamic> _studentData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        setState(() {
          _studentData = userDoc.data() ?? {};
        });
      }
    } catch (e) {
      print('Error loading student data: $e');
      _showError('Error loading data');
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
          'My Progress',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Academics'),
            Tab(text: 'Attendance'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAcademicsTab(),
                _buildAttendanceTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final studentName = _studentData['name'] ?? 'Student';
    final rollNumber = _studentData['rollNumber'] ?? 'N/A';
    final className = _studentData['className'] ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2962FF), Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    studentName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2962FF),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll No: $rollNumber',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Class: $className',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Performance Summary
          FutureBuilder<Map<String, dynamic>>(
            future: _getOverviewData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,  
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(
                        'Overall Score',
                        '${(data['avgScore'] ?? 0.0).toStringAsFixed(1)}%',
                        Colors.blue,
                        Icons.school,
                      ),
                      _buildStatCard(
                        'Attendance',
                        '${data['attendance'] ?? 0}%',
                        Colors.green,
                        Icons.check_circle,
                      ),
                      _buildStatCard(
                        'Assignments',
                        '${data['completedAssignments']}/${data['totalAssignments']}',
                        Colors.orange,
                        Icons.assignment,
                      ),
                      _buildStatCard(
                        'Rank',
                        '#${data['rank'] ?? '-'}',
                        Colors.purple,
                        Icons.emoji_events,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Performance Trend
                  const Text(
                    'Performance Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceTrendChart(data['trendData'] ?? []),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Performance
          const Text(
            'Subject Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getSubjectPerformance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final subjects = snapshot.data ?? [];

              if (subjects.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No subject data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: subjects.map((subject) {
                  return _buildSubjectCard(subject);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent Assignments
          const Text(
            'Recent Assignments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getRecentAssignments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final assignments = snapshot.data ?? [];

              if (assignments.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No assignments yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: assignments.map((assignment) {
                  return _buildAssignmentCard(assignment);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance Overview
          FutureBuilder<Map<String, dynamic>>(
            future: _getAttendanceOverview(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data ?? {};
              final attendancePercentage = data['percentage'] ?? 0.0;
              final present = data['present'] ?? 0;
              final absent = data['absent'] ?? 0;
              final leave = data['leave'] ?? 0;
              final total = data['total'] ?? 0;

              return Column(
                children: [
                  // Attendance Circle
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 180,
                                width: 180,
                                child: CircularProgressIndicator(
                                  value: attendancePercentage / 100,
                                  strokeWidth: 20,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    attendancePercentage >= 90
                                        ? Colors.green
                                        : attendancePercentage >= 75
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${attendancePercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Text(
                                    'Attendance',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAttendanceStat('Present', present, Colors.green),
                            _buildAttendanceStat('Absent', absent, Colors.red),
                            _buildAttendanceStat('Leave', leave, Colors.orange),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total Days: $total',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Attendance Records
                  const Text(
                    'Recent Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentAttendance(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getOverviewData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      // Get assignment performance
      final submissionsSnapshot = await _firestore
          .collection('assignment_submissions')
          .where('studentId', isEqualTo: user.uid)
          .get();

      int totalAssignments = submissionsSnapshot.docs.length;
      int completedAssignments = submissionsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'graded')
          .length;

      double totalScore = 0;
      int scoreCount = 0;
      List<Map<String, dynamic>> trendData = [];

      for (var subDoc in submissionsSnapshot.docs) {
        final subData = subDoc.data();
        if (subData['status'] == 'graded') {
          final marks = subData['marks'] ?? 0;
          final assignmentId = subData['assignmentId'];
          
          final assignmentDoc = await _firestore
              .collection('assignments')
              .doc(assignmentId)
              .get();

          if (assignmentDoc.exists) {
            final assignmentData = assignmentDoc.data();
            final totalMarks = assignmentData?['totalMarks'] ?? 100;
            if (totalMarks > 0) {
              final percentage = (marks / totalMarks) * 100;
              totalScore += percentage;
              scoreCount++;
              
              trendData.add({
                'date': subData['submittedAt'],
                'score': percentage,
              });
            }
          }
        }
      }

      // Sort trend data by date
      trendData.sort((a, b) {
        final aTime = a['date'] as Timestamp?;
        final bTime = b['date'] as Timestamp?;
        return (aTime?.compareTo(bTime ?? Timestamp.now()) ?? 0);
      });

      final avgScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

      // Get attendance
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final startDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

      final attendanceSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
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

      final attendance = totalDays > 0 ? ((presentCount / totalDays) * 100).round() : 0;

      // Calculate rank (simplified - compare with classmates)
      int rank = 1;
      if (_studentData['classId'] != null) {
        final classmatesSnapshot = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .where('classId', isEqualTo: _studentData['classId'])
            .get();

        for (var classmateDoc in classmatesSnapshot.docs) {
          if (classmateDoc.id == user.uid) continue;

          final classmateSubmissions = await _firestore
              .collection('assignment_submissions')
              .where('studentId', isEqualTo: classmateDoc.id)
              .where('status', isEqualTo: 'graded')
              .get();

          double classmateScore = 0;
          int classmateCount = 0;

          for (var subDoc in classmateSubmissions.docs) {
            final subData = subDoc.data();
            final marks = subData['marks'] ?? 0;
            final assignmentId = subData['assignmentId'];
            
            final assignmentDoc = await _firestore
                .collection('assignments')
                .doc(assignmentId)
                .get();

            if (assignmentDoc.exists) {
              final totalMarks = assignmentDoc.data()?['totalMarks'] ?? 100;
              if (totalMarks > 0) {
                classmateScore += (marks / totalMarks) * 100;
                classmateCount++;
              }
            }
          }

          final classmateAvg = classmateCount > 0 ? classmateScore / classmateCount : 0.0;
          if (classmateAvg > avgScore) {
            rank++;
          }
        }
      }

      return {
        'avgScore': avgScore,
        'attendance': attendance,
        'totalAssignments': totalAssignments,
        'completedAssignments': completedAssignments,
        'rank': rank,
        'trendData': trendData.take(10).toList(),
      };
    } catch (e) {
      print('Error getting overview data: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _getSubjectPerformance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final submissionsSnapshot = await _firestore
          .collection('assignment_submissions')
          .where('studentId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'graded')
          .get();

      Map<String, Map<String, dynamic>> subjectData = {};

      for (var subDoc in submissionsSnapshot.docs) {
        final subData = subDoc.data();
        final marks = subData['marks'] ?? 0;
        final assignmentId = subData['assignmentId'];
        
        final assignmentDoc = await _firestore
            .collection('assignments')
            .doc(assignmentId)
            .get();

        if (assignmentDoc.exists) {
          final assignmentData = assignmentDoc.data();
          final subject = assignmentData?['subject'] ?? 'General';
          final totalMarks = assignmentData?['totalMarks'] ?? 100;

          if (!subjectData.containsKey(subject)) {
            subjectData[subject] = {
              'subject': subject,
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

      List<Map<String, dynamic>> subjects = [];
      subjectData.forEach((subject, data) {
        final total = data['totalMarks'] as double;
        final possible = data['totalPossible'] as double;
        final count = data['count'] as int;

        if (possible > 0) {
          subjects.add({
            'subject': subject,
            'percentage': (total / possible) * 100,
            'assignments': count,
          });
        }
      });

      subjects.sort((a, b) =>
          (b['percentage'] as double).compareTo(a['percentage'] as double));

      return subjects;
    } catch (e) {
      print('Error getting subject performance: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentAssignments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final submissionsSnapshot = await _firestore
          .collection('assignment_submissions')
          .where('studentId', isEqualTo: user.uid)
          .orderBy('submittedAt', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> assignments = [];

      for (var subDoc in submissionsSnapshot.docs) {
        final subData = subDoc.data();
        final assignmentId = subData['assignmentId'];
        
        final assignmentDoc = await _firestore
            .collection('assignments')
            .doc(assignmentId)
            .get();

        if (assignmentDoc.exists) {
          final assignmentData = assignmentDoc.data();
          
          assignments.add({
            'title': assignmentData?['title'] ?? 'Assignment',
            'subject': assignmentData?['subject'] ?? 'General',
            'marks': subData['marks'] ?? 0,
            'totalMarks': assignmentData?['totalMarks'] ?? 100,
            'status': subData['status'] ?? 'pending',
            'submittedAt': subData['submittedAt'],
            'feedback': subData['feedback'] ?? '',
          });
        }
      }

      return assignments;
    } catch (e) {
      print('Error getting recent assignments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _getAttendanceOverview() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final attendanceSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('attendance')
          .get();

      int present = 0;
      int absent = 0;
      int leave = 0;
      int total = attendanceSnapshot.docs.length;

      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final status = data['status'];
        
        if (status == 'Present') {
          present++;
        } else if (status == 'Absent') {
          absent++;
        } else if (status == 'Leave') {
          leave++;
        }
      }

      final percentage = total > 0 ? (present / total) * 100 : 0.0;

      return {
        'present': present,
        'absent': absent,
        'leave': leave,
        'total': total,
        'percentage': percentage,
      };
    } catch (e) {
      print('Error getting attendance overview: $e');
      return {};
    }
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrendChart(List<Map<String, dynamic>> trendData) {
    if (trendData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No trend data available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: trendData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value['score'] as double,
                );
              }).toList(),
              isCurved: true,
              color: const Color(0xFF2962FF),
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF2962FF).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final percentage = subject['percentage'] as double;
    final color = percentage >= 85
        ? Colors.green
        : percentage >= 75
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject['subject'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${subject['assignments']} assignment(s)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final status = assignment['status'] as String;
    final marks = assignment['marks'] as int;
    final totalMarks = assignment['totalMarks'] as int;
    final percentage = totalMarks > 0 ? (marks / totalMarks) * 100 : 0.0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'graded') {
      statusColor = Colors.green;
      statusText = 'Graded';
      statusIcon = Icons.check_circle;
    } else if (status == 'submitted') {
      statusColor = Colors.orange;
      statusText = 'Under Review';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.grey;
      statusText = 'Pending';
      statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment['subject'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status == 'graded') ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $marks/$totalMarks',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 85
                        ? Colors.green
                        : percentage >= 75
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ],
            ),
            if (assignment['feedback'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.message, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        assignment['feedback'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 8),
          Text(
            'Submitted: ${_formatDate(assignment['submittedAt'])}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAttendance() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecentAttendanceRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No attendance records yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: records.map((record) {
            return _buildAttendanceRecordCard(record);
          }).toList(),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getRecentAttendanceRecords() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final attendanceSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('attendance')
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> records = [];

      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        records.add({
          'date': data['date'],
          'status': data['status'],
          'remarks': data['remarks'] ?? '',
        });
      }

      return records;
    } catch (e) {
      print('Error getting recent attendance: $e');
      return [];
    }
  }

  Widget _buildAttendanceRecordCard(Map<String, dynamic> record) {
    final status = record['status'] as String;
    Color statusColor;
    IconData statusIcon;

    if (status == 'Present') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'Absent') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.event_busy;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateString(record['date']),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (record['remarks'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record['remarks'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'N/A';
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('EEEE, MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}