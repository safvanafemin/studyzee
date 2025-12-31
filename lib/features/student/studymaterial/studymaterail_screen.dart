// import 'package:flutter/material.dart';

// class StudyMaterialScreen extends StatelessWidget {
//   const StudyMaterialScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFf8f9ff),
//       appBar: AppBar(
//         title: const Text(
//           'Study Materials',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Column(
//           children: [
//             StudyMaterialCard(
//               title: 'Calculus II - Integrals',
//               subject: 'Mathematics',
//               fileType: 'PDF',
//               uploadedDate: 'October 26, 2024',
//               progress: 0.75,
//               icon: Icons.picture_as_pdf,
//               iconColor: Colors.red.shade400,
//             ),
//             const SizedBox(height: 16),
//             StudyMaterialCard(
//               title: 'Introduction to Physics',
//               subject: 'Physics',
//               fileType: 'Video',
//               uploadedDate: 'October 25, 2024',
//               progress: 0.50,
//               icon: Icons.play_circle_fill,
//               iconColor: Colors.blue.shade400,
//             ),
//             const SizedBox(height: 16),
//             StudyMaterialCard(
//               title: 'His first flight',
//               subject: 'English',
//               fileType: 'DOCX',
//               uploadedDate: 'October 24, 2024',
//               progress: 0.0,
//               icon: Icons.description,
//               iconColor: Colors.lightGreen.shade400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class StudyMaterialCard extends StatelessWidget {
//   final String title;
//   final String subject;
//   final String fileType;
//   final String uploadedDate;
//   final double progress;
//   final IconData icon;
//   final Color iconColor;

//   const StudyMaterialCard({
//     super.key,
//     required this.title,
//     required this.subject,
//     required this.fileType,
//     required this.uploadedDate,
//     required this.progress,
//     required this.icon,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: iconColor, size: 36),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Subject: $subject',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         'File Type: $fileType',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         'Uploaded: $uploadedDate',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.grey[200],
//               color: Colors.blue,
//               minHeight: 8,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${(progress * 100).toStringAsFixed(0)}% read',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     // Download/Open action
//                   },
//                   icon: const Icon(Icons.download, color: Colors.blue),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () {
//                     // Share action
//                   },
//                   icon: const Icon(Icons.share, color: Colors.blue),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class StudentNotesScreen extends StatefulWidget {
  const StudentNotesScreen({super.key});

  @override
  State<StudentNotesScreen> createState() => _StudentNotesScreenState();
}

class _StudentNotesScreenState extends State<StudentNotesScreen>
    with TickerProviderStateMixin {
  String selectedClass = 'My Class'; // Changed default to My Class
  String searchQuery = '';
  late AnimationController _fadeController;
  late AnimationController _listController;
  bool isGridView = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> classFilters = ['My Class']; // Changed to start with My Class
  List<Note> allNotes = [];
  List<Map<String, dynamic>> _availableClasses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _studentClassId = '';
  String _studentClassName = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
    _listController.forward();

    _loadStudentClassAndNotes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentClassAndNotes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get student's class information
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        _studentClassId = userData?['classId'] ?? '';
        _studentClassName = userData?['className'] ?? '';

        // If student has a class, set selectedClass to 'My Class'
        if (_studentClassName.isNotEmpty) {
          setState(() {
            selectedClass = 'My Class';
          });
        }
      }

      // Load all classes
      final classesSnapshot = await _firestore
          .collection('Classes')
          .orderBy('name')
          .get();

      setState(() {
        _availableClasses = classesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final className = data['name'] ?? 'Unknown';
          final section = data['section'] ?? '';
          final displayName = section.isNotEmpty
              ? '$className - Section $section'
              : className;
          final combinedName = section.isNotEmpty
              ? '$className - $section'
              : className;

          return {
            'id': doc.id,
            'name': className,
            'section': section,
            'displayName': displayName,
            'combinedName': combinedName,
          };
        }).toList();

        _updateClassFilters();
      });

      await _loadNotes();
    } catch (e) {
      print('Error loading student class: $e');
      _showError('Error loading data');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNotes() async {
    try {
      // Load notes - students can see all notes or filter by their class
      final notesSnapshot = await _firestore
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        allNotes = notesSnapshot.docs.map((doc) {
          final data = doc.data();
          final className = data['className'] ?? 'Unknown';

          String matchedDisplayName = className;
          for (var classData in _availableClasses) {
            if (className == classData['combinedName'] ||
                className == classData['displayName'] ||
                _normalizeClassName(className) ==
                    _normalizeClassName(classData['combinedName'])) {
              matchedDisplayName = classData['displayName'];
              break;
            }
          }

          return Note(
            id: doc.id,
            title: data['title'] ?? 'Untitled',
            description: data['description'] ?? '',
            subject: data['subject'] ?? 'Unknown',
            className: className,
            displayClassName: matchedDisplayName,
            classId: data['classId'] ?? '',
            dateUploaded: _formatDate(data['createdAt']),
            fileSize: _formatFileSize(data['fileSize'] ?? 0),
            fileType: data['fileType'] ?? 'FILE',
            fileName: data['fileName'] ?? 'file',
            fileUrl: data['fileUrl'] ?? '',
            downloads: (data['downloads'] ?? 0).toInt(),
            teacherName: data['teacherName'] ?? 'Teacher',
            createdAt: data['createdAt'],
          );
        }).toList();

        _isLoading = false;
        _isRefreshing = false;
        _updateClassFilters();
      });
    } catch (e) {
      print('Error loading notes: $e');
      _showError('Error loading notes');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  String _normalizeClassName(String className) {
    return className
        .toLowerCase()
        .replaceAll('+', '')
        .replaceAll('section', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim();
  }

  void _updateClassFilters() {
    Set<String> uniqueFilters = {'My Class'}; // Changed to start with My Class

    // Add "All Classes" option
    uniqueFilters.add('All Classes');

    for (var classData in _availableClasses) {
      uniqueFilters.add(classData['displayName']);
    }

    for (var note in allNotes) {
      if (note.className.isNotEmpty && note.className != 'Unknown') {
        bool foundMatch = false;
        for (var classData in _availableClasses) {
          if (_normalizeClassName(note.className) ==
              _normalizeClassName(classData['combinedName'])) {
            foundMatch = true;
            break;
          }
        }
        if (!foundMatch && !uniqueFilters.contains(note.className)) {
          uniqueFilters.add(note.className);
        }
      }
    }

    setState(() {
      classFilters = uniqueFilters.toList()
        ..sort((a, b) {
          if (a == 'My Class') return -1; // My Class first
          if (b == 'My Class') return 1;
          if (a == 'All Classes') return -1;
          if (b == 'All Classes') return 1;
          return a.compareTo(b);
        });
    });
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${_getDayName(date.weekday)} ${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown date';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return 'Unknown size';
    final bytes = size.toDouble();
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  List<Note> get filteredNotes {
    return allNotes.where((note) {
      // Handle "My Class" filter
      if (selectedClass == 'My Class') {
        final matchesMyClass =
            note.classId == _studentClassId ||
            _normalizeClassName(note.className) ==
                _normalizeClassName(_studentClassName) ||
            _normalizeClassName(note.displayClassName) ==
                _normalizeClassName(_studentClassName);
        return matchesMyClass && _matchesSearch(note);
      }

      if (selectedClass == 'All Classes') {
        return _matchesSearch(note);
      }

      bool matchesClass = false;
      if (note.displayClassName == selectedClass) {
        matchesClass = true;
      } else if (note.className == selectedClass) {
        matchesClass = true;
      } else {
        final normalizedNoteClass = _normalizeClassName(note.className);
        final normalizedSelectedClass = _normalizeClassName(selectedClass);
        matchesClass = normalizedNoteClass == normalizedSelectedClass;
      }

      final matchesSearch = _matchesSearch(note);
      return matchesClass && matchesSearch;
    }).toList();
  }

  bool _matchesSearch(Note note) {
    if (searchQuery.isEmpty) return true;

    final query = searchQuery.toLowerCase();
    return note.title.toLowerCase().contains(query) ||
        note.subject.toLowerCase().contains(query) ||
        note.description.toLowerCase().contains(query) ||
        note.className.toLowerCase().contains(query) ||
        note.displayClassName.toLowerCase().contains(query) ||
        note.teacherName.toLowerCase().contains(query);
  }

  void _viewNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentNoteDetailScreen(note: note),
      ),
    );
  }

  Future<void> _downloadNote(Note note) async {
    if (note.fileUrl.isEmpty) {
      _showError('No file available for download');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadProgressDialog(
        fileName: note.fileName,
        fileSize: note.fileSize,
      ),
    );

    try {
      // Increment download count
      await _firestore.collection('notes').doc(note.id).update({
        'downloads': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        note.downloads++;
      });

      final uri = Uri.parse(note.fileUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        Navigator.pop(context);
        _showSuccess('Opening file...');
      } else {
        await Clipboard.setData(ClipboardData(text: note.fileUrl));
        Navigator.pop(context);
        _showSuccess('URL copied to clipboard. Paste in browser to download.');
      }
    } catch (e) {
      Navigator.pop(context);
      print('Download error: $e');
      await Clipboard.setData(ClipboardData(text: note.fileUrl));
      _showSuccess('URL copied to clipboard. Paste in browser to download.');
    }
  }

  void _shareNote(Note note) {
    final text =
        'Check out this note: ${note.title}\nSubject: ${note.subject}\nClass: ${note.displayClassName}\nTeacher: ${note.teacherName}\n\nDownload link: ${note.fileUrl}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShareSheet(note: note, shareText: text),
    );
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
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
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

  Future<void> _refreshNotes() async {
    setState(() => _isRefreshing = true);
    await _loadNotes();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.folder_open,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No notes found'
                  : selectedClass == 'My Class'
                  ? 'No notes available for your class yet'
                  : selectedClass == 'All Classes'
                  ? 'No notes available yet'
                  : 'No notes for $selectedClass',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try a different search term or clear filters'
                  : selectedClass == 'My Class'
                  ? 'Your teacher will upload notes soon'
                  : 'Check back later for new study materials',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (selectedClass != 'All Classes')
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedClass = 'All Classes';
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.explore),
                label: const Text('View All Classes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshNotes,
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    children: [
                      // Custom App Bar
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2196F3,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Color(0xFF2196F3),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedClass == 'My Class'
                                            ? 'My Class Notes'
                                            : selectedClass == 'All Classes'
                                            ? 'All Notes'
                                            : selectedClass,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_studentClassName.isNotEmpty)
                                        Text(
                                          'Your Class: $_studentClassName',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
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
                                    color: const Color(
                                      0xFF2196F3,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${filteredNotes.length} notes',
                                    style: const TextStyle(
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2196F3,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isGridView
                                          ? Icons.view_list
                                          : Icons.grid_view,
                                      color: const Color(0xFF2196F3),
                                    ),
                                    onPressed: () => setState(
                                      () => isGridView = !isGridView,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Search Bar
                            TextField(
                              onChanged: (value) =>
                                  setState(() => searchQuery = value),
                              decoration: InputDecoration(
                                hintText: selectedClass == 'My Class'
                                    ? 'Search notes in your class...'
                                    : 'Search notes by title, subject, or teacher...',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF2196F3),
                                ),
                                suffixIcon: searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () =>
                                            setState(() => searchQuery = ''),
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Class Filters
                      if (classFilters.length > 1)
                        Container(
                          height: 70,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ...classFilters.map((className) {
                                final isSelected = selectedClass == className;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (className == 'My Class')
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.star,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        Text(
                                          className,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize:
                                                className == 'My Class' ||
                                                    className == 'All Classes'
                                                ? 14
                                                : 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedClass = selected
                                            ? className
                                            : 'My Class'; // Default back to My Class when unselected
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor: const Color(0xFF2196F3),
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    showCheckmark: className != 'My Class',
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                      // Stats Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedClass == 'My Class'
                                  ? 'Notes for your class'
                                  : 'Showing ${filteredNotes.length} of ${allNotes.length} notes',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (selectedClass != 'My Class')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  selectedClass,
                                  style: const TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Notes List/Grid
                      Expanded(
                        child: filteredNotes.isEmpty
                            ? _buildEmptyState()
                            : isGridView
                            ? GridView.builder(
                                padding: const EdgeInsets.all(20),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85,
                                    ),
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  return StudentNoteGridCard(
                                    note: filteredNotes[index],
                                    onTap: () =>
                                        _viewNote(filteredNotes[index]),
                                    onDownload: () =>
                                        _downloadNote(filteredNotes[index]),
                                    onShare: () =>
                                        _shareNote(filteredNotes[index]),
                                  );
                                },
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  return StudentNoteListCard(
                                    note: filteredNotes[index],
                                    onTap: () =>
                                        _viewNote(filteredNotes[index]),
                                    onDownload: () =>
                                        _downloadNote(filteredNotes[index]),
                                    onShare: () =>
                                        _shareNote(filteredNotes[index]),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// Note Model
class Note {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String className;
  final String displayClassName;
  final String classId;
  final String dateUploaded;
  final String fileSize;
  final String fileType;
  final String fileName;
  final String fileUrl;
  final String teacherName;
  int downloads;
  final dynamic createdAt;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className,
    required this.displayClassName,
    required this.classId,
    required this.dateUploaded,
    required this.fileSize,
    required this.fileType,
    required this.fileName,
    required this.fileUrl,
    required this.downloads,
    required this.teacherName,
    required this.createdAt,
  });
}

// Student Note List Card (No delete option)
class StudentNoteListCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const StudentNoteListCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onDownload,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getFileColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getFileIcon(), color: _getFileColor()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                note.displayClassName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.subject,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.subject,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.teacherName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      switch (value) {
                        case 'download':
                          onDownload();
                          break;
                        case 'share':
                          onShare();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(
                              Icons.download,
                              size: 20,
                              color: Color(0xFF2196F3),
                            ),
                            SizedBox(width: 8),
                            Text('Download'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(
                              Icons.share,
                              size: 20,
                              color: Color(0xFF2196F3),
                            ),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${note.fileSize} • ${note.fileType}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.download, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${note.downloads} downloads',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    note.dateUploaded,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (note.fileType.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'IMAGE':
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Icons.image;
      case 'TEXT':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (note.fileType.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'DOC':
      case 'DOCX':
        return Colors.blue;
      case 'IMAGE':
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Colors.green;
      case 'TEXT':
        return Colors.orange;
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// Student Note Grid Card
class StudentNoteGridCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const StudentNoteGridCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onDownload,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getFileColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getFileIcon(),
                      color: _getFileColor(),
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      note.displayClassName.split(' ').last,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                note.subject,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'By ${note.teacherName}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.download, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${note.downloads}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.insert_drive_file,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      note.fileSize,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (note.fileType.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'IMAGE':
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Icons.image;
      case 'TEXT':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (note.fileType.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'DOC':
      case 'DOCX':
        return Colors.blue;
      case 'IMAGE':
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Colors.green;
      case 'TEXT':
        return Colors.orange;
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// Student Note Detail Screen (Read-only)
class StudentNoteDetailScreen extends StatelessWidget {
  final Note note;

  const StudentNoteDetailScreen({Key? key, required this.note})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () => _downloadFile(context),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () => _shareFile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getFileColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(_getFileIcon(), size: 60, color: _getFileColor()),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              note.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Subject & Class
            Text(
              '${note.subject} • ${note.displayClassName}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Description
            if (note.description.isNotEmpty) ...[
              Text(
                note.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Uploaded',
                    note.dateUploaded,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.school, 'Teacher', note.teacherName),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.insert_drive_file,
                    'File Size',
                    note.fileSize,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.download,
                    'Downloads',
                    '${note.downloads} times',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // File Preview Section
            const Text(
              'File Preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getFileIcon(), size: 64, color: _getFileColor()),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        note.fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.fileType,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _downloadFile(context),
                      icon: const Icon(Icons.download),
                      label: const Text('Download File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getFileColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[700])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (note.fileUrl.isEmpty) return;

    try {
      final uri = Uri.parse(note.fileUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        await Clipboard.setData(ClipboardData(text: note.fileUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL copied to clipboard. Paste in browser.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    final text =
        'Check out this note: ${note.title}\nSubject: ${note.subject}\nClass: ${note.displayClassName}\nTeacher: ${note.teacherName}\n\nDownload link: ${note.fileUrl}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShareSheet(note: note, shareText: text),
    );
  }

  IconData _getFileIcon() {
    switch (note.fileType.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'IMAGE':
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Icons.image;
      case 'TEXT':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (note.fileType.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'DOC':
      case 'DOCX':
        return Colors.blue;
      case 'IMAGE':
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Colors.green;
      case 'TEXT':
        return Colors.orange;
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// Share Sheet
class ShareSheet extends StatelessWidget {
  final Note note;
  final String shareText;

  const ShareSheet({Key? key, required this.note, required this.shareText})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share Note',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            note.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${note.subject} • ${note.displayClassName}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(Icons.email, 'Email', Colors.red),
              _buildShareOption(Icons.message, 'WhatsApp', Colors.green),
              _buildShareOption(Icons.link, 'Copy Link', Colors.blue),
              _buildShareOption(Icons.file_copy, 'Save', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Download Progress Dialog
class DownloadProgressDialog extends StatelessWidget {
  final String fileName;
  final String fileSize;

  const DownloadProgressDialog({
    Key? key,
    required this.fileName,
    required this.fileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Downloading...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              fileName,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              fileSize,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
