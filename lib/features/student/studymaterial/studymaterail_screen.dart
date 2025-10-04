import 'package:flutter/material.dart';

class StudyMaterialScreen extends StatelessWidget {
  const StudyMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9ff),
      appBar: AppBar(
        title: const Text(
          'Study Materials',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            StudyMaterialCard(
              title: 'Calculus II - Integrals',
              subject: 'Mathematics',
              fileType: 'PDF',
              uploadedDate: 'October 26, 2024',
              progress: 0.75,
              icon: Icons.picture_as_pdf,
              iconColor: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            StudyMaterialCard(
              title: 'Introduction to Physics',
              subject: 'Physics',
              fileType: 'Video',
              uploadedDate: 'October 25, 2024',
              progress: 0.50,
              icon: Icons.play_circle_fill,
              iconColor: Colors.blue.shade400,
            ),
            const SizedBox(height: 16),
            StudyMaterialCard(
              title: 'His first flight',
              subject: 'English',
              fileType: 'DOCX',
              uploadedDate: 'October 24, 2024',
              progress: 0.0,
              icon: Icons.description,
              iconColor: Colors.lightGreen.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class StudyMaterialCard extends StatelessWidget {
  final String title;
  final String subject;
  final String fileType;
  final String uploadedDate;
  final double progress;
  final IconData icon;
  final Color iconColor;

  const StudyMaterialCard({
    super.key,
    required this.title,
    required this.subject,
    required this.fileType,
    required this.uploadedDate,
    required this.progress,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subject: $subject',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'File Type: $fileType',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Uploaded: $uploadedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% read',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    // Download/Open action
                  },
                  icon: const Icon(Icons.download, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Share action
                  },
                  icon: const Icon(Icons.share, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
