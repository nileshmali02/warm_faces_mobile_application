import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:warm_faces/features/profile_page/models/video_clips_model.dart';
import 'package:warm_faces/features/profile_page/repositories/video_clips_repository.dart';
import 'package:warm_faces/features/profile_page/widgets/full_screen_video_player.dart';

class ProfileClipsScreen extends StatefulWidget {
  final VideoClipStatus status;
  // final VoidCallback? onClipDeleted; // Add the callback
  final ValueChanged<bool>? onClipDeleted; // Change to ValueChanged<bool>

  const ProfileClipsScreen(
      {super.key, required this.status, this.onClipDeleted});

  @override
  State<ProfileClipsScreen> createState() => _ProfileClipsScreenState();
}

class _ProfileClipsScreenState extends State<ProfileClipsScreen> {
  // final List<String> videoUrls = [
  //   'assets/videos/7sec.mp4',
  //   'assets/videos/1min.mp4',
  //   'assets/videos/7sec.mp4',
  //   'assets/videos/1min.mp4',
  // ];
  late Future<List<VideoClipsModel>> clips;

  @override
  void initState() {
    super.initState();
    clips = VideoClipRepository().fetchClipsByStatus(context, widget.status);
  }

  // Refresh the video list when returning from the FullScreenVideoPlayer
  void _refreshClips() {
    setState(() {
      clips = VideoClipRepository().fetchClipsByStatus(context, widget.status);
    });
  }
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 1,
//       ),
//       itemCount: videoUrls.length,
//       itemBuilder: (context, index) {
//         return VideoItem(videoUrl: videoUrls[index]);
//       },
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoClipsModel>>(
      future: clips,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Center(child: CircularProgressIndicator());
          return Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!, // Light color
              highlightColor: Colors.grey[100]!, // Darker color
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount:
                    6, // You can set a fixed count for shimmer placeholder
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          color: Colors.grey[300], // Placeholder shimmer color
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No clips available.'));
        }

        final videoClips = snapshot.data!;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
          ),
          itemCount: videoClips.length,
          itemBuilder: (context, index) {
            return VideoItem(
              videoClip: videoClips[index],
              refreshClips: _refreshClips,
              onClipDeleted: widget.onClipDeleted, // Pass the callback here
            );
          },
        );
      },
    );
  }
}

class VideoItem extends StatelessWidget {
  // final String videoUrl;
  final VideoClipsModel videoClip;
  final VoidCallback refreshClips; // Add the callback
  // final VoidCallback? onClipDeleted;
  final ValueChanged<bool>? onClipDeleted; // Change to ValueChanged<bool>

  const VideoItem({
    super.key,
    required this.videoClip,
    required this.refreshClips,
    this.onClipDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (context) => FullScreenVideoPlayer(videoUrl: videoUrl),
        //   ),
        // );
        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (context) => FullScreenVideoPlayer(
        //         videoUrl: videoClip.url), // use videoClip.url
        //   ),
        // );
        bool? deleted = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => FullScreenVideoPlayer(
              videoUrl: videoClip.url,
              videoId: videoClip.id,
            ),
          ),
        );

        // if (deleted == true) {
        //   // If the video was deleted, call the refreshClips callback
        //   refreshClips();
        // }
        if (deleted == true) {
          // If the video was deleted, call the callback with true
          if (onClipDeleted != null) {
            onClipDeleted!(
                true); // Pass 'true' to indicate that a clip was deleted
          }
          refreshClips();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          // color: Colors.black,
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          // child: VideoPlayerPlaceholder(videoUrl: videoUrl),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(8.0), // Apply border radius here
            child: VideoPlayerPlaceholder(
                videoUrl: videoClip.url), // Remove AspectRatio
          ),
        ),
      ),
    );
  }
}

class VideoPlayerPlaceholder extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPlaceholder({super.key, required this.videoUrl});

  @override
  _VideoPlayerPlaceholderState createState() => _VideoPlayerPlaceholderState();
}

class _VideoPlayerPlaceholderState extends State<VideoPlayerPlaceholder> {
  late VideoPlayerController _controller;
  bool _isError = false;
  bool _isLoading = true; // Track loading state
  @override
  void initState() {
    super.initState();

    // Check if the video URL is a network URL or a local asset
    if (widget.videoUrl.startsWith('http://') ||
        widget.videoUrl.startsWith('https://')) {
      // Use network controller for remote videos
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      // Use asset controller for local assets
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }

    // Initialize the controller
    _controller.initialize().then((_) {
      setState(() {
        _isLoading = false; // Video is ready
      });
    }).catchError((error) {
      setState(() {
        _isError = true;
      });
      print("Error initializing video: $error");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Center(child: Text('Failed to load video.'));
    }

    // Show a loading indicator while the video is initializing
    // if (!_controller.value.isInitialized) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    // While video is still loading, show shimmer
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.grey[300],
        ),
      );
    }
    return VideoPlayer(_controller);
  }
}
