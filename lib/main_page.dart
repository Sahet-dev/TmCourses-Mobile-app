import 'package:flutter/material.dart';
import 'package:course/widgets/hero_section.dart';
import 'package:course/widgets/popular_courses_section.dart';
import 'package:course/widgets/latest_courses_section.dart';
import 'package:course/widgets/testimonials_section.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HeroSection(),
            PopularCoursesSection(),  // Fetches and displays popular courses
            LatestCoursesSection(),   // Fetches and displays latest courses
            TestimonialsSection(),
          ],
        ),
      ),
    );
  }
}
