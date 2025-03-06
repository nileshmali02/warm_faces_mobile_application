// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:warm_faces/features/give/repositories/give_screen_repository.dart';
// import 'package:warm_faces/utils/constant/colors.dart';
// import 'package:warm_faces/utils/widgets/c_sizebox.dart';

// class GiveScreen extends StatefulWidget {
//   const GiveScreen({super.key});

//   @override
//   State<GiveScreen> createState() => _GiveScreenState();
// }

// class _GiveScreenState extends State<GiveScreen> {
//   late CameraController _controller;
//   late List<CameraDescription> cameras;
//   late CameraDescription camera;
//   late VideoPlayerController _videoPlayerController;
//   late String videoPath;

//   bool isRecording = false;
//   bool isVideoInitialized = false;
//   bool isCameraInitialized = false;
//   bool isVideoPlayed = false; // Flag to track if video has been played

//   Timer? _recordingTimer;

//   final GiveScreenRepository _repository = GiveScreenRepository();
//   bool isUploading = false; // Add this variable
//   bool isUsingFrontCamera = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   // Initialize the camera
//   Future<void> _initializeCamera() async {
//     try {
//       // Get available cameras
//       cameras = await availableCameras();

//       // // Select the back camera (you can adjust this based on your requirements)
//       // camera = cameras.firstWhere(
//       //   (camera) => camera.lensDirection == CameraLensDirection.back,
//       //   orElse: () =>
//       //       cameras.first, // Fallback to first camera if no back camera found
//       // );

//       // Select the camera based on whether the user wants front or back
//       camera = cameras.firstWhere(
//         (camera) => isUsingFrontCamera
//             ? camera.lensDirection == CameraLensDirection.front
//             : camera.lensDirection == CameraLensDirection.back,
//         orElse: () => cameras.first, // Fallback to first available camera
//       );
//       // Initialize the CameraController with audio disabled
//       _controller = CameraController(
//         camera,
//         ResolutionPreset.high,
//         enableAudio: false, // Disable audio recording
//       );

//       // Wait for the controller to initialize
//       await _controller.initialize();

//       // Set the camera initialization flag to true
//       setState(() {
//         isCameraInitialized = true;
//       });
//     } catch (e) {
//       print("Error initializing camera: $e");
//     }
//   }

//   void _toggleCamera() {
//     setState(() {
//       isUsingFrontCamera = !isUsingFrontCamera;
//       isCameraInitialized = false; // Flag to reinitialize camera
//     });
//     _controller.dispose(); // Dispose of the current controller
//     _initializeCamera(); // Reinitialize with the new camera
//   }

//   // Start video recording
//   Future<void> _startRecording() async {
//     if (!_controller.value.isInitialized || isRecording) return;

//     final Directory appDirectory = await getTemporaryDirectory();
//     videoPath =
//         '${appDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

//     await _controller.startVideoRecording();
//     setState(() {
//       isRecording = true;
//     });

//     // Start a timer to stop recording after 4 seconds
//     _recordingTimer = Timer(const Duration(seconds: 4), _stopRecording);
//   }

//   // Stop video recording
//   Future<void> _stopRecording() async {
//     if (!_controller.value.isRecordingVideo) return;

//     final file = await _controller.stopVideoRecording();
//     setState(() {
//       isRecording = false;
//       videoPath = file.path;
//     });

//     // Initialize the video player with the recorded video path
//     _videoPlayerController = VideoPlayerController.file(File(videoPath))
//       ..initialize().then((_) {
//         setState(() {
//           isVideoInitialized = true;
//         });
//         _videoPlayerController.play();
//         _videoPlayerController.addListener(() {
//           if (!_videoPlayerController.value.isPlaying &&
//               _videoPlayerController.value.position ==
//                   _videoPlayerController.value.duration) {
//             setState(() {
//               isVideoPlayed = true; // Video has finished playing
//             });
//           }
//         });
//       });
//   }

//   // Retake video (reset to camera preview)
//   void _retakeVideo() {
//     setState(() {
//       isVideoInitialized = false;
//       videoPath = '';
//       isVideoPlayed = false;
//     });
//     _initializeCamera(); // Reinitialize camera for retake
//   }

//   // // Cancel video (discard current video and go back to camera)
//   // void _cancelVideo() {
//   //   setState(() {
//   //     isVideoInitialized = false;
//   //     videoPath = '';
//   //     isVideoPlayed = false;
//   //   });
//   //   _controller.dispose();
//   //   _initializeCamera(); // Reinitialize camera to start a new recording
//   // }

//   void _cancelVideo() {
//     // Show confirmation dialog to discard the video
//     showCupertinoDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: const Text('Discard Video?'),
//           content: const Text('Are you sure you want to discard this video?'),
//           actions: <Widget>[
//             CupertinoDialogAction(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             CupertinoDialogAction(
//               child: const Text('Discard'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 // Proceed with canceling and reinitializing the camera
//                 setState(() {
//                   isVideoInitialized = false;
//                   videoPath = '';
//                   isVideoPlayed = false;
//                 });
//                 _controller.dispose();
//                 _initializeCamera(); // Reinitialize camera to start a new recording
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Play the video again
//   void _playVideo() {
//     setState(() {
//       isVideoPlayed = false; // Reset flag so play button hides again
//     });
//     _videoPlayerController.play();
//   }

//   // Dispose camera controller and video player
//   @override
//   void dispose() {
//     _controller.dispose();
//     if (_videoPlayerController.value.isInitialized) {
//       _videoPlayerController.dispose();
//     }
//     _recordingTimer?.cancel(); // Cancel the timer if it's running
//     super.dispose();
//   }

// // Method to handle video upload and URL submission
//   Future<void> _uploadAndSendVideo() async {
//     try {
//       setState(() {
//         isUploading = true; // Start the loader when upload starts
//       });
//       // Upload video to the first API
//       File videoFile = File(videoPath); // Get the recorded video file
//       final videoUrl = await _repository.uploadVideo(videoFile);

//       if (videoUrl != null && videoUrl.isNotEmpty) {
//         // Send video URL to the second API
//         await _repository.sendVideoUrlToApi(videoUrl);
//         Navigator.of(context).pop(); // Close the dialog
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Clip uploaded successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload video')),
//         );
//       }
//     } catch (e) {
//       // If any exception is thrown, display the error message
//       String errorMessage = 'An error occurred';
//       if (e is Exception) {
//         // Extract the message after "Error: " (if it's in the exception message)
//         errorMessage = e.toString().replaceFirst('Exception: Error: ', '');
//         print(
//             'Caught exception: $errorMessage'); // Debug log to check the message
//       } else {
//         print('Caught non-exception error: $e');
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//     } finally {
//       // Stop the loader once the process is done (either success or error)
//       setState(() {
//         isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isCameraInitialized) {
//       // Show a loading indicator until the camera is initialized
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Give"),
//         leading: isVideoInitialized
//             ? Padding(
//                 padding: const EdgeInsets.only(right: 10),
//                 child: IconButton(
//                   onPressed: _cancelVideo,
//                   icon: const Icon(CupertinoIcons.clear),
//                 ),
//               )
//             : IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new_rounded),
//                 onPressed: () {
//                   Navigator.pop(
//                       context); // Navigate back when the back button is pressed
//                 },
//               ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 if (isVideoInitialized)
//                   // Display the recorded video
//                   Flexible(
//                     child: Stack(
//                       children: [
//                         SizedBox(
//                           width: double.infinity, // Ensure it takes full width
//                           height:
//                               double.infinity, // Ensure it takes full height
//                           child: AspectRatio(
//                             aspectRatio:
//                                 _videoPlayerController.value.aspectRatio,
//                             child: VideoPlayer(_videoPlayerController),
//                           ),
//                         ),
//                         // Show play button when video is finished playing
//                         if (isVideoPlayed)
//                           Center(
//                             child: CupertinoButton(
//                               onPressed: _playVideo,
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       const Color(0xFFD9D9D9).withOpacity(0.5),
//                                   borderRadius: BorderRadius.circular(50),
//                                 ),
//                                 child: Icon(
//                                   Icons.play_arrow,
//                                   color: Colors.grey.withOpacity(0.9),
//                                   size: 40,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   )
//                 else
//                   // Full-screen camera preview
//                   Flexible(
//                     child: SizedBox(
//                       width: double.infinity, // Ensure it takes full width
//                       height: double.infinity, // Ensure it takes full height
//                       child: CameraPreview(_controller),
//                     ),
//                   ),

//                 addVerticalSpace(20),

//                 // Positioned buttons at the bottom of the screen
//                 if (isVideoInitialized)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // Retake button
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 2),
//                             decoration: BoxDecoration(
//                               border: Border.all(width: 2, color: primaryColor),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: CupertinoButton(
//                               padding: const EdgeInsets.all(0),
//                               onPressed: _retakeVideo,
//                               child: const Text(
//                                 'Retake',
//                                 style: TextStyle(
//                                   color: textFieldTextColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         addHorizontalSpace(20),
//                         // Upload button (example, you can replace with actual upload functionality)
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             decoration: BoxDecoration(
//                               color: primaryColor,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: CupertinoButton(
//                               padding: const EdgeInsets.all(0),
//                               onPressed:
//                                   _uploadAndSendVideo, // Upload and send URL
//                               // onPressed: () {
//                               //   // Replace this with your upload logic
//                               //   ScaffoldMessenger.of(context).showSnackBar(
//                               //     const SnackBar(
//                               //         content: Text("Uploading video...")),
//                               //   );
//                               // },
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     'Give',
//                                     style: TextStyle(
//                                       color: textFieldTextColor,
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.arrow_forward_ios_rounded,
//                                     size: 20,
//                                     color: textFieldTextColor,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Positioned button at the bottom of the screen for recording
//                 if (!isVideoInitialized)
//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceEvenly, // Center both buttons
//                     children: [
//                       // const SizedBox(
//                       //   width: 50,
//                       // ),
//                       Flexible(
//                           child: IconButton(
//                         onPressed: () {},
//                         icon: const Icon(
//                           Icons.check_box_outline_blank,
//                           color: Colors.white,
//                         ),
//                       )),
//                       // Record button (centered)
//                       Flexible(
//                         child: ElevatedButton(
//                           onPressed:
//                               isRecording ? _stopRecording : _startRecording,
//                           style: ElevatedButton.styleFrom(
//                             shape: const CircleBorder(),
//                             padding: const EdgeInsets.all(10),
//                             backgroundColor: isRecording
//                                 ? Colors.red
//                                 : Colors.white, // Red for recording
//                           ),
//                           child: Icon(
//                             isRecording
//                                 ? CupertinoIcons
//                                     .stop_circle_fill // iOS stop icon (square filled)
//                                 : CupertinoIcons
//                                     .circle_fill, // iOS red circle icon for recording
//                             size: 40,
//                             color: isRecording
//                                 ? Colors.white
//                                 : Colors.red, // White for stop, red for record
//                           ),
//                         ),
//                       ),

//                       // const SizedBox(
//                       //     width: 20), // Add spacing between the buttons

//                       // Camera switch button (right side)
//                       Flexible(
//                         child: IconButton(
//                           icon: const Icon(
//                             // Iconsax.repeat_copy,
//                             // Icons.cameraswitch_outlined,
//                             CupertinoIcons.switch_camera,
//                             size: 30,
//                           ),
//                           onPressed: _toggleCamera,
//                         ),
//                       ),
//                     ],
//                   )
//               ],
//             ),

//             // Loader overlay
//             if (isUploading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black
//                       .withOpacity(0.5), // Semi-transparent background
//                   child: const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
