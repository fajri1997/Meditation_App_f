import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/models/meditation.dart';
import 'package:meditation_app/services/client.dart'; // Import ApiClient

class MeditationSessionsPage extends StatefulWidget {
  const MeditationSessionsPage({Key? key})
      : super(key: key); // Removed meditationId

  @override
  _MeditationSessionsPageState createState() => _MeditationSessionsPageState();
}

class _MeditationSessionsPageState extends State<MeditationSessionsPage> {
  List<MeditationSession> sessions = [];

  @override
  void initState() {
    super.initState();
    fetchMeditationSessions();
  }

  Future<void> fetchMeditationSessions() async {
    try {
      // Use ApiClient to make the GET request for all meditation sessions
      final response = await ApiClient.get('/meditation');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).goNamed("homepage");
          },
        ),
      ),
      body: sessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(sessions[index].title),
                  subtitle: Text('File: ${sessions[index].file}'),
                );
              },
            ),
    );
  }
}
