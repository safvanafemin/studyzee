import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyzee/helper/image_uploader.dart';

class UploadnoteScreen extends StatefulWidget {
  const UploadnoteScreen({super.key});

  @override
  State<UploadnoteScreen> createState() => _UploadnoteScreenState();
}

class _UploadnoteScreenState extends State<UploadnoteScreen> {
  String? selectedClassId;
  String? selectedSubject;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryUploader _cloudinaryUploader = CloudinaryUploader();
  final ImagePicker _picker = ImagePicker();

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

  XFile? _selectedFile;
  PlatformFile? _platformFile;
  bool _isLoading = false;
  double _uploadProgress = 0.0;

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
          final data = doc.data() as Map<String, dynamic>;
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
      // Show options for file selection
      final result = await showModalBottomSheet<FilePickerResult?>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: Color(0xFF2196F3)),
                title: const Text(
                  'Browse Files',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
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
                    _handleFilePickerResult(result);
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final fileSize = await image.length();
                    setState(() {
                      _selectedFile = image;
                      _platformFile = PlatformFile(
                        name: image.name,
                        size: fileSize,
                        path: image.path,
                      );
                    });
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2196F3),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final fileSize = await image.length();
                    setState(() {
                      _selectedFile = image;
                      _platformFile = PlatformFile(
                        name: image.name,
                        size: fileSize,
                        path: image.path,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error picking file: $e');
      _showError('Error selecting file');
    }
  }

  void _handleFilePickerResult(FilePickerResult result) {
    if (result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFile = XFile(file.path!);
        _platformFile = file;
      });
    }
  }

  Future<void> _uploadNote() async {
    // Validation
    if (selectedClassId == null) {
      _showError('Please select a class');
      return;
    }

    if (selectedSubject == null || selectedSubject!.isEmpty) {
      _showError('Please select a subject');
      return;
    }

    if (titleController.text.isEmpty) {
      _showError('Please enter note title');
      return;
    }

    if (_selectedFile == null) {
      _showError('Please select a file to upload');
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
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
          '${selectedClass['name']}${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}';

      // Upload file to Cloudinary
      final fileUrl = await _cloudinaryUploader.uploadFile(
        _selectedFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (fileUrl == null) {
        _showError('Failed to upload file. Please try again.');
        return;
      }

      // Create note document in Firestore
      await _firestore.collection('notes').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'subject': selectedSubject!,
        'classId': selectedClassId,
        'className': className,
        'teacherId': user.uid,
        'teacherName': user.displayName ?? 'Teacher',
        'fileName': _platformFile?.name ?? _selectedFile!.name,
        'fileSize': _platformFile?.size ?? await _selectedFile!.length(),
        'fileType': _getFileType(_selectedFile!),
        'fileUrl': fileUrl,
        'downloads': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSuccess('Note uploaded successfully!');

      // Reset form
      _resetForm();

      // Navigate back after delay
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pop(context);
    } catch (e) {
      print('Error uploading note: $e');
      _showError('Error uploading note: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  String _getFileType(XFile file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.pdf')) return 'PDF';
    if (path.endsWith('.doc') || path.endsWith('.docx')) return 'DOC';
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png'))
      return 'IMAGE';
    if (path.endsWith('.txt')) return 'TEXT';
    return 'FILE';
  }

  void _resetForm() {
    setState(() {
      selectedClassId = null;
      selectedSubject = null;
      _selectedFile = null;
      _platformFile = null;
      titleController.clear();
      descriptionController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Notes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload New Note',
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
                      labelText: 'Note Title *',
                      hintText: 'Enter note title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Enter note description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // File Upload Section
                  _buildFileUploadSection(),
                  const SizedBox(height: 30),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
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
                              'Upload Note',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedFile != null)
                        Text(
                          _platformFile?.name ?? _selectedFile!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Class *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedClassId,
            hint: const Text(
              'Choose class',
              style: TextStyle(color: Colors.grey),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2196F3)),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Choose class',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ..._classes.map((classData) {
                final displayName = classData['section'].isNotEmpty
                    ? '${classData['name']} - Section ${classData['section']}'
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedSubject,
            hint: const Text(
              'Choose subject',
              style: TextStyle(color: Colors.grey),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2196F3)),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Choose subject',
                  style: TextStyle(color: Colors.grey),
                ),
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

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload File *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : _pickFile,
          child: Container(
            constraints: const BoxConstraints(minHeight: 150),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedFile != null
                    ? const Color(0xFF2196F3)
                    : Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _selectedFile != null
                  ? const Color(0xFF2196F3).withOpacity(0.05)
                  : null,
            ),
            child: _selectedFile != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getFileIcon(),
                          size: 48,
                          color: const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _platformFile?.name ?? _selectedFile!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatFileSize(_platformFile?.size ?? 0),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pickFile,
                          icon: const Icon(Icons.change_circle, size: 16),
                          label: const Text('Change File'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2196F3),
                            side: const BorderSide(color: Color(0xFF2196F3)),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap to select file',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supports: PDF, DOC, JPG, PNG',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon() {
    if (_selectedFile == null) return Icons.insert_drive_file;
    final fileType = _getFileType(_selectedFile!);
    switch (fileType) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
        return Icons.description;
      case 'IMAGE':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
