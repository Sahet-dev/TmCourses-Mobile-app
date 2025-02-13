import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:course/widgets/hero_section.dart';
import 'package:course/widgets/popular_courses_section.dart';
import 'package:course/widgets/latest_courses_section.dart';
import 'package:course/widgets/testimonials_section.dart';
import 'package:course/pages/login_page.dart';
import 'package:course/pages/register_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Course Platform"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isAuthenticated) ...[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Login", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Register", style: TextStyle(color: Colors.blue)),
            ),
          ],
          const SizedBox(width: 15), // Space between buttons
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HeroSection(),
            PopularCoursesSection(),
            LatestCoursesSection(),
            TestimonialsSection(),
          ],
        ),
      ),
    );
  }
}
