// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:warm_faces/features/homepage/models/display_daily_clip_model.dart';
// import 'package:warm_faces/features/homepage/repositories/display_daily_clip_repository.dart';
// import 'package:warm_faces/utils/constant/colors.dart';
// import 'package:warm_faces/utils/constant/sized.dart';
// import 'package:warm_faces/utils/widgets/c_sizebox.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late VideoPlayerController _controller;
//   String videoUrl = '';
//   String videoID = '';
//   bool isLoading = true;
//   bool _isPlaying = true;
//   bool _isBuffering = false; // Track buffering state
//   int retryCount = 0; // Counter for retry attempts
//   Timer? _videoTimer; // Timer to stop video after 12 seconds
//   double selectedRating = 0.0; // Track the selected rating

//   final DisplayDailyClipRepository _displayDailyClipRepository =
//       DisplayDailyClipRepository();

//   // Variables to store rating status
//   bool beforeRatingStatus = false; // Track if before rating is submitted
//   bool afterRatingStatus = false; // Track if after rating is submitted

//   List<String> selectedReasons = []; // To store selected reasons
//   TextEditingController otherController =
//       TextEditingController(); // Text controller for "Others"

//   // Predefined reasons for the report
//   final List<String> predefinedReasons = [
//     'Explicit Content',
//     'Nudity',
//     'Low Quality',
//     'Inappropriate Content',
//     // 'Others'
//   ];
//   @override
//   void initState() {
//     super.initState();
//     _loadCachedVideoUrl(); // Check if we have a cached video URL
//     _fetchVideoDetails(); // Fetch video data asynchronously
//   }

//   // Try to load the video URL from local cache first
//   Future<void> _loadCachedVideoUrl() async {
//     final prefs = await SharedPreferences.getInstance();
//     String cachedUrl = prefs.getString('videoUrl') ?? '';
//     if (cachedUrl.isNotEmpty) {
//       setState(() {
//         videoUrl = cachedUrl;
//         isLoading = false; // Video already cached, so not loading
//       });
//       _initializeVideoPlayer();
//     }
//   }

//   // Fetch video URL and ID from API
//   Future<void> _fetchVideoDetails() async {
//     try {
//       // Fetch video data from API
//       DailyClipModel videoData =
//           await _displayDailyClipRepository.fetchDailyClip();
//       print("Called API");
//       // Save the video URL to cache
//       final prefs = await SharedPreferences.getInstance();
//       prefs.setString('videoUrl', videoData.url);

//       setState(() {
//         videoUrl = videoData.url;
//         videoID = videoData.clipId;
//         // videoID = "video7";
//         isLoading = false;
//       });

//       // Count the view whenever the user visits the screen (or re-enters the home screen)
//       await _incrementViewCount(videoID);
//       // _initializeVideoPlayer(); // Initialize video player with fetched URL
//       handleVideoPlayWithRatingCheck(
//           videoID); // Check if the video requires a rating before playing
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error fetching video details: $e");
//     }
//   }

//   // This function is responsible for incrementing the view count
//   Future<void> _incrementViewCount(String videoId) async {
//     try {
//       await _displayDailyClipRepository.incrementViewCount(videoId);
//       print("View count incremented for video: $videoId");
//     } catch (e) {
//       print("Error incrementing view count: $e");
//     }
//   }

//   // Check before rating status from the API
//   // Method to check rating status and decide video behavior
//   // Future<void> handleVideoPlayWithRatingCheck(String videoId) async {
//   //   try {
//   //     final beforeRating =
//   //         await _displayDailyClipRepository.checkBeforeRatingStatus(videoId);

//   //     if (beforeRating) {
//   //       // Directly play the video if beforeRating is true
//   //       await _initializeVideoPlayer();
//   //       // Set a timer to stop the video after 12 seconds
//   //       _videoTimer =
//   //           Timer(const Duration(seconds: 12), _stopVideoAfterTimeout);
//   //     } else {
//   //       _pauseVideo(); // Pause the video initially
//   //       await _showRatingBeforePopup(); // Show rating popup
//   //       // Pause the video and show the rating dialog if beforeRating is false
//   //       await _initializeVideoPlayer();
//   //       // Set a timer to stop the video after 12 seconds
//   //       _videoTimer =
//   //           Timer(const Duration(seconds: 12), _stopVideoAfterTimeout);
//   //     }
//   //   } catch (e) {
//   //     print("Error checking rating status: $e");
//   //   }
//   // }

//   Future<void> handleVideoPlayWithRatingCheck(String videoId) async {
//     try {
//       // Pause the video and show the before rating dialog
//       _pauseVideo();

//       final ratingStatus = await _displayDailyClipRepository
//           .checkBeforeAndAfterRatingStatus(videoId);

//       setState(() {
//         // Store the rating status in variables
//         beforeRatingStatus = ratingStatus['beforeRating'] == true;
//         // beforeRatingStatus = true;
//         afterRatingStatus = ratingStatus['afterRating'] == true;
//       });

//       print("beforeRatingStatus $beforeRatingStatus");
//       print("afterRatingStatus $afterRatingStatus");

//       // // Increment view count here before playing
//       // await _displayDailyClipRepository.incrementViewCount(videoId);

//       // Handle the "beforeRating"
//       if (beforeRatingStatus) {
//         // If before rating is submitted, play the video directly
//         await _initializeVideoPlayer();
//         setState(() {
//           _controller.play(); // Start playing automatically
//           _isPlaying = true; // Video is playing
//         });
//         _videoTimer =
//             Timer(const Duration(seconds: 12), _stopVideoAfterTimeout);
//       } else {
//         // Show the before rating popup if not submitted
//         await _showRatingBeforePopup();
//       }
//       // if (ratingStatus['beforeRating'] == true) {
//       //   // Directly play the video if beforeRating is true
//       //   await _initializeVideoPlayer();
//       //   _videoTimer =
//       //       Timer(const Duration(seconds: 12), _stopVideoAfterTimeout);
//       // } else {
//       //   // _controller.pause(); // Pause the video initially
//       //   await _showRatingBeforePopup(); // Show rating popup
//       //   // await _initializeVideoPlayer();
//       //   // _videoTimer =
//       //   //     Timer(const Duration(seconds: 12), _stopVideoAfterTimeout);
//       // }

//       // // Now handle the "afterRating" case
//       // if (ratingStatus['afterRating'] == false) {
//       //   // After video plays, show the rating popup
//       //   _videoTimer?.cancel();
//       //   _videoTimer = Timer(const Duration(seconds: 12), _showRatingAfterPopup);
//       // } else {
//       //   _controller.pause();
//       // }
//     } catch (e) {
//       print("Error checking rating status: $e");
//     }
//   }

//   Future<void> _showRatingBeforePopup() async {
//     print("Opening rating dialog");
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Disable closing the dialog by tapping outside
//       builder: (BuildContext context) {
//         // Using StatefulBuilder to update the dialog content dynamically
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setStateDialog) {
//             return AlertDialog(
//               backgroundColor:
//                   Colors.white, // Set the background color to white
//               title: const Text(
//                 'How are you today?',
//                 textAlign: TextAlign.center,
//               ),
//               content: SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(
//                         height: 20), // Add space between rating and image
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _ratingOption(
//                           1.0,
//                           'Awful',
//                           'assets/icons/ratingicons/awful.png',
//                           setStateDialog,
//                           color: selectedRating == 1.0
//                               ? const Color(0xFF3963C1)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           2.0,
//                           'Bad',
//                           'assets/icons/ratingicons/bad.png',
//                           setStateDialog,
//                           color: selectedRating == 2.0
//                               ? const Color(0xFF4E8EC6)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           3.0,
//                           'Okay',
//                           'assets/icons/ratingicons/okay.png',
//                           setStateDialog,
//                           color: selectedRating == 3.0
//                               ? const Color(0xFFF3B144)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           4.0,
//                           'Good',
//                           'assets/icons/ratingicons/good.png',
//                           setStateDialog,
//                           color: selectedRating == 4.0
//                               ? const Color(0xFF6CB16E)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           5.0,
//                           'Great',
//                           'assets/icons/ratingicons/great.png',
//                           setStateDialog,
//                           color: selectedRating == 5.0
//                               ? const Color(0xFF397F55)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               actions: [
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: CupertinoButton(
//                     onPressed: () async {
//                       // Check if a rating has been selected before proceeding
//                       if (selectedRating == 0.0) {
//                         // Ensure the user selects a rating before proceeding
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('Please select a rating')),
//                         );
//                         return;
//                       }
//                       Navigator.of(context).pop(); // Close the dialog

//                       // Submit the before rating (assuming videoID holds the clip ID)
//                       await _displayDailyClipRepository.submitRating(
//                         videoID, // clipId
//                         'before', // ratingType
//                         _getRatingText(selectedRating), // rating
//                       );
//                       print(
//                           "Submit Before Rating: $selectedRating  - ${_getRatingText(selectedRating)}");

//                       // _controller.play(); // Start the video after rating
//                       // // Restart the timer to stop the video after 12 seconds
//                       // _videoTimer?.cancel();
//                       // _videoTimer = Timer(
//                       //     const Duration(seconds: 12), _stopVideoAfterTimeout);
//                       // // setState(() {});
//                       // Now play the video after rating submission
//                       // await _initializeVideoPlayer();
//                       setState(() {
//                         selectedRating = 0.0;
//                         _controller.play(); // Start playing automatically
//                         _isPlaying = true; // Video is playing
//                       });
//                       _videoTimer = Timer(
//                           const Duration(seconds: 12), _stopVideoAfterTimeout);
//                     },
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // CupertinoDialogAction(
//                 //   onPressed: () async {
//                 //     // Check if a rating has been selected before proceeding
//                 //     if (selectedRating == 0.0) {
//                 //       // Ensure the user selects a rating before proceeding
//                 //       ScaffoldMessenger.of(context).showSnackBar(
//                 //         const SnackBar(content: Text('Please select a rating')),
//                 //       );
//                 //       return;
//                 //     }
//                 //     Navigator.of(context).pop(); // Close the dialog

//                 //     // Submit the before rating (assuming videoID holds the clip ID)
//                 //     await _displayDailyClipRepository.submitRating(
//                 //       videoID, // clipId
//                 //       'before', // ratingType
//                 //       _getRatingText(selectedRating), // rating
//                 //     );
//                 //     print(
//                 //         "Submit Before Rating: $selectedRating  - ${_getRatingText(selectedRating)}");

//                 //     // _controller.play(); // Start the video after rating
//                 //     // // Restart the timer to stop the video after 12 seconds
//                 //     // _videoTimer?.cancel();
//                 //     // _videoTimer = Timer(
//                 //     //     const Duration(seconds: 12), _stopVideoAfterTimeout);
//                 //     // // setState(() {});
//                 //     // Now play the video after rating submission
//                 //     // await _initializeVideoPlayer();
//                 //     setState(() {
//                 //       selectedRating = 0.0;
//                 //       _controller.play(); // Start playing automatically
//                 //       _isPlaying = true; // Video is playing
//                 //     });
//                 //     _videoTimer = Timer(
//                 //         const Duration(seconds: 12), _stopVideoAfterTimeout);
//                 //   },
//                 //   child: const Text('Submit'),
//                 // ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _showRatingAfterPopup() async {
//     print("Opening rating dialog after video");

//     // Show the Cupertino dialog for rating after 12 seconds of video playback
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Disable closing the dialog by tapping outside
//       builder: (BuildContext context) {
//         // Using StatefulBuilder to update the dialog content dynamically
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setStateDialog) {
//             return AlertDialog(
//               title: const Text(
//                 'How are you feeling now?',
//                 textAlign: TextAlign.center,
//               ),
//               content: SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(
//                         height: 20), // Add space between rating and image
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _ratingOption(
//                           1.0,
//                           'Awful',
//                           'assets/icons/ratingicons/awful.png',
//                           setStateDialog,
//                           color: selectedRating == 1.0
//                               ? const Color(0xFF3963C1)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           2.0,
//                           'Bad',
//                           'assets/icons/ratingicons/bad.png',
//                           setStateDialog,
//                           color: selectedRating == 2.0
//                               ? const Color(0xFF4E8EC6)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           3.0,
//                           'Okay',
//                           'assets/icons/ratingicons/okay.png',
//                           setStateDialog,
//                           color: selectedRating == 3.0
//                               ? const Color(0xFFF3B144)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           4.0,
//                           'Good',
//                           'assets/icons/ratingicons/good.png',
//                           setStateDialog,
//                           color: selectedRating == 4.0
//                               ? const Color(0xFF6CB16E)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                         _ratingOption(
//                           5.0,
//                           'Great',
//                           'assets/icons/ratingicons/great.png',
//                           setStateDialog,
//                           color: selectedRating == 5.0
//                               ? const Color(0xFF397F55)
//                               : Colors.black.withOpacity(0.7),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: CupertinoButton(
//                     onPressed: () async {
//                       // Optionally handle any actions for the rating
//                       _pauseVideo();
//                       // Check if the video requires a rating before playing
//                       Navigator.of(context).pop(); // Close the dialog
//                       // print("Submit Rating After Watching: $selectedRating");
//                       // Submit the before rating (assuming videoID holds the clip ID)
//                       await _displayDailyClipRepository.submitRating(
//                         videoID, // clipId
//                         'after', // ratingType
//                         _getRatingText(selectedRating), // rating
//                       );
//                       await handleVideoPlayWithRatingCheck(videoID);
//                       print(
//                           "Submit Rating After Watching: $selectedRating  - ${_getRatingText(selectedRating)}");
//                     },
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // CupertinoDialogAction(
//                 //   onPressed: () async {
//                 //     // Optionally handle any actions for the rating
//                 //     _pauseVideo();
//                 //     // Check if the video requires a rating before playing
//                 //     Navigator.of(context).pop(); // Close the dialog
//                 //     // print("Submit Rating After Watching: $selectedRating");
//                 //     // Submit the before rating (assuming videoID holds the clip ID)
//                 //     await _displayDailyClipRepository.submitRating(
//                 //       videoID, // clipId
//                 //       'after', // ratingType
//                 //       _getRatingText(selectedRating), // rating
//                 //     );
//                 //     await handleVideoPlayWithRatingCheck(videoID);
//                 //     print(
//                 //         "Submit Rating After Watching: $selectedRating  - ${_getRatingText(selectedRating)}");
//                 //   },
//                 //   child: const Text('Submit'),
//                 // ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

// // Helper method to convert rating number to text
//   String _getRatingText(double rating) {
//     switch (rating) {
//       case 1.0:
//         return 'awful';
//       case 2.0:
//         return 'bad';
//       case 3.0:
//         return 'okay';
//       case 4.0:
//         return 'good';
//       case 5.0:
//         return 'great';
//       default:
//         return '';
//     }
//   }

// // Widget to create each rating option with custom image
//   Widget _ratingOption(
//       double value, String label, String imagePath, StateSetter setStateDialog,
//       {required Color color}) {
//     bool isSelected =
//         selectedRating == value; // Check if this option is selected

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedRating = value; // Update the selected rating
//         });
//         setStateDialog(() {}); // Ensure the dialog rebuilds after selecting
//         print(
//             "Selected Rating: $selectedRating"); // Debugging line to check if it's updating correctly
//       },
//       child: Column(
//         children: [
//           // Custom border to highlight the selected icon
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 width: 3,
//                 color: isSelected
//                     ? color
//                     : Colors.transparent, // Change color if selected
//               ),
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child: Image.asset(
//               imagePath, // Custom image for the rating
//               width: 40.0, // Adjust size as needed
//               height: 40.0, // Adjust size as needed
//             ),
//           ),
//           const SizedBox(height: 5), // Adding space between icon and label
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: color, // Use the dynamic color
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Initialize video player with the dynamic network URL
//   Future<void> _initializeVideoPlayer() async {
//     if (videoUrl.isNotEmpty) {
//       // _controller = VideoPlayerController.network(videoUrl)
//       _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
//         ..initialize().then((_) {
//           setState(() {});
//           _controller.setLooping(true); // Enable looping
//           // _controller.play(); // Start playing automatically
//           // _isPlaying = true; // Video is playing
//         })
//         ..addListener(() {
//           setState(() {
//             // Detect buffering state
//             _isBuffering = _controller.value.isBuffering;
//           });
//         })
//         ..setVolume(1.0);

//       // Attempt to preload the video to avoid buffering
//       _controller.setVolume(1.0); // Ensure sound is enabled
//     }
//   }

//   // Stop the video after 12 seconds and show the play button
//   void _stopVideoAfterTimeout() {
//     if (_controller.value.isPlaying) {
//       _controller.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//       // // Show the rating dialog after 12 seconds of video
//       // _showRatingAfterPopup();
//       // Handle the "afterRating"
//       if (afterRatingStatus == false) {
//         // If after rating is not submitted, show the after rating popup after 12 seconds

//         _videoTimer?.cancel();
//         _showRatingAfterPopup();
//         // _videoTimer = Timer(const Duration(seconds: 12), _showRatingAfterPopup);
//       } else {
//         // If after rating is already submitted, pause the video
//         _controller.pause();
//       }
//     }
//   }

//   // Play the video when the play button is pressed
//   void _playVideo() {
//     if (!_isPlaying && _controller.value.isInitialized) {
//       setState(() {
//         _controller.play();
//         _isPlaying = true;
//       });
//       // // Increment the view count when the user presses play
//       // _displayDailyClipRepository.incrementViewCount(videoID);
//       // Restart the timer to stop the video after 12 seconds
//       _videoTimer?.cancel();
//       _videoTimer = Timer(const Duration(seconds: 12), _stopVideoAfterTimeout);
//     }
//   }

//   // Pause the video when clicked anywhere on the screen
//   void _pauseVideo() {
//     if (_isPlaying && _controller.value.isInitialized) {
//       setState(() {
//         _controller.pause();
//         _isPlaying = false;
//       });

//       _videoTimer?.cancel(); // Cancel the timer when video is paused
//     }
//   }

//   // Retry logic in case of video load failure
//   Future<void> _retryVideoLoading() async {
//     if (retryCount < 3) {
//       setState(() {
//         isLoading = true;
//         retryCount++;
//       });
//       await Future.delayed(
//         const Duration(seconds: 2),
//       ); // Wait for a bit before retrying
//       _fetchVideoDetails(); // Retry fetching the video details
//     } else {
//       // Show some error message after 3 retry attempts
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("Failed to load video. Please try again later.")),
//       );
//     }
//   }

//   Future<void> _showReportPopup() async {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       // isDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setStateDialog) {
//             return SingleChildScrollView(
//               // Wrap the content inside SingleChildScrollView
//               child: GestureDetector(
//                 onTap: () {
//                   // Dismiss keyboard when tapping outside of the text field
//                   FocusScope.of(context).unfocus();
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                       bottom: MediaQuery.of(context).viewInsets.bottom),
//                   child: Container(
//                     padding: const EdgeInsets.all(20.0),
//                     height: 500,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const SizedBox(height: 20),
//                         const Text(
//                           'Why are you reporting \nthis video?',
//                           style: TextStyle(
//                             fontSize: fontSizeExtraLarge,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                             'Please select the reason(s) for reporting:'),
//                         const SizedBox(height: 10),
//                         // Display reasons as selectable chips
//                         Wrap(
//                           spacing: 8.0,
//                           runSpacing: 4.0,
//                           children: predefinedReasons.map((reason) {
//                             return FilterChip(
//                               label: Text(reason),
//                               selected: selectedReasons.contains(reason),
//                               onSelected: (isSelected) {
//                                 setStateDialog(() {
//                                   if (isSelected) {
//                                     selectedReasons.add(reason);
//                                   } else {
//                                     selectedReasons.remove(reason);
//                                   }
//                                 });
//                               },
//                               selectedColor: primaryColor,
//                               backgroundColor: Colors.transparent,
//                               labelStyle: TextStyle(
//                                 color: selectedReasons.contains(reason)
//                                     ? Colors.black
//                                     : Colors.black,
//                               ),
//                               shadowColor: Colors.black,
//                             );
//                           }).toList(),
//                         ),
//                         if (selectedReasons.contains('Others')) ...[
//                           const SizedBox(height: 10),
//                           const Text('Please specify other reason:'),
//                           CupertinoTextField(
//                             controller: otherController,
//                             placeholder: 'Enter your reason...',
//                           ),
//                         ],
//                         const SizedBox(height: 14),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: CupertinoTextField(
//                             controller: otherController,
//                             placeholder: 'Write details',
//                             maxLines: 4,
//                             minLines: 4,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 10, horizontal: 12),
//                             textAlignVertical: TextAlignVertical.top,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.grey,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Container(
//                           width: MediaQuery.of(context).size.width,
//                           decoration: BoxDecoration(
//                             color: primaryColor,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: CupertinoButton(
//                             onPressed: () {
//                               _submitReport();
//                               Navigator.of(context).pop();
//                             },
//                             child: const Text(
//                               'Submit',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(() {});
//     _controller.dispose();
//     _videoTimer?.cancel(); // Cancel the timer on dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: Center(
//           child: isLoading
//               ? const CircularProgressIndicator() // Show loading spinner while waiting
//               : _controller.value.isInitialized
//                   ? GestureDetector(
//                       onTap: () {
//                         // Pause the video on tap anywhere if playing
//                         if (_isPlaying) {
//                           _pauseVideo();
//                         } else {
//                           _playVideo();
//                         }
//                       },
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           AspectRatio(
//                             aspectRatio: _controller.value.aspectRatio,
//                             child: VideoPlayer(_controller),
//                           ),
//                           // Show buffering indicator
//                           if (_isBuffering)
//                             const Positioned(
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           if (!_isPlaying) // Only show play button when paused
//                             Positioned(
//                               child: GestureDetector(
//                                 onTap: _playVideo,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFD9D9D9)
//                                         .withOpacity(0.5),
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                   child: Icon(
//                                     Icons.play_arrow,
//                                     color: Colors.grey.withOpacity(0.9),
//                                     size: 50,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           const Positioned(
//                             top: 10,
//                             left: 20,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Warm Faces',
//                                   style: TextStyle(
//                                     color: whiteColor,
//                                     fontWeight: FontWeight.w800,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 Text(
//                                   'For You',
//                                   style: TextStyle(
//                                     color: whiteColor,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Positioned(
//                             top: 10,
//                             right: 20,
//                             child: GestureDetector(
//                               onTap:
//                                   _showReportPopup, // Open the report popup on tap
//                               child: const Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.info_outline,
//                                     color: greyColor,
//                                   ),
//                                   Text(
//                                     'Report',
//                                     style: TextStyle(
//                                       color: whiteColor,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // // Positioning the buttons and view count vertically on the bottom-right
//                           // Positioned(
//                           //   bottom: 20,
//                           //   right: 20,
//                           //   child: Column(
//                           //     mainAxisAlignment: MainAxisAlignment.end,
//                           //     children: [
//                           //       // Button 1 (Play/Pause)
//                           //       GestureDetector(
//                           //         onTap: _isPlaying ? _pauseVideo : _playVideo,
//                           //         child: Container(
//                           //           padding: const EdgeInsets.all(8),
//                           //           decoration: BoxDecoration(
//                           //             color: Colors.black.withOpacity(0.5),
//                           //             borderRadius: BorderRadius.circular(8),
//                           //           ),
//                           //           child: Icon(
//                           //             _isPlaying
//                           //                 ? Icons.pause
//                           //                 : Icons.play_arrow,
//                           //             color: Colors.white,
//                           //           ),
//                           //         ),
//                           //       ),
//                           //       const SizedBox(
//                           //           height: 10), // Space between buttons

//                           //       // Views count button
//                           //       GestureDetector(
//                           //         onTap: () {
//                           //           // Optionally add any action on view count tap
//                           //         },
//                           //         child: Container(
//                           //           padding: const EdgeInsets.all(8),
//                           //           decoration: BoxDecoration(
//                           //             color: Colors.black.withOpacity(0.5),
//                           //             borderRadius: BorderRadius.circular(8),
//                           //           ),
//                           //           child: Text(
//                           //             formatViews(
//                           //                 12345), // Example: 12345 views
//                           //             style:
//                           //                 const TextStyle(color: Colors.white),
//                           //           ),
//                           //         ),
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     )
//                   : GestureDetector(
//                       onTap:
//                           _retryVideoLoading, // Retry loading if video fails to initialize
//                       child: const CircularProgressIndicator(),
//                     ),
//         ),
//       ),
//     );
//   }

//   String formatViews(int count) {
//     if (count >= 1000000) {
//       return '${(count / 1000000).toStringAsFixed(1)}M'; // Example: 1.2M
//     } else if (count >= 1000) {
//       return '${(count / 1000).toStringAsFixed(1)}k'; // Example: 12.3k
//     } else {
//       return count.toString(); // Show the count as-is if less than 1000
//     }
//   }

//   // Function to submit the report
//   Future<void> _submitReport() async {
//     // Here you can implement the logic to send the report to your server or database.
//     // For now, we are just printing the report information to the console.

//     // String reportDetails = 'Reasons: ${selectedReasons.join(', ')}';

//     // if (selectedReasons.contains('Others')) {
//     //   reportDetails += '\nCustom Reason: ${otherController.text}';
//     // }

//     // Format the reasons list as a string in the form of a JSON array
//     String reasonsJson = jsonEncode(
//         selectedReasons); // Converts list to a string like '["good", "bad"]'

//     // Get the description from the text field
//     String description = otherController.text.isEmpty
//         ? "No additional description"
//         : otherController.text;

//     try {
//       // Create an instance of ReportRepository to handle the API call
//       await _displayDailyClipRepository.submitReport(
//           videoID, selectedReasons, description);

//       // Reset the form after successful submission
//       setState(() {
//         selectedReasons.clear();
//         otherController.clear();
//       });

//       // Show confirmation message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Report submitted successfully.')),
//       );
//     } catch (e) {
//       // Handle errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting report: $e')),
//       );
//     }
//     // // Print the report details (you would replace this with actual report submission logic)
//     // print('Report Submitted: $reasonsJson');

//     // // Reset the form after submission
//     // setState(() {
//     //   selectedReasons.clear();
//     //   otherController.clear();
//     // });

//     // // Optionally, you can show a confirmation message to the user
//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   const SnackBar(content: Text('Report submitted successfully.')),
//     // );
//   }
// }

// // User can selecte the multiple chips


// // Users should be able to choose the reasons such as Nudity, Abusive Content, Sexual References, Others(Text box) for reporting the clip as inappropriate.
// // The user should be able to submit the report anonymously.