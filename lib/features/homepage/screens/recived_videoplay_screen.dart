import 'package:flutter/material.dart';

class RecivedVideoPlayScreen extends StatelessWidget {
  final VoidCallback onVideoPlayComplete;
  const RecivedVideoPlayScreen({super.key, required this.onVideoPlayComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Play Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: onVideoPlayComplete,
          child: const Text('Complete Video'),
        ),
      ),
    );
  }
}
