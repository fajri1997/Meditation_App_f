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
      final response = await http.get(
        Uri.parse('https://coded-meditation.eapi.joincoded.com/meditation'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          sessions = data
              .map((session) => MeditationSession.fromJson(session))
              .toList();
        });
      } else {
        print('Failed to load meditation sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching meditation sessions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Sessions'),
      ),
      body: sessions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(sessions[index].title),
                  subtitle: Text('ID: ${sessions[index].id}'),
                  onTap: () {
                    // Handle tap on a meditation session
                    print('Meditation Session ${sessions[index].id} tapped');
                    // You can navigate to a detail page or play the meditation session here
                  },
                );
              },
            ),
    );
  }
}
