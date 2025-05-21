import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _saveToProfile = false; // State for the checkbox

  // Placeholder for initial numbers from backend (if any)
  String? _initialWhatsappNumber;
  String? _initialPhoneNumber;

  @override
  void initState() {
    super.initState();
    // Simulate fetching existing data from user profile (replace with actual backend call)
    _fetchInitialContactInfo();
  }

  void _fetchInitialContactInfo() async {
    // In a real app, you would make an API call here to get user's existing contact info.
    // For demonstration, we'll simulate a delay and set some dummy data.
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    setState(() {
      _initialWhatsappNumber = '671234567'; // Example existing WhatsApp
      _initialPhoneNumber = '698765432';   // Example existing Phone
      _whatsappController.text = _initialWhatsappNumber ?? '';
      _phoneController.text = _initialPhoneNumber ?? '';
    });
  }

  // Validator to ensure at least one number is provided
  String? _validateContactNumbers(String? whatsapp, String? phone) {
    if ((whatsapp == null || whatsapp.trim().isEmpty) && (phone == null || phone.trim().isEmpty)) {
      return 'Please provide at least one contact number (WhatsApp or Phone).';
    }
    return null;
  }

  void _submitContactInfo() {
    // Manually trigger the combined validation for both fields
    final String? whatsappText = _whatsappController.text.trim();
    final String? phoneText = _phoneController.text.trim();
    final String? combinedError = _validateContactNumbers(whatsappText, phoneText);

    if (_formKey.currentState!.validate() && combinedError == null) {
      // If validation passes and at least one number is provided
      // Here, you would send data to your backend
      print('WhatsApp Number: $whatsappText');
      print('Phone Number: $phoneText');
      print('Save to Profile: $_saveToProfile');

      // Simulate API call to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact information saved!')),
      );

      // In a real app, if _saveToProfile is true, you'd send these numbers
      // to your backend for the user's profile.
    } else {
      // Show combined error if exists, or individual field errors
      if (combinedError != null) {
        // A common way to show global errors is via SnackBar or a general error message at the top.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(combinedError), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Provide your contact details. At least one number is required.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),

              // WhatsApp Number Field
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(10), // Limit length for typical phone numbers
                ],
                decoration: InputDecoration(
                  labelText: 'WhatsApp Number (e.g., 67X XXX XXX)',
                  hintText: 'e.g., 671234567',
                  prefixIcon: const Icon(Icons.phone_callback),
                  border: const OutlineInputBorder(),
                  // The primary validation will happen on submit for this field due to combined rule.
                  // You can add individual validation if needed, e.g., format.
                ),
                validator: (value) {
                  // Only validate for format if provided
                  if (value != null && value.isNotEmpty && value.length < 9) {
                    return 'Number must be at least 9 digits.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(10), // Limit length
                ],
                decoration: InputDecoration(
                  labelText: 'Phone Number (e.g., 69X XXX XXX)',
                  hintText: 'e.g., 698765432',
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                  // The primary validation will happen on submit for this field due to combined rule.
                ),
                 validator: (value) {
                  // Only validate for format if provided
                  if (value != null && value.isNotEmpty && value.length < 9) {
                    return 'Number must be at least 9 digits.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Checkbox to save to profile
              Row(
                children: [
                  Checkbox(
                    value: _saveToProfile,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _saveToProfile = newValue ?? false;
                      });
                    },
                  ),
                  const Text('Save this information to my profile'),
                ],
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitContactInfo,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}