import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading delay

    String? authToken = await _secureStorage.read(key: 'token');

    if (mounted) {
      Navigator.pushReplacementNamed(context, authToken != null ? '/home' : '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: const Center(
        child: Text(
          'Welcome to Flutter!',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}
