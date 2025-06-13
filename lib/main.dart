import 'package:back2u/providers/theme_provider.dart';
import 'package:back2u/views/my_reports/index.dart';
import 'package:back2u/views/saved_reports/index.dart';
import 'package:back2u/views/settings/index.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider for state management

// Import your custom files
import 'package:back2u/firebase_options.dart'; // Firebase options
import 'package:back2u/services/auth_kyc_service.dart'; // <--- UPDATED: AuthKycService
import 'package:back2u/services/get_reports_service.dart';

import 'package:back2u/views/splash.dart';
import 'package:back2u/views/home/index.dart';
import 'package:back2u/views/onboarding/index.dart';
import 'package:back2u/views/report/index.dart';
import 'package:back2u/views/auth/kyc_form_page.dart';
import 'package:back2u/views/data/data_seeder.dart';

import 'package:back2u/views/auth/auth_page.dart'; // <--- NEW: Import the AuthPage
import 'package:back2u/constants/app_theme.dart'; // NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // <--- UPDATED: AuthKycService is now a ChangeNotifierProvider --->
        ChangeNotifierProvider<AuthKycService>(
          create: (_) => AuthKycService(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        Provider<ReportService>(
          create: (_) => ReportService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Back2U App',
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // UPDATED
      darkTheme: AppTheme.darkTheme, // UPDATED
      home: const Splash(),
      routes: {
        '/splash': (context) => const Splash(),
        '/home': (context) => const Home(),
        '/onboarding': (context) => const Onboarding(),
        '/report': (context) => const ReportPage(),
        '/kyc_form': (context) => const KycFormPage(),
        '/data_seeder': (context) => const DataSeederPage(),
        '/settings': (context) => const SettingsPage(),
        '/my_reports': (context) => const MyReportsPage(),
        '/saved_reports': (context) => const SavedReportsPage(), // Net)w route for saved reports
        '/auth': (context) =>
            const AuthPage(), // <--- NEW: Route for the AuthPage
      },
    );
  }
}
