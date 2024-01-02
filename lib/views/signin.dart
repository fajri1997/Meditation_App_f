//signin.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/models/user.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:provider/provider.dart';

// import 'package:flutter/scheduler.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final User user = User(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    try {
      // Attempt to sign in and get a token
      final String token = await authProvider.signin(user: user);

      // Check if the token is not empty
      if (token.isNotEmpty) {
        // Navigate to the home screen if the sign-in is successful
        GoRouter.of(context).goNamed("homepage");
      } else {
        // If the token is empty, the sign-in was not successful
        _showSignInError(context, 'Invalid username or password.');
      }
    } catch (e) {
      // If an exception occurred, treat it as a failed sign-in
      _showSignInError(context, 'Sign-in failed: ${e.toString()}');
    }
  }

  void _showSignInError(BuildContext context, String message) {
    // Show a SnackBar with the error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  _performSignIn(context);
                },
                child: Text('Sign In'),
              ),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go("/signup");
                },
                child: Text('Create new user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
