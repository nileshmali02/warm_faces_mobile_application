import 'package:flutter/material.dart';

class BeforeRatingScreen extends StatelessWidget {
  final VoidCallback onRatingSubmitted;
  const BeforeRatingScreen({super.key, required this.onRatingSubmitted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Before Rating Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: onRatingSubmitted,
          child: const Text('Submit Rating'),
        ),
      ),
    );
  }
}
