import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warm_faces/features/Instructions/screens/splash_screen.dart';
import 'package:warm_faces/utils/http/api.dart';

class LogoutRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  // Base URL for the API. Replace with your actual API URL.
  final String _baseUrl = HttpConfig.baseUrl;
  Future<void> logout(BuildContext context) async {
    try {
      // Get the current token
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User is not logged in');
      }

      // Make the API call to log out the user
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/logout'), // Replace with your actual logout API endpoint
        headers: {
          'Authorization':
              'Bearer $token', // Include the token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        // If the API call was successful, clear the shared preferences and secure storage
        final prefs = await SharedPreferences.getInstance();

        // // Remove specific values from SharedPreferences
        await prefs.remove('isLoggedIn');
        // await prefs.remove('dontShowAgain');
        // await prefs.remove('isFirstLaunch');

        // // Clear all the data from SharedPreferences
        // await prefs.clear();
        // Clear all data from secure storage
        await storage.deleteAll();

        // Navigate to the Splash Screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const SplashScreen(),
          ),
        );
      } else {
        throw Exception('Failed to log out: ${response.body}');
      }
    } catch (e) {
      print('Error during logout: $e');
      // Handle any errors here, such as showing a message to the user
      // Optionally, navigate to the splash screen even if logout fails
      // Navigator.pushReplacement(
      //   context,
      //   CupertinoPageRoute(
      //     builder: (context) => const SplashScreen(),
      //   ),
      // );
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> deActiveUser(BuildContext context) async {
    try {
      // If the API call was successful, clear the shared preferences and secure storage
      final prefs = await SharedPreferences.getInstance();

      // // Remove specific values from SharedPreferences
      await prefs.remove('isLoggedIn');
      // await prefs.remove('dontShowAgain');
      // await prefs.remove('isFirstLaunch');

      // // Clear all the data from SharedPreferences
      // await prefs.clear();
      // Clear all data from secure storage
      await storage.deleteAll();

      // Navigate to the Splash Screen
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => const SplashScreen(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account has been deactivated')),
      );
    } catch (e) {
      print('Error during logout: $e');
      // Handle any errors here, such as showing a message to the user
      // Optionally, navigate to the splash screen even if logout fails
      // Navigator.pushReplacement(
      //   context,
      //   CupertinoPageRoute(
      //     builder: (context) => const SplashScreen(),
      //   ),
      // );
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      rethrow;
    }
  }
}
