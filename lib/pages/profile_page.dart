import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:meditation_app/providrors/ThemeProvider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final String username = authProvider.getUserUsername();
    final String defaultImageUrl = 'https://via.placeholder.com/150';

    final TextEditingController _usernameController =
        TextEditingController(text: username);
    final TextEditingController _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).goNamed("homepage");
          },
        ),
        actions: [
          Switch(
            value: themeProvider.getTheme().brightness == Brightness.dark,
            onChanged: (bool value) {
              themeProvider.setTheme(
                value ? ThemeData.dark() : ThemeData.light(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(defaultImageUrl),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'New Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    bool success = await authProvider.updateProfile(
                      _usernameController.text,
                      _passwordController.text,
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated successfully."),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to update profile."),
                        ),
                      );
                    }
                  } catch (e) {
                    print('An error occurred during profile update: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text('Update Profile'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  GoRouter.of(context).go('/signin');
                },
                child: const Text('Logout'),
              ),
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
            icon: Icon(Icons.fitness_center),
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
              context.go(
                  '/homepage'); // Make sure '/home' is defined in your routes
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
}
