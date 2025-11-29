import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utils/helper/helper_snackbar.dart';

class ClassSectionsTab extends StatefulWidget {
  const ClassSectionsTab({super.key});

  @override
  State<ClassSectionsTab> createState() => _ClassSectionsTabState();
}

class _ClassSectionsTabState extends State<ClassSectionsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search classes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 2, 18, 69),
                onPressed: () => _showAddEditDialog(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Classes')
                .orderBy('createat', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No classes found. Add one to get started!'),
                );
              }

              // Filter documents based on search query
              final filteredDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final section = (data['section'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) || section.contains(_searchQuery);
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Text('No classes match your search.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final className = data['name'] ?? 'Unknown';
                  final section = data['section'] ?? '';
                  final docId = doc.id;

                  // Extract class number for avatar (e.g., "10" from "Class 10")
                  final classNumber = className.replaceAll(RegExp(r'[^0-9]'), '');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          classNumber.isNotEmpty ? classNumber : className[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '$className${section.isNotEmpty ? " - Section $section" : ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Tap to manage class details',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showAddEditDialog(
                              context,
                              docId: docId,
                              className: className,
                              section: section,
                            );
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, docId, className);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEditDialog(
    BuildContext context, {
    String? docId,
    String? className,
    String? section,
  }) {
    final classNameController = TextEditingController(text: className ?? '');
    final sectionController = TextEditingController(text: section ?? '');
    final isEditing = docId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Class Section' : 'Add Class Section'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: classNameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name (e.g., Class 10)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section (e.g., A, B, C)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 18, 69),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (classNameController.text.isEmpty) {
                CustomSnackBar.show(
                  context,
                  message: "CLASS NAME IS REQUIRED",
                  status: SnackBarStatus.error,
                );
                return;
              }

              try {
                final data = {
                  'name': classNameController.text.trim(),
                  'section': sectionController.text.trim(),
                  'status': 1,
                };

                if (isEditing) {
                  // Update existing document
                  await FirebaseFirestore.instance
                      .collection('Classes')
                      .doc(docId)
                      .update(data);

                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomSnackBar.show(
                      context,
                      message: "CLASS UPDATED SUCCESSFULLY",
                      status: SnackBarStatus.success,
                    );
                  }
                } else {
                  // Add new document
                  data['createat'] = DateTime.now();
                  
                  final docRef = await FirebaseFirestore.instance
                      .collection('Classes')
                      .add(data);

                  await docRef.update({'id': docRef.id});

                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomSnackBar.show(
                      context,
                      message: "CLASS ADDED SUCCESSFULLY",
                      status: SnackBarStatus.success,
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  CustomSnackBar.show(
                    context,
                    message: "ERROR: ${e.toString()}",
                    status: SnackBarStatus.error,
                  );
                }
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class Section'),
        content: Text(
          'Are you sure you want to delete "$className"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('Classes')
                    .doc(docId)
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackBar.show(
                    context,
                    message: "CLASS DELETED SUCCESSFULLY",
                    status: SnackBarStatus.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackBar.show(
                    context,
                    message: "ERROR DELETING CLASS: ${e.toString()}",
                    status: SnackBarStatus.error,
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}