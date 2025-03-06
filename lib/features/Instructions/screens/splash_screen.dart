import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warm_faces/features/Instructions/screens/instruction_screen.dart';
import 'package:warm_faces/features/authentication/screens/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    clearCache(); // Clear cache every time the app starts
    _navigateToNextScreen(); // Start navigation after the splash screen
  }

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
    print("Cache cleared on app startup.");
  }

  // Method to navigate to the appropriate screen
  Future<void> _navigateToNextScreen() async {
    // Wait for 3 seconds to display the splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Check if this is the user's first launch
    bool isFirstLaunch = await _checkFirstLaunch();

    // Navigate to InstructionScreen or SigninScreen based on the first launch
    Navigator.pushReplacement(context, CupertinoPageRoute(
      builder: (context) {
        return isFirstLaunch ? const InstructionScreen() : const SigninScreen();
      },
    ));
  }

  // Check if it's the user's first launch and update preferences
  static Future<bool> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch == null) {
      // First launch: set the flag and return true to show onboarding
      prefs.setBool('isFirstLaunch', false);
      return true;
    }
    // Not the first launch: return false to skip onboarding
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Image.asset(
              'assets/images/splash_screen_bg.png', // Your background image
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Apply blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 20px blur
              child: Container(
                color: Colors.white
                    .withOpacity(0.1), // Optional: add color overlay
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: Image.asset(
                'assets/images/splash_screen_logo.png', // Logo displayed on the splash screen
                fit: BoxFit.cover,
                width: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
