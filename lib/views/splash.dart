
import 'dart:async';

import 'package:back2u/views/home/index.dart';
import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      // Navigator.pushReplacementNamed(context, '/home/index');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      );
    });
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/images/logo.png',
              //   width: 200,
              // ),
               Icon(
                Icons.backpack,
                size: 100,
                color: Colors.blue,
              ),
               SizedBox(height: 20),
               Text(
                'Back to you',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}