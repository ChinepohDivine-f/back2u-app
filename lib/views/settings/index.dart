// lib/views/settings/settings_page.dart
import 'package:back2u/providers/theme_provider.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase User
import 'package:back2u/services/auth_kyc_service.dart'; // Your auth service
import 'package:back2u/models/user_model.dart'; // Your AppUser model
import 'package:back2u/views/auth/kyc_form_page.dart';
import 'package:provider/provider.dart'; // Your KYC form page

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthKycService _authKycService = AuthKycService();
  User? _currentUser;
  AppUser? _appUser;
  bool _isLoading = true;

  // System settings (example values, these would usually be persisted)
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English'; // Example default language
  ThemeMode _currentThemeMode = ThemeMode.system; // Example default theme

  @override
  void initState() {
    super.initState();
    _authKycService.authStateChanges.listen((user) async {
      if (!mounted) return; // Ensure widget is still in tree
      setState(() {
        _currentUser = user;
        _isLoading = true;
      });
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _appUser = null;
        setState(() {
          _isLoading = false;
        });
      }
    });
    _loadLocalSettings(); // Load persisted settings if any
  }

  Future<void> _loadUserProfile(String uid) async {
    _appUser = await _authKycService.getUserProfile(uid);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  // Dummy function to load local settings (e.g., from SharedPreferences)
  void _loadLocalSettings() {
    // In a real app, you'd load from SharedPreferences or similar
    // _notificationsEnabled = await SharedPreferences.getBool('notifications') ?? true;
    // _selectedLanguage = await SharedPreferences.getString('language') ?? 'English';
    // String? themeString = await SharedPreferences.getString('theme');
    // _currentThemeMode = _parseThemeMode(themeString);
    if (mounted) {
      setState(() {
        // Just setting initial values for this example
      });
    }
  }

  // Dummy function to save local settings
  void _saveLocalSettings() {
    // In a real app, you'd save to SharedPreferences
    // SharedPreferences.setBool('notifications', _notificationsEnabled);
    // SharedPreferences.setString('language', _selectedLanguage);
    // SharedPreferences.setString('theme', _currentThemeMode.toString());
  }

  // Helper to parse theme string (if needed)
  ThemeMode _parseThemeMode(String? themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    final bool userLoggedIn =
        _currentUser != null && !_currentUser!.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- User Account Settings ---
            _buildSectionHeader(context, 'Account Settings'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline,
                        color: colors.onSurfaceVariant),
                    title: Text('Profile Information',
                        style: theme.textTheme.bodyLarge),
                    subtitle: Text(
                      userLoggedIn
                          ? (_appUser?.username ??
                              _currentUser?.displayName ??
                              'Not set')
                          : 'Sign in to manage profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withOpacity(0.7)),
                    ),
                    trailing: userLoggedIn
                        ? Icon(Icons.arrow_forward_ios,
                            size: 16,
                            color: colors.onSurfaceVariant.withOpacity(0.7))
                        : null,
                    onTap: userLoggedIn
                        ? () {
                            // Navigate to Edit Profile Page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Navigate to Edit Profile Page')),
                            );
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                          }
                        : null,
                  ),
                  // const Divider(indent: 16, endIndent: 16),
                  // ListTile(
                  //   leading: Icon(Icons.lock_outline,
                  //       color: colors.onSurfaceVariant),
                  //   title: Text('Change Password',
                  //       style: theme.textTheme.bodyLarge),
                  //   subtitle: Text(
                  //     userLoggedIn
                  //         ? 'Update your account password'
                  //         : 'Sign in to change password',
                  //     style: theme.textTheme.bodyMedium?.copyWith(
                  //         color: colors.onSurfaceVariant.withOpacity(0.7)),
                  //   ),
                  //   trailing: userLoggedIn
                  //       ? Icon(Icons.arrow_forward_ios,
                  //           size: 16,
                  //           color: colors.onSurfaceVariant.withOpacity(0.7))
                  //       : null,
                  //   onTap: userLoggedIn
                  //       ? () {
                  //           // Navigate to Change Password Page
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //                 content: Text(
                  //                     'Navigate to Change Password Page')),
                  //           );
                  //           // Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));
                  //         }
                  //       : null,
                  // ),
                  // // Add more account settings here, e.g., Delete Account
                  if (userLoggedIn) ...[
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading:
                          Icon(Icons.delete_outline, color: colors.error),
                      title: Text('Delete Account',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: colors.error)),
                      onTap: () {
                        _showDeleteAccountDialog(context);
                      },
                    ),
                  ],
                ],
              ),
            ),

            // --- KYC Settings ---
            _buildSectionHeader(context, 'KYC Settings'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.verified_user_outlined,
                        color: colors.onSurfaceVariant),
                    title: Text('KYC Verification Status',
                        style: theme.textTheme.bodyLarge),
                    subtitle: Text(
                      userLoggedIn
                          ? (_appUser?.kycCompleted == true
                              ? 'Verified'
                              : 'Not Verified')
                          : 'Sign in to view KYC status',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: userLoggedIn &&
                                (_appUser?.kycCompleted == true)
                            ? Colors.green
                            : (userLoggedIn
                                ? Colors.red
                                : colors.onSurfaceVariant.withOpacity(0.7)),
                        fontWeight: userLoggedIn
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: userLoggedIn && (_appUser?.kycCompleted != true)
                        ? FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const KycFormPage()),
                              ).then((_) => _loadUserProfile(_currentUser!
                                  .uid)); // Reload user data after KYC
                            },
                            icon: const Icon(Icons.how_to_reg),
                            label: const Text('Complete KYC'),
                          )
                        : null,
                    onTap: userLoggedIn && (_appUser?.kycCompleted == true)
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Your profile is already verified.')),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),

            // --- System Settings ---
            _buildSectionHeader(context, 'System Settings'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications_none,
                        color: colors.onSurfaceVariant),
                    title: Text('Notifications',
                        style: theme.textTheme.bodyLarge),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                          _saveLocalSettings();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Notifications ${value ? 'enabled' : 'disabled'}')),
                        );
                      },
                      activeColor: colors.primary,
                    ),
                    onTap: () {
                      setState(() {
                        _notificationsEnabled = !_notificationsEnabled;
                        _saveLocalSettings();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Notifications ${_notificationsEnabled ? 'enabled' : 'disabled'}')),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading:
                        Icon(Icons.language, color: colors.onSurfaceVariant),
                    title: Text('Language', style: theme.textTheme.bodyLarge),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLanguage = newValue;
                            _saveLocalSettings();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Language set to $newValue')),
                          );
                        }
                      },
                      items: <String>['English', 'Français']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:
                              Text(value, style: theme.textTheme.bodyLarge),
                        );
                      }).toList(),
                    ),
                    onTap: () {
                      // Tapping the ListTile opens the dropdown
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.brightness_medium,
                        color: colors.onSurfaceVariant),
                    // title: Text('Theme', style: theme.textTheme.bodyLarge),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const <ButtonSegment<ThemeMode>>[
                        ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode)),
                        ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode)),
                        ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.settings_brightness)),
                      ],
                      selected: <ThemeMode>{_currentThemeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        setState(() {
                          _currentThemeMode = newSelection.first;
                          _saveLocalSettings();
                          // In a real app, you'd update your MaterialApp's themeMode
                          Provider.of<ThemeProvider>(context, listen: false).setThemeMode(_currentThemeMode);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Theme set to ${_currentThemeMode.name}')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- Other Important Stuff ---
            _buildSectionHeader(context, 'About Back2U'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.policy_outlined,
                        color: colors.onSurfaceVariant),
                    title: Text('Privacy Policy',
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Navigate to Privacy Policy')),
                      );
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.description_outlined,
                        color: colors.onSurfaceVariant),
                    title: Text('Terms of Service',
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Navigate to Terms of Service')),
                      );
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => TermsOfServicePage()));
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  AboutListTile(
                    icon: Icon(Icons.info_outline,
                        color: colors.onSurfaceVariant),
                    applicationName: 'Back2U',
                    applicationVersion:
                        '1.0.0', // Update your app version here
                    applicationLegalese:
                        '© 2025 Back2U. All rights reserved.',
                    aboutBoxChildren: [
                      Text(
                          'Back2U helps you find your lost documents and items, and report found ones.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Developed in Cameroon.',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                    child:
                        Text('About App', style: theme.textTheme.bodyLarge),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.support_agent,
                        color: colors.onSurfaceVariant),
                    title: Text('Help & Support',
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Navigate to Help & Support')),
                      );
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => HelpAndSupportPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Attempting to delete account...')),
                );
                // TODO: Implement actual account deletion logic
                // This usually involves:
                // 1. Re-authenticating the user for security.
                // 2. Deleting user data from Firestore.
                // 3. Deleting the Firebase Auth user.
                try {
                  // Example: await _authKycService.deleteAccount();
                  // Navigator.pushReplacementNamed(context, '/login'); // Redirect to login
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Account deletion is not yet implemented.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
