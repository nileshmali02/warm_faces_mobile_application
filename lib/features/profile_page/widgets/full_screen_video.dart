import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final String videoUrl;
  const FullScreenVideo({super.key, required this.videoUrl});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Start with video playing
        _isPlaying = true;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                title: Text(_isPlaying ? 'Pause Video' : 'Play Video'),
                onTap: () {
                  setState(() {
                    _isPlaying ? _controller.pause() : _controller.play();
                    _isPlaying = !_isPlaying;
                  });
                  Navigator.pop(context); // Close options
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Video'),
                onTap: () {
                  // Implement delete functionality here
                  Navigator.pop(context); // Close options
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _isPlaying ? _controller.pause() : _controller.play();
                    _isPlaying = !_isPlaying;
                  });
                },
                child: SizedBox(
                  // Set the height and width as desired
                  width: double.infinity, // Full width
                  height: 400, // Set your desired height
                  child: VideoPlayer(_controller),
                ),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}
