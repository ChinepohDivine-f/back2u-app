import 'package:flutter/material.dart';
import 'package:back2u/l10n/app_localizations.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        // title: Text(loc?.termsOfService ?? 'Terms of Service'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: January 2025',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using the Back2U application, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            
            _buildSection(
              context,
              '2. Description of Service',
              'Back2U is a lost and found platform that allows users to report lost items and documents, and to claim found items. The service facilitates the connection between individuals who have lost items and those who have found them.',
            ),
            
            _buildSection(
              context,
              '3. User Responsibilities',
              '• Provide accurate and truthful information when reporting lost or found items\n• Respect the privacy and rights of other users\n• Do not use the service for fraudulent or malicious purposes\n• Maintain the confidentiality of your account credentials',
            ),
            
            _buildSection(
              context,
              '4. Privacy and Data Protection',
              'We are committed to protecting your privacy. Your personal information will be handled in accordance with our Privacy Policy. We collect and process data necessary for the provision of our services.',
            ),
            
            _buildSection(
              context,
              '5. Prohibited Activities',
              'Users are prohibited from:\n• Submitting false or misleading information\n• Harassing or threatening other users\n• Using the service for commercial purposes without authorization\n• Attempting to gain unauthorized access to the system',
            ),
            
            _buildSection(
              context,
              '6. Intellectual Property',
              'The Back2U application and its content are protected by intellectual property laws. Users retain ownership of their submitted content but grant us a license to use it for service provision.',
            ),
            
            _buildSection(
              context,
              '7. Limitation of Liability',
              'Back2U is provided "as is" without warranties. We are not liable for any damages arising from the use of our service, including but not limited to lost items, miscommunications, or service interruptions.',
            ),
            
            _buildSection(
              context,
              '8. Service Modifications',
              'We reserve the right to modify or discontinue the service at any time. We will provide reasonable notice of significant changes when possible.',
            ),
            
            _buildSection(
              context,
              '9. Termination',
              'We may terminate or suspend your account at any time for violations of these terms. You may also terminate your account at any time.',
            ),
            
            _buildSection(
              context,
              '10. Governing Law',
              'These terms are governed by the laws of Cameroon. Any disputes will be resolved in the courts of Cameroon.',
            ),
            
            _buildSection(
              context,
              '11. Contact Information',
              'For questions about these terms, please contact us at:\nEmail: support@back2u.com\nPhone: +237 XXX XXX XXX',
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'By using Back2U, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 