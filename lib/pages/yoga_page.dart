import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

class ExercisePage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final token = await getToken(); // Method to get the saved auth token

      final response = await http.get(
        Uri.parse('https://coded-meditation.eapi.joincoded.com/exercises'),
        headers: {
          'Authorization': 'Bearer $token', // Include the authorization header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> exercisesJson = json.decode(response.body);
        setState(() {
          exercises =
              exercisesJson.map((json) => Exercise.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load exercises with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e); // For debugging purposes
      // Handle the exception by showing user feedback or logging it
    }
  }

  Future<String> getToken() async {
    // Logic to retrieve the stored token
    // This might involve using SharedPreferences or another form of persistent storage
    // For example:
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found');
    }
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yoga Exercises'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Use context.go to navigate to the homepage route using GoRouter
            context.go('/homepage');
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise.title),
                  subtitle:
                      Text(exercise.finished ? 'Completed' : 'Incomplete'),
                  onTap: () => navigateToVideoPage(exercise.file),
                );
              },
            ),
    );
  }

  void navigateToVideoPage(String videoUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Exercise {
  final int id;
  final String title;
  final String file;
  final bool finished;

  Exercise({
    required this.id,
    required this.title,
    required this.file,
    required this.finished,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      file: json['file'],
      finished: json['finished'],
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Video'),
      ),
      body: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
