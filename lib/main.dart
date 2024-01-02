//main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:meditation_app/providrors/ThemeProvider.dart';
import 'package:meditation_app/views/signin.dart';
import 'package:meditation_app/views/signup.dart';
import 'package:provider/provider.dart';
import 'package:meditation_app/pages/Exercise_page.dart';
import 'package:meditation_app/pages/home_page.dart';
import 'package:meditation_app/pages/meditation_page.dart';
import 'package:meditation_app/pages/music_page.dart';
import 'package:meditation_app/pages/profile_page.dart';
import 'package:meditation_app/pages/tips_page.dart';
import 'package:meditation_app/pages/yoga_page.dart';
import 'package:meditation_app/views/splash.dart';

// import 'package:meditation_app/views/StaticPage.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                ThemeProvider(ThemeData.light())), // Added ThemeProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: themeProvider.getTheme(),
      routerConfig: _router,
    );
  }

  final _router = GoRouter(routes: [
    GoRoute(
      path: '/homepage',
      name: 'homepage',
      builder: (context, state) => MyHomePage(),
    ),
    GoRoute(
      path: "/",
      name: "SplashScreen",
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: "/signup",
      name: 'signup',
      builder: (context, state) => SignUpPage(),
    ),
    GoRoute(
      path: "/signin",
      name: "signin",
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/tips',
      name: 'tips',
      builder: (context, state) => TipsPage(),
    ),
    GoRoute(
      path: '/exercise',
      name: 'exercise',
      builder: (context, state) => ExercisePage(),
    ),
    GoRoute(
      path: '/yoga_page',
      name: 'yoga_page',
      builder: (context, state) => YogaPage(),
    ),
    GoRoute(
      path: '/music_page',
      name: 'music_page',
      builder: (context, state) => MusicPage(),
    ),
    GoRoute(
      path: '/meditation_page',
      name: 'meditation_page',
      builder: (context, state) => MeditationSessionsPage(
        meditationId: 1, // Provide a constant value or get it dynamically
      ),
    )
  ]);
}
