// course_catalog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:course/services/auth_service.dart';

/// Model representing a course.
class Course {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final String? price;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    this.price,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnail: "https://course-server.sahet-dev.com/storage/${json['thumbnail']}",
      price: json['price'] != null ? json['price'].toString() : 'Free',
    );
  }
}

/// Model for handling pagination data.
class Pagination {
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

/// Combined response model for courses list.
class CoursesResponse {
  final int currentPage;
  final List<Course> courses;
  final Pagination pagination;

  CoursesResponse({
    required this.currentPage,
    required this.courses,
    required this.pagination,
  });

  factory CoursesResponse.fromJson(Map<String, dynamic> json) {
    var coursesJson = json['data'] as List;
    List<Course> coursesList =
    coursesJson.map((course) => Course.fromJson(course)).toList();
    Pagination pagination = Pagination.fromJson(json);
    return CoursesResponse(
      currentPage: json['current_page'],
      courses: coursesList,
      pagination: pagination,
    );
  }
}

/// The CourseCatalog widget fetches and displays courses with pagination.
class CourseCatalog extends StatefulWidget {
  const CourseCatalog({super.key});

  @override
  State<CourseCatalog> createState() => _CourseCatalogState();
}

class _CourseCatalogState extends State<CourseCatalog> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  CoursesResponse? _coursesResponse;

  @override
  void initState() {
    super.initState();
    // Fetch the first page of courses on initialization.
    _fetchCourses("https://course.sahet-dev.com/api/courses-list");
  }

  /// Fetches courses from the API.
  Future<void> _fetchCourses(String url) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // If your ApiService sets the base URL, adjust the URL accordingly.
      final response = await _apiService.get(url.replaceFirst("https://course.sahet-dev.com/api/", ""));
      final Map<String, dynamic> jsonResponse = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      setState(() {
        _coursesResponse = CoursesResponse.fromJson(jsonResponse);
      });
    } catch (err) {
      setState(() {
        _error = "Failed to load courses. Please try again later.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _navigateToCourseDetail(int courseId) {
    Navigator.pushNamed(
      context,
      '/courseDetail',
      arguments: {'courseId': courseId},
    );
  }


  /// Builds a card widget for each course.
  Widget _buildCourseCard(Course course) {

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>  _navigateToCourseDetail(course.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display course thumbnail.
            Expanded(
              child: Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.price ?? "Free",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.blue),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToCourseDetail(course.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text("Enroll Now"),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Builds pagination controls.
  Widget _buildPagination() {
    final pagination = _coursesResponse?.pagination;
    if (pagination == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: pagination.prevPageUrl == null
                ? null
                : () => _fetchCourses(pagination.prevPageUrl!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text("Previous"),
          ),
          const SizedBox(width: 16),
          Text("Page ${pagination.currentPage} of ${pagination.lastPage}"),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: pagination.nextPageUrl == null
                ? null
                : () => _fetchCourses(pagination.nextPageUrl!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Catalog")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade100,
              Colors.pink.shade50,
              Colors.blue.shade50,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : _coursesResponse == null
            ? const SizedBox.shrink()
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Course Catalog",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLandscape ? 2 : 1, // 2 columns in landscape, 1 in portrait
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 16 / 14, // Ensures 16:9 aspect ratio
                    ),
                    itemCount: _coursesResponse!.courses.length,
                    itemBuilder: (context, index) {
                      final course = _coursesResponse!.courses[index];
                      return _buildCourseCard(course);
                    },
                  );
                },
              ),
            ),


            _buildPagination(),
          ],
        ),
      ),
    );
  }
}
