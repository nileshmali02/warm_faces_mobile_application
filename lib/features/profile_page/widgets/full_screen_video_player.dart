import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:video_player/video_player.dart';
import 'package:warm_faces/features/profile_page/repositories/video_clips_repository.dart';
import 'package:warm_faces/utils/constant/colors.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String videoId; // Pass the video ID for deletion
  final VoidCallback? onClipDeleted; // Add the callback here

  const FullScreenVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.videoId,
    this.onClipDeleted,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _initializeController(); // Initialize the controller when the screen is first built
    // // _controller = VideoPlayerController.asset(widget.videoUrl)
    // //   ..initialize().then((_) {
    // //     setState(() {});
    // //     _controller.play(); // Start with video playing
    // //     _isPlaying = true;
    // //   });
    // // Check if the URL is valid (non-null and non-empty)
    // if (widget.videoUrl.isEmpty) {
    //   // If URL is empty, display an error or show a default error video
    //   throw Exception("Video URL is empty.");
    // }

    // // Check if the URL is a network URL or an asset URL
    // if (widget.videoUrl.startsWith('http://') ||
    //     widget.videoUrl.startsWith('https://')) {
    //   // Network URL
    //   _controller = VideoPlayerController.network(widget.videoUrl);
    // } else {
    //   // Asset URL
    //   _controller = VideoPlayerController.asset(widget.videoUrl);
    // }

    // _controller.initialize().then((_) {
    //   setState(() {});
    //   _controller.play(); // Start with video playing
    //   _isPlaying = true;
    // }).catchError((error) {
    //   // Handle errors if initialization fails
    //   print("Error initializing video: $error");
    //   setState(() {
    //     _isPlaying = false;
    //   });
    // });

    // // Listen for changes in video playback
    // _controller.addListener(() {
    //   if (_controller.value.position == _controller.value.duration) {
    //     setState(() {
    //       _isPlaying = false; // Video has completed, so show the play icon
    //     });
    //   }
    // });
  }

// Initialize the controller based on the current video URL
  void _initializeController() {
    // Check if the URL is empty
    if (widget.videoUrl.isEmpty) {
      throw Exception("Video URL is empty.");
    }

    // Initialize the video player based on whether it's an asset or a network URL
    if (widget.videoUrl.startsWith('http://') ||
        widget.videoUrl.startsWith('https://')) {
      // Network video
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      // Asset video
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }

    _controller.initialize().then((_) {
      setState(() {
        _controller.play(); // Automatically play the video when it is ready
        _isPlaying = true;
      });
    }).catchError((error) {
      print("Error initializing video: $error");
      setState(() {
        _isPlaying = false;
      });
    });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isPlaying = false; // Video completed, so we stop the playback
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {}); // Clean up the listener
    _controller.dispose();
    super.dispose();
  }

  // Function to delete the video using repository
  // Future<void> _deleteVideo(BuildContext context) async {
  //   try {
  //     // Call the delete method in the repository
  //     await VideoClipRepository().deleteVideo(widget.videoId);
  //     // If successful, pop the screen and return true to indicate deletion
  //     Navigator.pop(context, true);
  //   } catch (error) {
  //     // If there's an error, show a dialog
  //     showDialog(
  //       context: context,
  //       builder: (context) => CupertinoAlertDialog(
  //         title: const Text('Error'),
  //         content:
  //             const Text('Failed to delete the video. Please try again later.'),
  //         actions: <Widget>[
  //           CupertinoDialogAction(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // Function to delete the video using Cupertino Dialog
  void _deleteVideo(BuildContext context) {
    // Show Cupertino confirmation dialog before deleting
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Video'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                // // Clear the video controller and delete video
                // setState(() {
                //   _controller.dispose(); // Dispose the controller
                // });
                // // Navigator.of(context).pop(); // Close dialog
                // // Dispose the controller before calling delete
                // if (_controller.value.isInitialized) {
                //   _controller.dispose(); // Dispose the controller
                // }
                // // Call the delete method in the repository
                // await VideoClipRepository().deleteVideo(widget.videoId);
                // // If successful, pop the screen and return true to indicate deletion
                // Navigator.pop(context, true);
                // Navigator.pop(context);
                // Perform video deletion logic
                try {
                  // Attempt to delete the video using the repository
                  await VideoClipRepository().deleteVideo(widget.videoId);
                  // Call the onClipDeleted callback to update the ProfileScreenTemp
                  if (widget.onClipDeleted != null) {
                    widget.onClipDeleted!();
                  }
                  Navigator.of(context).pop(true); // Close the dialog
                  Navigator.of(context)
                      .pop(true); // Close the FullScreenVideoPlayer screen
                } catch (e) {
                  // If there's an error, show an error message
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error deleting video')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    // Toggle play/pause on tap
                    _isPlaying ? _controller.pause() : _controller.play();
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Stack(
                  alignment: Alignment.center, // Center the stack content
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    // // Video Player with full screen
                    // Positioned.fill(
                    //   // Ensures that the video fills the screen
                    //   child: AspectRatio(
                    //     aspectRatio: _controller.value.aspectRatio,
                    //     child: VideoPlayer(_controller),
                    //   ),
                    // ),
                    if (!_isPlaying) // Show play icon when paused or video completes
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.play(); // Play the video
                              _isPlaying = true; // Update state to playing
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.grey.withOpacity(0.9),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.only(left: 9),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9).withOpacity(0.5),
                            shape: BoxShape.circle),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 30,
                            ),
                            color: whiteColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showOptions(context),
      //   child: const Icon(Icons.more_vert),
      // ),
      // Speed Dial FAB with multiple actions
      floatingActionButton: SpeedDial(
        // animatedIcon:
        //     AnimatedIcons.menu_close, // Animated icon for the Speed Dial
        icon: CupertinoIcons.ellipsis,
        animatedIconTheme: const IconThemeData(size: 22.0),
        visible: true,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,

        children: [
          // SpeedDialChild(
          //   child: const Icon(Icons.play_arrow),
          //   label: 'Play Video',
          //   onTap: () {
          //     setState(() {
          //       _controller.play(); // Play the video
          //       _isPlaying = true;
          //     });
          //   },
          // ),
          // SpeedDialChild(
          //   child: const Icon(Icons.pause),
          //   label: 'Pause Video',
          //   onTap: () {
          //     setState(() {
          //       _controller.pause(); // Pause the video
          //       _isPlaying = false;
          //     });
          //   },
          // ),

          SpeedDialChild(
            child: const Icon(Icons.delete),
            label: 'Delete Video',
            onTap: () {
              _deleteVideo(context); // Show delete confirmation
            },
          ),
        ],
      ),
    );
  }
}
