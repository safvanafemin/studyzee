import 'package:flutter/material.dart';
import 'package:studyzee/core/models/app_notification.dart';
import 'package:studyzee/core/services/notification_service.dart';
import 'package:studyzee/features/teacher/profile/profile_model.dart';
import 'package:studyzee/features/teacher/assignment/assignment_screen.dart';
import 'package:studyzee/features/teacher/attendace/attendance_screen.dart';
import 'package:studyzee/features/teacher/notes/notes_screen.dart';
import 'package:studyzee/features/teacher/notification/notification_list.dart';
import 'package:studyzee/features/teacher/profile/teacher_profile_screen.dart';
import 'package:studyzee/features/teacher/students_parent/manage_form.dart';
import 'package:studyzee/features/teacher/trclass/trclass_screen.dart';
import 'package:studyzee/features/teacher/trexam/teacher_list_exam.dart';
import 'package:studyzee/features/teacher/trprogress/trprogress_screen.dart';
import 'package:studyzee/features/teacher/trtimetable/trtimetable.dart';

class TrHomeScreen extends StatefulWidget {
  const TrHomeScreen({super.key});

  @override
  State<TrHomeScreen> createState() => _TrHomeScreenState();
}

class _TrHomeScreenState extends State<TrHomeScreen> {
  final ProfileService _profileService = ProfileService();
  final NotificationService _notificationService = NotificationService();
  int _currentIndex = 0;
  late Stream<TeacherProfile> _profileStream;
  @override
  void initState() {
    super.initState();
    _profileStream = _profileService.getTeacherProfile();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TeacherProfile>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.hasError) {
          print('Error loading teacher profile: ${profileSnapshot.error}');
        }
        final profile = profileSnapshot.data;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: _currentIndex == 0
              ? _buildHomeContent(profile)
              : const TeacherProfileScreen(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF4285F4),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(TeacherProfile? profile) {
    final user = _profileService.currentUser;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          title: const Text(
            'Teacher Module',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            StreamBuilder<List<AppNotification>>(
              stream: user != null
                  ? _notificationService.getNotifications(user.uid)
                  : Stream.value([]),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error loading notifications: ${snapshot.error}');
                }
                final notifications = snapshot.data ?? [];
                final unreadCount = notifications
                    .where((n) => !n.isRead)
                    .length;

                return IconButton(
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                        size: 28,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: profile?.profilePictureUrl != null
                          ? ClipOval(
                              child: Image.network(
                                profile!.profilePictureUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.name ?? 'Teacher',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Feature Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: .9,
                children: [
                  _buildFeatureCard('Add Students In Class', Icons.add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentManagementScreen(),
                      ),
                    );
                  }),
                  _buildFeatureCard('Upload Notes', Icons.upload_file, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotesScreen()),
                    );
                  }),
                  _buildFeatureCard(
                    'Mark Attendance',
                    Icons.calendar_today,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrAttendanceScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard('Class', Icons.video_library, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrclassScreen()),
                    );
                  }),
                  _buildFeatureCard('Exam', Icons.event_available, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherExamsListScreen(),
                      ),
                    );
                  }),
                  _buildFeatureCard(
                    'Assignment',
                    Icons.assignment_turned_in,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignmentViewScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard('Progress', Icons.trending_up, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrprogressScreen(),
                      ),
                    );
                  }),
                  _buildFeatureCard('Timetable', Icons.schedule, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherTimetableViewScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF4285F4)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
