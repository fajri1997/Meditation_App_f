//profile_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:meditation_app/providrors/ThemeProvider.dart';
import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:meditation_app/models/tip.dart';
// import 'package:meditation_app/providrors/AuthProvider.dart';
// import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the AuthProvider to get user data and logout functionality
    final authProvider = context.read<AuthProvider>();
    final themeProvider =
        Provider.of<ThemeProvider>(context, listen: false); // Add themeProvider
    final String username = authProvider.getUserUsername();
    final String defaultImageUrl =
        'https://via.placeholder.com/150'; // Replace with your actual default image URL if you have one

    // Controllers for text fields
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
            onChanged: (value) {
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
                        _usernameController.text, _passwordController.text);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Profile updated successfully."),
                      ));
                    } else {
                      // If the method returns false without throwing an exception
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Failed to update profile."),
                      ));
                    }
                  } catch (e) {
                    // Log the error message to the console
                    print('An error occurred during profile update: $e');
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text('Update Profile'),
              ),

              // ElevatedButton(
              //   onPressed: () async {
              //     // Call the updateProfile method with the new username and password
              //     bool success = await authProvider.updateProfile(
              //         _usernameController.text, _passwordController.text);
              //     if (success) {
              //       // Show a success message or handle the successful update
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text("Profile updated successfully."),
              //         ),
              //       );
              //     } else {
              //       // Handle the error case
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text("Failed to update profile."),
              //         ),
              //       );
              //     }
              //   },
              //   child: const Text('Update Profile'),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Call the logout method from the AuthProvider
                  await authProvider.logout();

                  // Use GoRouter to navigate back to the /signin route
                  GoRouter.of(context).go('/signin');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
