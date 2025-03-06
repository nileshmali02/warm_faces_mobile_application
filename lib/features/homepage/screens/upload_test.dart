import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  XFile? _videoFile; // Use XFile instead of String
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      _controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_controller!.value.isRecordingVideo) {
      return;
    }

    // Start video recording and get the file
    // _videoFile = await _controller!.startVideoRecording();
    setState(() {
      _isRecording = true;
    });

    // Stop recording after 4 seconds
    Timer(const Duration(seconds: 4), _stopRecording);
  }

  Future<void> _stopRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      return;
    }

    await _controller!.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });

    // Initialize video player controller to play the recorded video
    _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path))
      ..initialize().then((_) {
        setState(() {});
      });

    print("Video recorded at: ${_videoFile!.path}");
  }

  void _retakeVideo() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _startRecording();
  }

  void _uploadVideo() {
    // Implement your upload logic here
    print("Upload video: ${_videoFile!.path}");

    // Example upload code (pseudo-code):
    // final response = await uploadVideoToBackend(File(_videoFile!.path));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: _isRecording
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                const ElevatedButton(
                  onPressed: null,
                  child: Text('Recording...'),
                ),
              ],
            )
          : (_videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized)
              ? Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                    VideoProgressIndicator(_videoPlayerController!,
                        allowScrubbing: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _retakeVideo,
                          child: const Text('Retake'),
                        ),
                        ElevatedButton(
                          onPressed: _uploadVideo,
                          child: const Text('Upload'),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                    ElevatedButton(
                      onPressed: _isRecording ? null : _startRecording,
                      child: const Text('Record Video'),
                    ),
                  ],
                ),
    );
  }
}
