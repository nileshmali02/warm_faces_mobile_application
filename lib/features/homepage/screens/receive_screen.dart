// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:warm_faces/features/authentication/repositories/logout_repository.dart';
// import 'package:warm_faces/features/homepage/models/display_daily_clip_model.dart';
// import 'package:warm_faces/features/homepage/repositories/display_daily_clip_repository.dart';
// import 'package:warm_faces/features/homepage/screens/after_rating_screen.dart';
// import 'package:warm_faces/features/homepage/screens/before_rating_screen.dart';
// import 'package:warm_faces/features/homepage/screens/recived_videoplay_screen.dart';

// class ReceiveScreen extends StatefulWidget {
//   const ReceiveScreen({super.key});

//   @override
//   State<ReceiveScreen> createState() => _ReceiveScreenState();
// }

// class _ReceiveScreenState extends State<ReceiveScreen> {
//   String videoUrl = '';
//   String videoID = '';
//   bool isLoading = true;

//   final DisplayDailyClipRepository _displayDailyClipRepository =
//       DisplayDailyClipRepository();

//   @override
//   void initState() {
//     super.initState();
//     _fetchVideoDetails(); // Fetch video data asynchronously
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
//         // videoID = "video8";
//         isLoading = false;
//       });

//       // // Preload the video immediately after fetching the URL
//       _initializeVideoPlayer(); // Start buffering as soon as the URL is received

//       // Count the view whenever the user visits the screen (or re-enters the home screen)
//       await _incrementViewCount(videoID);
//       // _initializeVideoPlayer(); // Initialize video player with fetched URL
//       handleVideoPlayWithRatingCheck(
//           videoID); // Check if the video requires a rating before playing
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });

//       // Directly use the error message without prefix
//       String errorMessage;
//       if (e is Exception) {
//         errorMessage = e
//             .toString()
//             .replaceFirst('Exception: ', ''); // Remove the "Exception: " prefix
//       } else {
//         errorMessage =
//             'An unknown error occurred. Please try again.'; // Fallback for other errors
//       }

//       if ("Invalid or expired token" == "Invalid or expired token") {
//         LogoutRepository().deActiveUser(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }

//       print("Error fetching video details: $e");
//     }
//   }

//   // Variables to store rating status
//   bool beforeRatingStatus = false; // Track if before rating is submitted
//   bool afterRatingStatus = false; // Track if after rating is submitted

//   @override
//   Widget build(BuildContext context) {
//     // Logic to determine which screen to display
//     if (!beforeRatingStatus) {
//       // If beforeRatingStatus is false, show BeforeRatingScreen
//       return BeforeRatingScreen(
//         onRatingSubmitted: () {
//           setState(() {
//             beforeRatingStatus = true; // After rating, set status to true
//           });
//         },
//       );
//     } else if (beforeRatingStatus && !afterRatingStatus) {
//       // If beforeRatingStatus is true, show RecivedVideoPlayScreen
//       return RecivedVideoPlayScreen(
//         onVideoPlayComplete: () {
//           setState(() {
//             afterRatingStatus = false; // Logic for after video play
//           });
//         },
//       );
//     } else {
//       // If beforeRatingStatus is true and afterRatingStatus is false, show AfterRatingScreen
//       return AfterRatingScreen(
//         onRatingCompleted: () {
//           setState(() {
//             afterRatingStatus = true; // Set after rating status to true
//           });
//         },
//       );
//     }
//   }
// }
