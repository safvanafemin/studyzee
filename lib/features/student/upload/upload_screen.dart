import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDate;
  FilePickerResult? _filePickerResult;
  final TextEditingController _titleController = TextEditingController();

  // Sample uploaded assignments
  final List<Map<String, dynamic>> uploadedAssignments = [
    {
      'title': 'Mathematics - Algebra',
      'dueDate': DateTime.now().subtract(const Duration(days: 2)),
      'fileName': 'math_assignment.pdf',
      'fileSize': 2048,
      'status': 'submitted',
      'submittedDate': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'title': 'Science - Physics',
      'dueDate': DateTime.now().add(const Duration(days: 5)),
      'fileName': 'physics_project.docx',
      'fileSize': 5120,
      'status': 'pending',
      'submittedDate': null,
    },
    {
      'title': 'English - Essay',
      'dueDate': DateTime.now().subtract(const Duration(days: 5)),
      'fileName': 'essay_submission.docx',
      'fileSize': 1024,
      'status': 'submitted',
      'submittedDate': DateTime.now().subtract(const Duration(days: 4)),
    },
    {
      'title': 'History - Project',
      'dueDate': DateTime.now().add(const Duration(days: 10)),
      'fileName': 'history_research.pdf',
      'fileSize': 3072,
      'status': 'pending',
      'submittedDate': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Function to show the date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to handle file picking
  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePickerResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9ff),
      appBar: AppBar(
        title: const Text(
          'Assignment',
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
            Tab(text: 'Upload'),
            Tab(text: 'View Submissions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upload Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Due Date Section
                _buildDatePickerField(context),
                const SizedBox(height: 16),
                // Title Section
                _buildTitleField(),
                const SizedBox(height: 24),
                // File Upload Section
                _buildFileUploadArea(),
                const SizedBox(height: 24),
                // Display selected file
                if (_filePickerResult != null) _buildSelectedFileCard(),
                const SizedBox(height: 24),
                // Upload Button
                ElevatedButton(
                  onPressed: () {
                    // Handle the upload logic here
                    if (_filePickerResult != null &&
                        _selectedDate != null &&
                        _titleController.text.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File submitted successfully!'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields and select a file.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // View Submissions Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uploadedAssignments.length,
            itemBuilder: (context, index) {
              final assignment = uploadedAssignments[index];
              return _buildAssignmentCard(assignment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: _selectedDate == null
                        ? 'Date'
                        : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Date',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.title, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadArea() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Drag and drop your file here',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'or',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open, size: 20),
              label: const Text('Browse Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard() {
    if (_filePickerResult == null) return const SizedBox.shrink();

    final PlatformFile file = _filePickerResult!.files.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${(file.size / 1024).toStringAsFixed(2)} KB',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _filePickerResult = null;
              });
            },
            icon: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    bool isSubmitted = assignment['status'] == 'submitted';
    bool isOverdue =
        assignment['dueDate'].isBefore(DateTime.now()) && !isSubmitted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  child: Text(
                    assignment['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSubmitted
                        ? Colors.green.shade50
                        : isOverdue
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSubmitted
                        ? 'Submitted'
                        : isOverdue
                            ? 'Overdue'
                            : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSubmitted
                          ? Colors.green
                          : isOverdue
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Due: ${DateFormat('MMM d, yyyy').format(assignment['dueDate'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            if (isSubmitted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Submitted: ${DateFormat('MMM d, yyyy').format(assignment['submittedDate']!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file,
                      size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['fileName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${(assignment['fileSize'] / 1024).toStringAsFixed(2)} KB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Downloading ${assignment['fileName']}...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}