import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9ff),
      appBar: AppBar(
        title: const Text(
          'Progress Report',
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
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 24),

              // Student Info
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blue.shade100,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shabnam',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1f2937),
                          ),
                        ),
                        Text(
                          'Grade 8',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Overall Grade
              _buildOverallGradeCard(85),

              const SizedBox(height: 32),

              // Chart Area
              _buildChart(),

              const SizedBox(height: 32),

              // Performance Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Maths',
                      '85%',
                      '100',
                      Colors.blue,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Science',
                      '92%',
                      '100',
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'English',
                      '78%',
                      '100',
                      Colors.orange,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'History',
                      '65%',
                      '100',
                      Colors.red,
                      Icons.trending_down,
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

  Widget _buildOverallGradeCard(int grade) {
    Color gradeColor;
    if (grade >= 90) {
      gradeColor = Colors.green;
    } else if (grade >= 80) {
      gradeColor = Colors.blue;
    } else if (grade >= 70) {
      gradeColor = Colors.orange;
    } else {
      gradeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Overall Grade: ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gradeColor,
            ),
          ),
          Text(
            '$grade%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gradeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(left: 30, right: 10),
      child: Stack(
        children: [
          // Y-axis grid lines and labels
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGridLineAndLabel('100', true),
                _buildGridLineAndLabel('80'),
                _buildGridLineAndLabel('60'),
                _buildGridLineAndLabel('40'),
                _buildGridLineAndLabel('20'),
                _buildGridLineAndLabel('0', true),
              ],
            ),
          ),

          // Chart area
          Positioned(
            left: 30,
            right: 0,
            top: 0,
            bottom: 30,
            child: CustomPaint(painter: LineChartPainter()),
          ),

          // X-axis labels
          Positioned(
            left: 30,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Maths',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Science',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'English',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'History',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLineAndLabel(String label, [bool bold = false]) {
    return Row(
      children: [
        SizedBox(
          width: 25,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String total,
    Color color,
    IconData? icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ' / $total',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
              ),
            ],
          ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(icon, color: color, size: 20),
            ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Subject scores
    final scores = {
      'Maths': 85.0,
      'Science': 92.0,
      'English': 78.0,
      'History': 65.0,
    };

    // Determine the width for each subject
    final double subjectWidth = size.width / scores.length;
    final List<Offset> points = [];
    final List<Color> colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];
    final List<String> subjects = scores.keys.toList();

    for (int i = 0; i < scores.length; i++) {
      final score = scores[subjects[i]]!;
      // Scale the score to the chart's height. 100% is at the top (0), 0% is at the bottom (size.height).
      final y = size.height - (score / 100.0) * size.height;
      final x = (i + 0.5) * subjectWidth;
      points.add(Offset(x, y));
    }

    // Draw lines
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      paint.color = Colors
          .blue
          .shade600; // Use a single color for the line for simplicity
      canvas.drawPath(path, paint);
    }

    // Draw points and score labels
    for (int i = 0; i < points.length; i++) {
      pointPaint.color = colors[i];
      canvas.drawCircle(points[i], 5, pointPaint);

      // Draw score label above the point
      textPainter.text = TextSpan(
        text: '${scores[subjects[i]]!.toInt()}%',
        style: TextStyle(
          color: colors[i],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          points[i].dy - textPainter.height - 5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
