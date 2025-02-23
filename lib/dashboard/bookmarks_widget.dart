// bookmarks_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:course/services/auth_service.dart';

/// Model class representing a Bookmark.
class Bookmark {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final String price;
  final String type;
  final int teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int premium;
  final int subscriptionAccess;

  Bookmark({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.price,
    required this.type,
    required this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    required this.premium,
    required this.subscriptionAccess,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      price: json['price'],
      type: json['type'],
      teacherId: json['teacher_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      premium: json['premium'],
      subscriptionAccess: json['subscription_access'],
    );
  }
}

/// A widget that fetches and displays bookmarks.
class BookmarksWidget extends StatefulWidget {
  const BookmarksWidget({super.key});

  @override
  State<BookmarksWidget> createState() => _BookmarksWidgetState();
}

class _BookmarksWidgetState extends State<BookmarksWidget> {
  late Future<List<Bookmark>> _bookmarksFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _bookmarksFuture = _fetchBookmarks();
  }

  /// Fetches bookmarks using the ApiService.
  Future<List<Bookmark>> _fetchBookmarks() async {
    try {
      final response = await _apiService.get('bookmarks');
      // Ensure the response data is decoded into a List.
      final List<dynamic> jsonData = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return jsonData.map((json) => Bookmark.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load bookmarks: $error');
    }
  }

  /// Builds a Card widget for each bookmark.
  Widget _buildBookmarkCard(Bookmark bookmark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          // Change AssetImage to NetworkImage if thumbnails are remote.
          backgroundImage: AssetImage('assets/images/${bookmark.thumbnail}'),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          bookmark.title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          bookmark.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Text(
          "\$${bookmark.price}",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.green),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bookmark>>(
      future: _bookmarksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final bookmarks = snapshot.data!;
          if (bookmarks.isEmpty) {
            return Center(
              child: Text('No bookmarks found.',
                  style: Theme.of(context).textTheme.titleMedium),
            );
          }
          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) =>
                _buildBookmarkCard(bookmarks[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
