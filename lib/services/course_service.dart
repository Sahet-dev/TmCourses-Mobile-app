import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class CourseService {
  final Dio _dio = Dio();
  final String coursesApiUrl = "https://course-server.sahet-dev.com/api/api-course";
  final String baseUrl = "https://course-server.sahet-dev.com/api/api-courses/";
  final cacheManager = DefaultCacheManager();

  // Connectivity check helper function
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Caches course data (including lessons if returned) for offline use.
  Future<Map<String, dynamic>> fetchCourses() async {
    try {
      final bool online = await hasInternetConnection();
      // Attempt to load from cache first
      final fileInfo = await cacheManager.getFileFromCache(coursesApiUrl);

      if (!online && fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        final jsonData = json.decode(cachedData);
        return {
          "popularCourses": jsonData["popularCourses"] ?? [],
          "latestCourses": jsonData["latestCourses"] ?? [],
        };
      }

      // If online or no cache exists, fetch fresh data from the API
      final response = await _dio.get(coursesApiUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        // Cache the response with a max age of 1 day
        await cacheManager.putFile(
          coursesApiUrl,
          utf8.encode(json.encode(data)),
          fileExtension: "json",
          maxAge: Duration(days: 1),
        );
        return {
          "popularCourses": data["popularCourses"] ?? [],
          "latestCourses": data["latestCourses"] ?? [],
        };
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      print("Error fetching courses: $e");
      // Fallback to cache if available
      final fileInfo = await cacheManager.getFileFromCache(coursesApiUrl);
      if (fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        final jsonData = json.decode(cachedData);
        return {
          "popularCourses": jsonData["popularCourses"] ?? [],
          "latestCourses": jsonData["latestCourses"] ?? [],
        };
      }
      return {"popularCourses": [], "latestCourses": []};
    }
  }

  /// Caches private course details (including lessons if part of the response) for offline use.
  Future<Map<String, dynamic>> fetchPrivateCourse(int courseId) async {
    final String courseUrl = "$baseUrl$courseId";
    try {
      final bool online = await hasInternetConnection();
      // Attempt to load from cache first if offline
      final fileInfo = await cacheManager.getFileFromCache(courseUrl);
      if (!online && fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        return json.decode(cachedData);
      }

      // If online or no cache exists, fetch fresh data from the API
      final response = await _dio.get(courseUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        // Cache the response with a max age of 1 day
        await cacheManager.putFile(
          courseUrl,
          utf8.encode(json.encode(data)),
          fileExtension: "json",
          maxAge: Duration(days: 1),
        );
        return data;
      } else {
        throw Exception("Failed to load course details");
      }
    } catch (e) {
      print("Error fetching private course: $e");
      // Fallback to cache if available
      final fileInfo = await cacheManager.getFileFromCache(courseUrl);
      if (fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        return json.decode(cachedData);
      }
      return {};
    }
  }
}

