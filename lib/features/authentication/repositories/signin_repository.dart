// lib/features/authentication/repositories/signup_repository.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warm_faces/features/authentication/models/signin_model.dart';
import 'package:warm_faces/utils/http/api.dart';

class SignInRepository {
  // Base URL for the API. Replace with your actual API URL.
  final String _baseUrl = HttpConfig.baseUrl;
  final storage = const FlutterSecureStorage();
  Future<bool> signIn(SignInModel signInModel) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/signin'), // Endpoint for sign-up
        headers: {'Content-Type': 'application/json'}, // Set content type
        body: jsonEncode(signInModel.toJson()), // Convert model to JSON
      )
          .timeout(
        const Duration(seconds: 10), // Set timeout duration here
        onTimeout: () {
          throw Exception('The request timed out. Please try again later.');
        },
      );

      if (response.statusCode == 200) {
        // Extract token from response
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final data = responseBody['data'];

        print('Token: $token');

        // Extract user details from the data map
        final String userId = data['userId'];
        final String name = data['name'];
        final String email = data['email'];
        final String dob = data['dob'];

        // Print or log the user details
        print('User ID: $userId');
        print('Name: $name');
        print('Email: $email');
        print('Date of Birth: $dob');

        // Store the user information securely
        await storage.write(key: 'jwt_token', value: token);
        await storage.write(key: 'user_id', value: userId);
        await storage.write(key: 'name', value: name);
        await storage.write(key: 'email', value: email);
        await storage.write(key: 'dob', value: dob);
        // Store the token securely
        // await storage.write(key: 'jwt_token', value: token);
        return true; // Sign-up successful
      } else {
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'An unknown error occurred';

        // Handle different status codes and provide user-friendly messages
        switch (response.statusCode) {
          case 401:
            // errorMessage = 'Unauthorized access: User not found';
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

      // Handle timeout error
      if (e is TimeoutException) {
        throw Exception('The request timed out. Please try again later.');
      }
      // Log the error and rethrow for handling at the caller level
      print('Error during sign-in: $e');
      rethrow;
    }
  }
}




// // Function to retrieve the token for API requests
// Future<String?> getToken() async {
//   return await storage.read(key: 'jwt_token');
// }

// // Example usage of fetching a protected resource
// Future<void> fetchProtectedResource() async {
//   final token = await getToken();
//   if (token != null) {
//     final response = await http.get(
//       Uri.parse('$_baseUrl/protected-resource'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       // Handle the successful response
//     } else {
//       // Handle the error response
//     }
//   } else {
//     // Handle the case where the token is not available
//   }
// }