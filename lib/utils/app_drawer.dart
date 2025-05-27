import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anonymous',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.person), 
                    ),
                  ],
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(
                  context, '/home'); // Navigate to Home page
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('My Reports'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(
                  context, '/settings'); // Navigate to Settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Saved Reports'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(
                  context, '/settings'); // Navigate to Settings page
            },
          ),
          const AboutListTile(
            icon: Icon(Icons.info),
            applicationName: 'My Awesome App',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2025 My Company',
          ),
        ],
      ),
    );
  }
}
