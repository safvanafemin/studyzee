import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:studyzee/features/auth/login_screen.dart';
import 'package:studyzee/features/teacher/profile/profile_model.dart';
import 'package:studyzee/features/teacher/profile/teacher_profile_screen.dart';

// Parent Screen to View All Teachers
class AllTeachersScreen extends StatefulWidget {
  const AllTeachersScreen({super.key});

  @override
  State<AllTeachersScreen> createState() => _AllTeachersScreenState();
}

class _AllTeachersScreenState extends State<AllTeachersScreen> {
  final ProfileService _profileService = ProfileService();
  late Stream<List<TeacherProfile>> _teachersStream;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _teachersStream = _profileService.getAllTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4285F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Teachers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search teachers by name, subject...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4285F4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          // Teachers List
          Expanded(
            child: StreamBuilder<List<TeacherProfile>>(
              stream: _teachersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTeachers = snapshot.data ?? [];

                // Filter teachers based on search query
                final filteredTeachers = allTeachers.where((teacher) {
                  return teacher.name.toLowerCase().contains(_searchQuery) ||
                      (teacher.subject?.toLowerCase().contains(_searchQuery) ??
                          false) ||
                      (teacher.email.toLowerCase().contains(_searchQuery));
                }).toList();

                if (filteredTeachers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No teachers found'
                              : 'No teachers found for "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTeachers.length,
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return _buildTeacherCard(teacher);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(TeacherProfile teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Info
            Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: teacher.profilePictureUrl != null
                      ? ClipOval(
                          child: Image.network(
                            teacher.profilePictureUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Color(0xFF4285F4),
                                size: 30,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Color(0xFF4285F4),
                          size: 30,
                        ),
                ),
                const SizedBox(width: 16),
                // Name and Subject
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (teacher.subject != null &&
                          teacher.subject!.isNotEmpty)
                        Text(
                          teacher.subject!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (teacher.designation != null &&
                          teacher.designation!.isNotEmpty)
                        Text(
                          teacher.designation!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                // Quick Action Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view_profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 8),
                          Text('View Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'send_email',
                      child: Row(
                        children: [
                          Icon(Icons.email_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Send Email'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'call',
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Call'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    _handleQuickAction(value, teacher);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Contact Information
            if (teacher.email.isNotEmpty)
              _buildContactInfoItem(
                Icons.email_outlined,
                teacher.email,
                onTap: () => _launchEmail(teacher.email),
              ),
            if (teacher.phone != null && teacher.phone!.isNotEmpty)
              _buildContactInfoItem(
                Icons.phone_outlined,
                teacher.phone!,
                onTap: () => _makePhoneCall(teacher.phone!),
              ),
            if (teacher.qualification != null &&
                teacher.qualification!.isNotEmpty)
              _buildContactInfoItem(
                Icons.school_outlined,
                teacher.qualification!,
              ),
            if (teacher.experience != null && teacher.experience!.isNotEmpty)
              _buildContactInfoItem(
                Icons.work_outline,
                'Experience: ${teacher.experience!}',
              ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchEmail(teacher.email),
                    icon: const Icon(Icons.email, size: 18),
                    label: const Text('Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        teacher.phone != null && teacher.phone!.isNotEmpty
                        ? () => _makePhoneCall(teacher.phone!)
                        : null,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4285F4),
                      side: const BorderSide(color: Color(0xFF4285F4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildContactInfoItem(
    IconData icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(String action, TeacherProfile teacher) {
    switch (action) {
      case 'view_profile':
        _showTeacherProfile(context, teacher);
        break;
      case 'send_email':
        _launchEmail(teacher.email);
        break;
      case 'call':
        if (teacher.phone != null && teacher.phone!.isNotEmpty) {
          _makePhoneCall(teacher.phone!);
        }
        break;
    }
  }

  void _showTeacherProfile(BuildContext context, TeacherProfile teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4285F4).withOpacity(0.1),
                        ),
                        child: teacher.profilePictureUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  teacher.profilePictureUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF4285F4),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        teacher.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (teacher.designation != null &&
                          teacher.designation!.isNotEmpty)
                        Text(
                          teacher.designation!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Contact Information
                _buildProfileDetailItem(Icons.email, 'Email', teacher.email),
                if (teacher.phone != null && teacher.phone!.isNotEmpty)
                  _buildProfileDetailItem(Icons.phone, 'Phone', teacher.phone!),
                if (teacher.subject != null && teacher.subject!.isNotEmpty)
                  _buildProfileDetailItem(
                    Icons.school,
                    'Subject',
                    teacher.subject!,
                  ),
                if (teacher.qualification != null &&
                    teacher.qualification!.isNotEmpty)
                  _buildProfileDetailItem(
                    Icons.card_membership,
                    'Qualification',
                    teacher.qualification!,
                  ),
                if (teacher.experience != null &&
                    teacher.experience!.isNotEmpty)
                  _buildProfileDetailItem(
                    Icons.work,
                    'Experience',
                    teacher.experience!,
                  ),
                if (teacher.address != null && teacher.address!.isNotEmpty)
                  _buildProfileDetailItem(
                    Icons.location_on,
                    'Address',
                    teacher.address!,
                  ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchEmail(teacher.email),
                        icon: const Icon(Icons.email),
                        label: const Text('Send Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (teacher.phone != null && teacher.phone!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _makePhoneCall(teacher.phone!),
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4285F4),
                            side: const BorderSide(color: Color(0xFF4285F4)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4285F4), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Message from StudyZee Parent App',
        'body': 'Dear Teacher,\n\nI would like to discuss...',
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Update the ProfileService to include getAllTeachers method
extension TeacherListService on ProfileService {
  Stream<List<TeacherProfile>> getAllTeachers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Teacher')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TeacherProfile.fromMap(doc.data());
          }).toList();
        });
  }
}
 