import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading

    final prefs = await SharedPreferences.getInstance();
    final bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    Navigator.pushReplacementNamed(context, isAuthenticated ? '/dashboard' : '/main');
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
