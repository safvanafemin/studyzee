import 'package:flutter/material.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Fees',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const Text(
              'Pending Fees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Pending Fee Card for May Tuition
            FeeCard(
              title: 'May Tuition Fee',
              dueDate: 'Due: May 25, 2025',
              amount: '₹5,000',
              icon: Icons.pending_actions,
              iconColor: Colors.orange,
              buttonText: 'Pay Now',
              buttonColor: Colors.orange.shade600,
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            // Section Title
            const Text(
              'Paid Fees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Paid Fee Card for April Tuition
            FeeCard(
              title: 'April Tuition Fee',
              dueDate: 'Paid: Apr 20, 2025',
              amount: '₹5,000',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              buttonText: 'View Receipt',
              buttonColor: Colors.green.shade600,
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            // Paid Fee Card for March Tuition
            FeeCard(
              title: 'March Tuition Fee',
              dueDate: 'Paid: Mar 20, 2025',
              amount: '₹5,000',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              buttonText: 'View Receipt',
              buttonColor: Colors.green.shade600,
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            // Section Title
            const Text(
              'Late Fees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Late Fee Card for February Tuition
            FeeCard(
              title: 'February Tuition Fee',
              dueDate: 'Late: Mar 01, 2025',
              amount: '₹5,000',
              icon: Icons.warning,
              iconColor: Colors.red,
              buttonText: 'Pay Now',
              buttonColor: Colors.red.shade600,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class FeeCard extends StatelessWidget {
  final String title;
  final String dueDate;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;

  const FeeCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}