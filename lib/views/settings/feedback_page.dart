import 'package:flutter/material.dart';
import 'package:back2u/services/feedback_service.dart';
import 'package:back2u/l10n/app_localizations.dart';
import 'package:back2u/constants/app_theme.dart';
import 'package:back2u/components/app_text_field.dart';
import 'package:back2u/components/button.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackService _feedbackService = FeedbackService();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedType = 'general_feedback';
  String _selectedCategory = 'other';
  String _selectedPriority = 'medium';
  String _title = '';
  String _description = '';
  int _rating = 0;
  bool _isAnonymous = false;
  String _contactPreference = 'email';
  bool _isSubmitting = false;
  String _deviceInfo = '';
  String _appVersion = '';

  final List<Map<String, String>> _feedbackTypes = [
    {'value': 'general_feedback', 'label': 'General Feedback'},
    {'value': 'bug_report', 'label': 'Bug Report'},
    {'value': 'feature_request', 'label': 'Feature Request'},
    {'value': 'app_review', 'label': 'App Review'},
  ];

  final List<Map<String, String>> _categories = [
    {'value': 'ui_ux', 'label': 'UI/UX'},
    {'value': 'performance', 'label': 'Performance'},
    {'value': 'functionality', 'label': 'Functionality'},
    {'value': 'content', 'label': 'Content'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _priorities = [
    {'value': 'low', 'label': 'Low'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'high', 'label': 'High'},
    {'value': 'critical', 'label': 'Critical'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      
      String deviceInfoText = '';
      
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceInfoText = 'Android ${androidInfo.version.release} (${androidInfo.model})';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceInfoText = 'iOS ${iosInfo.systemVersion} (${iosInfo.model})';
      }
      
      setState(() {
        _deviceInfo = deviceInfoText;
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      print('Error loading device info: $e');
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _feedbackService.submitFeedback(
        type: _selectedType,
        category: _selectedCategory,
        title: _title,
        description: _description,
        rating: _rating,
        priority: _selectedPriority,
        deviceInfo: _deviceInfo,
        appVersion: _appVersion,
        isAnonymous: _isAnonymous,
        contactPreference: _contactPreference,
        metadata: {
          'submittedAt': DateTime.now().toIso8601String(),
          'platform': Theme.of(context).platform.toString(),
        },
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit feedback. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
      ),
      body: Center(
        child: SingleChildScrollView(
          // Removed the Container (card) and replaced with Padding
          child: Padding( 
            padding: const EdgeInsets.all(16.0), // Consistent padding
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Feedback Type
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Feedback Type',
                      border: OutlineInputBorder(), // Added border for consistent style
                    ),
                    items: _feedbackTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category['value'],
                        child: Text(category['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Title
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.trim().length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _description = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Rating (for app review type)
                  if (_selectedType == 'app_review') ...[
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Priority
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: _priorities.map((priority) {
                      return DropdownMenuItem(
                        value: priority['value'],
                        child: Text(priority['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Anonymous option
                  CheckboxListTile(
                    title: const Text('Submit anonymously'),
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (!_isAnonymous) ...[
                    DropdownButtonFormField<String>(
                      value: _contactPreference,
                      decoration: const InputDecoration(
                        labelText: 'Contact Preference',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'email', child: Text('Email')),
                        DropdownMenuItem(value: 'in_app', child: Text('In-App')),
                        DropdownMenuItem(value: 'none', child: Text('No Contact')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _contactPreference = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Feedback'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}