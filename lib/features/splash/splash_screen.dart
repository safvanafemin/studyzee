import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyzee/features/admin/home/home_screen.dart';
import 'package:studyzee/features/auth/login_screen.dart';
import 'package:studyzee/features/parent/home1/home1_screen.dart';
import 'package:studyzee/features/student/home/home_screen.dart';
import 'package:studyzee/teacher/home/home_screen.dart';
// Import your home screens here based on role
// import 'package:studyzee/features/student/home_screen.dart';
// import 'package:studyzee/features/teacher/home_screen.dart';
// import 'package:studyzee/features/parent/home_screen.dart';
// import 'package:studyzee/features/admin/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    // Add a small delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check if user is already logged in
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // User is logged in, check their role and navigate accordingly
        await _navigateBasedOnRole(currentUser.uid);
      } else {
        // No user logged in, go to login screen
        _navigateToLogin();
      }
    } catch (e) {
      // If any error occurs, go to login screen
      print('Error checking current user: $e');
      _navigateToLogin();
    }
  }

  Future<void> _navigateBasedOnRole(String userId) async {
    try {
      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        // User data not found in Firestore, go to login
        _navigateToLogin();
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userRole = userData['role'] ?? 'Student';

      // Navigate based on role
      _navigateToHomeScreen(userRole);
    } catch (e) {
      print('Error getting user role: $e');
      _navigateToLogin();
    }
  }

  void _navigateToHomeScreen(String role) {
    Widget homeScreen;

    // Map roles to their respective home screens
    // Replace with your actual screen imports
    switch (role) {
      case 'Student':
        homeScreen = const HomeScreen(); // Replace with your StudentHomeScreen
        break;
      case 'Teacher':
        homeScreen =
            const TrHomeScreen(); // Replace with your TeacherHomeScreen
        break;
      case 'Parent':
        homeScreen = const Home1Screen(); // Replace with your ParentHomeScreen
        break;
      case 'Admin':
        homeScreen =
            const AdminHomeScreen(); // Replace with your AdminHomeScreen
        break;
      default:
        homeScreen = const LoginScreen(); // Fallback to login
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
      (route) => false,
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize as needed
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo/image
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            // Optional loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 2, 18, 69),
              ),
            ),
            const SizedBox(height: 20),
            // Optional loading text
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 2, 18, 69),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
