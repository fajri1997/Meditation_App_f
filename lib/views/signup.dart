//signup.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/models/user.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
                  // Perform sign-up logic here
                  final User user = User(
                    username: _usernameController.text,
                    password: _passwordController.text,
                  );

                  context.read<AuthProvider>().signup(user: user).then((token) {
                    if (token.isNotEmpty) {
                      // Navigate back to the sign-in page and pop the sign-up page from the stack
                      GoRouter.of(context).goNamed("signin");
                      Navigator.pop(context);
                    }
                  });
                },
                child: Text('Sign Up'),
              ),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go("/signin");
                },
                child: Text('Already have an account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
