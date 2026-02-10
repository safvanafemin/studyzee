import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import './add_fee_screen.dart';

class FeesManageScreen extends StatefulWidget {
  const FeesManageScreen({super.key});

  @override
  State<FeesManageScreen> createState() => _FeesManageScreenState();
}

class _FeesManageScreenState extends State<FeesManageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Fees'),
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('FeeStructures')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active fee structures found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildFeeCard(doc.id, data);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFeeScreen()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 2, 18, 69),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeeCard(String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Untitled Fee';
    final amount = (data['amount'] ?? 0).toDouble();
    final className = data['className'] ?? 'Unknown Class';
    final dueDate = (data['dueDate'] as Timestamp?)?.toDate();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class: $className'),
            if (dueDate != null)
              Text('Due: ${DateFormat('dd MMM yyyy').format(dueDate)}'),
          ],
        ),
        trailing: Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: View details or edit
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                  Text('Class: $className'),
                  if (dueDate != null)
                    Text(
                      'Due Date: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(data['description'] ?? 'No description'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    // Delete functionality
                    await _firestore
                        .collection('FeeStructures')
                        .doc(id)
                        .delete();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
