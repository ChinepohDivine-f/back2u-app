import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Back2U',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: [Date]',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              'IMPORTANT: This is a template privacy policy. You must review and customize it to fit your app\'s specific data practices and consult with a legal professional to ensure compliance with all applicable laws and regulations.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
              'Welcome to Back2U. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us at [Contact Email].'
            ),
            _buildSectionTitle('2. Information We Collect'),
            _buildSectionContent(
              'We collect personal information that you voluntarily provide to us when you register on the app, express an interest in obtaining information about us or our products and services, when you participate in activities on the app or otherwise when you contact us.\n\n'
              'The personal information that we collect depends on the context of your interactions with us and the app, the choices you make and the products and features you use. The personal information we collect may include the following:\n\n'
              '- Full Name\n'
              '- Phone Number\n'
              '- WhatsApp Number (Optional)\n'
              '- Profile Photo\n'
              '- National ID Card (Front and Back)\n'
            ),
            _buildSectionTitle('3. How We Use Your Information'),
            _buildSectionContent(
              'We use personal information collected via our app for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations. We indicate the specific processing grounds we rely on next to each purpose listed below.\n\n'
              'We use the information we collect or receive:\n\n'
              '- To facilitate account creation and logon process.\n'
              '- To verify your identity (Know Your Customer - KYC).\n'
              '- To send administrative information to you.\n'
              '- To protect our Services.\n'
              '- To enforce our terms, conditions and policies for business purposes, to comply with legal and regulatory requirements or in connection with our contract.\n'
            ),
             _buildSectionTitle('4. Will Your Information Be Shared With Anyone?'),
            _buildSectionContent(
              'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.'
            ),
             _buildSectionTitle('5. How We Keep Your Information Safe'),
            _buildSectionContent(
              'We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure, so we cannot promise or guarantee that hackers, cybercriminals, or other unauthorized third parties will not be able to defeat our security, and improperly collect, access, steal, or modify your information.'
            ),
            _buildSectionTitle('6. Your Privacy Rights'),
            _buildSectionContent(
              'In some regions, you have certain rights under applicable data protection laws. These may include the right (i) to request access and obtain a copy of your personal information, (ii) to request rectification or erasure; (iii) to restrict the processing of your personal information; and (iv) if applicable, to data portability.'
            ),
             _buildSectionTitle('7. Contact Us'),
            _buildSectionContent(
              'If you have questions or comments about this policy, you may email us at [Contact Email].'
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }
}
