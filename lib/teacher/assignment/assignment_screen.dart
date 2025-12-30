//
// assignment_view_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyzee/teacher/assignment/assigment_upload_scereen.dart';

class AssignmentViewScreen extends StatefulWidget {
  const AssignmentViewScreen({super.key});

  @override
  State<AssignmentViewScreen> createState() => _AssignmentViewScreenState();
}

class _AssignmentViewScreenState extends State<AssignmentViewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedClassId;
  String? selectedAssignmentId;
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _submissions = [];
  Map<String, dynamic>? _selectedAssignmentDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

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
      });
    } catch (e) {
      print('Error loading classes: $e');
      _showError('Error loading classes');
    }
  }

  Future<void> _loadAssignments() async {
    if (selectedClassId == null) return;

    setState(() {
      _isLoading = true;
      _assignments = [];
      _submissions = [];
      _selectedAssignmentDetails = null;
    });

    try {
      final querySnapshot = await _firestore
          .collection('assignments')
          .where('classId', isEqualTo: selectedClassId)
          .get();

      setState(() {
        _assignments = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? 'No Title',
            'subject': data['subject'] ?? 'General',
            'dueDate': data['dueDate'],
            'totalMarks': data['totalMarks'] ?? 100,
            'createdAt': data['createdAt'],
          };
        }).toList();
      });

      if (_assignments.isNotEmpty) {
        selectedAssignmentId = _assignments.first['id'];
        await _loadAssignmentDetails(_assignments.first['id']);
      }
    } catch (e) {
      print('Error loading assignments: $e');
      _showError('Error loading assignments');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssignmentDetails(String assignmentId) async {
    setState(() {
      _isLoading = true;
      _submissions = [];
    });

    try {
      // Get assignment details
      final assignmentDoc = await _firestore
          .collection('assignments')
          .doc(assignmentId)
          .get();

      if (assignmentDoc.exists) {
        final data = assignmentDoc.data();
        setState(() {
          _selectedAssignmentDetails = {
            'title': data?['title'] ?? '',
            'description': data?['description'] ?? '',
            'subject': data?['subject'] ?? '',
            'assignedDate': _formatDate(data?['createdAt']),
            'dueDate': _formatDate(data?['dueDate']),
            'dueTime': _formatTime(data?['dueDate']),
            'totalMarks': data?['totalMarks'] ?? 100,
            'duration': _calculateDuration(
              data?['createdAt'],
              data?['dueDate'],
            ),
            'fileUrl': data?['fileUrl'] ?? '',
            'fileName': data?['fileName'] ?? '',
          };
        });
      }

      // Load submissions
      final submissionsSnapshot = await _firestore
          .collection('assignment_submissions')
          .where('assignmentId', isEqualTo: assignmentId)
          .orderBy('submittedAt', descending: true)
          .get();

      setState(() {
        _submissions = submissionsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'studentId': data['studentId'],
            'studentName': data['studentName'] ?? 'Unknown',
            'submittedAt': data['submittedAt'],
            'status': data['status'] ?? 'pending',
            'fileUrl': data['fileUrl'] ?? '',
            'fileName': data['fileName'] ?? '',
            'marks': data['marks'] ?? 0,
            'feedback': data['feedback'] ?? '',
            'submissionDate': _formatDate(data['submittedAt']),
            'submissionTime': _formatTime(data['submittedAt']),
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading assignment details: $e');
      _showError('Error loading assignment details');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final hour = date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $amPm';
  }

  String _calculateDuration(Timestamp? start, Timestamp? end) {
    if (start == null || end == null) return 'N/A';
    final startDate = start.toDate();
    final endDate = end.toDate();
    final difference = endDate.difference(startDate).inDays;
    return '$difference days';
  }

  Future<void> _updateSubmissionStatus(
    String submissionId,
    String status,
    int marks,
    String feedback,
  ) async {
    try {
      await _firestore
          .collection('assignment_submissions')
          .doc(submissionId)
          .update({
            'status': status,
            'marks': marks,
            'feedback': feedback,
            'gradedAt': FieldValue.serverTimestamp(),
            'gradedBy': _auth.currentUser?.uid,
          });

      // Reload submissions
      await _loadAssignmentDetails(selectedAssignmentId!);
      _showSuccess('Submission $status successfully!');
    } catch (e) {
      print('Error updating submission: $e');
      _showError('Error updating submission');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[50]!;
      case 'graded':
        return Colors.green[50]!;
      case 'approved':
        return Colors.blue[50]!;
      case 'rejected':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'graded':
        return Colors.green[700]!;
      case 'approved':
        return Colors.blue[700]!;
      case 'rejected':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildFilePreviewWidget(String url, String? fileName) {
    if (fileName?.endsWith('.pdf') ?? false) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('PDF Document'),
          SizedBox(height: 8),
          Text('Download to view', style: TextStyle(color: Colors.grey)),
        ],
      );
    } else if (fileName?.endsWith('.doc') ??
        fileName?.endsWith('.docx') ??
        false) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Word Document'),
          SizedBox(height: 8),
          Text('Download to view', style: TextStyle(color: Colors.grey)),
        ],
      );
    } else if (fileName?.endsWith('.jpg') ??
        fileName?.endsWith('.jpeg') ??
        fileName?.endsWith('.png') ??
        false) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load image'),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Document'),
          SizedBox(height: 8),
          Text('Download to view', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
  }

  void _viewSubmission(Map<String, dynamic> submission) {
    final fileUrl = submission['fileUrl'];
    final fileName = submission['fileName'];

    if (fileUrl == null || fileUrl.isEmpty) {
      _showError('No file attached');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        submission['studentName'][0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submission['studentName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${submission['submissionDate']} at ${submission['submissionTime']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // File Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: _buildFilePreviewWidget(fileUrl, fileName),
                ),
              ),

              // Action Buttons for grading
              if (submission['status'] == 'pending')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showGradingDialog(submission, false),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showGradingDialog(submission, true),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Grade & Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionItem(Map<String, dynamic> submission) {
    final fileUrl = submission['fileUrl'];
    final fileName = submission['fileName'];

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
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  submission['studentName'][0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission['studentName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted: ${submission['submissionDate']} at ${submission['submissionTime']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  color: _getStatusColor(submission['status']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  submission['status'].toString().toUpperCase(),
                  style: TextStyle(
                    color: _getStatusTextColor(submission['status']),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (fileUrl != null && fileUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _viewSubmission(submission),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(_getFileIcon(fileName), color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName ?? 'Submission',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (submission['marks'] != null &&
                              submission['marks'] > 0)
                            Text(
                              'Marks: ${submission['marks']}/${_selectedAssignmentDetails?['totalMarks'] ?? 100}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.visibility, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ),
          ],

          // Grade/Feedback section
          if (submission['feedback'] != null &&
              submission['feedback'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (submission['marks'] != null)
                    Text(
                      'Marks: ${submission['marks']}/${_selectedAssignmentDetails?['totalMarks'] ?? 100}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  if (submission['feedback'] != null &&
                      submission['feedback'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Feedback:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(submission['feedback']),
                  ],
                ],
              ),
            ),
          ],

          // Action buttons for pending submissions
          if (submission['status'] == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showGradingDialog(submission, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showGradingDialog(submission, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Grade & Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showGradingDialog(Map<String, dynamic> submission, bool isApprove) {
    TextEditingController marksController = TextEditingController();
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Grade Assignment' : 'Reject Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isApprove) ...[
              TextField(
                controller: marksController,
                decoration: InputDecoration(
                  labelText: 'Marks',
                  hintText:
                      'Enter marks out of ${_selectedAssignmentDetails?['totalMarks'] ?? 100}',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                hintText: 'Enter feedback for student',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isApprove) {
                if (marksController.text.isEmpty) {
                  _showError('Please enter marks');
                  return;
                }
                final marks = int.tryParse(marksController.text) ?? 0;
                if (marks < 0 ||
                    marks >
                        (_selectedAssignmentDetails?['totalMarks'] ?? 100)) {
                  _showError('Invalid marks');
                  return;
                }
              }

              await _updateSubmissionStatus(
                submission['id'],
                isApprove ? 'graded' : 'rejected',
                isApprove ? int.parse(marksController.text) : 0,
                feedbackController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(
              isApprove ? 'Submit Grade' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadAssignmentScreen()),
          );
        },
      ),
      appBar: AppBar(title: Text('Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Selection
            const Text(
              'Select Class',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedClassId,
                hint: const Text('Select Class'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Class'),
                  ),
                  ..._classes.map((classData) {
                    final displayName = classData['section'].isNotEmpty
                        ? '${classData['name']} - ${classData['section']}'
                        : classData['name'];
                    return DropdownMenuItem<String>(
                      value: classData['id'],
                      child: Text(displayName),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedClassId = value;
                    selectedAssignmentId = null;
                    _assignments = [];
                    _submissions = [];
                    _selectedAssignmentDetails = null;
                  });
                  if (value != null) {
                    _loadAssignments();
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            if (selectedClassId != null) ...[
              // Assignment Selection
              const Text(
                'Select Assignment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedAssignmentId,
                  hint: const Text('Select Assignment'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Assignment'),
                    ),
                    ..._assignments.map((assignment) {
                      return DropdownMenuItem<String>(
                        value: assignment['id'],
                        child: Text(assignment['title']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAssignmentId = value;
                    });
                    if (value != null) {
                      _loadAssignmentDetails(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (_selectedAssignmentDetails != null) ...[
                // Assignment Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Assigned Date',
                              _selectedAssignmentDetails!['assignedDate'] ??
                                  'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              'Due Date',
                              '${_selectedAssignmentDetails!['dueDate']}\n${_selectedAssignmentDetails!['dueTime']}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Duration',
                              _selectedAssignmentDetails!['duration'] ?? 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              'Total Marks',
                              _selectedAssignmentDetails!['totalMarks']
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedAssignmentDetails!['description'] != null &&
                          _selectedAssignmentDetails!['description']
                              .isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          'Description',
                          _selectedAssignmentDetails!['description'],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Submissions List
                Text(
                  'Student Submissions (${_submissions.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (!_isLoading && _submissions.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Icon(Icons.assignment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No submissions yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          'Students will appear here once they submit',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (!_isLoading && _submissions.isNotEmpty)
                  ..._submissions.map(_buildSubmissionItem).toList(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
