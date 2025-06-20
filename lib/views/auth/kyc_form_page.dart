import 'dart:io';
import 'package:back2u/views/settings/privacy_policy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/views/home/index.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class KycFormPage extends StatefulWidget {
  const KycFormPage({super.key});

  @override
  State<KycFormPage> createState() => _KycFormPageState();
}

class _KycFormPageState extends State<KycFormPage> {
  bool _agreedToPolicy = false;
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String _phoneNumber = '';
  String _verificationId = '';
  bool _isVerifying = false;
  bool _codeSent = false;
  bool _isLoading = false;
  final AuthKycService _authKycService = AuthKycService();

  @override
  void dispose() {
    _accountNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Format phone number with Cameroon country code
  String _formatPhoneNumber(String number) {
    if (number.startsWith('+')) return number;
    return '+237${number.startsWith('0') ? number.substring(1) : number}';
  }

  /// Check if phone number is a valid Cameroon number
  bool _isValidCameroonNumber(String number) {
    // Remove any non-digit characters first
    final digits = number.replaceAll(RegExp(r'\D'), '');
    // Check if it's a valid Cameroonian mobile number (9 digits starting with 2, 3, 6, or 7)
    return RegExp(r'^[2367]\d{8}$').hasMatch(digits);
  }



  /// Show a message to the user
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  /// Build a phone number input field with verification button


  /// Build a verification button with loading state


  /// Submit KYC data
  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    _authKycService.verifyPhoneAndCompleteKyc(
      phoneNumber: _phoneNumber,
      accountNameOnId: _accountNameController.text.trim(),
      onCodeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
          _verificationId = verificationId;
        });
        _showMessage('OTP sent to $_phoneNumber');
      },
      onVerificationCompleted: (PhoneAuthCredential credential) async {
        _completeLogin(credential);
      },
      onVerificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Verification failed: ${e.message}', isError: true);
      },
      onCodeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
      },
    );
  }

  void _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showMessage('Please enter the OTP', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      await _completeLogin(credential);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Invalid OTP or verification failed', isError: true);
    }
  }

  Future<void> _completeLogin(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      // The onVerificationCompleted callback in the service will handle the rest
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }
    } catch (e) {
      _showMessage('Failed to sign in: ${e.toString()}', isError: true);
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile (KYC)'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Uploading and saving data...', style: textTheme.bodyLarge),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Complete your KYC',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'CM',
                      onChanged: (phone) {
                        _phoneNumber = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_codeSent)
                      TextFormField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'OTP Code',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(height: 16),

                    // Account Name as on ID
                    TextFormField(
                      controller: _accountNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name (as on ID Card)',
                        hintText: 'e.g., John Doe',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name as on ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToPolicy,
                          onChanged: (value) {
                            setState(() {
                              _agreedToPolicy = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I have read and agree to the '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PrivacyPolicyPage()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _agreedToPolicy ? (_codeSent ? _verifyOtp : _sendOtp) : null,
                      icon: const Icon(Icons.verified_user),
                      label: Text(_codeSent ? 'Verify OTP' : 'Send OTP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}