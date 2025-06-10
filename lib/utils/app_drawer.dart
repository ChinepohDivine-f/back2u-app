import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore if AppUser uses Timestamp, or for data fetching
import 'package:back2u/services/auth_kyc_service.dart'; // Your AuthKycService
import 'package:back2u/models/user_model.dart'; // Your AppUser model

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthKycService _authKycService = AuthKycService();
  User? _currentUser; // Internal Firebase User object
  AppUser? _appUser; // Internal custom user profile object
  bool _isLoading = true; // Internal loading state

  @override
  void initState() {
    super.initState();
    // Listen to Firebase authentication state changes directly
    _authKycService.authStateChanges.listen((user) async {
      // Use a mounted check to prevent calling setState if the widget is disposed
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _isLoading = true; // Set loading true while fetching user profile
      });
      if (user != null) {
        // If user is logged in, fetch their custom AppUser profile
        await _checkAndLoadUserProfile(user.uid);
      } else {
        _appUser = null; // Clear custom user profile if logged out
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Fetches the custom AppUser profile from Firestore
  Future<void> _checkAndLoadUserProfile(String uid) async {
    _appUser = await _authKycService.getUserProfile(uid);
    // Use a mounted check again before setState
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  // Handles user logout directly from the drawer
  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authKycService.signOut();
      // After logout, navigate to the login page
      if (mounted) {
        // Pop the drawer first
        Navigator.pop(context);
        // Then navigate, replacing the current route
        Navigator.pushReplacementNamed(context, '/splash');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Determine login status based on internal _currentUser
    final bool userLoggedIn = _currentUser != null && !_currentUser!.isAnonymous;

    // Display loading indicator if data is still being fetched
    if (_isLoading) {
      return Drawer(
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- Drawer Header Section ---
          _buildDrawerHeader(context, colorScheme, userLoggedIn),

          // --- Common Menu Items ---
          ListTile(
            leading: Icon(Icons.home, color: colorScheme.onSurfaceVariant),
            title: Text('Home', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home page
            },
          ),
          //Todo: update the data on the db for categories and locations
          //  ListTile(
          //     leading: Icon(Icons.data_array, color: colorScheme.onSurfaceVariant),
          //     title: Text('Set db data', style: Theme.of(context).textTheme.bodyLarge),
          //     onTap: () {
          //       Navigator.pop(context);
          //       Navigator.pushReplacementNamed(context, '/data_seeder'); // Navigate to Data Seeder page
          //     },
          //   ),
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
                _signOut(); // Call the internal logout function
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging out...')),
                );
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
                Navigator.pushReplacementNamed(context, '/auth'); // Navigate to Login/Sign Up page
              },
            ),
          ],
          const Divider(), // Separator before info

          // --- About/Info Section (Common to both) ---
          AboutListTile(
            icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
            applicationName: 'Back2U',
            applicationVersion: '1.0.0',
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
  Widget _buildDrawerHeader(BuildContext context, ColorScheme colorScheme, bool userLoggedIn) {
    if (userLoggedIn) {
      return UserAccountsDrawerHeader(
        accountName: Text(
          _appUser?.username ?? _currentUser?.displayName ?? 'User Name', // Fallback name
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        accountEmail: Text(
          _appUser?.email ?? _currentUser?.email ?? 'user@example.com', // Fallback email
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundImage: _currentUser?.photoURL != null && _currentUser!.photoURL!.isNotEmpty
              ? NetworkImage(_currentUser!.photoURL!)
              : null,
          child: _currentUser?.photoURL == null || _currentUser!.photoURL!.isEmpty
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
          mainAxisAlignment: MainAxisAlignment.center,
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