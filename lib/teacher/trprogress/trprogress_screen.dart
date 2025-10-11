import 'package:flutter/material.dart';

class TrprogressScreen extends StatefulWidget {
  const TrprogressScreen({super.key});

  @override
  State<TrprogressScreen> createState() => _TeacherProgressScreenState();
}

class _TeacherProgressScreenState extends State<TrprogressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9ff),
      appBar: AppBar(
        title: const Text(
          'Student Progress Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue.shade600,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Class Analytics'),
            Tab(text: 'Individual Student'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassAnalyticsTab(),
          _buildIndividualStudentTab(),
        ],
      ),
    );
  }

  Widget _buildClassAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Selection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.class_, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: 'Class 10 - A',
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: ['Class 10 - A', 'Class 10 - B', 'Class 9 - A']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Overall Statistics Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Class Performance Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox('Total Students', '45', Colors.white),
                    _buildStatBox('Avg Score', '82.5%', Colors.white),
                    _buildStatBox('Passing Rate', '95%', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Subject-wise Performance
          const Text(
            'Subject-wise Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubjectPerformanceChart(),
          const SizedBox(height: 24),

          // Class Performance Metrics
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Attendance',
                  '92%',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Assignment Rate',
                  '88%',
                  Colors.blue,
                  Icons.assignment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Test Avg',
                  '81.3%',
                  Colors.orange,
                  Icons.assessment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Participation',
                  '85%',
                  Colors.purple,
                  Icons.people,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualStudentTab() {
    final students = [
      {
        'name': 'Aarav Sharma',
        'avgScore': 92.0,
        'attendance': 95,
        'trend': 'up',
        'performance': 'Excellent'
      },
      {
        'name': 'Aisha Patel',
        'avgScore': 85.5,
        'attendance': 90,
        'trend': 'up',
        'performance': 'Good'
      },
      {
        'name': 'Bhavna Singh',
        'avgScore': 78.2,
        'attendance': 85,
        'trend': 'flat',
        'performance': 'Average'
      },
      {
        'name': 'Chirag Kumar',
        'avgScore': 88.9,
        'attendance': 92,
        'trend': 'up',
        'performance': 'Excellent'
      },
      {
        'name': 'Diya Verma',
        'avgScore': 72.5,
        'attendance': 80,
        'trend': 'down',
        'performance': 'Needs Improvement'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentCard(
          name: student['name'] as String,
          avgScore: student['avgScore'] as double,
          attendance: student['attendance'] as int,
          trend: student['trend'] as String,
          performance: student['performance'] as String,
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformanceChart() {
    final subjects = [
      {'name': 'Mathematics', 'score': 85.0, 'color': Colors.blue},
      {'name': 'Science', 'score': 82.5, 'color': Colors.green},
      {'name': 'English', 'score': 78.0, 'color': Colors.orange},
      {'name': 'History', 'score': 80.5, 'color': Colors.red},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subjects.map((subject) {
          final score = subject['score'] as double;
          final color = subject['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            )
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard({
    required String name,
    required double avgScore,
    required int attendance,
    required String trend,
    required String performance,
  }) {
    Color performanceColor;
    if (avgScore >= 85) {
      performanceColor = Colors.green;
    } else if (avgScore >= 75) {
      performanceColor = Colors.orange;
    } else {
      performanceColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      performance,
                      style: TextStyle(
                        fontSize: 12,
                        color: performanceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${avgScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: performanceColor,
                    ),
                  ),
                  Icon(
                    trend == 'up'
                        ? Icons.trending_up
                        : trend == 'down'
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    color: trend == 'up'
                        ? Colors.green
                        : trend == 'down'
                            ? Colors.red
                            : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$attendance%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: attendance / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    attendance >= 90 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}