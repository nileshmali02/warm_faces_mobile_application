import 'package:flutter/material.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Our Service!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'By using our service, you agree to the following terms and conditions:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. Acceptance of Terms\n'
                'By accessing or using our service, you accept and agree to be bound by these terms.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '2. Modifications\n'
                'We reserve the right to modify these terms at any time. Please review them periodically.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '3. User Responsibilities\n'
                'Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '4. Limitation of Liability\n'
                'Our service is provided "as is" and we are not liable for any damages resulting from its use.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '5. Governing Law\n'
                'These terms are governed by the laws of [Your Jurisdiction].\n',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'If you have any questions about these terms, please contact us at [Your Contact Information].',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              Text(
                'Last updated: [Date]',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
