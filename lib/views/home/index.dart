import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: true,
        ),
        body: const Column(children: [ Text('Home Page', style: TextStyle(fontSize: 16),)]),
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
