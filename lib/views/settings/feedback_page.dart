import 'package:flutter/material.dart';
import 'package:back2u/services/feedback_service.dart';
import 'package:back2u/l10n/app_localizations.dart';
import 'package:back2u/constants/app_theme.dart';
import 'package:back2u/components/app_text_field.dart';
import 'package:back2u/components/button.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/models/feedback_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedType = 'general';
  String _contactPreference = 'none';
  bool _isAnonymous = false;
  bool _isLoading = false;

  // To hold device and app info
  Map<String, dynamic> _deviceInfo = {};
  Map<String, dynamic> _appInfo = {};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfoPlugin = await PackageInfo.fromPlatform();

      _appInfo = {
        'appName': packageInfoPlugin.appName,
        'packageName': packageInfoPlugin.packageName,
        'version': packageInfoPlugin.version,
        'buildNumber': packageInfoPlugin.buildNumber,
      };

      // Platform-specific device info
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo = {
          'platform': 'android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = {
          'platform': 'ios',
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
        };
      } else {
        _deviceInfo = {'platform': 'other'};
      }
    } catch (e) {
      // Handle error getting device info
      print('Failed to get device info: $e');
      _deviceInfo = {'error': 'Failed to get device info'};
    }
  }

  void _submitFeedback() async {
    final loc = AppLocalizations.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final feedbackService = context.read<FeedbackService>();
        final authService = context.read<AuthKycService>();
        final user = authService.currentUser;

        final newFeedback = FeedbackModel(
          feedbackId: '', // Will be set by service
          userId: _isAnonymous ? 'anonymous' : user?.uid ?? 'unknown',
          username:
              _isAnonymous ? 'Anonymous' : authService.appUser?.username ?? 'Unknown',
          type: _selectedType,
          message: _messageController.text.trim(),
          createdAt: DateTime.now(),
          contactPreference: _contactPreference,
          isAnonymous: _isAnonymous,
          deviceInfo: _deviceInfo, // Add device info
          appInfo: _appInfo, // Add app info
        );

        await feedbackService.submitFeedback(newFeedback);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.success),
              backgroundColor: Colors.green,
            ),
          );
          _formKey.currentState?.reset();
          _messageController.clear();
          setState(() {
            _selectedType = 'general';
            _contactPreference = 'none';
            _isAnonymous = false;
          });
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          print('Error: ' + e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.error ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthKycService>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final feedbackTypes = {
      'general': loc.feedback,
      'bug': loc.error,
      'suggestion': loc.suggestion ?? 'Suggestion',
      'other': loc.other ?? 'Other',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.sendFeedback),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.feedbackComingSoon,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                loc.pleaseEnterValidData,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // Feedback type using ChoiceChips
              Text(loc.feedback, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: feedbackTypes.keys.map((String key) {
                  return ChoiceChip(
                    label: Text(feedbackTypes[key]!),
                    selected: _selectedType == key,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = key;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Feedback message
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: loc.sendFeedback,
                  hintText: loc.pleaseEnterValidData,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.invalidInput;
                  }
                  if (value.trim().length < 10) {
                    return loc.pleaseEnterValidData;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (authService.isAuthenticated)
                CheckboxListTile(
                  title: Text(loc.signInAnonymously),
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

              // Contact preference (if not anonymous)
              if (!_isAnonymous && authService.isAuthenticated)
                DropdownButtonFormField<String>(
                  value: _contactPreference,
                  decoration: InputDecoration(
                    labelText: loc.contactInformation,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.contact_mail_outlined),
                  ),
                  items: [
                    DropdownMenuItem(value: 'email', child: Text(loc.email)),
                    DropdownMenuItem(value: 'in_app', child: Text(loc.inAppMessage ?? 'In-app Message')),
                    DropdownMenuItem(value: 'none', child: Text(loc.doNotContactMe ?? 'Do not contact me')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _contactPreference = value ?? 'none';
                    });
                  },
                ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submitFeedback,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? loc.loading : loc.sendFeedback),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}