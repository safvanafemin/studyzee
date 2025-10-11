import 'package:flutter/material.dart';

// New placeholder widget for the exam page
class ExamStartPage extends StatelessWidget {
  final String examTitle;
  final String action; // 'Start' or 'Continue'

  const ExamStartPage({super.key, required this.examTitle, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$action: $examTitle'),
        backgroundColor: const Color(0xFF60a5fa),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 80, color: Color(0xFF60a5fa)),
            const SizedBox(height: 20),
            Text(
              'You are about to $action the test:',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              examTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1e3a8a)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would lead to the actual exam interface
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(action == 'Start' ? 'Begin Exam' : 'Resume Exam', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  // Helper method for navigation to the exam page
  void _navigateToExamPage(BuildContext context, String title, String action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamStartPage(examTitle: title, action: action),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Exams',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onSelected: (value) {
              if (value == 'results') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResultsPage(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'results',
                child: Row(
                  children: [
                    Icon(Icons.assessment, color: Color(0xFF60a5fa)),
                    SizedBox(width: 12),
                    Text('View All Results'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for Science Quiz
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Science Quiz - Chapter 1',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Upcoming Test Card (The main card)
            _buildUpcomingTestCard(
              context: context,
              title: 'Science Quiz - Chapter 1',
              subject: 'Science',
              date: 'May 10, 2024, 10:00 AM',
              duration: '30 mins',
              status: 'Upcoming',
              startAction: () {
                // Navigates to the ExamStartPage
                _navigateToExamPage(context, 'Science Quiz - Chapter 1', 'Start');
              },
            ),
            const SizedBox(height: 24),
            // Section Title
            const Text(
              'Upcoming Tests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // List of Upcoming Tests
            _buildTestCard(
              context: context,
              title: 'Math Test - Chapter 2',
              date: 'May 10, 2024, 03:00 PM',
              duration: '30 mins',
              status: 'Not started',
              buttonText: 'Start Test',
              buttonColor: const Color(0xFF60a5fa),
              icon: Icons.calendar_today,
              onPressed: () {
                // Navigates to the ExamStartPage
                _navigateToExamPage(context, 'Math Test - Chapter 2', 'Start');
              },
            ),
            const SizedBox(height: 16),
            // Section Title
            const Text(
              'Ongoing Tests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // List of Ongoing Tests
            _buildTestCard(
              context: context,
              title: 'English Test',
              date: '25:ae', // Placeholder for timer
              duration: '', // No duration needed for ongoing test
              status: '', // No status needed for ongoing test
              buttonText: 'Continue Test',
              buttonColor: const Color.fromARGB(
                255, // Changed 225 to 255 for solid color
                207,
                230,
                57,
              ), // Custom color for ongoing
              icon: Icons.schedule,
              onPressed: () {
                // Navigates to the ExamStartPage
                _navigateToExamPage(context, 'English Test', 'Continue');
              },
            ),
            const SizedBox(height: 16),
            // Section Title
            const Text(
              'Completed Tests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // List of Completed Tests
            _buildCompletedTestCard(
              context: context,
              title: 'History Test',
              score: '18/20',
              progress: 0.8,
              onPressed: () {
                // Handle View Results action - could navigate to a detailed results page
              },
            ),
            const SizedBox(height: 16),
            _buildCompletedTestCard(
              context: context,
              title: 'Biology Quiz',
              score: '15/20',
              progress: 0.75,
              onPressed: () {
                // Handle View Results action - could navigate to a detailed results page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTestCard({
    required BuildContext context,
    required String title,
    required String subject,
    required String date,
    required String duration,
    required String status,
    required VoidCallback startAction,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // FIX: Replaced invalid Color.from with a valid ARGB color
                    color: const Color(0xFF138EA5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subject,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 244, 244, 245),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              duration,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: startAction, // This now calls the navigation function
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60a5fa),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required BuildContext context,
    required String title,
    required String date,
    required String duration,
    required String status,
    required String buttonText,
    required Color buttonColor,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF60a5fa)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (date.isNotEmpty)
                    Text(
                      date,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  if (duration.isNotEmpty)
                    Text(
                      duration,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onPressed, // This now calls the navigation function
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTestCard({
    required BuildContext context,
    required String title,
    required String score,
    required double progress,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: Colors.green,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Results Page Widget (No changes needed here)
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      {
        'subject': 'Mathematics',
        'test': 'Mid-Term Exam',
        'score': '85/100',
        'percentage': 85.0,
        'grade': 'A',
        'date': 'Oct 01, 2025',
        'rank': '5th',
      },
      {
        'subject': 'Physics',
        'test': 'Chapter 3 Test',
        'score': '42/50',
        'percentage': 84.0,
        'grade': 'A',
        'date': 'Sep 28, 2025',
        'rank': '8th',
      },
      {
        'subject': 'Chemistry',
        'test': 'Unit Test',
        'score': '38/50',
        'percentage': 76.0,
        'grade': 'B+',
        'date': 'Sep 25, 2025',
        'rank': '12th',
      },
      {
        'subject': 'Biology',
        'test': 'Quiz',
        'score': '18/20',
        'percentage': 90.0,
        'grade': 'A+',
        'date': 'Sep 22, 2025',
        'rank': '2nd',
      },
      {
        'subject': 'English',
        'test': 'Grammar Test',
        'score': '28/30',
        'percentage': 93.0,
        'grade': 'A+',
        'date': 'Sep 20, 2025',
        'rank': '1st',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF60a5fa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall Performance Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF60a5fa), Color(0xFF3b82f6)],
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Average', '85.6%', Icons.trending_up),
                      _buildStatCard('Tests', '5', Icons.quiz),
                      _buildStatCard('Rank', '6th', Icons.emoji_events),
                    ],
                  ),
                ],
              ),
            ),

            // Results List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return _buildResultCard(
                  result['subject'] as String,
                  result['test'] as String,
                  result['score'] as String,
                  result['percentage'] as double,
                  result['grade'] as String,
                  result['date'] as String,
                  result['rank'] as String,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String subject,
    String test,
    String score,
    double percentage,
    String grade,
    String date,
    String rank,
  ) {
    Color gradeColor = _getGradeColor(grade);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        test,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Percentage',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rank',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rank,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return const Color(0xFF10B981);
      case 'A':
        return const Color(0xFF3B82F6);
      case 'B+':
        return const Color(0xFFF59E0B);
      case 'B':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}