import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CourseService {
  final Dio _dio = Dio();
  final String apiUrl = "https://course-server.sahet-dev.com/api/api-course";

  Future<Map<String, dynamic>> fetchCourses() async {
    try {
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.getSingleFile(apiUrl);

      // Check if data exists in cache
      if (file.existsSync()) {
        final cachedData = await file.readAsString();
        final jsonData = json.decode(cachedData);
        return {
          "popularCourses": jsonData["popularCourses"] ?? [],
          "latestCourses": jsonData["latestCourses"] ?? [],
        };
      }

      // Fetch from API if no cache found
      final response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        final data = response.data;

        // Cache the response
        await cacheManager.putFile(apiUrl, utf8.encode(json.encode(data)));

        return {
          "popularCourses": data["popularCourses"] ?? [],
          "latestCourses": data["latestCourses"] ?? [],
        };
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      print("Error fetching courses: $e");
      return {"popularCourses": [], "latestCourses": []};
    }
  }
}
