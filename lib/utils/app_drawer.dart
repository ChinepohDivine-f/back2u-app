import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore if AppUser uses Timestamp, or for data fetching
import 'package:back2u/services/auth_kyc_service.dart'; // Your AuthKycService
import 'package:back2u/models/user_model.dart'; // Your AppUser model
// import 'package:back2u/views/settings/feedback_page.dart'; // Import feedback page
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back2u/l10n/app_localizations.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Locale _currentLocale;
  final AuthKycService _authKycService = AuthKycService();
  User? _currentUser; // Internal Firebase User object
  AppUser? _appUser; // Internal custom user profile object
  bool _isLoading = true; // Internal loading state

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _currentLocale = languageCode == 'fr' ? const Locale('fr') : const Locale('en');
    });
  }

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(loc.signOut),
          ],
        ),
        content: Text(loc.deleteAccountConfirmationContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.signOut),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      setState(() { _isLoading = false; });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await _authKycService.signOut();
      if (mounted) {
        Navigator.pop(context);
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
    final loc = AppLocalizations.of(context);

    // Determine login status based on internal _currentUser
    final bool userLoggedIn = _currentUser != null && !_currentUser!.isAnonymous;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- Drawer Header Section ---
          // SizedBox(height: 10),
          _buildDrawerHeader(context, colorScheme, userLoggedIn, loc),

          // --- Common Menu Items ---
          ListTile(
            leading: Icon(Icons.home, color: colorScheme.onSurfaceVariant),
            title: Text(loc.home, style: Theme.of(context).textTheme.bodyLarge),
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
            if (_isLoading)
              ListTile(
                leading: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                ),
                title: Text('Loading your options...', style: Theme.of(context).textTheme.bodyLarge),
              )
            else ...[
              ListTile(
                leading: Icon(Icons.description_outlined, color: colorScheme.onSurfaceVariant),
                title: Text(loc.myReports, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/my_reports');
                },
              ),
              ListTile(
                leading: Icon(Icons.bookmark_outline, color: colorScheme.onSurfaceVariant),
                title: Text(loc.savedReports, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/saved_reports');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: colorScheme.onSurfaceVariant),
                title: Text(loc.settings, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_active_outlined, color: colorScheme.onSurfaceVariant),
                title: Text(loc.notifications, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/notifications');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text(loc.signOut, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
                onTap: () {
                  _signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.signOut)),
                  );
                },
              ),
            ],
          ] else ...[
            // --- Anonymous User Specific Menu Items ---
            const Divider(), // Separator
            // Settings for anonymous users (restricted)
            ListTile(
              leading: Icon(Icons.settings_outlined, color: colorScheme.onSurfaceVariant),
              title: Text(loc.settings, style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/settings'); // Should navigate to restricted settings
              },
            ),
            ListTile(
              leading: Icon(Icons.login, color: colorScheme.primary),
              title: Text(loc.signIn, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/auth');
              },
            ),
          ],
          const Divider(), // Separator before info

          // --- About/Info Section (Common to both) ---
          AboutListTile(
            icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
            applicationName: loc.appTitle,
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2025 Back2U. ${loc.all ?? 'All rights reserved.'}',
            aboutBoxChildren: [
              Text(loc.aboutApp, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Developed in Cameroon.', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          
          // --- Feedback Section ---
          // ListTile(
          //   leading: Icon(Icons.feedback_outlined, color: colorScheme.onSurfaceVariant),
          //   title: Text('Give Feedback', style: Theme.of(context).textTheme.bodyLarge),
          //   onTap: () {
          //     Navigator.pop(context); // Close drawer
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const FeedbackPage()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  // Helper method to build the appropriate drawer header
  Widget _buildDrawerHeader(BuildContext context, ColorScheme colorScheme, bool userLoggedIn, AppLocalizations loc) {
    if (userLoggedIn) {
      return UserAccountsDrawerHeader(
        accountName: Text(
          _appUser?.username ?? _currentUser?.displayName ?? loc.profileInformation, // Fallback name
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
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
        child: SafeArea(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, size: 48, color: colorScheme.onPrimary.withOpacity(0.9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.welcome + ', ' + loc.signInAnonymously + '!',
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
              loc.pleaseSignIn,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
            ),
          ],
        ),),
      );
    }
  }
}