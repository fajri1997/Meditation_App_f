//music_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/models/tip.dart';

class MusicPage extends StatelessWidget {
  MusicPage({Key? key}) : super(key: key);

  // Example list of tips, replace with your data source
  final List<Tip> tips = [
    Tip(id: 1, text: 'Music Track 1', author: 'Author 1', owner: ''),
    Tip(id: 2, text: 'Music Track 2', author: 'Author 2', owner: ''),
    // Add more tips...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).goNamed("homepage");
          },
        ),
      ),
      body: ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tips[index].text ?? 'Default tip text'),
            subtitle: Text('Author: ${tips[index].author ?? 'Unknown'}'),
            onTap: () {
              // Handle tap on a tip
              print('Tip ${tips[index].id} tapped');
            },
          );
        },
      ),
    );
  }
}
