import 'package:flutter/material.dart';
import 'package:course/widgets/course_card.dart';
import 'package:course/services/course_service.dart';
import 'package:course/pages/course_detail_page.dart';

class LatestCoursesSection extends StatefulWidget {
  const LatestCoursesSection({super.key});

  @override
  _LatestCoursesSectionState createState() => _LatestCoursesSectionState();
}

class _LatestCoursesSectionState extends State<LatestCoursesSection> {
  final CourseService _courseService = CourseService();
  List<dynamic> _latestCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final data = await _courseService.fetchCourses();
    setState(() {
      _latestCourses = data["latestCourses"];
      _isLoading = false;
    });
  }

  void _navigateToCourseDetail(int courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailPage(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Latest Courses",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _latestCourses.isEmpty
              ? const Center(child: Text("No latest courses found"))
              : Column(
            children: _latestCourses.map((course) {
              return CourseCard(
                title: course["title"],
                imageUrl: "https://course-server.sahet-dev.com/storage/${course["thumbnail"]}",
                description: course["description"],
                price: course["price"] != null ? "\$${course["price"]}" : "Free",
                onTap: () => _navigateToCourseDetail(course["id"]),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("See All Courses"),
            ),
          ),
        ],
      ),
    );
  }
}
