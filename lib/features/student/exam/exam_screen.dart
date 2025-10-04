import 'package:flutter/material.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

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
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
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
                // Handle Start Test action
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
                // Handle Start Test action
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
                225,
                207,
                230,
                57,
              ), // Custom color for ongoing
              icon: Icons.schedule,
              onPressed: () {
                // Handle Continue Test action
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
                // Handle View Results action
              },
            ),
            const SizedBox(height: 16),
            _buildCompletedTestCard(
              context: context,
              title: 'Biology Quiz',
              score: '15/20',
              progress: 0.75,
              onPressed: () {
                // Handle View Results action
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
                    color: const Color.from(
                      alpha: 1,
                      red: 0.071,
                      green: 0.447,
                      blue: 0.529,
                    ),
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
                onPressed: startAction,
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
              onPressed: onPressed,
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
