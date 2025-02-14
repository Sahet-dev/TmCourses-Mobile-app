import 'package:flutter/material.dart';
import 'package:course/services/course_service.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseService _courseService = CourseService();
  Map<String, dynamic>? _course;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    final response =
    await _courseService.fetchPrivateCourse(widget.courseId);
    setState(() {
      _course = response["course"];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_course?["title"] ?? "Course Details")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _course == null
          ? const Center(child: Text("Course not found"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _course!["title"],
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_course!["description"]),
            const SizedBox(height: 10),
            Text(
              _course!["price"] != null
                  ? "\$${_course!["price"]}"
                  : "Free",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lessons",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...(_course!["lessons"] as List).map((lesson) {
              return ListTile(
                title: Text(lesson["title"]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
