// import 'dart:async';

// import 'package:back2u/views/home/index.dart';
// import 'package:back2u/views/onboarding/index.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Splash extends StatelessWidget {
//   const Splash({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;
//     final colorScheme = theme.colorScheme;
//     Timer(const Duration(seconds: 5), () {
//       // anonymous authentication with firebase
      

//       // Navigate to the Onboarding screen after 5 seconds
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const Onboarding(),
//         ),
//       );
//     });
//     return SafeArea(
//       child: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: colorScheme.primaryContainer,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Image.asset(
//                   'assets/images/2.png',
//                   width: 300,

//                 ),
//               ),
//               //  Icon(
//               //   Icons.backpack,
//               //   size: 100,
//               //   color: theme.primaryColor,
//               // ),
//               const SizedBox(height: 20),
//               // Text(
//               //   "Connecting Document Owners with Finders.",
//               //   textAlign: TextAlign.center,
//               //   style: TextStyle(fontSize: 16, color: TextTheme().bodyMedium?.color),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';

import 'package:back2u/views/home/index.dart'; // Your main app screen
import 'package:back2u/views/onboarding/index.dart'; // Your onboarding screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

// Constant for the SharedPreferences key to track initial setup completion
const String _kHasCompletedInitialSetup = 'has_completed_initial_setup';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Call the function to handle initialization and navigation
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // Wait for a short duration to display the splash screen gracefully
    await Future.delayed(const Duration(seconds: 3));

    // Ensure the widget is still mounted before proceeding with navigation
    if (!mounted) return;

    // Get SharedPreferences instance to store/retrieve flags
    final prefs = await SharedPreferences.getInstance();

    // Check if the user has previously completed the initial setup (e.g., seen onboarding after first anonymous login)
    final bool hasCompletedInitialSetup = prefs.getBool(_kHasCompletedInitialSetup) ?? false;

    // Get the current user from Firebase Authentication.
    // This will be null if no user is signed in, or a User object if there's an active session
    // (anonymous, Google, email/password, etc.).
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Case 1: No user is currently signed in.
      // Attempt to sign in anonymously. This is treated as a "first-time" authentication attempt.
      try {
        await FirebaseAuth.instance.signInAnonymously();
        print("Signed in with temporary account.");

        // If anonymous sign-in is successful for a previously unauthenticated user,
        // mark the initial setup as complete (they are now authenticated for the first time)
        // and navigate them to the Onboarding screen.
        await prefs.setBool(_kHasCompletedInitialSetup, true);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Authentication errors during anonymous sign-in.
        // If authentication fails (e.g., "operation-not-allowed"), or any other error,
        // we still need to guide the user, so direct them to Onboarding.
        print("Firebase Auth error during anonymous sign-in: ${e.code} - ${e.message}");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding()),
          );
        }
      } catch (e) {
        // Catch any other unexpected errors during the process
        print("General error during anonymous sign-in: $e");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding()),
          );
        }
      }
    } else {
      // Case 2: A user is already signed in.
      // This could be an existing anonymous user from a previous session,
      // or a user signed in via Google/Email/etc.

      print("User is already signed in: ${currentUser.uid}, isAnonymous: ${currentUser.isAnonymous}");

      // Now, check if this user has already completed the initial setup.
      if (hasCompletedInitialSetup) {
        // If they have completed initial setup, navigate directly to the Home screen.
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        // Edge Case: A user exists (e.g., an old anonymous user from before this logic was implemented),
        // but the 'hasCompletedInitialSetup' flag is false.
        // In this scenario, we'll assume they need to see the onboarding.
        // Mark initial setup as complete now and then send them to Onboarding.
        await prefs.setBool(_kHasCompletedInitialSetup, true);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Image.asset(
                  'assets/images/2.png', // Ensure this asset exists in your pubspec.yaml
                  width: 250,
                ),
              ),
              const SizedBox(height: 20),
              // Display a loading indicator while the authentication and navigation logic runs
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}