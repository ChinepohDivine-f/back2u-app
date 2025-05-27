import 'dart:async';

import 'package:back2u/views/home/index.dart'; // Assuming this is your main app screen after onboarding/login
import 'package:back2u/views/onboarding/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Convert Splash to a StatefulWidget to manage asynchronous operations
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // Use initState to perform asynchronous operations when the widget is created
  @override
  void initState() {
    super.initState();
    _initializeApp(); // Call a method to handle initialization and navigation
  }

  Future<void> _initializeApp() async {
    // Wait for a short duration to display the splash screen
    await Future.delayed(const Duration(seconds: 3)); // Reduced to 3 seconds for better UX

    // Listen to Firebase Authentication state changes
    // This is more robust as it handles existing sessions,
    // and also the result of signInAnonymously.
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // No user is signed in, attempt anonymous sign-in
        try {
          await FirebaseAuth.instance.signInAnonymously();
          print("Signed in with temporary account.");
          // After successful anonymous sign-in, navigate to Home
          if (mounted) { // Check if the widget is still in the tree before navigating
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()), // Navigate to Home after anonymous sign-in
            );
          }
        } on FirebaseAuthException catch (e) {
          // Handle authentication errors
          switch (e.code) {
            case "operation-not-allowed":
              print("Anonymous auth hasn't been enabled for this project.");
              // If anonymous auth is not enabled, navigate to Onboarding
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Onboarding()),
                );
              }
              break;
            default:
              print("Unknown Firebase Auth error: ${e.message}");
              // For other errors, navigate to Onboarding
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Onboarding()),
                );
              }
          }
        }
      } else {
        // User is already signed in (could be anonymous or another type), navigate to Home
        print("User is already signed in: ${user.uid}");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      }
    });
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
                  width: 300,
                ),
              ),
              const SizedBox(height: 20),
              // You can add a loading indicator here if desired
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