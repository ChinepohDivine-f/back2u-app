import "package:flutter/material.dart";

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Onboarding'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Onboarding Page',
            style: TextStyle(fontSize: 16),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            print("dont touch me.. or create a report");
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}