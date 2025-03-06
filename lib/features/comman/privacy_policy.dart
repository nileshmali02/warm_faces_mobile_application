import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'We are committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. Information We Collect\n'
                'We may collect personal information such as your name, email address, and phone number when you use our services.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '2. How We Use Your Information\n'
                'We use your information to improve our services, communicate with you, and fulfill your requests.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '3. Data Sharing\n'
                'We do not sell or rent your personal information to third parties. We may share your information with trusted partners to provide services on our behalf.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '4. Security of Your Information\n'
                'We take reasonable measures to protect your personal information from unauthorized access and disclosure.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '5. Your Rights\n'
                'You have the right to access, correct, or delete your personal information. Please contact us for assistance.\n',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'If you have any questions about this privacy policy, please contact us at [Your Contact Information].',
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
