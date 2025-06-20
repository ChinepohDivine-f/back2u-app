import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:back2u/views/home/index.dart';

class PhoneVerificationPage extends StatefulWidget {
  final bool isFromReportDetails;
  
  const PhoneVerificationPage({
    Key? key,
    this.isFromReportDetails = false,
  }) : super(key: key);

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  /// Check if phone number is valid
  bool _isValidPhoneNumber(String phone) {
    // Basic phone number validation (adjust based on your requirements)
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Format phone number with Cameroon country code
  String _formatPhoneNumber(String number) {
    if (number.startsWith('+')) return number;
    return '+237${number.startsWith('0') ? number.substring(1) : number}';
  }

  /// Update verification status and navigate on success
  void _updateVerificationStatus(bool isVerified) {
    if (!isVerified || !mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }
  
  /// Show error message to user
  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _verificationId = '';
      _codeSent = false;
    });

    final testNumber = '+237678439032';
    if (_formatPhoneNumber(_phoneController.text) == testNumber) {
      // Test mode: instantly "send" OTP
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _verificationId = 'test_verification_id';
        _codeSent = true;
        _isLoading = false;
        _phoneNumber = testNumber;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test OTP sent! Use code 123456.')),
      );
      return;
    }

    try {
      final phoneNumber = _formatPhoneNumber(_phoneController.text);
      _phoneNumber = phoneNumber; // Store for later use
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              final authService = Provider.of<AuthKycService>(context, listen: false);
              final uid = userCredential.user!.uid;
              await authService.updateKycData(
                uid: uid,
                phone: phoneNumber,
                whatsappNumber: phoneNumber,
                accountNameOnId: '',
              );
              await authService.refreshUserProfile();
              _updateVerificationStatus(true);
            }
          } catch (e) {
            _showError('Failed to complete verification: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError('Verification failed: \\${e.message}');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError('Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    if (_otpController.text.isEmpty) {
      _showError('Please enter the verification code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final testNumber = '+237678439032';
    if (_formatPhoneNumber(_phoneController.text) == testNumber && _otpController.text.trim() == '123456') {
      // Test mode: consider verified
      final authService = Provider.of<AuthKycService>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'test_uid';
      await authService.updateKycData(
        uid: uid,
        phone: testNumber,
        whatsappNumber: testNumber,
        accountNameOnId: '',
      );
      await authService.refreshUserProfile();
      setState(() => _isLoading = false);
      _updateVerificationStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test phone verified successfully!')),
      );
      return;
    }

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final phoneNumber = _formatPhoneNumber(_phoneController.text);
        final authService = Provider.of<AuthKycService>(context, listen: false);
        final uid = userCredential.user!.uid;
        await authService.updateKycData(
          uid: uid,
          phone: phoneNumber,
          whatsappNumber: phoneNumber,
          accountNameOnId: '',
        );
        await authService.refreshUserProfile();
        _updateVerificationStatus(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_codeSent) ...[  // Phone number input
                const Text(
                  'Enter your phone number to verify your identity',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '677123456',
                    prefixText: '+237 ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Basic phone number validation for Cameroon
                    if (!RegExp(r'^[2367]\d{8}$').hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                      return 'Please enter a valid Cameroon phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhoneNumber,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send Verification Code'),
                ),
              ] else ...[  // OTP input
                Text(
                  'Enter the verification code sent to $_phoneNumber',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    hintText: '123456',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.length < 6) {
                      return 'Verification code must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Verify Code'),
                ),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _codeSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Change Phone Number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}