import 'package:back2u/views/home/index.dart';
import 'package:back2u/views/onboarding/index.dart';
import 'package:back2u/views/report/index.dart';
import 'package:back2u/views/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // theme: ThemeData(
      //   brightness: Brightness.light,
      //   primarySwatch: Colors.blue,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //   useMaterial3: true,
      // ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Splash(),
      routes: {
        '/home': (context) => const Home(),
        '/settings': (context) => const Report(),
        '/onboarding': (context) => const Onboarding(),
        '/report': (context) => const Report(),
      },
    );
  }
}
