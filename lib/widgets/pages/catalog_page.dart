import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CatalogPage extends StatefulWidget {
  final String? searchQuery; // Accept search query

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
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(
                "https://course-server.sahet-dev.com/${course['thumbnail']}",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(course['title']),
              subtitle: Text(course['description']),
              trailing: Text(
                course['price'] != null ? "\$${course['price']}" : "Free",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
