import 'package:back2u/views/data/data_seeder.dart';
import 'package:back2u/views/home/index.dart';
import 'package:back2u/views/onboarding/index.dart';
import 'package:back2u/views/report/index.dart';
import 'package:back2u/views/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import the auto-generated Firebase options

// Make the main function asynchronous to allow for Firebase initialization
void main() async {
  // Ensure that Flutter widgets binding is initialized before using Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Back2U App', // Changed title for clarity
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Splash(), // The splash screen is the initial route
      routes: {
        '/home': (context) => const Home(),
        // Note: '/settings' and '/report' point to the same Report widget.
        // You might want to differentiate them or use a single route if they are truly the same.
        '/settings': (context) => const ReportPage(), 
        '/onboarding': (context) => const Onboarding(),
        '/data_seeder': (context) => const DataSeederPage(), // Assuming this is for testing purposes
        '/report': (context) => const ReportPage(),
      },
    );
  }
}