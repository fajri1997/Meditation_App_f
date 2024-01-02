//meditation_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/models/meditation.dart';
import 'package:meditation_app/models/tip.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:meditation_app/providrors/ThemeProvider.dart';
import 'package:provider/provider.dart';

class MeditationSessionsPage extends StatefulWidget {
  final int meditationId;

  const MeditationSessionsPage({Key? key, required this.meditationId})
      : super(key: key);

  @override
  _MeditationSessionsPageState createState() => _MeditationSessionsPageState();
}

class _MeditationSessionsPageState extends State<MeditationSessionsPage> {
  List<MeditationSession> sessions = [];

  @override
  void initState() {
    super.initState();
    // Fetch meditation sessions when the widget is created
    fetchMeditationSessions();
  }

  Future<void> fetchMeditationSessions() async {
    try {
      // Make the API request to fetch meditation sessions for the selected meditation

      final response = await http.get(
        Uri.parse(
            'https://coded-meditation.eapi.joincoded.com/meditation/${widget.meditationId}'),
      );

      // Parse the response data
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          // Update the sessions list with the parsed data
          sessions = data
              .map((session) => MeditationSession.fromJson(session))
              .toList();
        });
      } else {
        // Handle error if the request was not successful
        print('Failed to load meditation sessions: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that might occur
      print('Error fetching meditation sessions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meditation Sessions'),
      ),
      body: sessions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(sessions[index].title),
                  subtitle: Text('File: ${sessions[index].file}'),
                  // You can add more details or actions here
                );
              },
            ),
    );
  }
}
