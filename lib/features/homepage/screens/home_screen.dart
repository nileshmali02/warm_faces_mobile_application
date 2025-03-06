import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:warm_faces/features/authentication/repositories/logout_repository.dart';
import 'package:warm_faces/features/comman/bottom_navbar.dart';
import 'package:warm_faces/features/comman/welcome_screen.dart';
import 'package:warm_faces/features/homepage/models/display_daily_clip_model.dart';
import 'package:warm_faces/features/homepage/repositories/display_daily_clip_repository.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/constant/sized.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  String videoUrl = '';
  String videoID = '';
  bool isLoading = true;
  bool _isPlaying = true;
  bool _isBuffering = false; // Track buffering state
  int retryCount = 0; // Counter for retry attempts
  Timer? _videoTimer; // Timer to stop video after 12 seconds
  double selectedRating = 0.0; // Track the selected rating
  bool showRatingValidation = false; //show alert msg when rating not selected

  final DisplayDailyClipRepository _displayDailyClipRepository =
      DisplayDailyClipRepository();

  // Variables to store rating status
  bool beforeRatingStatus = false; // Track if before rating is submitted
  bool afterRatingStatus = false; // Track if after rating is submitted

  List<String> selectedReasons = []; // To store selected reasons
  TextEditingController otherController =
      TextEditingController(); // Text controller for "Others"

  // Predefined reasons for the report
  final List<String> predefinedReasons = [
    'Others',
    'Inappropriate Content',
    'Low Quality'
  ];
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(videoUrl);
    _loadCachedVideoUrl(); // Check if we have a cached video URL
    _fetchVideoDetails(); // Fetch video data asynchronously
  }

  // Try to load the video URL from local cache first
  Future<void> _loadCachedVideoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String cachedUrl = prefs.getString('videoUrl') ?? '';
    if (cachedUrl.isNotEmpty) {
      setState(() {
        videoUrl = cachedUrl;
        isLoading = false; // Video already cached, so not loading
      });
      _initializeVideoPlayer();
    }
  }

  // Fetch video URL and ID from API
  Future<void> _fetchVideoDetails() async {
    try {
      // Fetch video data from API
      DailyClipModel videoData =
          await _displayDailyClipRepository.fetchDailyClip();
      print("Called API");
      // Save the video URL to cache
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('videoUrl', videoData.url);

      setState(() {
        videoUrl = videoData.url;
        videoID = videoData.clipId;
        // videoID = "video8";
        isLoading = false;
      });

      // // Preload the video immediately after fetching the URL
      _initializeVideoPlayer(); // Start buffering as soon as the URL is received

      // Count the view whenever the user visits the screen (or re-enters the home screen)
      await _incrementViewCount(videoID);
      // _initializeVideoPlayer(); // Initialize video player with fetched URL
      handleVideoPlayWithRatingCheck(
          videoID); // Check if the video requires a rating before playing
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Directly use the error message without prefix
      String errorMessage;
      if (e is Exception) {
        errorMessage = e
            .toString()
            .replaceFirst('Exception: ', ''); // Remove the "Exception: " prefix
      } else {
        errorMessage =
            'An unknown error occurred. Please try again.'; // Fallback for other errors
      }

      if ("Invalid or expired token" == "Invalid or expired token") {
        LogoutRepository().deActiveUser(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }

      print("Error fetching video details: $e");
    }
  }

  // This function is responsible for incrementing the view count
  Future<void> _incrementViewCount(String videoId) async {
    try {
      await _displayDailyClipRepository.incrementViewCount(videoId);
      print("View count incremented for video: $videoId");
    } catch (e) {
      print("Error incrementing view count: $e");
    }
  }

  Future<void> handleVideoPlayWithRatingCheck(String videoId) async {
    try {
      // Pause the video and show the before rating dialog
      _pauseVideo();

      final ratingStatus = await _displayDailyClipRepository
          .checkBeforeAndAfterRatingStatus(videoId);

      setState(() {
        // Store the rating status in variables
        beforeRatingStatus = ratingStatus['beforeRating'] == true;
        // beforeRatingStatus = true;
        afterRatingStatus = ratingStatus['afterRating'] == true;
        // // Store the rating status in variables
        // beforeRatingStatus = false;
        // // beforeRatingStatus = true;
        // afterRatingStatus = false;
      });

      print("beforeRatingStatus $beforeRatingStatus");
      print("afterRatingStatus $afterRatingStatus");

      // // Increment view count here before playing
      // await _displayDailyClipRepository.incrementViewCount(videoId);

      // Handle the "beforeRating"
      if (beforeRatingStatus) {
        // If before rating is submitted, play the video directly
        await _initializeVideoPlayer();
        setState(() {
          _controller.play(); // Start playing automatically
          _isPlaying = true; // Video is playing
        });
        // _videoTimer =
        //     Timer(const Duration(seconds: 10), _stopVideoAfterTimeout);
      } else {
        // Show the before rating popup if not submitted
        await _showRatingBeforePopup();
      }
    } catch (e) {
      print("Error checking rating status: $e");
    }
  }

  // Initialize video player with the dynamic network URL
  Future<void> _initializeVideoPlayer() async {
    if (videoUrl.isNotEmpty) {
      // _controller = VideoPlayerController.network(videoUrl)
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          setState(() {});
          _controller.setLooping(true); // Enable looping
          _controller.play(); // Start playing automatically
          // _isPlaying = true; // Video is playing

          // code for stop video after 10 sce and navigate to home screen
          if (beforeRatingStatus == true && afterRatingStatus == true) {
            _videoTimer = Timer(const Duration(seconds: 10), () {
              _controller.pause();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavbar()),
              ); // New action
            });
          }
        })
        ..addListener(() {
          setState(() {
            // Detect buffering state
            _isBuffering = _controller.value.isBuffering;
          });
        })
        ..setVolume(1.0);

      // Attempt to preload the video to avoid buffering
      _controller.setVolume(1.0); // Ensure sound is enabled
    }
  }

  // Stop the video after 10 seconds and show the play button
  void _stopVideoAfterTimeout() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
      // // Show the rating dialog after 10 seconds of video
      // _showRatingAfterPopup();
      // Handle the "afterRating"
      if (afterRatingStatus == false) {
        // If after rating is not submitted, show the after rating popup after 10 seconds

        _videoTimer?.cancel();
        _showRatingAfterPopup();
        // _videoTimer = Timer(const Duration(seconds: 10), _showRatingAfterPopup);
      } else {
        // If after rating is already submitted, pause the video
        _controller.pause();
      }
    }
  }

  // Play the video when the play button is pressed
  void _playVideo() {
    if (!_isPlaying && _controller.value.isInitialized) {
      setState(() {
        _controller.play();
        _isPlaying = true;
      });
      // // Increment the view count when the user presses play
      // _displayDailyClipRepository.incrementViewCount(videoID);
      // Restart the timer to stop the video after 10 seconds
      _videoTimer?.cancel();
      // _videoTimer = Timer(const Duration(seconds: 10), _stopVideoAfterTimeout);
    }
  }

  // Pause the video when clicked anywhere on the screen
  void _pauseVideo() {
    if (_isPlaying && _controller.value.isInitialized) {
      setState(() {
        _controller.pause();
        _isPlaying = false;
      });

      _videoTimer?.cancel(); // Cancel the timer when video is paused
    }
  }

  // Retry logic in case of video load failure
  Future<void> _retryVideoLoading() async {
    if (retryCount < 3) {
      setState(() {
        isLoading = true;
        retryCount++;
      });
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Wait for a bit before retrying
      _fetchVideoDetails(); // Retry fetching the video details
    } else {
      // Show some error message after 3 retry attempts
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to load video. Please try again later.")),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    _videoTimer?.cancel(); // Cancel the timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator() // Show loading spinner while waiting
              : _controller.value.isInitialized
                  ? GestureDetector(
                      onTap: () {
                        // Pause the video on tap anywhere if playing
                        if (_isPlaying) {
                          _pauseVideo();
                        } else {
                          _playVideo();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                          // Show buffering indicator
                          if (_isBuffering)
                            const Positioned(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          // if (!_isPlaying) // Only show play button when paused
                          //   Positioned(
                          //     child: GestureDetector(
                          //       onTap: _playVideo,
                          //       child: Container(
                          //         padding: const EdgeInsets.all(8),
                          //         decoration: BoxDecoration(
                          //           color: const Color(0xFFD9D9D9)
                          //               .withOpacity(0.5),
                          //           borderRadius: BorderRadius.circular(50),
                          //         ),
                          //         child: Icon(
                          //           Icons.play_arrow,
                          //           color: Colors.grey.withOpacity(0.9),
                          //           size: 50,
                          //         ),
                          //       ),
                          //     ),
                          //   ),

                          Positioned(
                            top: 0,
                            left:
                                0, // Ensure the Positioned widget starts from the left edge
                            right:
                                0, // Ensure the Positioned widget takes full width
                            child: Container(
                              color: Colors.black
                                  .withOpacity(0.4), // Semi-transparent overlay
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Row(
                                children: [
                                  // Left-aligned Column
                                  Visibility(
                                    visible: afterRatingStatus == true,
                                    child: IconButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BottomNavbar()), // Replace with your home page widget
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: whiteColor,
                                          size: 25,
                                        )),
                                  ),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Warm Faces',
                                          style: TextStyle(
                                            color: whiteColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          'For You',
                                          style: TextStyle(
                                            color: whiteColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right-aligned GestureDetector
                                  GestureDetector(
                                    onTap:
                                        _showReportPopup, // Open the report popup on tap
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: whiteColor,
                                        ),
                                        Text(
                                          'Report',
                                          style: TextStyle(
                                            color: whiteColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )

                          // const Positioned(
                          //   top: 10,
                          //   left: 20,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         'Warm Faces',
                          //         style: TextStyle(
                          //           color: whiteColor,
                          //           fontWeight: FontWeight.w800,
                          //           fontSize: 18,
                          //         ),
                          //       ),
                          //       Text(
                          //         'For You',
                          //         style: TextStyle(
                          //           color: whiteColor,
                          //           fontWeight: FontWeight.w500,
                          //           fontSize: 14,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Positioned(
                          //   top: 10,
                          //   right: 20,
                          //   child: GestureDetector(
                          //     onTap:
                          //         _showReportPopup, // Open the report popup on tap
                          //     child: const Column(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: [
                          //         Icon(
                          //           Icons.info_outline,
                          //           color: greyColor,
                          //         ),
                          //         Text(
                          //           'Report',
                          //           style: TextStyle(
                          //             color: whiteColor,
                          //             fontWeight: FontWeight.w500,
                          //             fontSize: 14,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // // Positioning the buttons and view count vertically on the bottom-right
                          // Positioned(
                          //   bottom: 20,
                          //   right: 20,
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       // Button 1 (Play/Pause)
                          //       GestureDetector(
                          //         onTap: _isPlaying ? _pauseVideo : _playVideo,
                          //         child: Container(
                          //           padding: const EdgeInsets.all(8),
                          //           decoration: BoxDecoration(
                          //             color: Colors.black.withOpacity(0.5),
                          //             borderRadius: BorderRadius.circular(8),
                          //           ),
                          //           child: Icon(
                          //             _isPlaying
                          //                 ? Icons.pause
                          //                 : Icons.play_arrow,
                          //             color: Colors.white,
                          //           ),
                          //         ),
                          //       ),
                          //       const SizedBox(
                          //           height: 10), // Space between buttons
                          //       // Views count button
                          //       GestureDetector(
                          //         onTap: () {
                          //           // Optionally add any action on view count tap
                          //         },
                          //         child: Container(
                          //           padding: const EdgeInsets.all(8),
                          //           decoration: BoxDecoration(
                          //             color: Colors.black.withOpacity(0.5),
                          //             borderRadius: BorderRadius.circular(8),
                          //           ),
                          //           child: Text(
                          //             formatViews(
                          //                 12345), // Example: 12345 views
                          //             style:
                          //                 const TextStyle(color: Colors.white),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap:
                          _retryVideoLoading, // Retry loading if video fails to initialize
                      child: const CircularProgressIndicator(),
                    ),
        ),
      ),
    );
  }

  Future<void> _showRatingBeforePopup() async {
    print("Opening rating dialog");
    showDialog(
      context: context,
      barrierDismissible:
          false, // Disable closing the dialog by tapping outside
      builder: (BuildContext context) {
        // Using StatefulBuilder to update the dialog content dynamically
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/splash_screen_bg.png', // Your background image
                    fit: BoxFit.cover, // Make the image cover the entire screen
                  ),
                ),
                Center(
                  child: Dialog(
                    backgroundColor:
                        Colors.white, // Set the background color to white
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'How are you today?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSizeHeader,
                                fontWeight: FontWeight.w400,
                                //color: color, // Use the dynamic color
                              ),
                            ),
                            const SizedBox(
                                height:
                                    30), // Add space between rating and image
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ratingOption(
                                  1.0,
                                  'Awful',
                                  'assets/icons/ratingicons/awful.png',
                                  setStateDialog,
                                  color: selectedRating == 1.0
                                      ? const Color(0xFF3963C1)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  2.0,
                                  'Bad',
                                  'assets/icons/ratingicons/bad.png',
                                  setStateDialog,
                                  color: selectedRating == 2.0
                                      ? const Color(0xFF4E8EC6)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  3.0,
                                  'Okay',
                                  'assets/icons/ratingicons/okay.png',
                                  setStateDialog,
                                  color: selectedRating == 3.0
                                      ? const Color(0xFFF3B144)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  4.0,
                                  'Good',
                                  'assets/icons/ratingicons/good.png',
                                  setStateDialog,
                                  color: selectedRating == 4.0
                                      ? const Color(0xFF6CB16E)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  5.0,
                                  'Great',
                                  'assets/icons/ratingicons/great.png',
                                  setStateDialog,
                                  color: selectedRating == 5.0
                                      ? const Color(0xFF397F55)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Visibility(
                            //   visible: showRatingValidation == true,
                            //   child: const Text(
                            //     "Please select a rating",
                            //     style: TextStyle(
                            //         fontSize: fontSizeNormal,
                            //         color: Colors.red),
                            //   ),
                            // ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CupertinoButton(
                                onPressed: () async {
                                  // Check if a rating has been selected before proceeding
                                  if (selectedRating == 0.0) {
                                    // Ensure the user selects a rating before proceeding
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Please select a rating')),
                                    );

                                    return;
                                  }
                                  Navigator.of(context)
                                      .pop(); // Close the dialog

                                  // Submit the before rating (assuming videoID holds the clip ID)
                                  await _displayDailyClipRepository
                                      .submitRating(
                                    videoID, // clipId
                                    'before', // ratingType
                                    _getRatingText(selectedRating), // rating
                                  );
                                  print(
                                      "Submit Before Rating: $selectedRating  - ${_getRatingText(selectedRating)}");

                                  // _controller.play(); // Start the video after rating
                                  // // Restart the timer to stop the video after 12 seconds
                                  // _videoTimer?.cancel();
                                  // _videoTimer = Timer(
                                  //     const Duration(seconds: 12), _stopVideoAfterTimeout);
                                  // // setState(() {});
                                  // Now play the video after rating submission
                                  // await _initializeVideoPlayer();
                                  setState(() {
                                    selectedRating = 0.0;
                                    _controller
                                        .play(); // Start playing automatically
                                    _isPlaying = true; // Video is playing
                                    //showRatingValidation = false;
                                  });
                                  _videoTimer = Timer(
                                      const Duration(seconds: 10),
                                      _stopVideoAfterTimeout);
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showRatingAfterPopup() async {
    print("Opening rating dialog after video");
    showDialog(
      context: context,
      barrierDismissible:
          false, // Disable closing the dialog by tapping outside
      builder: (BuildContext context) {
        // Using StatefulBuilder to update the dialog content dynamically
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/splash_screen_bg.png', // Your background image
                    fit: BoxFit.cover, // Make the image cover the entire screen
                  ),
                ),
                Center(
                  child: Dialog(
                    backgroundColor:
                        Colors.white, // Set the background color to white
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25.0, horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'How are you feeling now?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSizeHeader,
                                fontWeight: FontWeight.w400,
                                //color: color, // Use the dynamic color
                              ),
                            ),
                            const SizedBox(
                                height:
                                    30), // Add space between rating and image
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ratingOption(
                                  1.0,
                                  'Awful',
                                  'assets/icons/ratingicons/awful.png',
                                  setStateDialog,
                                  color: selectedRating == 1.0
                                      ? const Color(0xFF3963C1)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  2.0,
                                  'Bad',
                                  'assets/icons/ratingicons/bad.png',
                                  setStateDialog,
                                  color: selectedRating == 2.0
                                      ? const Color(0xFF4E8EC6)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  3.0,
                                  'Okay',
                                  'assets/icons/ratingicons/okay.png',
                                  setStateDialog,
                                  color: selectedRating == 3.0
                                      ? const Color(0xFFF3B144)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  4.0,
                                  'Good',
                                  'assets/icons/ratingicons/good.png',
                                  setStateDialog,
                                  color: selectedRating == 4.0
                                      ? const Color(0xFF6CB16E)
                                      : Colors.black.withOpacity(0.7),
                                ),
                                _ratingOption(
                                  5.0,
                                  'Great',
                                  'assets/icons/ratingicons/great.png',
                                  setStateDialog,
                                  color: selectedRating == 5.0
                                      ? const Color(0xFF397F55)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Visibility(
                            //   visible: selectedRating == 0.0,
                            //   child: const Text(
                            //     "Please Select Rating",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CupertinoButton(
                                onPressed: () async {
                                  // Optionally handle any actions for the rating
                                  _pauseVideo();

                                  // Check if a rating has been selected before proceeding
                                  if (selectedRating == 0.0) {
                                    // Ensure the user selects a rating before proceeding
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Please select a rating')),
                                    );
                                    return;
                                  }
                                  // Check if the video requires a rating before playing
                                  // Navigator.of(context)
                                  //     .pop(); // Close the dialog

                                  // print("Submit Rating After Watching: $selectedRating");
                                  // Submit the before rating (assuming videoID holds the clip ID)
                                  await _displayDailyClipRepository
                                      .submitRating(
                                    videoID, // clipId
                                    'after', // ratingType
                                    _getRatingText(selectedRating), // rating
                                  );
                                  await handleVideoPlayWithRatingCheck(videoID);
                                  print(
                                      "Submit Rating After Watching: $selectedRating  - ${_getRatingText(selectedRating)}");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BottomNavbar()), // Replace with your home page widget
                                  );
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Helper method to convert rating number to text
  String _getRatingText(double rating) {
    switch (rating) {
      case 1.0:
        return 'Awful';
      case 2.0:
        return 'Bad';
      case 3.0:
        return 'Okay';
      case 4.0:
        return 'Good';
      case 5.0:
        return 'Great';
      default:
        return '';
    }
  }

// Widget to create each rating option with custom image
  Widget _ratingOption(
      double value, String label, String imagePath, StateSetter setStateDialog,
      {required Color color}) {
    bool isSelected =
        selectedRating == value; // Check if this option is selected

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRating = value; // Update the selected rating
        });
        setStateDialog(() {}); // Ensure the dialog rebuilds after selecting
        print(
            "Selected Rating: $selectedRating"); // Debugging line to check if it's updating correctly
      },
      child: Column(
        children: [
          // Custom border to highlight the selected icon
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 3,
                color: isSelected
                    ? color
                    : Colors.transparent, // Change color if selected
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset(
              imagePath, // Custom image for the rating
              width: 40.0, // Adjust size as needed
              height: 40.0, // Adjust size as needed
            ),
          ),
          const SizedBox(height: 5), // Adding space between icon and label
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color, // Use the dynamic color
            ),
          ),
        ],
      ),
    );
  }

  String formatViews(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M'; // Example: 1.2M
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k'; // Example: 12.3k
    } else {
      return count.toString(); // Show the count as-is if less than 1000
    }
  }

  Future<void> _showReportPopup() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // isDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return SingleChildScrollView(
              // Wrap the content inside SingleChildScrollView
              child: GestureDetector(
                onTap: () {
                  // Dismiss keyboard when tapping outside of the text field
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    height: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Why are you reporting \nthis video?',
                          style: TextStyle(
                            fontSize: fontSizeExtraLarge,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                            'Please select the reason(s) for reporting:'),
                        const SizedBox(height: 10),
                        // Display reasons as selectable chips
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: predefinedReasons.map((reason) {
                            return FilterChip(
                              label: Text(reason),
                              selected: selectedReasons.contains(reason),
                              onSelected: (isSelected) {
                                setStateDialog(() {
                                  if (isSelected) {
                                    selectedReasons.add(reason);
                                  } else {
                                    selectedReasons.remove(reason);
                                  }
                                });
                              },
                              selectedColor: primaryColor,
                              backgroundColor: Colors.transparent,
                              labelStyle: TextStyle(
                                color: selectedReasons.contains(reason)
                                    ? Colors.black
                                    : Colors.black,
                              ),
                              shadowColor: Colors.black,
                            );
                          }).toList(),
                        ),
                        if (selectedReasons.contains('Others')) ...[
                          const SizedBox(height: 10),
                          const Text('Please specify other reason:'),
                          CupertinoTextField(
                            controller: otherController,
                            placeholder: 'Enter your reason...',
                          ),
                        ],
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoTextField(
                            controller: otherController,
                            placeholder: 'Write details',
                            maxLines: 4,
                            minLines: 4,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            textAlignVertical: TextAlignVertical.top,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CupertinoButton(
                            onPressed: () {
                              _submitReport();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to submit the report
  Future<void> _submitReport() async {
    // Check if the user has selected at least one reason or provided a description
    if (selectedReasons.isEmpty && otherController.text.isEmpty) {
      // Show an error message if neither reason nor description is provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a reason or provide a description.')),
      );
      return; // Exit the method to prevent the report from being submitted
    }
    // Here you can implement the logic to send the report to your server or database.
    // For now, we are just printing the report information to the console.

    // String reportDetails = 'Reasons: ${selectedReasons.join(', ')}';

    // if (selectedReasons.contains('Others')) {
    //   reportDetails += '\nCustom Reason: ${otherController.text}';
    // }

    // Format the reasons list as a string in the form of a JSON array
    String reasonsJson = jsonEncode(
        selectedReasons); // Converts list to a string like '["good", "bad"]'

    // Get the description from the text field
    String description = otherController.text.isEmpty
        ? "No additional description"
        : otherController.text;

    try {
      // Create an instance of ReportRepository to handle the API call
      await _displayDailyClipRepository.submitReport(
          videoID, selectedReasons, description);

      // Reset the form after successful submission
      setState(() {
        selectedReasons.clear();
        otherController.clear();
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully.')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
    }
  }
}
