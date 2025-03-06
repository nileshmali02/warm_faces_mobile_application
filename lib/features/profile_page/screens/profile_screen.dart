import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warm_faces/features/profile_page/repositories/video_clips_repository.dart';
import 'package:warm_faces/features/profile_page/screens/end_drawer_screen.dart';
import 'package:warm_faces/features/profile_page/widgets/profile_clips_screen.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/constant/sized.dart';
import 'package:warm_faces/utils/widgets/c_sizebox.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  int liveCount = 0;
  int underReviewCount = 0;
  int rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _loadClipCounts();
  }

  Future<void> _loadUserData() async {
    String? storedName = await storage.read(key: 'name') ?? '';
    String? storedEmail = await storage.read(key: 'email') ?? '';
    setState(() {
      userName = storedName;
      userEmail = storedEmail;
    });
  }

  Future<void> _loadClipCounts() async {
    // Fetch the clip counts for each status (Live, Pending, Rejected)
    try {
      int liveCounts = await VideoClipRepository()
          .fetchClipCountByStatus(VideoClipStatus.accepted);
      int underReviewCounts = await VideoClipRepository()
          .fetchClipCountByStatus(VideoClipStatus.pending);
      int rejectedCounts = await VideoClipRepository()
          .fetchClipCountByStatus(VideoClipStatus.rejected);
      setState(() {
        liveCount = liveCounts;
        underReviewCount = underReviewCounts;
        rejectedCount = rejectedCounts;
      }); // Ensure UI rebuild
    } catch (e) {
      print('Error fetching clip counts: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName ?? 'Guest',
                            style: const TextStyle(
                                fontSize: fontSizeHeader, color: blackColor),
                            overflow: TextOverflow.ellipsis),
                        Text(userEmail ?? 'No Email Provided',
                            style: const TextStyle(color: textFieldTextColor),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      var updatedProfile = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EndDrawerScreen()),
                      );
                      if (updatedProfile != null) {
                        _loadUserData();
                      }
                    },
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ],
              ),
              addVerticalSpace(30),
              // TabBar for status counts
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$liveCount',
                            style: const TextStyle(fontSize: 16)),
                        const Text('Live', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$underReviewCount',
                            style: const TextStyle(fontSize: 16)),
                        const Text('Pending', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$rejectedCount',
                            style: const TextStyle(fontSize: 16)),
                        const Text('Rejected', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelPadding: const EdgeInsets.only(bottom: 8),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
              addVerticalSpace(20),
              // TabBarView for the clips
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProfileClipsScreen(
                      status: VideoClipStatus.accepted,
                      onClipDeleted: (bool deleted) {
                        if (deleted) {
                          _loadClipCounts();
                        }
                      },
                    ),
                    ProfileClipsScreen(
                      status: VideoClipStatus.pending,
                      onClipDeleted: (bool deleted) {
                        if (deleted) {
                          _loadClipCounts();
                        }
                      },
                    ),
                    ProfileClipsScreen(
                      status: VideoClipStatus.rejected,
                      onClipDeleted: (bool deleted) {
                        if (deleted) {
                          _loadClipCounts();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
