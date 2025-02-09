// splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Text(
          'Welcome to Flutter!',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}
