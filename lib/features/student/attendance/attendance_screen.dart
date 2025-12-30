// features/student/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _studentId;
  String? _studentName;
  String? _rollNumber;
  String? _className;

  List<DocumentSnapshot> _attendanceRecords = [];
  Map<String, Map<String, dynamic>> _monthlyStats = {};
  Map<String, int> _yearlyStats = {
    'present': 0,
    'absent': 0,
    'leave': 0,
    'total': 0,
  };

  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;
  bool _showStats = true;
  String _filterStatus = 'All'; // 'All', 'Present', 'Absent', 'Leave'
  String _timeFilter = 'This Month'; // 'This Month', 'Last Month', 'Custom'

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() => _isLoading = true);

      // Get student document
      final studentDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _studentId = studentDoc.id;
          _studentName = studentData['name'] ?? 'Student';
          _rollNumber = studentData['rollNumber']?.toString() ?? 'N/A';
          _className = studentData['className'] ?? 'Unknown Class';
        });

        await _loadAttendanceRecords();
        await _calculateStats();
      }
    } catch (e) {
      print('Error loading student data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendanceRecords() async {
    if (_studentId == null) return;

    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (_timeFilter) {
        case 'This Month':
          startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          break;
        case 'Last Month':
          final lastMonth = DateTime(
            _selectedMonth.year,
            _selectedMonth.month - 1,
            1,
          );
          startDate = DateTime(lastMonth.year, lastMonth.month, 1);
          endDate = DateTime(lastMonth.year, lastMonth.month + 1, 0);
          break;
        case 'Custom':
        default:
          // Last 30 days
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_studentId)
          .collection('attendance')
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('dateTime', descending: true)
          .get();

      setState(() {
        _attendanceRecords = querySnapshot.docs;
      });
    } catch (e) {
      print('Error loading attendance records: $e');
    }
  }

  Future<void> _calculateStats() async {
    if (_studentId == null) return;

    try {
      // Reset stats
      _monthlyStats.clear();
      setState(() {
        _yearlyStats = {'present': 0, 'absent': 0, 'leave': 0, 'total': 0};
      });

      // Get current year's attendance
      final startOfYear = DateTime(DateTime.now().year, 1, 1);

      final yearlyQuery = await _firestore
          .collection('users')
          .doc(_studentId)
          .collection('attendance')
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear),
          )
          .get();

      // Calculate yearly stats
      for (var record in yearlyQuery.docs) {
        final data = record.data() as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status != null) {
          if (_yearlyStats.containsKey(status.toLowerCase())) {
            _yearlyStats[status.toLowerCase()] =
                _yearlyStats[status.toLowerCase()]! + 1;
          }
          _yearlyStats['total'] = _yearlyStats['total']! + 1;
        }
      }

      // Calculate monthly stats for current year
      final monthlyGroup = <String, Map<String, int>>{};
      for (var record in yearlyQuery.docs) {
        final data = record.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        final dateTime = (data['dateTime'] as Timestamp?)?.toDate();

        if (dateTime != null && status != null) {
          final monthKey = DateFormat('yyyy-MM').format(dateTime);

          if (!monthlyGroup.containsKey(monthKey)) {
            monthlyGroup[monthKey] = {
              'present': 0,
              'absent': 0,
              'leave': 0,
              'total': 0,
            };
          }

          monthlyGroup[monthKey]![status.toLowerCase()] =
              monthlyGroup[monthKey]![status.toLowerCase()]! + 1;
          monthlyGroup[monthKey]!['total'] =
              monthlyGroup[monthKey]!['total']! + 1;
        }
      }

      setState(() {
        _monthlyStats = monthlyGroup.map(
          (key, value) => MapEntry(key, value as Map<String, dynamic>),
        );
      });
    } catch (e) {
      print('Error calculating stats: $e');
    }
  }

  Widget _buildHeader() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  radius: 30,
                  child: Icon(Icons.person, size: 30, color: Colors.blue[800]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentName ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll No: ${_rollNumber ?? 'N/A'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        'Class: ${_className ?? 'Unknown'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick stats bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    'Total',
                    _yearlyStats['total']?.toString() ?? '0',
                    Colors.blue,
                  ),
                  _buildQuickStat(
                    'Present',
                    _yearlyStats['present']?.toString() ?? '0',
                    Colors.green,
                  ),
                  _buildQuickStat(
                    'Absent',
                    _yearlyStats['absent']?.toString() ?? '0',
                    Colors.red,
                  ),
                  _buildQuickStat(
                    'Leave',
                    _yearlyStats['leave']?.toString() ?? '0',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Time Filter
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Period:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _timeFilter,
                  onChanged: (value) {
                    setState(() {
                      _timeFilter = value!;
                    });
                    _loadAttendanceRecords();
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: 'Last Month',
                      child: Text('Last Month'),
                    ),
                    DropdownMenuItem(
                      value: 'Custom',
                      child: Text('Last 30 Days'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status Filter
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Present', child: Text('Present')),
                    DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                    DropdownMenuItem(value: 'Leave', child: Text('Leave')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attendanceRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No attendance records found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Period: $_timeFilter',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Filter records by status
    List<DocumentSnapshot> filteredRecords = _attendanceRecords;
    if (_filterStatus != 'All') {
      filteredRecords = _attendanceRecords.where((record) {
        final data = record.data() as Map<String, dynamic>;
        return (data['status'] as String?) == _filterStatus;
      }).toList();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        final data = record.data() as Map<String, dynamic>;
        final dateStr = data['date'] as String? ?? 'Unknown';
        final status = data['status'] as String? ?? 'Unknown';
        final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
        final markedBy = data['markedByEmail'] as String? ?? 'Unknown';
        final className = data['className'] as String? ?? _className;

        DateTime date;
        try {
          date = dateTime ?? DateTime.parse(dateStr);
        } catch (e) {
          date = DateTime.now();
        }

        Color statusColor = _getStatusColor(status);
        IconData statusIcon = _getStatusIcon(status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 1,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            title: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Class: $className'),
                Text('Marked by: ${markedBy.split('@')[0]}'),
                if (data['markedAt'] != null)
                  Text(
                    'Time: ${DateFormat('hh:mm a').format((data['markedAt'] as Timestamp).toDate())}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              _showAttendanceDetails(data);
            },
          ),
        );
      },
    );
  }

  Widget _buildMonthlyStats() {
    if (_monthlyStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No monthly statistics available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final monthStats = _monthlyStats[currentMonth];

    if (monthStats == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No attendance data for current month',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final total = monthStats['total'] ?? 0;
    final present = monthStats['present'] ?? 0;
    final absent = monthStats['absent'] ?? 0;
    final leave = monthStats['leave'] ?? 0;
    final percentage = total > 0 ? (present / total * 100) : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'This Month Statistics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attendance Rate: ${percentage.toStringAsFixed(1)}%'),
                    Text('$present/$total days'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  color: _getAttendanceColor(percentage),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatItem('Present', present.toString(), Colors.green),
                _buildStatItem('Absent', absent.toString(), Colors.red),
                _buildStatItem('Leave', leave.toString(), Colors.orange),
                _buildStatItem('Total Days', total.toString(), Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'leave':
        return Icons.airplane_ticket;
      default:
        return Icons.help;
    }
  }

  void _showAttendanceDetails(Map<String, dynamic> data) {
    final dateStr = data['date'] as String? ?? 'Unknown';
    final status = data['status'] as String? ?? 'Unknown';
    final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
    final markedBy = data['markedByEmail'] as String? ?? 'Unknown';
    final markedAt = (data['markedAt'] as Timestamp?)?.toDate();
    final className = data['className'] as String? ?? _className;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attendance Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem(
                  'Date',
                  DateFormat(
                    'EEEE, MMMM d, yyyy',
                  ).format(dateTime ?? DateTime.parse(dateStr)),
                ),
                _buildDetailItem('Status', status),
                _buildDetailItem('Class', className ?? 'Unknown'),
                _buildDetailItem('Marked by', markedBy.split('@')[0]),
                if (markedAt != null)
                  _buildDetailItem(
                    'Marked at',
                    DateFormat('hh:mm a').format(markedAt),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
            icon: Icon(_showStats ? Icons.list : Icons.bar_chart),
            tooltip: _showStats ? 'Show List' : 'Show Stats',
          ),
          IconButton(
            onPressed: _loadStudentData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _studentName == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header with student info
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Filters
                  _buildFilters(),
                  const SizedBox(height: 16),

                  if (_showStats) ...[
                    // Monthly Statistics
                    _buildMonthlyStats(),
                    const SizedBox(height: 16),
                  ],

                  // Attendance List Header
                  Row(
                    children: [
                      Text(
                        'Attendance Records (${_attendanceRecords.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_filterStatus != 'All')
                        Chip(
                          label: Text(_filterStatus),
                          onDeleted: () {
                            setState(() => _filterStatus = 'All');
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Attendance List
                  _buildAttendanceList(),
                ],
              ),
            ),
    );
  }
}
