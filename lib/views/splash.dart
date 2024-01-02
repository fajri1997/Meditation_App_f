//splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<String?> readTokenFuture =
        context.read<AuthProvider>().readTokenInStorage();

    return Scaffold(
      body: FutureBuilder<String?>(
          future: readTokenFuture,
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            // While waiting for the future to complete, show a loading indicator
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If the future completes with an error, show an error message
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading auth status"));
            }

            // If the future completes with a token, navigate to the signin or signup page
            final String? token = snapshot.data;
            if (token != null && token.isNotEmpty) {
              // Navigate to the signin page if a token exists
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).go('/signin');
              });
            } else {
              // Navigate to the signup page if there is no token
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).go('/signup');
              });
            }

            // Return an empty container to avoid any further build issues
            return const SizedBox.shrink();
          }),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:meditation_app/providrors/AuthProvider.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter/scheduler.dart';

// class SplashScreen extends StatelessWidget {
//   SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         future: context.read<AuthProvider>().readTokenInStorage(),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             print("token : ${context.read<AuthProvider>().token}");
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text("Error"),
//             );
//           } else {
//             final String? token = snapshot.data;

//             if (token != null && token.isNotEmpty) {
//               WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
//                 GoRouter.of(context).go("/signin");
//               });
//             } else {
//               WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
//                 GoRouter.of(context).go("/signup");
//               });
//             }
//             return SizedBox();
//           }
//         },
//       ),
//     );
//   }
// }