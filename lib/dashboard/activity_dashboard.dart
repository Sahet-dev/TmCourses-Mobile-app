import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:course/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:course/pages/course_detail_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ActivityDashboard extends StatefulWidget {
  const ActivityDashboard({super.key});

  @override
  State<ActivityDashboard> createState() => _ActivityDashboardState();
}

class _ActivityDashboardState extends State<ActivityDashboard> {
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> latestActivities = [];
  List<Map<String, dynamic>> popularCourses = [];
  List<Map<String, dynamic>> featuredCourses = [];
  List<int> monthlyData = List.filled(12, 0);

  // Create a cache manager instance.
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  // Connectivity check helper function.
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;
    print("Connectivity check: $connectivityResult, hasConnection: $hasConnection");
    return hasConnection;
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
  void initState() {
    super.initState();
    fetchCoursesData();
    fetchActivityData();
  }

  Widget _buildErrorState() {
    return Center(
      child: Text('Something went wrong: $error'),
    );
  }

  // Modified to check connectivity and use cache.
  void fetchCoursesData() async {
    final String cacheKey = 'user_latest_activities';
    try {
      bool online = await hasInternetConnection();
      if (!online) {
        print("Offline mode: Attempting to load courses data from cache with key: $cacheKey");
        // Offline: attempt to load from cache.
        final fileInfo = await cacheManager.getFileFromCache(cacheKey);
        if (fileInfo != null) {
          final cachedData = await fileInfo.file.readAsString();
          print("Cached courses data found: $cachedData");
          final jsonData = json.decode(cachedData);
          setState(() {
            latestActivities = List<Map<String, dynamic>>.from(jsonData["latestCourses"] ?? []);
            popularCourses = List<Map<String, dynamic>>.from(jsonData["popularCourses"] ?? []);
          });
          return;
        } else {
          setState(() {
            error = "No internet and no cached courses data available.";
          });
          print("No cached courses data found for key: $cacheKey");
          return;
        }
      }

      // Online: fetch from API.
      print("Online mode: Fetching courses data from API");
      ApiService apiService = ApiService();
      Response response = await apiService.get('user/latest-activities');
      if (response.statusCode == 200) {
        print("API response for courses data: ${response.data}");
        // Cache the API response as JSON.
        await cacheManager.putFile(
          cacheKey,
          utf8.encode(json.encode(response.data)),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );
        print("Courses data cached with key: $cacheKey");
        setState(() {
          latestActivities = List<Map<String, dynamic>>.from(response.data["latestCourses"] ?? []);
          popularCourses = List<Map<String, dynamic>>.from(response.data["popularCourses"] ?? []);
        });
      } else {
        throw Exception("Failed to load courses data");
      }
    } catch (err) {
      print("Error in fetchCoursesData: ${err.toString()}");
      // On error, attempt to load cached data.
      final fileInfo = await cacheManager.getFileFromCache(cacheKey);
      if (fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        print("Using cached courses data after error: $cachedData");
        final jsonData = json.decode(cachedData);
        setState(() {
          latestActivities = List<Map<String, dynamic>>.from(jsonData["latestCourses"] ?? []);
          popularCourses = List<Map<String, dynamic>>.from(jsonData["popularCourses"] ?? []);
        });
      } else {
        setState(() {
          error = "Failed to load courses data: ${err.toString()}";
        });
      }
    }
  }

  // Modified to check connectivity and use cache.
  void fetchActivityData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final String cacheKey = 'user_activities';
    try {
      bool online = await hasInternetConnection();
      if (!online) {
        print("Offline mode: Attempting to load activity data from cache with key: $cacheKey");
        // Offline: load from cache.
        final fileInfo = await cacheManager.getFileFromCache(cacheKey);
        if (fileInfo != null) {
          final cachedData = await fileInfo.file.readAsString();
          print("Cached activity data found: $cachedData");
          List<dynamic> data = json.decode(cachedData);
          _processActivityData(data);
        } else {
          setState(() {
            error = "No internet and no cached activity data available.";
          });
          print("No cached activity data found for key: $cacheKey");
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Online: fetch from API.
      print("Online mode: Fetching activity data from API");
      ApiService apiService = ApiService();
      Response response = await apiService.get('user/activities');
      if (response.statusCode == 200) {
        print("API response for activity data: ${response.data}");
        // Cache the API response.
        await cacheManager.putFile(
          cacheKey,
          utf8.encode(json.encode(response.data)),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );
        print("Activity data cached with key: $cacheKey");
        List<dynamic> data = response.data;
        _processActivityData(data);
      } else {
        throw Exception("Failed to load activity data");
      }
    } catch (err) {
      print("Error in fetchActivityData: ${err.toString()}");
      // On error, attempt to load from cache.
      final fileInfo = await cacheManager.getFileFromCache(cacheKey);
      if (fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        print("Using cached activity data after error: $cachedData");
        List<dynamic> data = json.decode(cachedData);
        _processActivityData(data);
      } else {
        setState(() {
          error = "Failed to load activity data: ${err.toString()}";
        });
        print("No cached activity data found for key: $cacheKey after error");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper to process activity data into monthlyData.
  void _processActivityData(List<dynamic> data) {
    List<int> newMonthlyData = List.filled(12, 0);
    for (var item in data) {
      String monthStr = item["month"] ?? "";
      int interactionCount = item["interaction_count"] ?? 0;
      if (monthStr.contains('-')) {
        int? monthIndex = int.tryParse(monthStr.split('-')[1]);
        if (monthIndex != null && monthIndex > 0 && monthIndex <= 12) {
          newMonthlyData[monthIndex - 1] = interactionCount;
        }
      }
    }
    setState(() {
      monthlyData = newMonthlyData;
    });
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activity Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ];
                        int index = value.toInt();
                        if (index >= 0 && index < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 5),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.green],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestActivitiesSection() {
    String baseUrl = "https://course-server.sahet-dev.com/storage/";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Most Interacted Courses",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: latestActivities.map((course) {
              String imageUrl = baseUrl + (course["thumbnail"] ?? "default.png");
              return GestureDetector(
                onTap: () {
                  int courseId = course["id"];
                  _navigateToCourseDetail(courseId);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course["title"],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course["description"],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${course["price"]}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  Text(
                                    "Interactions: ${course["interaction_count"]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCoursesSection(BuildContext context) {
    String baseUrl = "https://course-server.sahet-dev.com/storage/";
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Featured Courses",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                mainAxisExtent: 200,
              ),
              itemCount: popularCourses.length,
              itemBuilder: (context, index) {
                var course = popularCourses[index];
                String imageUrl = course["thumbnail"].startsWith("http")
                    ? course["thumbnail"]
                    : "$baseUrl${course["thumbnail"]}";
                return GestureDetector(
                  onTap: () => _navigateToCourseDetail(course["id"]),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            course["title"] ?? "No title",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: isLoading
              ? const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
              : error != null
              ? _buildErrorState()
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activity Dashboard",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              _buildChartSection(),
              const SizedBox(height: 24),
              _buildLatestActivitiesSection(),
              const SizedBox(height: 24),
              _buildFeaturedCoursesSection(context),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/courseCatalog');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Browse Catalog",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
