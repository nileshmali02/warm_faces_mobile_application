// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:warm_faces/features/Instructions/screens/instruction_screen.dart';
// import 'package:warm_faces/features/Instructions/screens/splash_screen.dart';

// import 'package:warm_faces/features/authentication/screens/signup_screen.dart';
// import 'package:warm_faces/features/comman/bottom_navbar.dart';
// import 'package:warm_faces/utils/themes/theme.dart';

// void main() {
//   runApp(const MyApp()); // Start the app by running MyApp widget
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo', // Title of the app
//       // theme: CupertinoThemeData(
//       //   brightness: Brightness.light, // Light theme for the app
//       // ),
//       theme: lightMode,
//       home: const SplashScreen(), // Initial screen of the app
//       // Uncomment the following code to check first launch
//       // home: FutureBuilder<bool>(
//       //   future: _checkFirstLaunch(),
//       //   builder: (context, snapshot) {
//       //     if (snapshot.connectionState == ConnectionState.waiting) {
//       //       // Show a loading indicator while checking
//       //       return const Center(child: CircularProgressIndicator());
//       //     } else {
//       //       // Navigate to InstructionScreen or SplashScreen based on the result
//       //       return snapshot.data == true
//       //           ? const InstructionScreen()
//       //           : const SplashScreen();
//       //     }
//       //   },
//       // ),
//     );
//   }

//   // Future<bool> _checkFirstLaunch() async {
//   //   // This function checks if it's the user's first launch
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
//   //   // Return true if it's the first launch or if the value is null
//   //   return isFirstLaunch == null || isFirstLaunch;
//   // }

//   // Alternative check for first launch
//   // static Future<bool> _checkFirstLaunch() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
//   //   if (isFirstLaunch == null) {
//   //     // If no value is set, mark it as first launch
//   //     prefs.setBool('isFirstLaunch', false);
//   //     return true; // Show onboarding
//   //   }
//   //   return false; // Not first launch, skip onboarding
//   // }
// }
