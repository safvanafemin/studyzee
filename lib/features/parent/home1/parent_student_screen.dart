// features/parent/student_progress_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ParentStudentProgressScreen extends StatefulWidget {
  const ParentStudentProgressScreen({super.key});

  @override
  State<ParentStudentProgressScreen> createState() =>
      _ParentStudentProgressScreenState();
}

class _ParentStudentProgressScreenState
    extends State<ParentStudentProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;
  bool _isLoading = true;
  String _selectedView = 'overview'; // 'overview', 'attendance', 'assignments'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadParentChildren();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadParentChildren() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load parent document to get children list
      final parentDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (parentDoc.exists) {
        final parentData = parentDoc.data() as Map<String, dynamic>;
        final childrenIds = parentData['children'] as List<dynamic>? ?? [];

        for (var childId in childrenIds) {
          // Load child details
          final childDoc = await _firestore
              .collection('users')
              .doc(childId.toString())
              .get();

          if (childDoc.exists) {
            final childData = childDoc.data() as Map<String, dynamic>;
            _children.add({
              'id': childId,
              'name': childData['name'] ?? 'Unknown',
              'class': childData['className'] ?? 'Unknown',
              'rollNumber': childData['rollNumber'] ?? '',
              'classId': childData['classId'],
            });
          }
        }

        // Auto-select first child if available
        if (_children.isNotEmpty && _selectedChild == null) {
          _selectedChild = _children.first;
        }
      }
    } catch (e) {
      print('Error loading children: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _getChildProgress(String childId) async {
    try {
      // Get student details
      final studentDoc = await _firestore
          .collection('users')
          .doc(childId)
          .get();

      final studentData = studentDoc.data() as Map<String, dynamic>? ?? {};
      final className = studentData['className'] ?? 'Unknown';

      // Calculate attendance for last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final startDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

      final attendanceSnapshot = await _firestore
          .collection('users')
          .doc(childId)
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

      // Get graded assignments
      final submissionsSnapshot = await _firestore
          .collection('assignment_submissions')
          .where('studentId', isEqualTo: childId)
          .where('status', isEqualTo: 'graded')
          .get();

      double totalScore = 0;
      int scoreCount = 0;
      List<Map<String, dynamic>> recentAssignments = [];
      Map<String, List<double>> subjectScores = {};

      for (var subDoc in submissionsSnapshot.docs) {
        final subData = subDoc.data();
        final marks = subData['marks'] ?? 0;
        final assignmentId = subData['assignmentId'];
        final submittedAt = subData['submittedAt'] as Timestamp?;
        final feedback = subData['feedback'] ?? '';

        // Get assignment details
        final assignmentDoc = await _firestore
            .collection('assignments')
            .doc(assignmentId)
            .get();

        if (assignmentDoc.exists) {
          final assignmentData =
              assignmentDoc.data() as Map<String, dynamic>? ?? {};
          final subject = assignmentData['subject'] ?? 'General';
          final totalMarks = assignmentData['totalMarks'] ?? 100;
          final title = assignmentData['title'] ?? 'Assignment';

          // Calculate percentage
          final percentage = (marks / totalMarks) * 100;
          totalScore += percentage;
          scoreCount++;

          // Store subject scores for subject-wise breakdown
          if (!subjectScores.containsKey(subject)) {
            subjectScores[subject] = [];
          }
          subjectScores[subject]!.add(percentage);

          // Add to recent assignments (limit to 5)
          if (recentAssignments.length < 5) {
            recentAssignments.add({
              'title': title,
              'subject': subject,
              'marks': marks,
              'totalMarks': totalMarks,
              'percentage': percentage,
              'feedback': feedback,
              'date': submittedAt?.toDate(),
            });
          }
        }
      }

      // Calculate subject-wise averages
      List<Map<String, dynamic>> subjectPerformance = [];
      subjectScores.forEach((subject, scores) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        subjectPerformance.add({
          'name': subject,
          'score': avg,
          'color': _getSubjectColor(subject),
        });
      });

      // Sort by score descending
      subjectPerformance.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double),
      );

      // Calculate overall average
      final avgScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

      // Determine performance level
      String performance;
      Color performanceColor;
      if (avgScore >= 85) {
        performance = 'Excellent';
        performanceColor = Colors.green;
      } else if (avgScore >= 75) {
        performance = 'Good';
        performanceColor = Colors.orange;
      } else if (avgScore >= 60) {
        performance = 'Average';
        performanceColor = Colors.blue;
      } else {
        performance = 'Needs Improvement';
        performanceColor = Colors.red;
      }

      return {
        'name': studentData['name'] ?? 'Unknown',
        'className': className,
        'rollNumber': studentData['rollNumber'] ?? '',
        'avgScore': avgScore,
        'attendance': attendance,
        'performance': performance,
        'performanceColor': performanceColor,
        'subjectPerformance': subjectPerformance,
        'recentAssignments': recentAssignments,
        'totalAssignments': submissionsSnapshot.docs.length,
        'presentCount': presentCount,
        'totalDays': totalDays,
      };
    } catch (e) {
      print('Error getting child progress: $e');
      return {
        'name': 'Unknown',
        'className': 'Unknown',
        'rollNumber': '',
        'avgScore': 0.0,
        'attendance': 0,
        'performance': 'No Data',
        'performanceColor': Colors.grey,
        'subjectPerformance': [],
        'recentAssignments': [],
        'totalAssignments': 0,
        'presentCount': 0,
        'totalDays': 0,
      };
    }
  }

  Color _getSubjectColor(String subject) {
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
    return subjectColors[subject] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9ff),
      appBar: AppBar(
        title: const Text(
          'Student Progress',
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
            Tab(text: 'Performance Overview'),
            Tab(text: 'Detailed Report'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No children found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please contact your school administrator',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPerformanceOverviewTab(),
                _buildDetailedReportTab(),
              ],
            ),
    );
  }

  Widget _buildPerformanceOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Selection Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedChild,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _children.map((child) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: child,
                        child: Text(
                          child['name'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedChild = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_selectedChild != null)
            FutureBuilder<Map<String, dynamic>>(
              future: _getChildProgress(_selectedChild!['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading progress',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final progress = snapshot.data ?? {};
                return _buildProgressOverview(progress);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(Map<String, dynamic> progress) {
    final name = progress['name'] as String;
    final className = progress['className'] as String;
    final avgScore = progress['avgScore'] as double;
    final attendance = progress['attendance'] as int;
    final performance = progress['performance'] as String;
    final performanceColor = progress['performanceColor'] as Color;
    final subjectPerformance =
        progress['subjectPerformance'] as List<Map<String, dynamic>>;
    final recentAssignments =
        progress['recentAssignments'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[50],
                radius: 30,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(className, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: performanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        performance,
                        style: TextStyle(
                          fontSize: 12,
                          color: performanceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Overall Performance Card
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
                'Overall Performance',
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
                    'Average Score',
                    '${avgScore.toStringAsFixed(1)}%',
                    Colors.white,
                  ),
                  _buildStatBox('Attendance', '$attendance%', Colors.white),
                  _buildStatBox(
                    'Assignments',
                    '${progress['totalAssignments']}',
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

        // Recent Assignments
        if (recentAssignments.isNotEmpty) ...[
          const Text(
            'Recent Assignments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...recentAssignments.map((assignment) {
            return _buildAssignmentCard(assignment);
          }).toList(),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailedReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // View Type Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentedButton(
                    'Overview',
                    Icons.dashboard,
                    _selectedView == 'overview',
                    () {
                      setState(() {
                        _selectedView = 'overview';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildSegmentedButton(
                    'Attendance',
                    Icons.calendar_today,
                    _selectedView == 'attendance',
                    () {
                      setState(() {
                        _selectedView = 'attendance';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildSegmentedButton(
                    'Assignments',
                    Icons.assignment,
                    _selectedView == 'assignments',
                    () {
                      setState(() {
                        _selectedView = 'assignments';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_selectedChild != null)
            FutureBuilder<Map<String, dynamic>>(
              future: _getChildProgress(_selectedChild!['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final progress = snapshot.data ?? {};

                return _buildDetailedView(progress, _selectedView);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedView(Map<String, dynamic> progress, String viewType) {
    switch (viewType) {
      case 'attendance':
        return _buildAttendanceDetails(progress);
      case 'assignments':
        return _buildAssignmentsDetails(progress);
      default:
        return _buildOverviewDetails(progress);
    }
  }

  Widget _buildOverviewDetails(Map<String, dynamic> progress) {
    final avgScore = progress['avgScore'] as double;
    final attendance = progress['attendance'] as int;
    final presentCount = progress['presentCount'] as int;
    final totalDays = progress['totalDays'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Performance Trend
        Container(
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
            children: [
              const Text(
                'Performance Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Simplified trend visualization
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${avgScore.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Average Score'),
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$attendance%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Attendance'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Attendance Summary
        Container(
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
            children: [
              const Text(
                'Attendance Summary (Last 30 Days)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$presentCount',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('Days Present'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${totalDays - presentCount}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text('Days Absent'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$totalDays',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Total Days'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceDetails(Map<String, dynamic> progress) {
    // In a real app, you would fetch detailed attendance records here
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
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          // Sample attendance data - replace with actual data from Firestore
          ..._generateSampleAttendanceData().map((record) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(record['date'])),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: record['status'] == 'Present'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        record['status'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: record['status'] == 'Present'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(record['time'], textAlign: TextAlign.end),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAssignmentsDetails(Map<String, dynamic> progress) {
    final recentAssignments =
        progress['recentAssignments'] as List<Map<String, dynamic>>;

    if (recentAssignments.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No assignments found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentAssignments.map((assignment) {
        return _buildDetailedAssignmentCard(assignment);
      }).toList(),
    );
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

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final title = assignment['title'] as String;
    final subject = assignment['subject'] as String;
    final marks = assignment['marks'] as int;
    final totalMarks = assignment['totalMarks'] as int;
    final percentage = assignment['percentage'] as double;
    final feedback = assignment['feedback'] as String;
    final date = assignment['date'] as DateTime?;

    Color scoreColor;
    if (percentage >= 85) {
      scoreColor = Colors.green;
    } else if (percentage >= 75) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Score: $marks/$totalMarks',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Feedback: $feedback',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (date != null) ...[
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedAssignmentCard(Map<String, dynamic> assignment) {
    final title = assignment['title'] as String;
    final subject = assignment['subject'] as String;
    final marks = assignment['marks'] as int;
    final totalMarks = assignment['totalMarks'] as int;
    final percentage = assignment['percentage'] as double;
    final feedback = assignment['feedback'] as String;
    final date = assignment['date'] as DateTime?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 75 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marks Obtained',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '$marks',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Out of', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '$totalMarks',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Percentage', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teacher Feedback',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(feedback),
                ],
              ),
            ),
          ],
          if (date != null) ...[
            const SizedBox(height: 8),
            Text(
              'Submitted on: ${DateFormat('MMMM dd, yyyy').format(date)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentedButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateSampleAttendanceData() {
    return [
      {'date': 'Nov 15, 2023', 'status': 'Present', 'time': '8:30 AM'},
      {'date': 'Nov 14, 2023', 'status': 'Present', 'time': '8:45 AM'},
      {'date': 'Nov 13, 2023', 'status': 'Present', 'time': '8:35 AM'},
      {'date': 'Nov 12, 2023', 'status': 'Absent', 'time': '--'},
      {'date': 'Nov 11, 2023', 'status': 'Present', 'time': '8:40 AM'},
    ];
  }
}
