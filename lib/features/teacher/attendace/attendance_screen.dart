// features/teacher/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:studyzee/features/teacher/students_parent/add_student_parent.dart';

class TrAttendanceScreen extends StatefulWidget {
  const TrAttendanceScreen({super.key});

  @override
  State<TrAttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<TrAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedClassId;
  String? _selectedClassName;
  List<DocumentSnapshot<Map<String, dynamic>>> _classes = [];
  List<DocumentSnapshot<Map<String, dynamic>>> _students = [];

  DateTime _selectedDate = DateTime.now();
  Map<String, String> _attendanceStatus = {}; // studentId -> status
  Map<String, bool> _isSelected = {}; // For checkboxes

  bool _isLoading = false;
  bool _isMarking = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final querySnapshot = await _firestore
          .collection('Classes')
          .orderBy('name') 
          .get();

      setState(() {
        _classes = querySnapshot.docs;
      });
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('classId', isEqualTo: _selectedClassId)
          .get();

      // Alternative query if above doesn't work
      if (querySnapshot.docs.isEmpty) {
        final allStudents = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .get();

        // Filter manually by classId
        final filteredStudents = allStudents.docs.where((student) {
          final data = student.data() as Map<String, dynamic>;
          return data['classId'] == _selectedClassId;
        }).toList();

        setState(() {
          _students = filteredStudents;
        });
      } else {
        setState(() {
          _students = querySnapshot.docs;
        });
      }

      // Initialize attendance status
      _attendanceStatus.clear();
      _isSelected.clear();

      for (var student in _students) {
        _attendanceStatus[student.id] = 'Present';
        _isSelected[student.id] = true;
      }

      // Load today's attendance if exists
      await _loadTodayAttendance();
    } catch (e) {
      print('Error loading students: $e');
      // Try a different approach - get all students and filter manually
      try {
        final allStudents = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .get();

        setState(() {
          _students = allStudents.docs.where((student) {
            final data = student.data() as Map<String, dynamic>;
            return data['classId'] == _selectedClassId;
          }).toList();

          // Initialize attendance status
          _attendanceStatus.clear();
          _isSelected.clear();

          for (var student in _students) {
            _attendanceStatus[student.id] = 'Present';
            _isSelected[student.id] = true;
          }
        });

        await _loadTodayAttendance();
      } catch (e2) {
        print('Error in fallback loading: $e2');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTodayAttendance() async {
    if (_selectedClassId == null || _students.isEmpty) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final attendanceDoc = await _firestore
          .collection('Attendance')
          .doc(_selectedClassId)
          .collection('daily_records')
          .doc(dateStr)
          .get();

      if (attendanceDoc.exists) {
        final data = attendanceDoc.data() as Map<String, dynamic>;
        final studentsAttendance = data['students'] as Map<String, dynamic>?;

        if (studentsAttendance != null) {
          setState(() {
            for (var student in _students) {
              final studentId = student.id;
              // Check if this student has attendance data
              if (studentsAttendance.containsKey(studentId)) {
                final studentAttendanceData =
                    studentsAttendance[studentId] as Map<String, dynamic>?;
                if (studentAttendanceData != null) {
                  final status = studentAttendanceData['status'] as String?;
                  if (status != null) {
                    _attendanceStatus[studentId] = status;
                    // Set checkbox: checked only if Present
                    _isSelected[studentId] = status == 'Present';
                  }
                }
              } else {
                // Student not in attendance record, set default
                _attendanceStatus[studentId] = 'Present';
                _isSelected[studentId] = true;
              }
            }
          });
        } else {
          // No students data in record, set defaults
          setState(() {
            for (var student in _students) {
              _attendanceStatus[student.id] = 'Present';
              _isSelected[student.id] = true;
            }
          });
        }
      } else {
        // No attendance record exists for this date, set defaults
        setState(() {
          for (var student in _students) {
            _attendanceStatus[student.id] = 'Present';
            _isSelected[student.id] = true;
          }
        });
      }
    } catch (e) {
      print('Error loading attendance: $e');
      // Set defaults on error
      setState(() {
        for (var student in _students) {
          _attendanceStatus[student.id] = 'Present';
          _isSelected[student.id] = true;
        }
      });
    }
  }

  Future<void> _markAttendance() async {
    if (_selectedClassId == null || _students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isMarking = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timestamp = FieldValue.serverTimestamp();
      final teacher = _auth.currentUser;

      // Prepare attendance data
      Map<String, dynamic> studentsAttendance = {};
      for (var student in _students) {
        final studentData = student.data() as Map<String, dynamic>;
        studentsAttendance[student.id] = {
          'status': _attendanceStatus[student.id] ?? 'Present',
          'name': studentData['name'] ?? 'Unknown',
          'rollNumber': studentData['rollNumber'] ?? 'N/A',
        };
      }

      // Calculate statistics
      final totalStudents = _students.length;
      final presentCount = _attendanceStatus.values
          .where((s) => s == 'Present')
          .length;
      final absentCount = _attendanceStatus.values
          .where((s) => s == 'Absent')
          .length;
      final leaveCount = _attendanceStatus.values
          .where((s) => s == 'Leave')
          .length;

      // Save to Firestore - class attendance record
      await _firestore
          .collection('Attendance')
          .doc(_selectedClassId)
          .collection('daily_records')
          .doc(dateStr)
          .set({
            'classId': _selectedClassId,
            'className': _selectedClassName,
            'date': dateStr,
            'dateTime': Timestamp.fromDate(_selectedDate),
            'teacherId': teacher?.uid,
            'teacherEmail': teacher?.email,
            'teacherName': teacher?.displayName ?? 'Teacher',
            'students': studentsAttendance,
            'totalStudents': totalStudents,
            'present': presentCount,
            'absent': absentCount,
            'leave': leaveCount,
            'markedAt': timestamp,
            'updatedAt': timestamp,
          }, SetOptions(merge: true));

      // Update each student's attendance record
      for (var student in _students) {
        final studentData = student.data() as Map<String, dynamic>;
        final studentAttendanceRef = _firestore
            .collection('users')
            .doc(student.id)
            .collection('attendance')
            .doc(dateStr);

        await studentAttendanceRef.set({
          'date': dateStr,
          'dateTime': Timestamp.fromDate(_selectedDate),
          'status': _attendanceStatus[student.id],
          'classId': _selectedClassId,
          'className': _selectedClassName,
          'markedBy': teacher?.uid,
          'markedByEmail': teacher?.email,
          'studentName': studentData['name'],
          'rollNumber': studentData['rollNumber'],
          'markedAt': timestamp,
        }, SetOptions(merge: true));

        // Also store a summary in student document
        await _firestore.collection('users').doc(student.id).update({
          'lastAttendanceDate': dateStr,
          'lastAttendanceStatus': _attendanceStatus[student.id],
          'updatedAt': timestamp,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance marked successfully! ($presentCount present, $absentCount absent, $leaveCount leave)',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } on FirebaseException catch (e) {
      print('Firebase Error: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('General Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isMarking = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadTodayAttendance();
    }
  }

  Widget _buildClassDropdown() {
    if (_classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No classes found. Please add classes first.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Class',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedClassId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'Select a class',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select a class'),
                ),
                ..._classes.map((classDoc) {
                  final classData = classDoc.data() as Map<String, dynamic>;
                  final className = classData['name'] ?? 'Unknown';
                  final section = classData['section'] ?? '';
                  final displayName = section.isNotEmpty
                      ? '$className - Section $section'
                      : className;

                  return DropdownMenuItem<String>(
                    value: classDoc.id,
                    child: Text(displayName),
                  );
                }).toList(),  
              ],
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                  if (value != null) {
                    final selectedClass = _classes.firstWhere(
                      (doc) => doc.id == value,
                    );
                    final classData =
                        selectedClass.data() as Map<String, dynamic>;
                    final className = classData['name'] ?? 'Unknown';
                    final section = classData['section'] ?? '';
                    _selectedClassName = section.isNotEmpty
                        ? '$className - Section $section'
                        : className;
                  }
                  _students.clear();
                  _attendanceStatus.clear();
                  _isSelected.clear();
                });
                if (value != null) {
                  _loadStudents();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading students...'),
          ],
        ),
      );
    }

    if (_students.isEmpty && _selectedClassId != null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No students found in this class',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(   
              'Class: $_selectedClassName',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStudentScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Students'),
            ),
          ],
        ),
      );
    }

    // Sort students by roll number
    List<DocumentSnapshot<Map<String, dynamic>>> sortedStudents = List.from(
      _students,
    );
    sortedStudents.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aRoll = aData['rollNumber']?.toString() ?? '999';
      final bRoll = bData['rollNumber']?.toString() ?? '999';
      return aRoll.compareTo(bRoll);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedStudents.length,
      itemBuilder: (context, index) {
        final student = sortedStudents[index];
        final studentData = student.data() as Map<String, dynamic>;
        final studentId = student.id;
        final rollNumber = studentData['rollNumber']?.toString() ?? 'N/A';
        final name = studentData['name']?.toString() ?? 'Unknown';
        final currentStatus = _attendanceStatus[studentId] ?? 'Present';
        final isSelected = _isSelected[studentId] ?? true;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(currentStatus),
              child: Text(
                rollNumber.length > 2 ? rollNumber.substring(0, 2) : rollNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Roll No: $rollNumber'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentStatus).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(currentStatus)),
                  ),
                  child: Text(
                    currentStatus,
                    style: TextStyle(
                      color: _getStatusColor(currentStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Checkbox for quick select
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      _isSelected[studentId] = value ?? false;
                      _attendanceStatus[studentId] = (value ?? false)
                          ? 'Present'
                          : 'Absent';
                    });
                  },
                ),
              ],
            ),
            onTap: () {
              _showStatusDialog(studentId, name, rollNumber, currentStatus);
            },
          ),
        );
      },
    );
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

  Future<void> _showStatusDialog(
    String studentId,
    String name,
    String rollNumber,
    String currentStatus,
  ) async {
    String selectedStatus = currentStatus;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mark Attendance - $name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Roll No: $rollNumber'),
              const SizedBox(height: 20),
              ...['Present', 'Absent', 'Leave'].map((status) {
                return RadioListTile<String>(
                  title: Text(
                    status,
                    style: TextStyle(
                      color: status == selectedStatus
                          ? _getStatusColor(status)
                          : Colors.black,
                      fontWeight: status == selectedStatus
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  secondary: Icon(
                    status == 'Present'
                        ? Icons.check_circle
                        : status == 'Absent'
                        ? Icons.cancel
                        : Icons.airline_seat_individual_suite,
                    color: _getStatusColor(status),
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _attendanceStatus[studentId] = selectedStatus;
                  _isSelected[studentId] = selectedStatus == 'Present';
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Date',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.edit_calendar),
              color: Colors.blue,
              tooltip: 'Change date',
            ),
            if (_selectedDate.isBefore(DateTime.now()))
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                  });
                  _loadTodayAttendance();
                },
                icon: const Icon(Icons.today),
                color: Colors.green,
                tooltip: 'Today',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    if (_students.isEmpty) return const SizedBox();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var student in _students) {
                          _attendanceStatus[student.id] = 'Present';
                          _isSelected[student.id] = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('All Present'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var student in _students) {
                          _attendanceStatus[student.id] = 'Absent';
                          _isSelected[student.id] = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.cancel, size: 20),
                    label: const Text('All Absent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_students.isEmpty) return const SizedBox();

    final total = _students.length;
    final present = _attendanceStatus.values
        .where((s) => s == 'Present')
        .length;
    final absent = _attendanceStatus.values.where((s) => s == 'Absent').length;
    final leave = _attendanceStatus.values.where((s) => s == 'Leave').length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Attendance Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', total.toString(), Colors.blue),
                _buildStatCard('Present', present.toString(), Colors.green),
                _buildStatCard('Absent', absent.toString(), Colors.red),
                _buildStatCard('Leave', leave.toString(), Colors.orange),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: total > 0 ? present / total : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 5),
            Text(
              'Attendance Rate: ${total > 0 ? ((present / total) * 100).toStringAsFixed(1) : 0}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
            icon: Icon(_showHistory ? Icons.list : Icons.history),
            tooltip: _showHistory ? 'Show Students' : 'Show History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date Selector
            _buildDateSelector(),
            const SizedBox(height: 16),

            // Class Dropdown
            _buildClassDropdown(),
            const SizedBox(height: 16),

            if (_selectedClassId != null && !_showHistory) ...[
              // Stats
              _buildStats(),
              const SizedBox(height: 16),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 16),

              // Student List Header
              Row(
                children: [
                  Text(
                    'Students (${_students.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_students.isNotEmpty)
                    Text(
                      'Tap student to change status',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Student List
              _buildStudentList(),
              const SizedBox(height: 20),

              // Submit Button
              if (_students.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isMarking ? null : _markAttendance,
                    icon: _isMarking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: _isMarking
                        ? const Text('Saving...')
                        : const Text(
                            'Save Attendance',
                            style: TextStyle(fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              // if (_students.isEmpty && _selectedClassId != null)
              //   SizedBox(
              //     width: double.infinity,
              //     height: 50,
              //     child: ElevatedButton.icon(
              //       onPressed: () {
              //         Navigator.pushNamed(context, '/add_student');
              //       },
              //       icon: const Icon(Icons.add),
              //       label: const Text('Add Students to This Class'),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.green,
              //         foregroundColor: Colors.white,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //       ),
              //     ),
              //   ),
            ],

            if (_showHistory && _selectedClassId != null) ...[
              const SizedBox(height: 16),
              _buildAttendanceHistory(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Attendance History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _refreshHistory(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<QuerySnapshot>(
          future: _firestore
              .collection('Attendance')
              .doc(_selectedClassId)
              .collection('daily_records')
              .orderBy('date', descending: true)
              .limit(20)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No attendance history found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start marking attendance to see history',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final records = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final data = record.data() as Map<String, dynamic>;
                final date = data['date'] as String? ?? 'Unknown';
                final present = data['present'] ?? 0;
                final absent = data['absent'] ?? 0;
                final leave = data['leave'] ?? 0;
                final total = data['totalStudents'] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: present == total
                          ? Colors.green
                          : present == 0
                          ? Colors.red
                          : Colors.orange,
                      child: Text(
                        DateFormat('dd').format(
                          data['dateTime'] != null
                              ? (data['dateTime'] as Timestamp).toDate()
                              : DateTime.parse(date),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(
                        data['dateTime'] != null
                            ? (data['dateTime'] as Timestamp).toDate()
                            : DateTime.parse(date),
                      ),
                    ),
                    subtitle: Text(
                      'Present: $present | Absent: $absent | Leave: $leave',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showAttendanceDetails(data);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _refreshHistory() async {
    setState(() {});
  }

  void _showAttendanceDetails(Map<String, dynamic> data) {
    final date = data['date'] as String? ?? 'Unknown';
    final className = data['className'] ?? 'Unknown';
    final teacherName = data['teacherName'] ?? 'Unknown';
    final present = data['present'] ?? 0;
    final absent = data['absent'] ?? 0;
    final leave = data['leave'] ?? 0;
    final total = data['totalStudents'] ?? 0;
    final students = data['students'] as Map<String, dynamic>? ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Attendance Details - $date'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Class:', className),
                  _buildDetailRow('Teacher:', teacherName),
                  const SizedBox(height: 16),
                  const Text(
                    'Summary:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Students:', total.toString()),
                  _buildSummaryRow(
                    'Present:',
                    '$present (${total > 0 ? ((present / total) * 100).toStringAsFixed(1) : 0}%)',
                    Colors.green,
                  ),
                  _buildSummaryRow(
                    'Absent:',
                    '$absent (${total > 0 ? ((absent / total) * 100).toStringAsFixed(1) : 0}%)',
                    Colors.red,
                  ),
                  _buildSummaryRow(
                    'Leave:',
                    '$leave (${total > 0 ? ((leave / total) * 100).toStringAsFixed(1) : 0}%)',
                    Colors.orange,
                  ),

                  if (students.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Student Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...students.entries.map((entry) {
                      final studentData = entry.value as Map<String, dynamic>;
                      final status = studentData['status'] ?? 'Unknown';
                      return _buildStudentStatusRow(
                        studentData['name'] ?? 'Unknown',
                        studentData['rollNumber'] ?? 'N/A',
                        status,
                      );
                    }).toList(),
                  ],
                ],
              ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatusRow(String name, String rollNumber, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('$name (Roll: $rollNumber)')),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _getStatusColor(status), width: 1),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
