import 'package:back2u/views/settings/kyc_update_page.dart';
import 'package:flutter/material.dart';
import 'package:back2u/models/user_model.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/views/auth/phone_verification_page.dart';

class PhoneManagementPage extends StatefulWidget {
  final AppUser? appUser;
  final VoidCallback onPhoneUpdated;

  const PhoneManagementPage({
    super.key,
    required this.appUser,
    required this.onPhoneUpdated,
  });

  @override
  State<PhoneManagementPage> createState() => _PhoneManagementPageState();
}

class _PhoneManagementPageState extends State<PhoneManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.appUser?.phone ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updatePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newPhone = _phoneController.text.trim();
      
      // Navigate to phone verification
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycUpdatePage(
            // phoneNumber: newPhone,
            // isUpdateMode: true,
          ),
        ),
      );

      if (result == true) {
        // Phone verification successful
        if (mounted) {
          widget.onPhoneUpdated();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update phone number: $e'),
            backgroundColor: Colors.red,
          ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Management'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Phone Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.appUser?.verified == true 
                    ? Colors.green.withOpacity(0.3)
                    : colors.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.appUser?.verified == true 
                          ? Icons.verified
                          : Icons.phone_outlined,
                        color: widget.appUser?.verified == true 
                          ? Colors.green
                          : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Phone Number',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.appUser?.phone ?? 'No phone number set',
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (widget.appUser?.verified == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Update Phone Section
            Text(
              'Update Phone Number',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your new phone number. You\'ll receive a verification code to confirm the change.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // _buildTextField(
            //   controller: _phoneController,
            //   label: 'New Phone Number',
            //   hint: '+237 6XX XXX XXX',
            //   icon: Icons.phone_outlined,
            //   enabled: false,
            //   keyboardType: TextInputType.phone,
            //   validator: (value) {
            //     if (value == null || value.trim().isEmpty) {
            //       return 'Phone number is required';
            //     }
            //     // Basic phone validation for Cameroon
            //     final phoneRegex = RegExp(r'^\+237\s?[6-9]\d{8}$');
            //     if (!phoneRegex.hasMatch(value.trim())) {
            //       return 'Please enter a valid Cameroonian phone number';
            //     }
            //     return null;
            //   },
            // ),
            // const SizedBox(height: 24),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Update Phone Number',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Your phone number is used for account verification\n'
                    '• You\'ll receive an SMS with a verification code\n'
                    '• The verification process is required for security\n'
                    '• Your old phone number will be replaced',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        // enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
} 