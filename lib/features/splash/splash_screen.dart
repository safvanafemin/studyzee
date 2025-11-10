import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyzee/features/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // timerstate()
    Timer.periodic(Duration(seconds: 3), (timer) {
      timer.cancel();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
