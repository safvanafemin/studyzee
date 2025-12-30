// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';

// class TrclassScreen extends StatefulWidget {
//   const TrclassScreen({super.key});

//   @override
//   State<TrclassScreen> createState() => _TrclassScreenState();
// }

// class _TrclassScreenState extends State<TrclassScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String selectedSubject = 'All';

//   final List<String> subjects = ['All', 'Mathematics', 'Physics'];

//   final List<Map<String, dynamic>> recordedClasses = [
//     {
//       'title': 'Trigonometry - Part 2',
//       'subject': 'Mathematics',
//       'teacher': 'Mr. Rajesh Kumar',
//       'date': 'Oct 03, 2025',
//       'views': 128,
//       'duration': '1h 30m',
//       'gradient': [Color(0xFF4A90E2), Color(0xFF357ABD)],
//     },
//     {
//       'title': 'Electromagnetic Induction',
//       'subject': 'Physics',
//       'teacher': 'Dr. Priya Sharma',
//       'date': 'Oct 02, 2025',
//       'views': 95,
//       'duration': '1h 45m',
//       'gradient': [Color(0xFF9B59B6), Color(0xFF8E44AD)],
//     },
//     {
//       'title': 'Calculus - Derivatives',
//       'subject': 'Mathematics',
//       'teacher': 'Mr. Rajesh Kumar',
//       'date': 'Oct 01, 2025',
//       'views': 152,
//       'duration': '2h 00m',
//       'gradient': [Color(0xFF4A90E2), Color(0xFF357ABD)],
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   List<Map<String, dynamic>> get filteredClasses {
//     if (selectedSubject == 'All') {
//       return recordedClasses;
//     }
//     return recordedClasses
//         .where((cls) => cls['subject'] == selectedSubject)
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2962FF),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Classes',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           indicatorWeight: 3,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           labelStyle: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           tabs: const [
//             Tab(text: 'Recorded Classes'),
//             Tab(text: 'Live Classes'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildRecordedClassesTab(),
//           _buildLiveClassesTab(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           _showUploadDialog(context);
//         },
//         backgroundColor: const Color(0xFF2962FF),
//         icon: const Icon(Icons.cloud_upload_outlined),
//         label: const Text(
//           'Upload Class',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecordedClassesTab() {
//     return Column(
//       children: [
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: subjects.map((subject) {
//                 final isSelected = selectedSubject == subject;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: ChoiceChip(
//                     label: Text(subject),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         selectedSubject = subject;
//                       });
//                     },
//                     backgroundColor: Colors.grey[200],
//                     selectedColor: const Color(0xFF2962FF),
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//         Expanded(
//           child: filteredClasses.isEmpty
//               ? Center(
//                   child: Text(
//                     'No classes available',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filteredClasses.length,
//                   itemBuilder: (context, index) {
//                     return _buildClassCard(filteredClasses[index]);
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildClassCard(Map<String, dynamic> classData) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Video thumbnail with gradient
//           Container(
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(12)),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: classData['gradient'],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 Center(
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.play_arrow_rounded,
//                       color: Colors.white,
//                       size: 36,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 12,
//                   right: 12,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black87,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       classData['duration'],
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   classData['title'],
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE3F2FD),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     classData['subject'],
//                     style: const TextStyle(
//                       color: Color(0xFF2962FF),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.person_outline,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       classData['teacher'],
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.calendar_today_outlined,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       classData['date'],
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     const Spacer(),
//                     Icon(
//                       Icons.visibility_outlined,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       '${classData['views']} views',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLiveClassesTab() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.videocam_outlined,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No live classes scheduled',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showUploadDialog(BuildContext context) {
//     final titleController = TextEditingController();
//     final descriptionController = TextEditingController();
//     String selectedSubjectUpload = 'Mathematics';
//     String? selectedFileName;
//     String? selectedFilePath;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return AlertDialog(
//             title: const Text(
//               'Upload Class Video',
//               style: TextStyle(fontWeight: FontWeight.w700),
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: const InputDecoration(
//                       labelText: 'Class Title',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: selectedSubjectUpload,
//                     decoration: const InputDecoration(
//                       labelText: 'Subject',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: ['Mathematics', 'Physics', 'Chemistry', 'Biology']
//                         .map((subject) => DropdownMenuItem(
//                               value: subject,
//                               child: Text(subject),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       selectedSubjectUpload = value!;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: descriptionController,
//                     maxLines: 3,
//                     decoration: const InputDecoration(
//                       labelText: 'Description',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   OutlinedButton.icon(
//                     onPressed: () async {
//                       // Open file picker for video files
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.video,
//                         allowMultiple: false,
//                       );

//                       if (result != null) {
//                         setDialogState(() {
//                           selectedFileName = result.files.single.name;
//                           selectedFilePath = result.files.single.path;
//                         });
//                       }
//                     },
//                     icon: const Icon(Icons.video_library_outlined),
//                     label: Text(
//                       selectedFileName ?? 'Select Video File',
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(48),
//                       foregroundColor: selectedFileName != null
//                           ? const Color(0xFF2962FF)
//                           : null,
//                     ),
//                   ),
//                   if (selectedFileName != null) ...[
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE3F2FD),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.check_circle,
//                             color: Color(0xFF2962FF),
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               selectedFileName!,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF2962FF),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, size: 18),
//                             onPressed: () {
//                               setDialogState(() {
//                                 selectedFileName = null;
//                                 selectedFilePath = null;
//                               });
//                             },
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: selectedFileName != null
//                     ? () {
//                         // Handle upload with the selected file
//                         Navigator.pop(context);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Uploading: $selectedFileName'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2962FF),
//                   disabledBackgroundColor: Colors.grey[300],
//                 ),
//                 child: const Text('Upload'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyzee/teacher/trclass/upload_class_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrclassScreen extends StatefulWidget {
  const TrclassScreen({super.key});

  @override
  State<TrclassScreen> createState() => _TrclassScreenState();
}

class _TrclassScreenState extends State<TrclassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedSubject = 'All';
  String? selectedClassId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> subjects = ['All'];
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadClasses();
    await _loadSubjects();
    setState(() {
      _isLoading = false;
    });
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
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final querySnapshot = await _firestore
          .collection('recorded_classes')
          .get();

      final subjectSet = <String>{'All'};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['subject'] != null) {
          subjectSet.add(data['subject']);
        }
      }

      setState(() {
        subjects = subjectSet.toList()..sort();
      });
    } catch (e) {
      print('Error loading subjects: $e');
    }
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
        children: [_buildRecordedClassesTab(), _buildLiveClassesTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadRecordedClassScreen(),
            ),
          ).then((_) {
            // Refresh data when returning
            _loadInitialData();
          });
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
        // Filter Section
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Filter
              SingleChildScrollView(
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
              const SizedBox(height: 12),
              // Class Filter
              if (_classes.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedClassId,
                  decoration: InputDecoration(
                    labelText: 'Filter by Class',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Classes'),
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
                    });
                  },
                ),
            ],
          ),
        ),
        // Classes List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: _getRecordedClassesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recorded classes available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Sort and filter classes in memory
                    final classes = _sortAndFilterClasses(snapshot.data!.docs);

                    if (classes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_list_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No classes match your filters',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        return _buildClassCard(classes[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getRecordedClassesStream() {
    // Use simpler queries to avoid complex index requirements
    Query query = _firestore.collection('recorded_classes');

    // Apply filters one at a time to avoid complex composite indexes
    if (selectedClassId != null) {
      query = query.where('classId', isEqualTo: selectedClassId);
    } else if (selectedSubject != 'All') {
      query = query.where('subject', isEqualTo: selectedSubject);
    }

    return query.snapshots();
  }

  // Sort and filter results in memory after fetching
  List<Map<String, dynamic>> _sortAndFilterClasses(
    List<QueryDocumentSnapshot> docs,
  ) {
    List<Map<String, dynamic>> classes = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    // Apply additional filtering if both filters are selected
    if (selectedClassId != null && selectedSubject != 'All') {
      classes = classes
          .where((cls) => cls['subject'] == selectedSubject)
          .toList();
    }

    // Sort by createdAt in memory
    classes.sort((a, b) {
      final aTime = a['createdAt'] as Timestamp?;
      final bTime = b['createdAt'] as Timestamp?;

      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime); // Descending order
    });

    return classes;
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    final videoId = classData['videoId'] ?? '';
    final thumbnailUrl =
        classData['thumbnailUrl'] ??
        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(classData: classData),
          ),
        );
      },
      child: Container(
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
            // Video thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF4A90E2),
                              const Color(0xFF357ABD),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF2962FF),
                        size: 36,
                      ),
                    ),
                  ),
                ),
                if (classData['duration'] != null)
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData['title'] ?? 'Untitled Class',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
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
                          classData['subject'] ?? 'General',
                          style: const TextStyle(
                            color: Color(0xFF2962FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (classData['className'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            classData['className'],
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
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
                      Expanded(
                        child: Text(
                          classData['teacherName'] ?? 'Teacher',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
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
                        _formatDate(classData['createdAt']),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${classData['views'] ?? 0} views',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildLiveClassesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Live Classes Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay tuned for live streaming classes',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const VideoPlayerScreen({super.key, required this.classData});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _incrementViews();
  }

  void _initializePlayer() {
    String videoId = widget.classData['videoId'] ?? '';

    // Clean the video ID (remove any parameters like ?si=xxx)
    videoId = _cleanVideoId(videoId);

    // If videoId is empty, try to extract from URL
    if (videoId.isEmpty && widget.classData['youtubeUrl'] != null) {
      videoId = _extractVideoId(widget.classData['youtubeUrl']) ?? '';
    }

    // Validate video ID (must be exactly 11 characters)
    if (videoId.isEmpty || videoId.length != 11) {
      print('Error: Invalid video ID: "$videoId" (length: ${videoId.length})');
      return;
    }

    print('Initializing YouTube player with video ID: $videoId');

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        forceHD: false,
        loop: false,
      ),
    )..addListener(_listener);
  }

  String _cleanVideoId(String videoId) {
    if (videoId.isEmpty) return '';

    // Remove any URL parameters (everything after ? or &)
    videoId = videoId.split('?')[0].split('&')[0];

    // Extract only the 11-character video ID using regex
    final pattern = RegExp(r'([a-zA-Z0-9_-]{11})');
    final match = pattern.firstMatch(videoId);

    return match?.group(1) ?? videoId;
  }

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;

    // Handle various YouTube URL formats
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final videoId = match.group(1);
        // Clean any trailing parameters
        if (videoId != null) {
          return videoId.split('?')[0].split('&')[0];
        }
      }
    }

    // Fallback: try to extract any 11-character alphanumeric string
    final fallbackPattern = RegExp(r'([a-zA-Z0-9_-]{11})');
    final fallbackMatch = fallbackPattern.firstMatch(url);
    if (fallbackMatch != null) {
      return fallbackMatch.group(1);
    }

    return null;
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  Future<void> _incrementViews() async {
    try {
      final docId = widget.classData['id'];
      if (docId != null) {
        await _firestore.collection('recorded_classes').doc(docId).update({
          'views': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have a valid video ID
    String videoId = widget.classData['videoId'] ?? '';

    // Clean the video ID
    videoId = _cleanVideoId(videoId);

    // Try to extract from URL if needed
    if (videoId.isEmpty && widget.classData['youtubeUrl'] != null) {
      videoId = _extractVideoId(widget.classData['youtubeUrl']) ?? '';
    }

    // Validate video ID length
    if (videoId.isEmpty || videoId.length != 11) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2962FF),
          title: const Text('Video Player'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Invalid Video',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Could not load video. Invalid video ID: "$videoId"',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Video ID must be exactly 11 characters',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF2962FF),
          onReady: () {
            _isPlayerReady = true;
          },
          onEnded: (data) {
            // Optional: Handle video end
          },
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.classData['title'] ?? 'Untitled Class',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.classData['subject'] ?? 'General',
                                      style: const TextStyle(
                                        color: Color(0xFF2962FF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (widget.classData['className'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.classData['className'],
                                        style: TextStyle(
                                          color: Colors.orange[800],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF2962FF),
                                    child: Text(
                                      (widget.classData['teacherName'] ??
                                              'T')[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.classData['teacherName'] ??
                                              'Teacher',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${widget.classData['views'] ?? 0} views',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.classData['description'] != null &&
                                  widget.classData['description'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.classData['description'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
