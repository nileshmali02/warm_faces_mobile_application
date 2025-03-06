import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warm_faces/features/Instructions/screens/splash_screen.dart';
import 'package:warm_faces/features/comman/bottom_navbar.dart';
import 'package:warm_faces/utils/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    runApp(MyApp(
      isLoggedIn: isLoggedIn,
    )); // Start the app by running MyApp widget
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warm Faces', // Title of the app
      theme: lightMode, // Set the Light Theme

      home: isLoggedIn
          ? const BottomNavbar()
          : const SplashScreen(), // Initial screen of the app
    );
  }
}
