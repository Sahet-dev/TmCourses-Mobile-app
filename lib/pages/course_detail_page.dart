import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:course/services/course_service.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

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

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    final response = await _courseService.fetchPrivateCourse(widget.courseId);
    setState(() {
      _course = response["course"];
      _isLoading = false;
    });
  }

  void _selectLesson(Map<String, dynamic> lesson) {
    setState(() {
      _selectedLesson = lesson;
      _isSidebarOpen = false;
    });
    _initializeVideoPlayer(lesson["video_url"]);
  }

  void _initializeVideoPlayer(String? videoUrl) {
    _disposeVideoPlayer(); // Dispose previous player

    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          setState(() {});
        });

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
      );
    }
  }

  void _disposeVideoPlayer() {
    _videoController?.dispose();
    _chewieController?.dispose();
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
              const Text("Lessons",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    return Column(
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
    );
  }

  Widget _buildLessonContent() {
    String? videoUrl = _selectedLesson?["video_url"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedLesson?["title"] ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        videoUrl != null && videoUrl.isNotEmpty
            ? AspectRatio(
          aspectRatio: 16 / 9,
          child: _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const Center(child: CircularProgressIndicator()),
        )
            : const Text("No video available for this lesson."),
        const SizedBox(height: 10),
        Text(
          'Description: ${_selectedLesson?["markdown_text"] ?? ''}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
