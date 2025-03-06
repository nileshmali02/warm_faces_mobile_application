// lib/features/authentication/repositories/signup_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:warm_faces/utils/http/api.dart';
import '../models/signup_model.dart';

/// This class handles user sign-up operations.
///
/// It implements the SignUpRepository interface and provides
/// the logic to communicate with the API.
class SignUpRepository {
  // Base URL for the API. Replace with your actual API URL.
  final String _baseUrl = HttpConfig.baseUrl;

  /// Signs up a new user by sending their information to the API.
  ///
  /// Takes a SignUpModel object as input, which contains the user's name,
  /// email, and password.
  ///
  /// Returns:
  /// A Future that resolves to true if the sign-up is successful,
  /// or throws an error if it fails.
  Future<bool> signUp(SignUpModel signUpModel) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'), // Endpoint for sign-up
        headers: {'Content-Type': 'application/json'}, // Set content type
        body: jsonEncode(signUpModel.toJson()), // Convert model to JSON
      );

      if (response.statusCode == 200) {
        return true; // Sign-up successful
      } else {
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'An unknown error occurred';

        // Handle different status codes and provide user-friendly messages
        switch (response.statusCode) {
          case 400:
            if (errorMessage == 'User already exists') {
              errorMessage =
                  'This email is already registered. Please try logging in or use another email.';
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
            errorMessage = 'Forbidden: $errorMessage';
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

  Future<bool> signUpEmailVerify(String email, int otp) async {
    try {
      // Create the payload
      final payload = {
        'email': email,
        'otp': otp,
      };

      // Create the request to the API
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'), // Endpoint for sign-up
        headers: {'Content-Type': 'application/json'}, // Set content type
        body: jsonEncode(payload), // Convert payload to JSON
      );

      if (response.statusCode == 200) {
        return true; // Sign-up successful
      } else {
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'An unknown error occurred';

        // Handle different status codes and provide user-friendly messages
        switch (response.statusCode) {
          case 400:
            if (errorMessage == 'Invalid OTP') {
              errorMessage = 'Invalid OTP';
            } else if (errorMessage == 'EMAIL and OTP are required') {
              errorMessage = 'EMAIL and OTP are required';
            } else {
              errorMessage = 'Invalid input: $errorMessage';
            }
            break;
          case 401:
            errorMessage = 'Unauthorized access: $errorMessage';
            break;
          case 403:
            errorMessage = 'Forbidden: $errorMessage';
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

  Future<bool> resendOTP(String email) async {
    try {
      // Create the payload
      final payload = {
        'email': email,
      };

      // Create the request to the API
      final response = await http.post(
        Uri.parse('$_baseUrl/resend-otp'), // Endpoint for sign-up
        headers: {'Content-Type': 'application/json'}, // Set content type
        body: jsonEncode(payload), // Convert payload to JSON
      );

      if (response.statusCode == 200) {
        return true; // Sign-up successful
      } else {
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'An unknown error occurred';

        // Handle different status codes and provide user-friendly messages
        switch (response.statusCode) {
          case 400:
            if (errorMessage == 'Email is required') {
              errorMessage = 'Email is required';
            } else {
              errorMessage = 'Invalid input: $errorMessage';
            }
            break;
          case 401:
            errorMessage = 'Unauthorized access: $errorMessage';
            break;
          case 403:
            errorMessage = 'Forbidden: $errorMessage';
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
      print('Error during sign-up:r $e');
      rethrow;
    }
  }
}
