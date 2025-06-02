import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:provider/provider.dart'; // Import Provider for state management

// Import your custom files
import 'package:back2u/firebase_options.dart'; // Import the auto-generated Firebase options
import 'package:back2u/services/auth_kyc_service.dart'; // Import your AuthKycService
import 'package:back2u/views/splash.dart'; // Your splash screen
import 'package:back2u/views/home/index.dart'; // Your home page
import 'package:back2u/views/onboarding/index.dart'; // Your main onboarding screen (renamed from index.dart for clarity)
import 'package:back2u/views/report/index.dart'; // Your report page (renamed from index.dart for clarity)
import 'package:back2u/views/auth/kyc_form_page.dart'; // Your KYC form page
import 'package:back2u/views/data/data_seeder.dart'; // Your data seeder page

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
    return MultiProvider(
      providers: [
        // Provide AuthKycService throughout the app's widget tree.
        // This allows any widget to access AuthKycService using Provider.of<AuthKycService>(context).
        Provider<AuthKycService>(
          create: (_) => AuthKycService(),
        ),
        // Add other services or providers here if your app grows
      ],
      child: MaterialApp(
        title: 'Back2U App',
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system, // Uses system theme (light/dark)
        debugShowCheckedModeBanner: false, // Hides the debug banner
        theme: ThemeData(
          // Define your Material 3 theme
          primarySwatch: Colors.blue, // Primary color swatch (for older widgets)
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, // Generates a Material 3 color scheme from a single seed color
            brightness: Brightness.light, // Default brightness for the theme
          ),
          useMaterial3: true, // Enable Material 3 features
          appBarTheme: const AppBarTheme(
            // Consistent app bar styling across the app
            centerTitle: true,
            elevation: 0, // No shadow under the app bar
          ),
          // You can customize other theme properties here (e.g., textTheme, buttonTheme)
        ),
        home: const Splash(), // The splash screen is the initial route

        // Define named routes for easy navigation
        routes: {
          '/home': (context) => const Home(),
          '/onboarding': (context) => const Onboarding(), // Corrected to OnboardingScreen
          '/report': (context) => const ReportPage(), // Corrected to ReportPage
          '/kyc_form': (context) => const KycFormPage(), // New route for the KYC form
          '/data_seeder': (context) => const DataSeederPage(), // For development/testing
          // '/settings' route is currently redundant if it points to ReportPage.
          // Consider if you need a separate settings page or remove this route.
          // '/settings': (context) => const ReportPage(),
        },
      ),
    );
  }
}