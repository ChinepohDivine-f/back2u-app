import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  // Added a boolean to check if the user is logged in
  final bool userLoggedIn;
  final String? userName; // Optional: for logged-in user's name
  final String? userEmail; // Optional: for logged-in user's email
  final String? userProfileImageUrl; // Optional: for logged-in user's profile image

  const AppDrawer({
    super.key,
    this.userLoggedIn = false, // Default to false (anonymous)
    this.userName,
    this.userEmail,
    this.userProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove default ListView padding
        children: <Widget>[
          // --- Drawer Header Section ---
          _buildDrawerHeader(context, colorScheme),

          // --- Common Menu Items ---
          ListTile(
            leading: Icon(Icons.home, color: colorScheme.onSurfaceVariant),
            title: Text('Home', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home page
            },
          ),
          ListTile(
            leading: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
            title: Text('Search', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(context, '/search'); // Navigate to Search page
            },
          ),
           ListTile(
              leading: Icon(Icons.data_array, color: colorScheme.onSurfaceVariant),
              title: Text('Set db data', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/data_seeder'); // Navigate to Settings page
              },
            ),
          // --- Logged-in User Specific Menu Items ---
          if (userLoggedIn) ...[
            const Divider(), // Separator for logged-in specific options
            ListTile(
              leading: Icon(Icons.description_outlined, color: colorScheme.onSurfaceVariant),
              title: Text('My Reports', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/my_reports'); // New route for user's reports
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark_outline, color: colorScheme.onSurfaceVariant),
              title: Text('Saved Reports', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/saved_reports'); // New route for saved reports
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: colorScheme.onSurfaceVariant),
              title: Text('Settings', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/settings'); // Navigate to Settings page
              },
            ),
            
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Logout', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement actual logout logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging out...')),
                );
                // Example: Navigate to login/home page after logout
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ] else ...[
            // --- Anonymous User Specific Menu Items ---
            const Divider(), // Separator
            ListTile(
              leading: Icon(Icons.login, color: colorScheme.primary),
              title: Text('Login / Sign Up', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to Login/Sign Up page
              },
            ),
          ],
          const Divider(), // Separator before info

          // --- About/Info Section (Common to both) ---
          AboutListTile(
            icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
            applicationName: 'Back2U',
            applicationVersion: '1.0.0', // Update your app version here
            applicationLegalese: '© 2025 Back2U. All rights reserved.',
            aboutBoxChildren: [
              Text('Back2U helps you find your lost documents and items, and report found ones.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Developed in Cameroon.', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the appropriate drawer header
  Widget _buildDrawerHeader(BuildContext context, ColorScheme colorScheme) {
    if (userLoggedIn) {
      return UserAccountsDrawerHeader(
        accountName: Text(
          userName ?? 'User Name', // Fallback name
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        accountEmail: Text(
          userEmail ?? 'user@example.com', // Fallback email
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundImage: userProfileImageUrl != null && userProfileImageUrl!.isNotEmpty
              ? NetworkImage(userProfileImageUrl!)
              : null,
          child: userProfileImageUrl == null || userProfileImageUrl!.isEmpty
              ? Icon(Icons.person, size: 40, color: colorScheme.onSecondaryContainer)
              : null,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary,
        ),
      );
    } else {
      // Anonymous user header
      return DrawerHeader(
        decoration: BoxDecoration(
          color: colorScheme.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, size: 48, color: colorScheme.onPrimary.withOpacity(0.9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome, Anonymous!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in for personalized features.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      );
    }
  }
}