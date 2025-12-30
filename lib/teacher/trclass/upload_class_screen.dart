import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadRecordedClassScreen extends StatefulWidget {
  const UploadRecordedClassScreen({super.key});

  @override
  State<UploadRecordedClassScreen> createState() => _UploadRecordedClassScreenState();
}

class _UploadRecordedClassScreenState extends State<UploadRecordedClassScreen> {
  String? selectedClassId;
  String? selectedSubject;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController youtubeUrlController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  String? _extractedVideoId;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    youtubeUrlController.addListener(_onYoutubeUrlChanged);
  }

  @override
  void dispose() {
    youtubeUrlController.removeListener(_onYoutubeUrlChanged);
    titleController.dispose();
    descriptionController.dispose();
    youtubeUrlController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _onYoutubeUrlChanged() {
    final url = youtubeUrlController.text;
    final videoId = _extractYoutubeVideoId(url);
    if (videoId != _extractedVideoId) {
      setState(() {
        _extractedVideoId = videoId;
      });
    }
  }

  String? _extractYoutubeVideoId(String url) {
    if (url.isEmpty) return null;
    
    // Handle various YouTube URL formats
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)'),
      RegExp(r'youtube\.com\/embed\/([^&\s]+)'),
      RegExp(r'youtube\.com\/v\/([^&\s]+)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    
    return null;
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

  Future<void> _uploadClass() async {
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
      _showError('Please enter class title');
      return;
    }

    if (youtubeUrlController.text.isEmpty) {
      _showError('Please enter YouTube URL');
      return;
    }

    final videoId = _extractYoutubeVideoId(youtubeUrlController.text);
    if (videoId == null || videoId.isEmpty) {
      _showError('Invalid YouTube URL. Please enter a valid YouTube link.');
      return;
    }

    if (durationController.text.isEmpty) {
      _showError('Please enter class duration (e.g., 1h 30m)');
      return;
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
          '${selectedClass['name']}${selectedClass['section'].isNotEmpty ? ' - ${selectedClass['section']}' : ''}';

      print('Uploading class with video ID: $videoId'); // Debug log

      // Create recorded class document in Firestore
      final docRef = await _firestore.collection('recorded_classes').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'subject': selectedSubject!,
        'classId': selectedClassId,
        'className': className,
        'teacherId': user.uid,
        'teacherName': user.displayName ?? 'Teacher',
        'youtubeUrl': youtubeUrlController.text.trim(),
        'videoId': videoId,
        'duration': durationController.text.trim(),
        'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
        'views': 0,
        'likes': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Document created with ID: ${docRef.id}'); // Debug log

      _showSuccess('Recorded class uploaded successfully!');

      // Reset form
      _resetForm();

      // Navigate back after delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context, true); // Pass true to indicate success
    } catch (e) {
      print('Error uploading class: $e');
      _showError('Error uploading class: ${e.toString()}');
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
      _extractedVideoId = null;
      titleController.clear();
      descriptionController.clear();
      youtubeUrlController.clear();
      durationController.clear();
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
        title: const Text('Upload Recorded Class'),
        backgroundColor: const Color(0xFF2962FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload New Recorded Class',
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
                    labelText: 'Class Title *',
                    hintText: 'Enter class title',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 20),

                // YouTube URL Field
                TextField(
                  controller: youtubeUrlController,
                  decoration: InputDecoration(
                    labelText: 'YouTube URL *',
                    hintText: 'https://www.youtube.com/watch?v=...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: const Icon(Icons.video_library),
                    suffixIcon: _extractedVideoId != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                ),
                if (_extractedVideoId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      'Video ID: $_extractedVideoId',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Duration Field
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration *',
                    hintText: 'e.g., 1h 30m or 45m',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 20),

                // Description Field
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter class description',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 20),

                // Preview Section
                if (_extractedVideoId != null)
                  _buildPreviewSection(),
                
                const SizedBox(height: 30),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
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
                            'Upload Recorded Class',
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2962FF),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Uploading class...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2962FF)),
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
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2962FF)),
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

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://img.youtube.com/vi/$_extractedVideoId/maxresdefault.jpg',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error_outline, size: 48),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Video ID: $_extractedVideoId',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}