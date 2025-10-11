import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TrclassScreen extends StatefulWidget {
  const TrclassScreen({super.key});

  @override
  State<TrclassScreen> createState() => _TrclassScreenState();
}

class _TrclassScreenState extends State<TrclassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedSubject = 'All';

  final List<String> subjects = ['All', 'Mathematics', 'Physics'];

  final List<Map<String, dynamic>> recordedClasses = [
    {
      'title': 'Trigonometry - Part 2',
      'subject': 'Mathematics',
      'teacher': 'Mr. Rajesh Kumar',
      'date': 'Oct 03, 2025',
      'views': 128,
      'duration': '1h 30m',
      'gradient': [Color(0xFF4A90E2), Color(0xFF357ABD)],
    },
    {
      'title': 'Electromagnetic Induction',
      'subject': 'Physics',
      'teacher': 'Dr. Priya Sharma',
      'date': 'Oct 02, 2025',
      'views': 95,
      'duration': '1h 45m',
      'gradient': [Color(0xFF9B59B6), Color(0xFF8E44AD)],
    },
    {
      'title': 'Calculus - Derivatives',
      'subject': 'Mathematics',
      'teacher': 'Mr. Rajesh Kumar',
      'date': 'Oct 01, 2025',
      'views': 152,
      'duration': '2h 00m',
      'gradient': [Color(0xFF4A90E2), Color(0xFF357ABD)],
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
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredClasses {
    if (selectedSubject == 'All') {
      return recordedClasses;
    }
    return recordedClasses
        .where((cls) => cls['subject'] == selectedSubject)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Classes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Recorded Classes'),
            Tab(text: 'Live Classes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordedClassesTab(),
          _buildLiveClassesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUploadDialog(context);
        },
        backgroundColor: const Color(0xFF2962FF),
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text(
          'Upload Class',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRecordedClassesTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: subjects.map((subject) {
                final isSelected = selectedSubject == subject;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedSubject = subject;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF2962FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: filteredClasses.isEmpty
              ? Center(
                  child: Text(
                    'No classes available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredClasses.length,
                  itemBuilder: (context, index) {
                    return _buildClassCard(filteredClasses[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail with gradient
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: classData['gradient'],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      classData['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    classData['subject'],
                    style: const TextStyle(
                      color: Color(0xFF2962FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      classData['teacher'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      classData['date'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${classData['views']} views',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No live classes scheduled',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedSubjectUpload = 'Mathematics';
    String? selectedFileName;
    String? selectedFilePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Upload Class Video',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Class Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedSubjectUpload,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Mathematics', 'Physics', 'Chemistry', 'Biology']
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedSubjectUpload = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Open file picker for video files
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.video,
                        allowMultiple: false,
                      );

                      if (result != null) {
                        setDialogState(() {
                          selectedFileName = result.files.single.name;
                          selectedFilePath = result.files.single.path;
                        });
                      }
                    },
                    icon: const Icon(Icons.video_library_outlined),
                    label: Text(
                      selectedFileName ?? 'Select Video File',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: selectedFileName != null 
                          ? const Color(0xFF2962FF) 
                          : null,
                    ),
                  ),
                  if (selectedFileName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2962FF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFileName!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2962FF),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setDialogState(() {
                                selectedFileName = null;
                                selectedFilePath = null;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
              ElevatedButton(
                onPressed: selectedFileName != null
                    ? () {
                        // Handle upload with the selected file
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Uploading: $selectedFileName'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }
}