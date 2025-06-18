import 'dart:io';
import 'package:back2u/views/settings/privacy_policy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back2u/services/auth_kyc_service.dart'; // Ensure correct path
import 'package:back2u/views/home/index.dart'; // Navigate to Home after KYC

class KycFormPage extends StatefulWidget {
  const KycFormPage({super.key});

  @override
  State<KycFormPage> createState() => _KycFormPageState();
}

class _KycFormPageState extends State<KycFormPage> {
  bool _agreedToPolicy = false;
  final _formKey = GlobalKey<FormState>();
  final AuthKycService _authKycService = AuthKycService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  File? _profileImage;
  File? _idCardFrontImage;
  File? _idCardBackImage;

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File?) setImage) async {
    final XFile? pickedFile = await _authKycService.pickImage(source);
    if (pickedFile != null) {
      setState(() {
        setImage(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitKyc() async {
    if (_formKey.currentState!.validate()) {
      if (_profileImage == null || _idCardFrontImage == null || _idCardBackImage == null) {
        _showMessage('Please upload all required images.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage('User not authenticated. Please sign in again.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final String uid = user.uid;

        // Upload images to Firebase Storage
        final profileImageUrl = await _authKycService.uploadImage(
          _profileImage!, 'users/$uid/profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        final idCardFrontUrl = await _authKycService.uploadImage(
          _idCardFrontImage!, 'users/$uid/kyc/id_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        final idCardBackUrl = await _authKycService.uploadImage(
          _idCardBackImage!, 'users/$uid/kyc/id_back_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (profileImageUrl == null || idCardFrontUrl == null || idCardBackUrl == null) {
          _showMessage('Failed to upload one or more images. Please try again.');
          return;
        }

        // Update user profile in Firestore with KYC data
        await _authKycService.updateKycData(
          uid: uid,
          phone: _phoneController.text.trim(),
          whatsappNumber: _whatsappController.text.trim(),
          accountNameOnId: _accountNameController.text.trim(),
          profileImageUrl: profileImageUrl,
          idCardFrontUrl: idCardFrontUrl,
          idCardBackUrl: idCardBackUrl,
        );

        _showMessage('KYC submitted successfully!');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
      } catch (e) {
        _showMessage('Error submitting KYC: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Help us verify your identity for secure transactions.',
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g., +237 677123456',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // WhatsApp Number (Optional)
                    TextFormField(
                      controller: _whatsappController,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp Number (Optional)',
                        hintText: 'e.g., +237 677123456',
                        prefixIcon: const Icon(Icons.phone_callback),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
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

                    Text(
                      'Upload ID & Profile Photos',
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),

                    // Profile Photo
                    _buildImagePicker(
                      context,
                      label: 'Profile Photo',
                      imageFile: _profileImage,
                      onPick: (source) => _pickImage(source, (file) => _profileImage = file),
                    ),
                    const SizedBox(height: 16),

                    // ID Card Front
                    _buildImagePicker(
                      context,
                      label: 'ID Card Front',
                      imageFile: _idCardFrontImage,
                      onPick: (source) => _pickImage(source, (file) => _idCardFrontImage = file),
                    ),
                    const SizedBox(height: 16),

                    // ID Card Back
                    _buildImagePicker(
                      context,
                      label: 'ID Card Back',
                      imageFile: _idCardBackImage,
                      onPick: (source) => _pickImage(source, (file) => _idCardBackImage = file),
                    ),
                    // Privacy Policy Agreement
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
                      onPressed: _agreedToPolicy ? _submitKyc : null,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Submit for Verification'),
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

  Widget _buildImagePicker(BuildContext context, {
    required String label,
    required File? imageFile,
    required Function(ImageSource) onPick,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : Center(
                  child: Text(
                    'No image selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onPick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onPick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}