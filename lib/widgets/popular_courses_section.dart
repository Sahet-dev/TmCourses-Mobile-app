import 'package:flutter/material.dart';
import 'package:course/widgets/course_card.dart';
import 'package:course/services/course_service.dart';
import 'package:course/pages/course_detail_page.dart';

class PopularCoursesSection extends StatefulWidget {
  const PopularCoursesSection({super.key});

  @override
  _PopularCoursesSectionState createState() => _PopularCoursesSectionState();
}

class _PopularCoursesSectionState extends State<PopularCoursesSection> {
  final CourseService _courseService = CourseService();
  List<dynamic> _popularCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final data = await _courseService.fetchCourses();

    setState(() {
      // Convert `popularCourses` map to list
      _popularCourses = data["popularCourses"].values.toList();
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
            "Popular Courses",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _popularCourses.isEmpty
              ? const Center(child: Text("No popular courses found"))
              : Column(
            children: _popularCourses.map((course) {
              return GestureDetector(
                onTap: () => _navigateToCourseDetail(course["id"]),
                child: CourseCard(
                  title: course["title"],
                  description: course["description"],
                  price: course["price"] != null
                      ? "\$${course["price"]}"
                      : "Free",
                ),
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
