// features/student/assignment_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:studyzee/helper/image_uploader.dart';

class StudentAssignmentScreen extends StatefulWidget {
  const StudentAssignmentScreen({super.key});

  @override
  State<StudentAssignmentScreen> createState() =>
      _StudentAssignmentScreenState();
}

class _StudentAssignmentScreenState extends State<StudentAssignmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryUploader _cloudinaryUploader = CloudinaryUploader();

  String? _studentId;
  String? _studentName;
  String? _rollNumber;
  String? _classId;
  String? _className;

  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _submittedAssignments = [];
  Map<String, Map<String, dynamic>> _assignmentSubmissions = {};

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _filter = 'all'; // 'all', 'pending', 'submitted', 'graded'
  String _viewMode = 'list'; // 'list', 'grid'

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

      // Get student document
      final studentDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _studentId = studentDoc.id;
          _studentName = studentData['name'] ?? 'Student';
          _rollNumber = studentData['rollNumber']?.toString() ?? 'N/A';
          _classId = studentData['classId'];
          _className = studentData['className'] ?? 'Unknown Class';
        });

        await _loadAssignments();
        await _loadSubmissions();
      }
    } catch (e) {
      print('Error loading student data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAssignments() async {
    if (_classId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('assignments')
          .where('classId', isEqualTo: _classId)
          .where('status', isEqualTo: 'active')
          // .orderBy('dueDate', descending: false)
          .get();

      setState(() {
        _assignments = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? 'No Title',
            'description': data['description'] ?? '',
            'subject': data['subject'] ?? 'General',
            'dueDate': data['dueDate'],
            'totalMarks': data['totalMarks'] ?? 100,
            'teacherName': data['teacherName'] ?? 'Teacher',
            'fileUrl': data['fileUrl'] ?? '',
            'fileName': data['fileName'] ?? '',
            'createdAt': data['createdAt'],
            'status': 'pending', // Default status
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading assignments: $e');
    }
  }

  Future<void> _loadSubmissions() async {
    if (_studentId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('assignment_submissions')
          .where('studentId', isEqualTo: _studentId)
          .get();

      // Create a map of assignmentId -> submission
      final submissionsMap = <String, Map<String, dynamic>>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        submissionsMap[data['assignmentId']] = {
          'id': doc.id,
          'status': data['status'] ?? 'pending',
          'submittedAt': data['submittedAt'],
          'fileUrl': data['fileUrl'] ?? '',
          'fileName': data['fileName'] ?? '',
          'marks': data['marks'] ?? 0,
          'feedback': data['feedback'] ?? '',
          'gradedAt': data['gradedAt'],
        };
      }

      setState(() {
        _assignmentSubmissions = submissionsMap;
      });

      // Update assignment statuses based on submissions
      _updateAssignmentStatuses();
    } catch (e) {
      print('Error loading submissions: $e');
    }
  }

  void _updateAssignmentStatuses() {
    for (var assignment in _assignments) {
      final submission = _assignmentSubmissions[assignment['id']];
      if (submission != null) {
        assignment['status'] = submission['status'];
        assignment['submission'] = submission;
      } else {
        // Check if assignment is overdue
        final dueDate = (assignment['dueDate'] as Timestamp).toDate();
        if (DateTime.now().isAfter(dueDate)) {
          assignment['status'] = 'overdue';
        } else {
          assignment['status'] = 'pending';
        }
      }
    }
    setState(() {});
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final dueDate = (assignment['dueDate'] as Timestamp).toDate();
    final isOverdue = DateTime.now().isAfter(dueDate);
    final status = assignment['status'] as String;
    final submission = assignment['submission'] as Map<String, dynamic>?;

    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);
    String statusText = _getStatusText(status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue && status != 'graded'
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewAssignmentDetails(assignment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(assignment['subject']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSubjectShort(assignment['subject']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isOverdue && status != 'graded')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, size: 12, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'OVERDUE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                assignment['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Subject: ${assignment['subject']}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM d, yyyy hh:mm a').format(dueDate)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (submission != null && submission['marks'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        '${submission['marks']}/${assignment['totalMarks']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (status == 'pending' || status == 'overdue')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _submitAssignment(assignment),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Submit Assignment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOverdue ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedAssignmentCard(Map<String, dynamic> assignment) {
    final submission = assignment['submission'] as Map<String, dynamic>?;
    final status = assignment['status'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSubjectColor(assignment['subject']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getSubjectShort(assignment['subject']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              assignment['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (submission != null) ...[
              _buildSubmissionInfo(submission),
              if (submission['feedback'] != null &&
                  submission['feedback'].isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Teacher Feedback:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(submission['feedback']),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionInfo(Map<String, dynamic> submission) {
    final submittedAt = (submission['submittedAt'] as Timestamp?)?.toDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'Submitted: ${submittedAt != null ? DateFormat('MMM d, yyyy hh:mm a').format(submittedAt) : 'N/A'}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (submission['fileUrl'] != null && submission['fileUrl'].isNotEmpty)
          GestureDetector(
            onTap: () =>
                _viewFile(submission['fileUrl'], submission['fileName']),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(submission['fileName']),
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission['fileName'] ?? 'Submission',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Tap to view',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.visibility, color: Colors.blue),
                ],
              ),
            ),
          ),
        if (submission['marks'] != null && submission['marks'] > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.grade, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marks Obtained',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${submission['marks']} / 100',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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
                    color: _calculateGradeColor(submission['marks']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _calculateGrade(submission['marks']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'graded':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'graded':
        return Icons.check_circle;
      case 'submitted':
        return Icons.cloud_upload;
      case 'pending':
        return Icons.pending;
      case 'overdue':
        return Icons.warning;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'graded':
        return 'Graded';
      case 'submitted':
        return 'Submitted - Awaiting grade';
      case 'pending':
        return 'Not Submitted';
      case 'overdue':
        return 'Overdue - Not Submitted';
      case 'rejected':
        return 'Rejected - Resubmit';
      default:
        return 'Unknown';
    }
  }

  Color _getSubjectColor(String subject) {
    final colors = {
      'Mathematics': Colors.deepPurple,
      'Science': Colors.green,
      'English': Colors.blue,
      'History': Colors.orange,
      'Physics': Colors.deepOrange,
      'Chemistry': Colors.purple,
      'Biology': Colors.lightGreen,
      'Geography': Colors.brown,
      'Computer Science': Colors.cyan,
      'Economics': Colors.teal,
    };
    return colors[subject] ?? Colors.grey;
  }

  String _getSubjectShort(String subject) {
    return subject.split(' ').map((word) => word[0]).join().toUpperCase();
  }

  IconData _getFileIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file;

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_fields;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _calculateGrade(int marks) {
    if (marks >= 90) return 'A+';
    if (marks >= 80) return 'A';
    if (marks >= 70) return 'B+';
    if (marks >= 60) return 'B';
    if (marks >= 50) return 'C';
    if (marks >= 40) return 'D';
    return 'F';
  }

  Color _calculateGradeColor(int marks) {
    if (marks >= 90) return Colors.green;
    if (marks >= 80) return Colors.lightGreen;
    if (marks >= 70) return Colors.yellow[700]!;
    if (marks >= 60) return Colors.orange;
    if (marks >= 50) return Colors.deepOrange;
    return Colors.red;
  }

  void _viewAssignmentDetails(Map<String, dynamic> assignment) {
    final dueDate = (assignment['dueDate'] as Timestamp).toDate();
    final isOverdue = DateTime.now().isAfter(dueDate);
    final submission = assignment['submission'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assignment['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getSubjectColor(assignment['subject']),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  assignment['subject'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Teacher:', assignment['teacherName']),
              _buildDetailRow(
                'Due Date:',
                DateFormat('EEEE, MMMM d, yyyy hh:mm a').format(dueDate),
              ),
              _buildDetailRow('Total Marks:', '${assignment['totalMarks']}'),

              if (isOverdue && assignment['status'] == 'overdue')
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This assignment is overdue. Late submissions may affect your grade.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              if (assignment['description'] != null &&
                  assignment['description'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(assignment['description']),
              ],

              if (assignment['fileUrl'] != null &&
                  assignment['fileUrl'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Attached File:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      _viewFile(assignment['fileUrl'], assignment['fileName']),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(assignment['fileName']),
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            assignment['fileName'] ?? 'Assignment File',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Icon(Icons.download, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],

              if (submission != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Submission',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSubmissionInfo(submission),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (assignment['status'] == 'pending' ||
              assignment['status'] == 'overdue')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitAssignment(assignment);
              },
              child: const Text('Submit'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _viewFile(String url, String? fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fileName ?? 'File Preview'),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fileName?.endsWith('.pdf') ?? false)
                const Column(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('PDF Document'),
                    SizedBox(height: 8),
                    Text(
                      'Download to view',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              else if (fileName?.endsWith('.doc') ??
                  fileName?.endsWith('.docx') ??
                  false)
                const Column(
                  children: [
                    Icon(Icons.description, size: 64, color: Colors.blue),
                    SizedBox(height: 16),
                    Text('Word Document'),
                    SizedBox(height: 8),
                    Text(
                      'Download to view',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              else if (fileName?.endsWith('.jpg') ??
                  fileName?.endsWith('.jpeg') ??
                  fileName?.endsWith('.png') ??
                  false)
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Failed to load image'),
                        ],
                      ),
                    );
                  },
                )
              else
                const Column(
                  children: [
                    Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Document Preview'),
                    SizedBox(height: 8),
                    Text(
                      'Download to view',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading file...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAssignment(Map<String, dynamic> assignment) async {
    PlatformFile? selectedFile;
    bool isUploading = false;
    double uploadProgress = 0.0;
    String? fileUrl;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Submit Assignment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Upload your assignment file'),
                  const SizedBox(height: 20),

                  if (selectedFile == null && !isUploading && fileUrl == null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'pdf',
                            'doc',
                            'docx',
                            'txt',
                            'jpg',
                            'jpeg',
                            'png',
                          ],
                          allowMultiple: false,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedFile = result.files.first;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose File'),
                    ),

                  if (selectedFile != null &&
                      !isUploading &&
                      fileUrl == null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(_getFileIcon(selectedFile!.name)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedFile!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedFile = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (isUploading) ...[
                    const SizedBox(height: 20),
                    LinearProgressIndicator(value: uploadProgress),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading... ${(uploadProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],

                  if (fileUrl != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'File uploaded successfully!',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (selectedFile != null && fileUrl == null && !isUploading)
                ElevatedButton(
                  onPressed: () async {
                    setState(() => isUploading = true);

                    try {
                      // Upload file to Cloudinary
                      final xFile = XFile(selectedFile!.path!);
                      final uploadedUrl = await _cloudinaryUploader.uploadFile(
                        xFile,
                        onProgress: (progress) {
                          setState(() => uploadProgress = progress);
                        },
                      );

                      setState(() {
                        isUploading = false;
                        fileUrl = uploadedUrl;
                      });
                    } catch (e) {
                      setState(() => isUploading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upload failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Upload File'),
                ),
              if (fileUrl != null)
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final submissionData = {
                        'assignmentId': assignment['id'],
                        'assignmentTitle': assignment['title'],
                        'studentId': _studentId,
                        'studentName': _studentName,
                        'rollNumber': _rollNumber,
                        'classId': _classId,
                        'className': _className,
                        'fileUrl': fileUrl,
                        'fileName': selectedFile!.name,
                        'submittedAt': FieldValue.serverTimestamp(),
                        'status': 'submitted',
                        'marks': 0,
                        'feedback': '',
                      };

                      await _firestore
                          .collection('assignment_submissions')
                          .add(submissionData);

                      // Update assignment submission count
                      await _firestore
                          .collection('assignments')
                          .doc(assignment['id'])
                          .update({
                            'submissionCount': FieldValue.increment(1),
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                      Navigator.pop(context);
                      _showSuccess('Assignment submitted successfully!');
                      await _loadStudentData(); // Reload data
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Submission failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Assignment'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredAssignments() {
    List<Map<String, dynamic>> filtered = _assignments;

    switch (_filter) {
      case 'pending':
        filtered = _assignments
            .where((a) => a['status'] == 'pending' || a['status'] == 'overdue')
            .toList();
        break;
      case 'submitted':
        filtered = _assignments
            .where((a) => a['status'] == 'submitted')
            .toList();
        break;
      case 'graded':
        filtered = _assignments
            .where((a) => a['status'] == 'graded' || a['status'] == 'rejected')
            .toList();
        break;
    }

    return filtered;
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Pending', 'pending'),
          _buildFilterChip('Submitted', 'submitted'),
          _buildFilterChip('Graded', 'graded'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (selected) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssignments = _getFilteredAssignments();
    final pendingCount = _assignments
        .where((a) => a['status'] == 'pending' || a['status'] == 'overdue')
        .length;
    final submittedCount = _assignments
        .where((a) => a['status'] == 'submitted')
        .length;
    final gradedCount = _assignments
        .where((a) => a['status'] == 'graded')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            onPressed: _loadStudentData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with stats
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assignment Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                pendingCount.toString(),
                                'Pending',
                                Colors.orange,
                              ),
                              _buildStatCard(
                                submittedCount.toString(),
                                'Submitted',
                                Colors.blue,
                              ),
                              _buildStatCard(
                                gradedCount.toString(),
                                'Graded',
                                Colors.green,
                              ),
                              _buildStatCard(
                                _assignments.length.toString(),
                                'Total',
                                Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filters
                  _buildFilters(),
                  const SizedBox(height: 16),

                  // Assignments List
                  Text(
                    'Assignments (${filteredAssignments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (filteredAssignments.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            _filter == 'pending'
                                ? Icons.assignment
                                : _filter == 'submitted'
                                ? Icons.cloud_upload
                                : _filter == 'graded'
                                ? Icons.grade
                                : Icons.assignment,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filter == 'pending'
                                ? 'No pending assignments'
                                : _filter == 'submitted'
                                ? 'No submitted assignments'
                                : _filter == 'graded'
                                ? 'No graded assignments'
                                : 'No assignments found',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredAssignments.map(_buildAssignmentCard).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
