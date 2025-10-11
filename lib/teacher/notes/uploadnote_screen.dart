import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadnoteScreen extends StatefulWidget {
  const UploadnoteScreen({super.key});

  @override
  State<UploadnoteScreen> createState() => _UploadnoteScreenState();
}

class _UploadnoteScreenState extends State<UploadnoteScreen> {
  String? selectedClass;
  String? selectedSubject;
  final TextEditingController titleController = TextEditingController();

  final List<String> classes = ['Class 6', 'Class 7', 'Class 8'];
  final List<String> subjects = ['Math', 'Science', 'English'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuition Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Profile action
            },
          )
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Upload Notes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Class Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Class',
                border: OutlineInputBorder(),
              ),
              value: selectedClass,
              items: classes
                  .map((cls) => DropdownMenuItem(
                        value: cls,
                        child: Text(cls),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedClass = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Subject Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              value: selectedSubject,
              items: subjects
                  .map((sub) => DropdownMenuItem(
                        value: sub,
                        child: Text(sub),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSubject = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // File Upload Box
            DottedBorderBox(),

            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Save action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatefulWidget {
  const DottedBorderBox({super.key});

  @override
  State<DottedBorderBox> createState() => _DottedBorderBoxState();
}

class _DottedBorderBoxState extends State<DottedBorderBox> {
   FilePickerResult? _filePickerResult;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  // Function to handle file picking
  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePickerResult = result;
      });
    }
  }
}
