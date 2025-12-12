import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyzee/teacher/notes/uploadnote_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with TickerProviderStateMixin {
  String selectedClass = 'All Classes';
  String searchQuery = '';
  late AnimationController _fadeController;
  late AnimationController _listController;
  bool isGridView = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> classFilters = ['All Classes'];
  List<Note> allNotes = [];
  List<Map<String, dynamic>> _availableClasses = []; // Store classes data
  bool _isLoading = true;
  bool _isRefreshing = false;

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

    _loadClassesAndNotes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadClassesAndNotes() async {
    try {
      // Load all classes from Classes collection
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
            'combinedName': combinedName, // Format: "Class 12 - A"
          };
        }).toList();

        // Create filter options
        _updateClassFilters();
      });

      // Load notes
      await _loadNotes();
    } catch (e) {
      print('Error loading classes: $e');
      _showError('Error loading classes');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNotes() async {
    try {
      // Load all notes
      final notesSnapshot = await _firestore
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        allNotes = notesSnapshot.docs.map((doc) {
          final data = doc.data();

          // Get className from data (this might be "+2 - A" or other format)
          final className = data['className'] ?? 'Unknown';

          // Try to match this className with available classes
          String matchedDisplayName = className;
          for (var classData in _availableClasses) {
            // Try different matching strategies
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
            className: className, // Original from Firestore
            displayClassName: matchedDisplayName, // For display and filtering
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

        // Debug: Print class matching results
        _debugClassMatching();
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
    // Normalize class names for comparison
    return className
        .toLowerCase()
        .replaceAll('+', '') // Remove + sign
        .replaceAll('section', '') // Remove "section" word
        .replaceAll('-', '') // Remove hyphens
        .replaceAll(' ', '') // Remove spaces
        .trim();
  }

  void _debugClassMatching() {
    print('=== CLASS MATCHING DEBUG ===');
    print('Available classes from Classes collection:');
    for (var classData in _availableClasses) {
      print(
        '  - ${classData['name']} | ${classData['section']} | Combined: ${classData['combinedName']}',
      );
    }

    print('\nNotes and their class names:');
    for (var note in allNotes.take(10)) {
      print(
        '  - "${note.title}" => Original: "${note.className}" | Display: "${note.displayClassName}"',
      );
    }

    print('\nUnique class names in notes:');
    final uniqueClasses = allNotes.map((n) => n.className).toSet();
    for (var className in uniqueClasses) {
      print('  - $className');
    }
    print('==========================');
  }

  void _updateClassFilters() {
    // Create filter options from available classes
    Set<String> uniqueFilters = {'All Classes'};

    for (var classData in _availableClasses) {
      uniqueFilters.add(classData['displayName']); // "Class 12 - Section A"
    }

    // Also check if notes have different class names
    for (var note in allNotes) {
      if (note.className.isNotEmpty && note.className != 'Unknown') {
        // Try to find if this className matches any available class
        bool foundMatch = false;
        for (var classData in _availableClasses) {
          if (_normalizeClassName(note.className) ==
              _normalizeClassName(classData['combinedName'])) {
            foundMatch = true;
            break;
          }
        }

        // If no match found, add the original className as a filter option
        if (!foundMatch && !uniqueFilters.contains(note.className)) {
          uniqueFilters.add(note.className);
        }
      }
    }

    setState(() {
      classFilters = uniqueFilters.toList()
        ..sort((a, b) {
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
      // If "All Classes" is selected, show all notes
      if (selectedClass == 'All Classes') {
        return _matchesSearch(note);
      }

      // Check if note matches selected class
      bool matchesClass = false;

      // Try multiple matching strategies
      if (note.displayClassName == selectedClass) {
        matchesClass = true;
      } else if (note.className == selectedClass) {
        matchesClass = true;
      } else {
        // Try normalized matching
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
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
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
      // Increment download count in Firestore
      await _firestore.collection('notes').doc(note.id).update({
        'downloads': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local note
      setState(() {
        note.downloads++;
      });

      // Try to open the URL
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
        // If can't launch, copy URL to clipboard
        await Clipboard.setData(ClipboardData(text: note.fileUrl));
        Navigator.pop(context);
        _showSuccess('URL copied to clipboard. Paste in browser to download.');
      }
    } catch (e) {
      Navigator.pop(context);
      print('Download error: $e');

      // Fallback: Copy URL to clipboard
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

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Delete Note?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently delete "${note.title}".'),
            const SizedBox(height: 8),
            Text(
              'Class: ${note.displayClassName}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Subject: ${note.subject}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('This action cannot be undone.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(note);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Note note) async {
    try {
      // Delete from Firestore
      await _firestore.collection('notes').doc(note.id).delete();

      // Update local list
      setState(() {
        allNotes.removeWhere((n) => n.id == note.id);
        _updateClassFilters(); // Update filters after deletion
      });

      _showSuccess('Note deleted successfully');
    } catch (e) {
      _showError('Error deleting note: $e');
    }
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
                  : selectedClass == 'All Classes'
                  ? 'No notes available'
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
                  : selectedClass == 'All Classes'
                  ? 'Upload your first note to get started'
                  : 'Try selecting "All Classes" or upload notes for this class',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!searchQuery.isNotEmpty && selectedClass == 'All Classes')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadnoteScreen(),
                    ),
                  ).then((_) => _refreshNotes());
                },
                icon: const Icon(Icons.add),
                label: const Text('Upload Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedClass = 'All Classes';
                  searchQuery = '';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
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
                                  child: Text(
                                    selectedClass == 'All Classes'
                                        ? 'All Notes (${allNotes.length})'
                                        : '$selectedClass (${filteredNotes.length})',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                                hintText:
                                    'Search notes by title, subject, class or teacher...',
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

                      // Class Filters with Scroll
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
                                    label: Text(
                                      className,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: className == 'All Classes'
                                            ? 14
                                            : 13,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedClass = selected
                                            ? className
                                            : 'All Classes';
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
                                    showCheckmark: true,
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
                              'Showing ${filteredNotes.length} of ${allNotes.length} notes',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (selectedClass != 'All Classes')
                              Text(
                                'Filtered by: $selectedClass',
                                style: TextStyle(
                                  color: const Color(0xFF2196F3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
                                  return NoteGridCard(
                                    note: filteredNotes[index],
                                    onTap: () =>
                                        _viewNote(filteredNotes[index]),
                                    onDownload: () =>
                                        _downloadNote(filteredNotes[index]),
                                    onShare: () =>
                                        _shareNote(filteredNotes[index]),
                                    onDelete: () =>
                                        _deleteNote(filteredNotes[index]),
                                  );
                                },
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  return NoteListCard(
                                    note: filteredNotes[index],
                                    onTap: () =>
                                        _viewNote(filteredNotes[index]),
                                    onDownload: () =>
                                        _downloadNote(filteredNotes[index]),
                                    onShare: () =>
                                        _shareNote(filteredNotes[index]),
                                    onDelete: () =>
                                        _deleteNote(filteredNotes[index]),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadnoteScreen()),
          ).then((_) {
            // Refresh notes when returning from upload screen
            _refreshNotes();
          });
        },
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add),
        label: const Text('Upload Note'),
      ),
    );
  }
}

// Updated Note Model with displayClassName
class Note {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String className; // Original from Firestore (e.g., "+2 - A")
  final String
  displayClassName; // Formatted for display (e.g., "Class 12 - Section A")
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

// Note List Card (updated to use displayClassName)
class NoteListCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const NoteListCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onDownload,
    required this.onShare,
    required this.onDelete,
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
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 8),
                            Text('Download'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
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

// Note Grid Card (updated to use displayClassName)
class NoteGridCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const NoteGridCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onDownload,
    required this.onShare,
    required this.onDelete,
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
                note.displayClassName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                note.subject,
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
                  Text(
                    note.fileSize,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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

// Note Detail Screen (updated to use displayClassName)
class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

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
        // Fallback: Copy URL to clipboard
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

// Share Sheet (updated to use displayClassName)
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

// Download Progress Dialog (keep existing)
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
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
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
