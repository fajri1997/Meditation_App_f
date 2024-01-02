//home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:meditation_app/models/tip.dart';
// import 'package:meditation_app/models/user.dart';
// import 'package:meditation_app/pages/profile_page.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
// import 'package:meditation_app/widgets/meditation.dart';
// import 'package:meditation_app/widgets/music.dart';
// import 'package:meditation_app/widgets/tips.dart';
// import 'package:meditation_app/widgets/yoga.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the user information from the AuthProvider
    final String username = context.read<AuthProvider>().getUserUsername();

    return Scaffold(
      appBar: AppBar(
        title: Text('Meditation App'),
      ),
      body: Center(
        // Wrap the GridView with a Center widget
        child: ConstrainedBox(
          // Use ConstrainedBox to limit the GridView size
          constraints:
              BoxConstraints(maxWidth: 600), // Set a maxWidth for better sizing
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16.0),
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio:
                (1 / 1), // Adjust the size ratio of the cards here
            children: <Widget>[
              _buildCard(context, 'Tips', 'assets/images/tips.png', '/tips'),
              _buildCard(
                  context, 'Yoga', 'assets/images/yoga.png', '/yoga_page'),
              _buildCard(
                  context, 'Music', 'assets/images/music.png', '/music_page'),
              _buildCard(context, 'Meditation', 'assets/images/meditation.png',
                  '/meditation_page'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex:
            0, // You can set the initial index based on your default page
        onTap: (index) {
          // Handle navigation based on the selected tab
          switch (index) {
            case 0:
              // Navigate to Home page
              context
                  .go('/home'); // Make sure '/home' is defined in your routes
              break;
            case 1:
              // Navigate to Exercise page
              context.go(
                  '/exercise'); // Replace with the correct route for the Exercise page
              break;
            case 2:
              // Navigate to Profile page
              context.go(
                  '/profile'); // Replace with the correct route for the Profile page
              break;
          }
        },
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String imagePath, String route) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go(route); // Use GoRouter to navigate to the specified route
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white, // Set the background color to white
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
