import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyzee/helper/image_uploader.dart';

class UploadAssignmentScreen extends StatefulWidget {
  const UploadAssignmentScreen({super.key});

  @override
  State<UploadAssignmentScreen> createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryUploader _cloudinaryUploader = CloudinaryUploader();
  final ImagePicker _imagePicker = ImagePicker();

  String? selectedClassId;
  String? selectedSubject;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController marksController = TextEditingController(
    text: '100',
  );
  final TextEditingController dueDateController = TextEditingController();

  List<Map<String, dynamic>> _classes = [];
  List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Physics',
    'Chemistry',
    'Biology',
    'Geography',
    'Computer Science',
    'Economics',
  ];

  bool _isLoading = false;
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;
  XFile? _selectedFile;
  String? _fileUrl;
  String? _fileName;
  DateTime? _selectedDueDate;

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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        // Convert PlatformFile to XFile
        final xFile = XFile(platformFile.path!);

        setState(() {
          _selectedFile = xFile;
          _fileName = platformFile.name;
          _fileUrl = null;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showError('Error picking file');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploadingFile = true;
      _uploadProgress = 0.0;
    });

    try {
      final uploadUrl = await _cloudinaryUploader.uploadFile(
        _selectedFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _isUploadingFile = false;
        if (uploadUrl != null) {
          _fileUrl = uploadUrl;
          _showSuccess('File uploaded successfully!');
        } else {
          _showError('Failed to upload file');
        }
      });
    } catch (e) {
      setState(() {
        _isUploadingFile = false;
      });
      print('Error uploading to Cloudinary: $e');
      _showError('Error uploading file: $e');
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 23, minute: 59),
      );

      if (pickedTime != null) {
        final dueDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDueDate = dueDateTime;
          dueDateController.text =
              '${dueDateTime.day}/${dueDateTime.month}/${dueDateTime.year} '
              '${pickedTime.format(context)}';
        });
      }
    }
  }

  Future<void> _uploadAssignment() async {
    // Validation
    if (selectedClassId == null) {
      _showError('Please select a class');
      return;
    }

    if (selectedSubject == null) {
      _showError('Please select a subject');
      return;
    }

    if (titleController.text.isEmpty) {
      _showError('Please enter assignment title');
      return;
    }

    if (_selectedDueDate == null) {
      _showError('Please select due date');
      return;
    }

    if (marksController.text.isEmpty) {
      _showError('Please enter total marks');
      return;
    }

    final marks = int.tryParse(marksController.text);
    if (marks == null || marks <= 0) {
      _showError('Please enter valid marks');
      return;
    }

    // If file is selected but not uploaded yet, upload it first
    if (_selectedFile != null && _fileUrl == null) {
      await _uploadFile();
      if (_fileUrl == null) {
        _showError('Please upload the selected file first');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError('User not authenticated');
        return;
      }

      // Get class details
      final selectedClass = _classes.firstWhere(
        (cls) => cls['id'] == selectedClassId,
      );
      final className =
          '${selectedClass['name']}'
          '${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}';

      // Create assignment document in Firestore
      await _firestore.collection('assignments').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'subject': selectedSubject!,
        'classId': selectedClassId,
        'className': className,
        'teacherId': user.uid,
        'teacherName': user.displayName ?? 'Teacher',
        'totalMarks': marks,
        'dueDate': Timestamp.fromDate(_selectedDueDate!),
        'fileUrl': _fileUrl,
        'fileName': _fileName,
        'fileType': _selectedFile != null
            ? _selectedFile!.path.split('.').last.toLowerCase()
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'submissionCount': 0,
      });

      _showSuccess('Assignment uploaded successfully!');
      _resetForm();
    } catch (e) {
      print('Error uploading assignment: $e');
      _showError('Error uploading assignment: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      selectedClassId = null;
      selectedSubject = null;
      _selectedFile = null;
      _fileUrl = null;
      _fileName = null;
      _selectedDueDate = null;
      _uploadProgress = 0.0;
      titleController.clear();
      descriptionController.clear();
      marksController.text = '100';
      dueDateController.clear();
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileUrl = null;
      _fileName = null;
      _uploadProgress = 0.0;
    });
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
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFileIcon(_selectedFile!.path),
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName ?? _selectedFile!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: _selectedFile!.length(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            '${(snapshot.data! / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return Text(
                          'Calculating size...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (!_isUploadingFile)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: _removeFile,
                ),
            ],
          ),

          if (_isUploadingFile) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],

          if (_fileUrl != null && !_isUploadingFile) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Uploaded successfully',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.visibility,
                      color: Colors.blue,
                      size: 16,
                    ),
                    onPressed: () {
                      if (_fileUrl != null) {
                        _showFilePreview(_fileUrl!);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_fields;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showFilePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Preview'),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_fileName?.endsWith('.pdf') ?? false)
                const Column(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('PDF Document'),
                  ],
                )
              else if (_fileName?.endsWith('.doc') ??
                  _fileName?.endsWith('.docx') ??
                  false)
                const Column(
                  children: [
                    Icon(Icons.description, size: 64, color: Colors.blue),
                    SizedBox(height: 16),
                    Text('Word Document'),
                  ],
                )
              else if (_fileName?.endsWith('.jpg') ??
                  _fileName?.endsWith('.jpeg') ??
                  _fileName?.endsWith('.png') ??
                  false)
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 64, color: Colors.red);
                  },
                )
              else
                const Column(
                  children: [
                    Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Document Preview'),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Assignment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Class Selection
            _buildClassDropdown(),
            const SizedBox(height: 20),

            // Subject Selection
            _buildSubjectDropdown(),
            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Assignment Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),

            // Due Date Field
            TextField(
              controller: dueDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Due Date *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _selectDueDate,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Marks Field
            TextField(
              controller: marksController,
              decoration: const InputDecoration(
                labelText: 'Total Marks *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // File Upload Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignment File (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildFilePreview(),

                  if (_selectedFile == null) ...[
                    ElevatedButton.icon(
                      onPressed: _isUploadingFile ? null : _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else if (!_isUploadingFile && _fileUrl == null) ...[
                    ElevatedButton.icon(
                      onPressed: _uploadFile,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  const Text(
                    'Supported formats: PDF, DOC, DOCX, TXT, JPG, PNG',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description Field
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 30),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _isUploadingFile)
                    ? null
                    : _uploadAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Upload Assignment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Class *',
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
              const DropdownMenuItem(value: null, child: Text('Select Class')),
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
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Subject *',
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
            value: selectedSubject,
            hint: const Text('Select Subject'),
            isExpanded: true,
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Select Subject'),
              ),
              ..._subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
