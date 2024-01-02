import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late List<Track> tracks;
  bool isLoading = true;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<void> fetchMusic() async {
    try {
      final response = await http
          .get(Uri.parse('https://coded-meditation.eapi.joincoded.com/music'));
      if (response.statusCode == 200) {
        final List<dynamic> musicListJson = json.decode(response.body);
        tracks = musicListJson.map((json) => Track.fromJson(json)).toList();
        setState(() {
          isLoading = false;
        });
      } else {
        // Handle error response
        throw Exception('Failed to load music');
      }
    } catch (e) {
      // Handle any exceptions
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Using GoRouter to navigate to the homepage route
            context.go('/homepage');
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Card(
                  // Wrap with Card for better UI
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    title: Text(
                      track.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tap to play'),
                    onTap: () => playTrack(track.file),
                    leading: Icon(Icons.music_note),
                    trailing: Icon(Icons.play_arrow),
                  ),
                );
              },
            ),
    );
  }

  void playTrack(String url) async {
    await audioPlayer.setSource(UrlSource(url));
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.release();
    audioPlayer.dispose();
    super.dispose();
  }
}

class Track {
  final int id;
  final String title;
  final String file;

  Track({required this.id, required this.title, required this.file});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      file: json['file'],
    );
  }
}
