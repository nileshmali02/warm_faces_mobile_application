// lib/features/authentication/repositories/signup_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warm_faces/features/authentication/repositories/logout_repository.dart';
import 'package:warm_faces/features/profile_page/models/edit_profile_model.dart';
import 'package:warm_faces/utils/http/api.dart';

/// This class handles user Edit Profile operations.
/// It contains the logic to communicate with the API and handle errors.
class EditProfileRepository {
  final storage = const FlutterSecureStorage();

  // Function to retrieve the token for API requests
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Base URL for the API. Replace with your actual API URL.
  final String _baseUrl = HttpConfig.baseUrl;

  /// Function to handle editing the profile.
  /// This makes a PUT request to the server with the provided profile data.
  Future<bool> editProfile(
      BuildContext context, EditProfileModel editProfileModel) async {
    try {
      // Fetch the token from secure storage
      final token = await getToken();
      print("Edit Profile Token: $token");

      // If no token is found, throw an Unauthorized exception
      if (token == null) {
        throw Exception("Unauthorized access. No token found.");
      }
      // Make a PUT request to the API to update the profile
      final response = await http.put(
        Uri.parse('$_baseUrl/user'), // API endpoint to edit user profile
        headers: {
          'Authorization':
              'Bearer $token', // Authorization header with Bearer token
          'Content-Type':
              'application/json', // Ensures the request body is JSON
        },
        body:
            jsonEncode(editProfileModel.toJson()), // Convert model data to JSON
      );
// Check if the response status is 200 (successful update)
      if (response.statusCode == 200) {
        return true; // Sign-up successful
      } else {
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'An unknown error occurred';

        // Handle different status codes and provide user-friendly messages
        switch (response.statusCode) {
          case 400:
            if (errorMessage == 'User not found') {
              errorMessage = 'User not found';
            } else if (errorMessage ==
                'You must be at least 18 years old to register') {
              errorMessage = 'You must be at least 18 years old.';
            } else {
              errorMessage = 'Invalid input: $errorMessage';
            }
            break;
          case 401:
            errorMessage = 'Unauthorized access: $errorMessage';
            break;
          case 403:
            // Check if the error message matches 'Invalid or expired token'
            if (errorMessage == 'Invalid or expired token') {
              // Call the logout function
              LogoutRepository().deActiveUser(context);
            }
            errorMessage = errorMessage; // Optionally modify the message
            break;
          case 500:
            errorMessage =
                'Something went wrong on our end. Please try again later.';
            break;
          default:
            errorMessage = 'Failed to sign up: $errorMessage';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      // Log the error and rethrow for handling at the caller level
      print('Error during sign-up: $e');
      rethrow;
    }
  }
}
