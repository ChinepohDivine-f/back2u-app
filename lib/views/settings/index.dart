// lib/views/settings/settings_page.dart
import 'package:back2u/providers/theme_provider.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase User
import 'package:back2u/services/auth_kyc_service.dart'; // Your auth service
import 'package:back2u/models/user_model.dart'; // Your AppUser model
import 'package:back2u/views/auth/kyc_form_page.dart';
import 'package:provider/provider.dart'; // Your KYC form page
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:back2u/l10n/app_localizations.dart';
import 'package:back2u/main.dart';
import 'package:back2u/views/settings/profile/edit_profile_page.dart';
import 'package:back2u/views/settings/profile/phone_management_page.dart';
import 'package:back2u/views/settings/privacy_policy.dart';
import 'package:back2u/views/settings/terms_of_service.dart';
import 'package:back2u/views/settings/help_and_support.dart';
import 'package:back2u/views/settings/feedback_page.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  
  const SettingsPage({super.key, this.onLocaleChanged});

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
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool userLoggedIn = _currentUser != null && !_currentUser!.isAnonymous;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc?.settings ?? 'Settings'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.settings ?? 'Settings'),
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
            _buildSectionHeader(context, loc.accountSettings),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.profileInformation,
                        style: theme.textTheme.bodyLarge),
                    subtitle: Text(
                      userLoggedIn
                          ? (_appUser?.username ??
                              _currentUser?.displayName ??
                              loc.notSet)
                          : loc.signInToManageProfile,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  appUser: _appUser,
                                  onProfileUpdated: () => _loadUserProfile(_currentUser!.uid),
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                  if (userLoggedIn) ...[
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.phone_outlined,
                          color: colors.onSurfaceVariant),
                      title: Text(loc.phoneManagement,
                          style: theme.textTheme.bodyLarge),
                      subtitle: Text(
                        _appUser?.phone ?? loc.noPhoneNumberSet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant.withOpacity(0.7)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_appUser?.verified == true)
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.green,
                            ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios,
                              size: 16,
                              color: colors.onSurfaceVariant.withOpacity(0.7)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneManagementPage(
                              appUser: _appUser,
                              onPhoneUpdated: () => _loadUserProfile(_currentUser!.uid),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (userLoggedIn) ...[
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading:
                          Icon(Icons.delete_outline, color: colors.error),
                      title: Text(loc.deleteAccount,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: colors.error)),
                      onTap: () {
                        _showDeleteAccountDialog(context, loc, colors);
                      },
                    ),
                  ],
                ],
              ),
            ),

            // --- KYC Settings ---
            _buildSectionHeader(context, loc.kycSettings),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.verified_user_outlined,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.kycVerificationStatus,
                        style: theme.textTheme.bodyLarge),
                    subtitle: Text(
                      userLoggedIn
                          ? (_appUser?.verified == true
                              ? loc.verified
                              : loc.notVerified)
                          : loc.signInToViewKyc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: userLoggedIn &&
                                (_appUser?.verified == true)
                            ? Colors.green
                            : (userLoggedIn
                                ? Colors.red
                                : colors.onSurfaceVariant.withOpacity(0.7)),
                        fontWeight: userLoggedIn
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: userLoggedIn && (_appUser?.verified != true)
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
                            label: Text(loc.completeKyc),
                          )
                        : null,
                    onTap: userLoggedIn && (_appUser?.verified == true)
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(loc.yourProfileIsAlreadyVerified)),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),

            // --- System Settings ---
            _buildSectionHeader(context, loc.systemSettings),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications_none,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.notifications,
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
                              content: Text(value
                                  ? loc.notificationsEnabled
                                  : loc.notificationsDisabled)),
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
                            content: Text(_notificationsEnabled
                                ? loc.notificationsEnabled
                                : loc.notificationsDisabled)),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.language, color: colors.onSurfaceVariant),
                    title: Text(loc.language, style: theme.textTheme.bodyLarge),
                    trailing: DropdownButton<Locale>(
                      value: Localizations.localeOf(context),
                      items: AppLocalizations.supportedLocales.map((locale) {
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(
                            locale.languageCode == 'en' 
                              ? loc.english
                              : loc.french,
                          ),
                        );
                      }).toList(),
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          MyApp.of(context)?.changeLocale(newLocale);
                        }
                      },
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    trailing: SegmentedButton<ThemeMode>(
                      segments: <ButtonSegment<ThemeMode>>[
                        ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text(loc.light),
                            icon: const Icon(Icons.light_mode, size: 12,)),
                        ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text(loc.dark),
                            icon: const Icon(Icons.dark_mode, size: 12,)),
                        ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            label: Text(loc.system),
                            icon: const Icon(Icons.settings_brightness, size: 12,)),
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
                              content: Text('${loc.themeSetTo} ${_currentThemeMode.name}')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- Other Important Stuff ---
            _buildSectionHeader(context, loc.about),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.policy_outlined,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.privacyPolicy,
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(loc.privacyPolicy)),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.description_outlined,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.termsOfService,
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(loc.termsOfService)),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TermsOfServicePage()));
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  AboutListTile(
                    icon: Icon(Icons.info_outline,
                        color: colors.onSurfaceVariant),
                    applicationName: loc.appTitle,
                    applicationVersion:
                        '1.0.0', // Update your app version here
                    applicationLegalese:
                        '© 2025 Back2U. ${loc.all ?? 'All rights reserved.'}',
                    aboutBoxChildren: [
                      Text(
                          loc.aboutApp ?? 'Back2U helps you find your lost documents and items, and report found ones.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Developed in Cameroon.',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                    child:
                        Text(loc.about, style: theme.textTheme.bodyLarge),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.support_agent,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.helpAndSupport,
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(loc.helpAndSupport)),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HelpAndSupportPage()));
                    },
                  ),
                ],
              ),
            ),

            // --- Feedback Section ---
            _buildSectionHeader(context, loc.feedback),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.feedback,
                        color: colors.onSurfaceVariant),
                    title: Text(loc.sendFeedback,
                        style: theme.textTheme.bodyLarge),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.onSurfaceVariant.withOpacity(0.7)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(loc.sendFeedback)),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
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

  Future<void> _showDeleteAccountDialog(BuildContext context, AppLocalizations loc, ColorScheme colors) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(loc.deleteAccountConfirmationTitle),
          content: Text(loc.deleteAccountConfirmationContent),
          actions: <Widget>[
            TextButton(
              child: Text(loc.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                await _deleteAccount(context);
              },
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // TODO: Implement account deletion logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account deletion not implemented.')),
    );
  }
}
