import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:course/widgets/course_card.dart';

class CatalogPage extends StatefulWidget {
  final String? searchQuery;

  const CatalogPage({super.key, this.searchQuery});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<dynamic> courses = [];
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 1;
  int lastPage = 1;
  final Dio _dio = Dio();
  final String baseUrl = 'https://course-server.sahet-dev.com/api/course-catalog';

  @override
  void initState() {
    super.initState();
    fetchCourses(widget.searchQuery ?? '');
  }

  Future<void> fetchCourses(String searchTerm, {int page = 1}) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {'search': searchTerm, 'page': page},
      );

      if (response.statusCode == 200) {
        setState(() {
          courses = response.data['courses'] ?? [];
          currentPage = page;
          lastPage = response.data['last_page'] ?? 1;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Failed to load courses. Try again!";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToCourseDetail(int courseId) {
    // Implement your navigation logic
    print("Navigating to Course ID: $courseId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Catalog")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return CourseCard(
            title: course["title"],
            imageUrl: "https://course-server.sahet-dev.com/storage/${course["thumbnail"]}",
            description: course["description"],
            price: course["price"] != null ? "\$${course["price"]}" : "Free",
            onTap: () => _navigateToCourseDetail(course["id"]),
          );
        },
      ),
    );
  }
}
