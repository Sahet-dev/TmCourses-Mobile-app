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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Title
          const Text(
            "Popular Courses",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          /// Loading Indicator or Courses
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_popularCourses.isEmpty)
            const Center(
              child: Text(
                "No popular courses found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            Column(
              children: _popularCourses.map((course) {
                return CourseCard(
                  title: course["title"],
                  imageUrl: "https://course-server.sahet-dev.com/storage/${course["thumbnail"]}",
                  description: course["description"],
                  price: course["price"],
                  onTap: () => _navigateToCourseDetail(course["id"]),
                );
              }).toList(),
            ),

          const SizedBox(height: 20),

          /// See All Courses Button
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "See All Courses",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }



}
