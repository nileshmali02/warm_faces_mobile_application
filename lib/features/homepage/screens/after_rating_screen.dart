import 'package:flutter/material.dart';

class AfterRatingScreen extends StatelessWidget {
  final VoidCallback onRatingCompleted;
  const AfterRatingScreen({super.key, required this.onRatingCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('After Rating Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: onRatingCompleted,
          child: const Text('Complete After Rating'),
        ),
      ),
    );
  }
}
