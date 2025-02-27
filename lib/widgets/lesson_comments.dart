import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LessonComments extends StatefulWidget {
  final int lessonId;
  final int courseId;
  const LessonComments({super.key, required this.lessonId, required this.courseId});

  @override
  _LessonCommentsState createState() => _LessonCommentsState();
}

class _LessonCommentsState extends State<LessonComments> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  // Create a cache manager instance.
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  List<dynamic> _comments = [];
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isSubmitting = false;
  String? _authToken;
  Set<int> _likedComments = {};

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    String? token = await _secureStorage.read(key: 'token');
    setState(() {
      _authToken = token;
      _isAuthenticated = token != null;
    });
  }

  // Helper method to check connectivity
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;
    print("Connectivity check: $connectivityResult, hasConnection: $hasConnection");
    return hasConnection;
  }

  Future<void> _fetchComments() async {
    final String cacheKey = 'lesson_comments_${widget.lessonId}';
    try {
      bool online = await _hasInternetConnection();
      if (!online) {
        print("Offline mode: loading comments from cache with key: $cacheKey");
        final fileInfo = await _cacheManager.getFileFromCache(cacheKey);
        if (fileInfo != null) {
          final cachedData = await fileInfo.file.readAsString();
          print("Cached comments data found: $cachedData");
          final jsonData = json.decode(cachedData);
          _updateCommentsState(jsonData);
        } else {
          print("No cached comments available");
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      print("Online mode: fetching comments for lesson ${widget.lessonId}");
      final response = await _dio.get(
        'https://course-server.sahet-dev.com/api/lessons/${widget.lessonId}/comments',
      );
      if (response.statusCode == 200) {
        print("API response for comments: ${response.data}");
        // Cache the API response as JSON.
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(json.encode(response.data)),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );
        _updateCommentsState(response.data);
      } else {
        throw Exception("Failed to load comments from API");
      }
    } catch (e) {
      print("Error fetching comments: $e");
      // Attempt to load from cache on error.
      final fileInfo = await _cacheManager.getFileFromCache(cacheKey);
      if (fileInfo != null) {
        final cachedData = await fileInfo.file.readAsString();
        print("Using cached comments data after error: $cachedData");
        final jsonData = json.decode(cachedData);
        _updateCommentsState(jsonData);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to update comments state
  void _updateCommentsState(dynamic data) {
    setState(() {
      _comments = data;
      _likedComments.clear();
      for (var comment in _comments) {
        if (comment['is_liked'] == true) {
          _likedComments.add(comment['id']);
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _likeComment(int commentId) async {
    if (!_isAuthenticated) {
      _showAuthRequiredSnackBar("like a comment");
      return;
    }

    try {
      final response = await _dio.post(
        'https://course-server.sahet-dev.com/api/courses/${widget.courseId}/lessons/${widget.lessonId}/comments/$commentId/toggle-like',
        options: Options(
          headers: {'Authorization': 'Bearer $_authToken'},
        ),
      );

      if (response.statusCode == 200) {
        String message = response.data['message'];
        int updatedLikes = response.data['commentLikesCount'] ?? 0;

        setState(() {
          if (message == "Liked") {
            _likedComments.add(commentId);
          } else {
            _likedComments.remove(commentId);
          }

          for (var comment in _comments) {
            if (comment['id'] == commentId) {
              comment['likes_count'] = updatedLikes;
              break;
            }
          }
        });
      }
    } catch (e) {
      print("Error liking comment: $e");
    }
  }

  void _showAuthRequiredSnackBar(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You must be logged in to $action"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Future<void> _postComment(String comment) async {
    if (!_isAuthenticated) {
      _showAuthRequiredSnackBar("post a comment");
      return;
    }

    if (comment.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _dio.post(
        'https://course-server.sahet-dev.com/api/courses/${widget.courseId}/lessons/${widget.lessonId}/comments',
        options: Options(
          headers: {'Authorization': 'Bearer $_authToken'},
        ),
        data: {'comment': comment},
      );

      if (response.statusCode == 201) {
        // Refresh comments after posting.
        _fetchComments();
        _commentController.clear();
      }
    } catch (e) {
      print("Error posting comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to post comment. Please try again."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return timeago.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Discussion",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          )
              : _comments.isEmpty
              ? _buildEmptyCommentsView()
              : _buildCommentsList(),
        ),
        Divider(height: 1),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildEmptyCommentsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No comments yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to start the discussion",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final bool isLiked = _likedComments.contains(comment['id']);

        return _buildCommentCard(comment, isLiked);
      },
    );
  }

  Widget _buildCommentCard(dynamic comment, bool isLiked) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildUserAvatar(comment['user']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['user']['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatTimestamp(comment['created_at']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment['comment'] ?? 'No content',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLikeButton(
                  isLiked: isLiked,
                  likesCount: comment['likes_count'] ?? 0,
                  onTap: () => _likeComment(comment['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic>? user) {
    final String avatarUrl = user?['avatar_url'] ?? '';
    final String name = user?['name'] ?? 'U';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: avatarUrl.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          placeholder: (context, url) => Center(
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Text(
            initial,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      )
          : Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLikeButton({
    required bool isLiked,
    required int likesCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              likesCount.toString(),
              style: TextStyle(
                color: isLiked ? Colors.red : Colors.grey[600],
                fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: _isAuthenticated
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            elevation: 0,
            child: InkWell(
              onTap: _isSubmitting
                  ? null
                  : () => _postComment(_commentController.text),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: _isSubmitting
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      )
          : OutlinedButton(
        onPressed: () {
          _showAuthRequiredSnackBar("post a comment");
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text(
          "Log in to join the discussion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
