// Minimalistic splash: solid background, logo fade/scale, subtle progress.

import 'package:back2u/views/home/index.dart'; // Your main app screen
import 'package:back2u/views/onboarding/index.dart'; // Your onboarding screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:provider/provider.dart';
import 'package:back2u/services/auth_kyc_service.dart';

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
    // Reduced delay for faster app startup
    await Future.delayed(const Duration(seconds: 1));

    // Ensure the widget is still mounted before proceeding with navigation
    if (!mounted) return;

    // Get SharedPreferences instance to store/retrieve flags
    final prefs = await SharedPreferences.getInstance();

    // Check if the user has previously completed the initial setup (e.g., seen onboarding after first anonymous login)
    final bool hasCompletedInitialSetup =
        prefs.getBool(_kHasCompletedInitialSetup) ?? false;

    // Get the current user from Firebase Authentication.
    // This will be null if no user is signed in, or a User object if there's an active session
    // (anonymous, Google, email/password, etc.).
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Case 1: No user is currently signed in.
      // Attempt to sign in anonymously. This is treated as a "first-time" authentication attempt.
      try {
        // Use AuthKycService for anonymous sign-in
        final authService = Provider.of<AuthKycService>(context, listen: false);
        await authService.signInAnonymously();
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
        print(
          "Firebase Auth error during anonymous sign-in: \\${e.code} - \\${e.message}",
        );
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

      print(
        "User is already signed in: ${currentUser.uid}, isAnonymous: ${currentUser.isAnonymous}",
      );

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

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(child:Center(child: Image.asset('assets/images/2.png', width: 160)),),
    );
  }

  @override
  void dispose() {
    // nothing extra to dispose
    super.dispose();
  }
}
