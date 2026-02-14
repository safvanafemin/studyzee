import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ExamSubmissionsScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const ExamSubmissionsScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ExamSubmissionsScreen> createState() => _ExamSubmissionsScreenState();
}

class _ExamSubmissionsScreenState extends State<ExamSubmissionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _examDetails;
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExamData();
  }

  Future<void> _loadExamData() async {
    try {
      // Load exam details
      final examDoc = await _firestore
          .collection('exams')
          .doc(widget.examId)
          .get();

      if (examDoc.exists) {
        setState(() {
          _examDetails = examDoc.data();
        });
      }

      // Load submissions
      final submissionsSnapshot = await _firestore
          .collection('exam_submissions')
          .where('examId', isEqualTo: widget.examId)
          .get();

      setState(() {
        _submissions = submissionsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exam data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submissions - ${widget.examTitle}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No submissions yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Exam Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Submissions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            '${_submissions.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Average Score',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            '${_calculateAverageScore()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Submissions List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _submissions.length,
                    itemBuilder: (context, index) {
                      return _buildSubmissionCard(_submissions[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  double _calculateAverageScore() {
    if (_submissions.isEmpty) return 0;

    double totalScore = 0;
    for (final submission in _submissions) {
      final score = submission['score'] ?? 0;
      final totalQuestions = submission['totalQuestions'] ?? 1;
      totalScore += (score / totalQuestions * 100);
    }

    return (totalScore / _submissions.length).roundToDouble();
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final submittedAt = (submission['submittedAt'] as Timestamp?)?.toDate();
    final dateStr = submittedAt != null
        ? DateFormat('MMM d, hh:mm a').format(submittedAt)
        : 'Unknown date';

    final score = submission['score'] ?? 0;
    final totalQuestions = submission['totalQuestions'] ?? 1;
    final percentage = (score / totalQuestions * 100).round();
    final isPassed = percentage >= 40;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    submission['studentName'] ?? 'Unknown Student',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isPassed
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted: $dateStr',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / totalQuestions,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$score/$totalQuestions',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewSubmissionDetails(submission);
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Download submission or view full details
                      _viewFullSubmission(submission);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                    ),
                    child: const Text('Full Review'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewSubmissionDetails(Map<String, dynamic> submission) {
    final score = submission['score'] ?? 0;
    final totalQuestions = submission['totalQuestions'] ?? 1;
    final percentage = (score / totalQuestions * 100).round();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${submission['studentName']}\'s Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: $score/$totalQuestions'),
            Text('Percentage: $percentage%'),
            Text('Status: ${percentage >= 40 ? 'Passed' : 'Failed'}'),
            const SizedBox(height: 16),
            if (_examDetails != null && _examDetails!['questions'] != null)
              ...List.generate(totalQuestions, (index) {
                final studentAnswer = submission['answers'][index.toString()];
                final correctAnswer =
                    _examDetails!['questions'][index]['correctAnswer'];
                final isCorrect = studentAnswer == correctAnswer;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Q${index + 1}: ${isCorrect ? 'Correct' : 'Incorrect'}',
                  ),
                  subtitle: Text(
                    'Student: $studentAnswer | Correct: $correctAnswer',
                  ),
                );
              }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewFullSubmission(Map<String, dynamic> submission) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullSubmissionReviewScreen(
          exam: _examDetails!,
          submission: submission,
        ),
      ),
    );
  }
}

// Optional: Detailed submission review screen
class FullSubmissionReviewScreen extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Map<String, dynamic> submission;

  const FullSubmissionReviewScreen({
    super.key,
    required this.exam,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final questions = List<Map<String, dynamic>>.from(exam['questions'] ?? []);
    final answers = submission['answers'] ?? {};
    final score = submission['score'] ?? 0;
    final totalQuestions = questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Submission Review - ${submission['studentName']}'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final studentAnswer = answers[index.toString()];
          final correctAnswer = question['correctAnswer'];
          final isCorrect = studentAnswer == correctAnswer;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}: ${question['question']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...['A', 'B', 'C', 'D'].map((option) {
                    final isStudentAnswer = studentAnswer == option;
                    final isCorrectOption = correctAnswer == option;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrectOption
                            ? Colors.green.shade100
                            : isStudentAnswer
                            ? Colors.red.shade100
                            : Colors.white,
                        border: Border.all(
                          color: isCorrectOption
                              ? Colors.green
                              : isStudentAnswer
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$option.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCorrectOption
                                  ? Colors.green.shade800
                                  : isStudentAnswer
                                  ? Colors.red.shade800
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question['option$option'] ?? '',
                              style: TextStyle(
                                color: isCorrectOption
                                    ? Colors.green.shade800
                                    : isStudentAnswer
                                    ? Colors.red.shade800
                                    : Colors.black87,
                                fontWeight: isCorrectOption || isStudentAnswer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCorrectOption)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (isStudentAnswer && !isCorrectOption)
                            const Icon(Icons.close, color: Colors.red),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    'Student Answer: $studentAnswer',
                    style: TextStyle(
                      color: isCorrect
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Correct Answer: $correctAnswer',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score: $score/$totalQuestions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${(score / totalQuestions * 100).round()}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
