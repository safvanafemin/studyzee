// features/parent/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({super.key});

  @override
  State<ParentAttendanceScreen> createState() => _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState extends State<ParentAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Parent data
  Map<String, dynamic>? _parentData;
  List<Map<String, dynamic>> _children = [];
  String? _selectedChildId;
  Map<String, dynamic>? _selectedChild;

  // Date selection
  DateTime _selectedDate = DateTime.now();
  DateTimeRange? _selectedDateRange;
  bool _isMonthView = true;

  // Attendance data
  List<Map<String, dynamic>> _attendanceRecords = [];
  Map<String, dynamic> _monthlyStats = {};
  Map<String, List<Map<String, dynamic>>> _attendanceByDate = {};

  // Loading states
  bool _isLoading = true;
  bool _isLoadingAttendance = false;

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _parentData = userDoc.data() as Map<String, dynamic>;

        // Load children data
        await _loadChildrenData();
      }
    } catch (e) {
      print('Error loading parent data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChildrenData() async {
    try {
      final children = _parentData?['children'] as List<dynamic>? ?? [];

      for (var childId in children) {
        final childDoc = await _firestore
            .collection('users')
            .doc(childId.toString())
            .get();
        if (childDoc.exists) {
          final childData = childDoc.data() as Map<String, dynamic>;
          _children.add({
            'id': childId,
            'name': childData['name'] ?? 'Unknown',
            'class': childData['className'] ?? 'Unknown',
            'rollNumber': childData['rollNumber'] ?? '',
            'classId': childData['classId'] ?? '',
          });
        }
      }

      // Select first child by default
      if (_children.isNotEmpty) {
        setState(() {
          _selectedChildId = _children.first['id'];
          _selectedChild = _children.first;
        });
        await _loadAttendanceData();
      }
    } catch (e) {
      print('Error loading children data: $e');
    }
  }

  Future<void> _loadAttendanceData() async {
    if (_selectedChildId == null) return;

    setState(() => _isLoadingAttendance = true);

    try {
      // Get current month dates
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // Load attendance records for the current month
      final attendanceQuery = await _firestore
          .collection('users')
          .doc(_selectedChildId)
          .collection('attendance')
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'dateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .orderBy('dateTime', descending: true)
          .get();

      _attendanceRecords = attendanceQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'date': data['date'] ?? '',
          'status': data['status'] ?? 'Unknown',
          'dateTime': data['dateTime'] is Timestamp
              ? (data['dateTime'] as Timestamp).toDate()
              : DateTime.now(),
        };
      }).toList();

      // Group by date and calculate statistics
      _processAttendanceData();
    } catch (e) {
      print('Error loading attendance data: $e');
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  void _processAttendanceData() {
    _attendanceByDate.clear();
    _monthlyStats.clear();

    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLeave = 0;
    int totalDays = 0;

    for (var record in _attendanceRecords) {
      final date = record['date'] as String;
      final status = record['status'] as String;

      if (!_attendanceByDate.containsKey(date)) {
        _attendanceByDate[date] = [];
      }
      _attendanceByDate[date]!.add(record);

      // Update stats
      switch (status) {
        case 'Present':
          totalPresent++;
          break;
        case 'Absent':
          totalAbsent++;
          break;
        case 'Leave':
          totalLeave++;
          break;
      }
    }

    // Calculate total days (unique dates)
    totalDays = _attendanceByDate.length;

    // Calculate monthly stats
    _monthlyStats = {
      'totalDays': totalDays,
      'present': totalPresent,
      'absent': totalAbsent,
      'leave': totalLeave,
      'attendanceRate': totalDays > 0 ? (totalPresent / totalDays) * 100 : 0,
    };
  }

  Future<void> _loadAttendanceForDate(DateTime date) async {
    if (_selectedChildId == null) return;

    setState(() => _isLoadingAttendance = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final attendanceDoc = await _firestore
          .collection('users')
          .doc(_selectedChildId)
          .collection('attendance')
          .doc(dateStr)
          .get();

      if (attendanceDoc.exists) {
        final data = attendanceDoc.data() as Map<String, dynamic>;
        setState(() {
          _selectedDate = date;
          _attendanceRecords = [
            {
              'id': attendanceDoc.id,
              ...data,
              'date': data['date'] ?? '',
              'status': data['status'] ?? 'Unknown',
              'dateTime': data['dateTime'] is Timestamp
                  ? (data['dateTime'] as Timestamp).toDate()
                  : DateTime.now(),
            },
          ];
        });
      } else {
        setState(() {
          _selectedDate = date;
          _attendanceRecords = [];
        });
      }
    } catch (e) {
      print('Error loading attendance for date: $e');
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  Widget _buildChildSelector() {
    if (_children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.child_care, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              'No children found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact your school administrator',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Child',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _children.map((child) {
              final isSelected = _selectedChildId == child['id'];
              return ChoiceChip(
                label: Text(
                  child['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedChildId = child['id'];
                      _selectedChild = child;
                    });
                    _loadAttendanceData();
                  }
                },
                selectedColor: const Color(0xFF2196F3),
                backgroundColor: Colors.grey[200],
                avatar: CircleAvatar(
                  backgroundColor: isSelected ? Colors.white : Colors.grey,
                  child: Text(
                    child['rollNumber']?.toString().substring(0, 1) ?? '?',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedChild != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.school, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Class: ${_selectedChild!['class']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.numbers, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Roll: ${_selectedChild!['rollNumber']}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_selectedChild == null || _attendanceRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No attendance data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance will appear here once marked',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final totalDays = _monthlyStats['totalDays'] as int;
    final present = _monthlyStats['present'] as int;
    final absent = _monthlyStats['absent'] as int;
    final leave = _monthlyStats['leave'] as int;
    final attendanceRate = _monthlyStats['attendanceRate'] as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3),
            const Color(0xFF2196F3).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedChild?['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monthly Attendance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.percent, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Present', present.toString(), Colors.green),
              _buildStatItem('Absent', absent.toString(), Colors.red),
              _buildStatItem('Leave', leave.toString(), Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: attendanceRate / 100,
            backgroundColor: Colors.white.withOpacity(0.2),
            color: _getAttendanceRateColor(attendanceRate),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Rate',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              Text(
                '${attendanceRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on $totalDays school days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAttendanceCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Calendar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  _isMonthView
                      ? Icons.calendar_view_day
                      : Icons.calendar_view_month,
                  color: const Color(0xFF2196F3),
                ),
                onPressed: () {
                  setState(() {
                    _isMonthView = !_isMonthView;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _isMonthView ? 400 : 200,
            child: SfDateRangePicker(
              view: _isMonthView
                  ? DateRangePickerView.month
                  : DateRangePickerView.year,
              selectionMode: DateRangePickerSelectionMode.single,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  _loadAttendanceForDate(args.value as DateTime);
                }
              },
              monthViewSettings: const DateRangePickerMonthViewSettings(
                showTrailingAndLeadingDates: false,
              ),
              selectionColor: const Color(0xFF2196F3),
              monthCellStyle: DateRangePickerMonthCellStyle(
                todayCellDecoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2196F3)),
                  shape: BoxShape.circle,
                ),
                specialDatesDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Legend', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem('Present', Colors.green),
              _buildLegendItem('Absent', Colors.red),
              _buildLegendItem('Leave', Colors.orange),
              _buildLegendItem('Holiday', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoadingAttendance) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attendanceRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No attendance for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No attendance was marked for this date',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _attendanceRecords.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final record = _attendanceRecords[index];
        final date = record['date'] as String;
        final status = record['status'] as String;
        final dateTime = record['dateTime'] is DateTime
            ? record['dateTime'] as DateTime
            : DateTime.parse(date);
        final markedBy = record['markedBy'] ?? 'Unknown Teacher';
        final className = record['className'] ?? 'Unknown Class';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(status)),
                ),
                child: Center(
                  child: Text(
                    DateFormat('dd').format(dateTime),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$className • Marked by: $markedBy',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('h:mm a').format(dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle;
      case 'Absent':
        return Icons.cancel;
      case 'Leave':
        return Icons.airline_seat_individual_suite;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
            onPressed: _loadAttendanceData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Child Selector
                  _buildChildSelector(),
                  const SizedBox(height: 20),

                  if (_selectedChild != null) ...[
                    // Stats Card
                    _buildStatsCard(),
                    const SizedBox(height: 20),

                    // Attendance Calendar
                    _buildAttendanceCalendar(),
                    const SizedBox(height: 20),

                    // Selected Date Attendance
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Attendance for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF2196F3),
                                ),
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null &&
                                      picked != _selectedDate) {
                                    _loadAttendanceForDate(picked);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAttendanceList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
    );
  }
}
