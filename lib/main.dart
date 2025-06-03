import 'package:back2u/providers/theme_provider.dart';
import 'package:back2u/views/my_reports/index.dart';
import 'package:back2u/views/settings/index.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider for state management

// Import your custom files
import 'package:back2u/firebase_options.dart'; // Firebase options
import 'package:back2u/services/auth_kyc_service.dart'; // Your AuthKycService
import 'package:back2u/services/get_reports_service.dart'; // <--- NEW: Import your ReportService
// import 'package:back2u/providers/theme_provider.dart'; // <--- NEW: Import your ThemeProvider

import 'package:back2u/views/splash.dart'; // Your splash screen
import 'package:back2u/views/home/index.dart'; // Your home page (assuming class name is Home)
import 'package:back2u/views/onboarding/index.dart'; // Your main onboarding screen (assuming class name is Onboarding)
import 'package:back2u/views/report/index.dart'; // Your report page (assuming class name is ReportPage)
import 'package:back2u/views/auth/kyc_form_page.dart'; // Your KYC form page
import 'package:back2u/views/data/data_seeder.dart'; // Your data seeder page
// import 'package:back2u/views/settings/settings_page.dart'; // Your settings page (assuming class name is SettingsPage)
// import 'package:back2u/views/my_reports/my_reports_page.dart'; // Your reports page (assuming class name is MyReportsPage)
// Note: If your actual class names differ from the file names (e.g., index.dart contains class Home),
// ensure the class names used in routes match the actual class names.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Provide AuthKycService throughout the app's widget tree.
        Provider<AuthKycService>(
          create: (_) => AuthKycService(),
          // Optional: If AuthKycService has a dispose method, call it here
          // dispose: (_, service) => service.dispose(),
        ),
        // <--- FIX: Add ThemeProvider for theme management --->
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        // <--- FIX: Add ReportService for report fetching --->
        Provider<ReportService>(
          create: (_) => ReportService(),
          dispose: (_, service) => service.dispose(), // Ensure dispose is called
        ),
        // Add other services or providers here if your app grows
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // <--- FIX: Access the ThemeProvider for themeMode --->
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Back2U App',
      // <--- FIX: Use themeProvider's themeMode for dynamic theme switching --->
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,

      // <--- FIX: Define a proper light theme --->
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Explicitly light brightness
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        // You can customize other theme properties here (e.g., textTheme, buttonTheme)
      ),

      // <--- FIX: Define a proper dark theme, complementing the light theme --->
      darkTheme: ThemeData(
        primarySwatch: Colors.blue, // Still using primarySwatch for older widgets if any
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark, // Explicitly dark brightness
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        // Customize dark theme specific properties if needed
      ),

      home: const Splash(), // The splash screen is the initial route

      // Define named routes for easy navigation
      routes: {
        '/home': (context) => const Home(),
        '/onboarding': (context) => const Onboarding(),
        '/report': (context) => const ReportPage(),
        '/kyc_form': (context) => const KycFormPage(),
        '/data_seeder': (context) => const DataSeederPage(),
        '/settings': (context) => const SettingsPage(), // Correctly points to SettingsPage
        '/my_reports': (context) => const MyReportsPage(), // Correctly points to MyReportsPage
        // <--- FIX: Removed incorrect/commented out route --->
        // '/authKyc': (context) => Provider.of<KycFormPage>(context, listen: false),
      },
    );
  }
}