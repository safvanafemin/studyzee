import 'package:flutter/material.dart';
import 'package:studyzee/features/student/attendance/attendance_screen.dart';
import 'package:studyzee/features/student/exam/exam_screen.dart';
import 'package:studyzee/features/student/fees/fees_screen.dart';
import 'package:studyzee/features/student/progress/progress_screen.dart';
import 'package:studyzee/features/student/studymaterial/studymaterail_screen.dart';
import 'package:studyzee/features/student/timetable/timetable_screen.dart';
import 'package:studyzee/features/student/upload/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4ff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  'STUDYZEE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1f2937),
                  ),
                ),
              ),

              // Profile Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFe6f2ff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93c5fd),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shabnam',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1e3a8a),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Student ID: STU001',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1e3a8a),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: .9,
                children: [
                  _buildFeatureCard(
                    'Attendance',
                    Icons.access_time,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceScreen(),
                        ),
                      );
                      print('Navigate to Attendance');
                    },
                  ),
                  _buildFeatureCard(
                    'Upload',
                    Icons.cloud_upload,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadScreen()),
                      );
                      print('Navigate to Upload');
                    },
                  ),
                  _buildFeatureCard(
                    'Class',
                    Icons.videocam,
                    const Color(0xFF60a5fa),
                    () {
                      print('Navigate to Live & Recorded Class');
                    },
                  ),
                  _buildFeatureCard(
                    'Fees',
                    Icons.school,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeesScreen(),
                        ),
                      );
                      print('Navigate to Fees');
                    },
                  ),
                  _buildFeatureCard(
                    'Progress',
                    Icons.trending_up,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgressScreen(),
                        ),
                      );
                      print('Navigate to Progress Graph');
                    },
                  ),
                  _buildFeatureCard(
                    'Time Table',
                    Icons.calendar_today,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimetableScreen(),
                        ),
                      );
                      print('Navigate to Time Table');
                    },
                  ),
                  _buildFeatureCard(
                    'Exam',
                    Icons.quiz,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExamScreen()),
                      );
                      ('Navigate to Exam');
                    },
                  ),
                  _buildFeatureCard(
                    'Study Material',
                    Icons.library_books,
                    const Color(0xFF60a5fa),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyMaterialScreen(),
                        ),
                      );
                      print('Navigate to Study Material');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home, 'Home', true),
          _buildBottomNavItem(Icons.chat_bubble_outline, 'Chat', false),
          _buildBottomNavItem(Icons.person_outline, 'Profile', false),
          _buildBottomNavItem(Icons.settings_outlined, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF60a5fa).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF60a5fa) : Colors.grey.shade400,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFF60a5fa) : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
