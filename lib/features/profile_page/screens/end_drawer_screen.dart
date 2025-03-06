import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warm_faces/features/authentication/repositories/logout_repository.dart';
import 'package:warm_faces/features/profile_page/screens/edit_profile_screen.dart';
import 'package:warm_faces/features/profile_page/screens/instruction_screen_profile.dart';
import 'package:warm_faces/utils/constant/colors.dart';

class EndDrawerScreen extends StatefulWidget {
  const EndDrawerScreen({super.key});

  @override
  State<EndDrawerScreen> createState() => _EndDrawerScreenState();
}

class _EndDrawerScreenState extends State<EndDrawerScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> logout() async {
    // Assuming you have an instance of AuthRepository
    LogoutRepository().logout(context);
//     final prefs = await SharedPreferences.getInstance();

//     // Remove specific values
//     await prefs.remove('isLoggedIn'); // Remove the login status
//     // await prefs
//     //     .remove('registeredEmails'); // Remove any other specific keys if needed

//     await prefs.remove('dontShowAgain');
//     await prefs.remove('isFirstLaunch');

// // Clear all data from secure storage
//     await storage.deleteAll();

//     // Navigate to the Splash Screen
//     Navigator.pushReplacement(
//       context,
//       CupertinoPageRoute(
//         builder: (context) => const SplashScreen(),
//       ),
//     );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/Home Screen Background.png', // Your background image
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.medium,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Your Profile'),
          centerTitle: false,
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/icon_Pencil.png',
                    color: const Color(0xFF6A6A6A),
                    height: 25,
                    width: 25,
                  ),
                  title: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ));
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: const Icon(
                    Iconsax.info_circle,
                    color: Color(0xFF6A6A6A),
                  ),
                  title: const Text(
                    'Instructions',
                    style: TextStyle(
                      color: blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              const InstructionScreenProfile(),
                        ));
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/icon_Logout.png',
                    color: const Color(0xFF6A6A6A),
                    height: 25,
                    width: 25,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: blackColor,
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context), // Show dialog on tap
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                // Add your logout logic here
                // Navigator.of(context).pop(); // Close the dialog
                // For example, navigate to login screen or remove user data
                logout();
              },
              isDefaultAction: true,
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
