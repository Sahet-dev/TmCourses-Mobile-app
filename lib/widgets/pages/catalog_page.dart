import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<dynamic> courses = [];
  bool isLoading = true;
  String errorMessage = '';
  int currentPage = 1;
  int lastPage = 1;
  final String baseUrl = 'https://course-server.sahet-dev.com/api/courses-list';

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses({int page = 1}) async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await Dio().get('$baseUrl?page=$page');
      var responseData = response.data;

      setState(() {
        courses = responseData['data']; // Extract course list
        currentPage = responseData['current_page'];
        lastPage = responseData['last_page'];
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load courses';
        isLoading = false;
      });
    }
  }

  void goToNextPage() {
    if (currentPage < lastPage) {
      fetchCourses(page: currentPage + 1);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      fetchCourses(page: currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Catalog')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                var course = courses[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  elevation: 3,
                  child: ListTile(
                    leading: Image.network(
                      'https://course-server.sahet-dev.com/${course['thumbnail']}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                    ),
                    title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(
                          course['price'] != null ? '\$${course['price']}' : 'Free',
                          style: TextStyle(
                            color: course['price'] != null ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle course click (navigate to details page if needed)
                    },
                  ),
                );
              },
            ),
          ),
          if (lastPage > 1) // Show pagination only if there's more than 1 page
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 1 ? goToPreviousPage : null,
                    icon: const Icon(Icons.arrow_back),
                    color: currentPage > 1 ? Colors.blue : Colors.grey,
                  ),
                  Text('Page $currentPage of $lastPage'),
                  IconButton(
                    onPressed: currentPage < lastPage ? goToNextPage : null,
                    icon: const Icon(Icons.arrow_forward),
                    color: currentPage < lastPage ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
