import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyzee/features/auth/login_screen.dart';
import 'package:studyzee/helper/image_uploader.dart';
import 'package:studyzee/features/teacher/profile/profile_model.dart';
// Import the service from separate file

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Stream<TeacherProfile> _profileStream;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _profileStream = _profileService.getTeacherProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<TeacherProfile>(
        stream: _profileStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data!;
          return _buildProfileContent(profile);
        },
      ),
    );
  }

  Widget _buildProfileContent(TeacherProfile profile) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF4285F4),
              elevation: 0,
              pinned: true,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4285F4), Color(0xFF0D47A1)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: _isUploadingImage
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF4285F4),
                                    ),
                                  )
                                : profile.profilePictureUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      profile.profilePictureUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF4285F4),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Color(0xFF4285F4),
                                            );
                                          },
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF4285F4),
                                  ),
                          ),
                          if (!_isUploadingImage)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _changeProfilePicture,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.designation ?? 'Teacher',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    _showEditProfileDialog(profile);
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileSection('Personal Information', [
                    _buildProfileItem(Icons.email, 'Email', profile.email),
                    _buildProfileItem(
                      Icons.phone,
                      'Phone',
                      profile.phone?.isNotEmpty == true
                          ? profile.phone!
                          : 'Not set',
                    ),
                    _buildProfileItem(
                      Icons.cake,
                      'Date of Birth',
                      profile.dateOfBirth?.isNotEmpty == true
                          ? profile.dateOfBirth!
                          : 'Not set',
                    ),
                    _buildProfileItem(
                      Icons.location_on,
                      'Address',
                      profile.address?.isNotEmpty == true
                          ? profile.address!
                          : 'Not set',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildProfileSection('Professional Details', [
                    _buildProfileItem(
                      Icons.school,
                      'Subject',
                      profile.subject?.isNotEmpty == true
                          ? profile.subject!
                          : 'Not set',
                    ),
                    _buildProfileItem(
                      Icons.work,
                      'Experience',
                      profile.experience?.isNotEmpty == true
                          ? profile.experience!
                          : 'Not set',
                    ),
                    _buildProfileItem(
                      Icons.badge,
                      'Employee ID',
                      profile.employeeId?.isNotEmpty == true
                          ? profile.employeeId!
                          : 'Not set',
                    ),
                    _buildProfileItem(
                      Icons.card_membership,
                      'Qualification',
                      profile.qualification?.isNotEmpty == true
                          ? profile.qualification!
                          : 'Not set',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildProfileSection('Account Settings', [
                    _buildProfileActionItem(
                      Icons.lock_outline,
                      'Change Password',
                      () {
                        _showChangePasswordDialog(context);
                      },
                    ),
                    _buildProfileActionItem(
                      Icons.notifications_outlined,
                      'Notification Settings',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings'),
                          ),
                        );
                      },
                    ),
                    _buildProfileActionItem(Icons.logout, 'Logout', () {
                      _showLogoutDialog(context);
                    }, isDestructive: true),
                  ]),
                ]),
              ),
            ),
          ],
        ),
        if (_isUploadingImage)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF4285F4),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDestructive ? Colors.red : Colors.grey[400],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Future<void> _changeProfilePicture() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _profileService.pickAndUploadProfilePicture();

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload profile picture'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _showEditProfileDialog(TeacherProfile profile) async {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone);
    final dobController = TextEditingController(text: profile.dateOfBirth);
    final addressController = TextEditingController(text: profile.address);
    final subjectController = TextEditingController(text: profile.subject);
    final experienceController = TextEditingController(
      text: profile.experience,
    );
    final employeeIdController = TextEditingController(
      text: profile.employeeId,
    );
    final qualificationController = TextEditingController(
      text: profile.qualification,
    );
    final designationController = TextEditingController(
      text: profile.designation,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildEditTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: dobController,
                  label: 'Date of Birth',
                  icon: Icons.cake,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: subjectController,
                  label: 'Subject',
                  icon: Icons.school,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: experienceController,
                  label: 'Experience',
                  icon: Icons.work,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: employeeIdController,
                  label: 'Employee ID',
                  icon: Icons.badge,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: qualificationController,
                  label: 'Qualification',
                  icon: Icons.card_membership,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: designationController,
                  label: 'Designation',
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _profileService.updateTeacherProfile({
                        'name': nameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'dateOfBirth': dobController.text.trim(),
                        'address': addressController.text.trim(),
                        'subject': subjectController.text.trim(),
                        'experience': experienceController.text.trim(),
                        'employeeId': employeeIdController.text.trim(),
                        'qualification': qualificationController.text.trim(),
                        'designation': designationController.text.trim(),
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update profile: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4285F4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildEditTextField(
                  controller: currentPasswordController,
                  label: 'Current Password',
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: newPasswordController,
                  label: 'New Password',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                _buildEditTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm New Password',
                  icon: Icons.lock_reset,
                  keyboardType: TextInputType.visiblePassword,
                  maxLines: 1,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must be at least 6 characters',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final user = _profileService.currentUser;
                      if (user != null) {
                        // Re-authenticate user
                        final cred = await user.reauthenticateWithCredential(
                          EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPasswordController.text,
                          ),
                        );

                        // Update password
                        await cred.user!.updatePassword(
                          newPasswordController.text,
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      String errorMessage = 'Failed to change password';
                      if (e.code == 'wrong-password') {
                        errorMessage = 'Current password is incorrect';
                      } else if (e.code == 'weak-password') {
                        errorMessage = 'New password is too weak';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $errorMessage'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
// services/profile_service.dart

// services/profile_service.dart

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryUploader _cloudinaryUploader = CloudinaryUploader();
  final ImagePicker _imagePicker = ImagePicker();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get teacher profile
  Stream<TeacherProfile> getTeacherProfile() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        // Create default profile if not exists
        return TeacherProfile(
          uid: userId,
          name: currentUser?.displayName ?? 'John Doe',
          email: currentUser?.email ?? '',
          phone: '',
          designation: 'Senior Teacher',
        );
      }
      return TeacherProfile.fromMap(snapshot.data()!);
    });
  }

  // Update teacher profile
  Future<void> updateTeacherProfile(Map<String, dynamic> updates) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Add updated timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();

      // Update in Firestore
      await _firestore.collection('users').doc(userId).update(updates);

      // If updating name, also update in Firebase Auth
      if (updates.containsKey('name') && currentUser != null) {
        await currentUser!.updateDisplayName(updates['name']);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update profile picture URL in Firestore
  Future<void> updateProfilePicture(String imageUrl) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(userId).update({
      'profilePictureUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Pick and upload profile picture
  Future<String?> pickAndUploadProfilePicture() async {
    try {
      // Pick image from gallery
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Upload to Cloudinary
      final imageUrl = await _cloudinaryUploader.uploadFile(pickedFile);

      if (imageUrl != null) {
        // Update in Firestore
        await updateProfilePicture(imageUrl);

        // Update in Firebase Auth
        if (currentUser != null) {
          await currentUser!.updatePhotoURL(imageUrl);
        }
      }

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get teacher profile by ID (for other teachers' profiles)
  Future<TeacherProfile> getTeacherProfileById(String teacherId) async {
    final snapshot = await _firestore.collection('users').doc(teacherId).get();

    if (!snapshot.exists) {
      throw Exception('Teacher profile not found');
    }

    return TeacherProfile.fromMap(snapshot.data()!);
  }

  // Check if user is teacher
  Future<bool> isUserTeacher() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final snapshot = await _firestore.collection('users').doc(userId).get();
    if (!snapshot.exists) return false;

    final data = snapshot.data()!;
    return data['role'] == 'Teacher';
  }
}
