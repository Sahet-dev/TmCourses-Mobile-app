import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:course/services/course_service.dart';
import 'package:course/widgets/lesson_comments.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CourseDetailPage extends StatefulWidget {
  final int courseId;
  const CourseDetailPage({super.key, required this.courseId});

  Future<void> cacheCourseData(Map<String, dynamic> courseData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_course_${courseData['id']}', jsonEncode(courseData));
  }

  Future<Map<String, dynamic>?> getCachedCourseData(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_course_$courseId');
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }
    return null;
  }

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseService _courseService = CourseService();
  Map<String, dynamic>? _course;
  bool _isLoading = true;
  bool _isSidebarOpen = false;
  Map<String, dynamic>? _selectedLesson;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // Tab selection: "guides" or "comments" with ToggleButtons.
  String _selectedTab = "guides";
  List<bool> _isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final response = await _courseService.fetchPrivateCourse(widget.courseId);
      setState(() {
        _course = response["course"];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching course details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectLesson(Map<String, dynamic> lesson) {
    setState(() {
      _selectedLesson = lesson;
      _isSidebarOpen = false;
      _selectedTab = "guides"; // Reset to guides when a new lesson is selected.
      _isSelected = [true, false];
    });

    _initializeVideoPlayer(lesson["video_url"]);
  }

  void _initializeVideoPlayer(String? videoUrl) {
    _disposeVideoPlayer();
    if (videoUrl != null && videoUrl.isNotEmpty) {
      // Check if the URL is relative and prepend the base URL if necessary.
      String finalUrl = videoUrl;
      if (!videoUrl.startsWith("http")) {
        finalUrl = "https://course-server.sahet-dev.com/storage/" + finalUrl;
      }
      print("Initializing video player with URL: $finalUrl");
      _videoController = VideoPlayerController.networkUrl(Uri.parse(finalUrl))
        ..initialize().then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
          );
          setState(() {}); // Update the UI once the video is initialized.
        }).catchError((error) {
          print("Video initialization error: $error");
        });
    } else {
      print("Invalid video URL provided: $videoUrl");
    }
  }

  void _disposeVideoPlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_course?['title'] ?? 'Course Details'),
        leading: IconButton(
          icon: Icon(_isSidebarOpen ? Icons.close : Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCourseContent(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: _buildSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lessons",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSidebarOpen = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...(_course?["lessons"] ?? []).map<Widget>((lesson) {
            return ListTile(
              title: Text(lesson["title"]),
              onTap: () {
                _selectLesson(lesson);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedLesson == null) ...[
                Text(
                  _course?["title"] ?? '',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(_course?["description"] ?? ''),
                const SizedBox(height: 10),
                Text(
                  _course?["price"] != null ? "\$${_course?["price"]}" : "Free",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],
              if (_selectedLesson != null) _buildLessonContent(),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildLessonContent() {
    String? videoUrl = _selectedLesson?["video_url"];
    final List lessons = _course?["lessons"] ?? [];
    final int currentIndex = lessons.indexOf(_selectedLesson);

    return Expanded( // Prevents overflow
      child: SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedLesson?["title"] ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              videoUrl != null && videoUrl.isNotEmpty
                  ? AspectRatio(
                aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                child: _chewieController != null &&
                    _videoController != null &&
                    _videoController!.value.isInitialized
                    ? Chewie(
                  controller: _chewieController!,
                )
                    : const Center(child: CircularProgressIndicator()),
              )
                  : const Text("No video available for this lesson."),
              const SizedBox(height: 10),
              // Navigation buttons for previous and next lesson.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentIndex > 0
                        ? () => _selectLesson(lessons[currentIndex - 1])
                        : null,
                    child: const Text("Previous"),
                  ),
                  ElevatedButton(
                    onPressed: currentIndex < lessons.length - 1
                        ? () => _selectLesson(lessons[currentIndex + 1])
                        : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ToggleButtons for Guides and Comments.
              Center(
                child: ToggleButtons(
                  color: Colors.black.withOpacity(0.60),
                  selectedColor: const Color(0xFF6200EE),
                  selectedBorderColor: const Color(0xFF6200EE),
                  fillColor: const Color(0xFF6200EE).withOpacity(0.08),
                  splashColor: const Color(0xFF6200EE).withOpacity(0.12),
                  hoverColor: const Color(0xFF6200EE).withOpacity(0.04),
                  borderRadius: BorderRadius.circular(4.0),
                  constraints: const BoxConstraints(minHeight: 36.0),
                  isSelected: _isSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _isSelected.length; i++) {
                        _isSelected[i] = i == index;
                      }
                      _selectedTab = index == 0 ? "guides" : "comments";
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book, size: 18),
                          SizedBox(width: 4),
                          Text('Guides'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.comment, size: 18),
                          SizedBox(width: 4),
                          Text('Comments'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Display content based on selected tab.
              _selectedTab == "guides"
                  ? Html(
                data: _selectedLesson?["markdown_text"] ?? '',
              )
                  : Container(
                // Provide a fixed height for the comments section.
                height: 300, // Adjust this value as needed
                child: LessonComments(
                  // lessonId: _selectedLesson?["id"],
                  lessonId: _selectedLesson?["id"] is int
                      ? _selectedLesson!["id"]
                      : int.tryParse(_selectedLesson?["id"] ?? '') ?? 0,
                  courseId: widget.courseId,

                ),
              ),
            ],
          )
      ),
    );
  }


}
