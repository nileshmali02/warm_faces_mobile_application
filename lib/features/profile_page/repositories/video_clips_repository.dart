import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warm_faces/features/authentication/repositories/logout_repository.dart';
import 'package:warm_faces/features/profile_page/models/video_clips_model.dart';
import 'package:warm_faces/utils/http/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum VideoClipStatus { accepted, pending, rejected, reported }

class VideoClipRepository {
  // Base URL for the API
  final String _baseUrl = HttpConfig.baseUrl;

  // Initialize Flutter Secure Storage
  final storage = const FlutterSecureStorage();

  // Function to retrieve the token for API requests
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Fetch clips by status
  Future<List<VideoClipsModel>> fetchClipsByStatus(
      BuildContext context, VideoClipStatus status) async {
    try {
      // Fetch the token from secure storage
      final token = await getToken();
      print("Edit Profile Token: $token");

      // Check if token is null or empty
      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing or invalid');
      }

      print("Fetched Token: $token");

      // Convert the status enum to the expected API string value
      final statusStr = status.toString().split('.').last.toUpperCase();

      // Make the real API call
      final response = await http.get(
        Uri.parse('$_baseUrl/clips/$statusStr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the response message indicates success
        if (responseData['message'] == 'Success') {
          var data = responseData['data'];

          // Ensure data is a List and not null
          if (data is List) {
            final List<dynamic> clipsJson = List<dynamic>.from(data);

            return clipsJson
                .map((clip) => VideoClipsModel.fromJson(clip))
                .where(
                    (clip) => clip.show) // Only include clips with "show": true
                .toList();
          } else {
            throw Exception('Data is not a valid list');
          }
        } else {
          throw Exception('Failed to load clips: ${responseData['message']}');
        }
      } else {
        // throw Exception('Failed to load clips: ${response.statusCode}');
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
      // throw Exception('Failed to load clips: $e');
      rethrow;
    }
  }

  Future<int> fetchClipCountByStatus(VideoClipStatus status) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing or invalid');
      }

      final statusStr = status.toString().split('.').last.toUpperCase();

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/clips/$statusStr'), // Assuming the backend supports this API
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['message'] == 'Success') {
          // Extract the data field, which is a list of clips
          var data = responseData['data'];

          if (data is List) {
            // Filter clips by status
            final statusStr = status.toString().split('.').last.toUpperCase();
            final filteredClips = List.from(data)
                .where((clip) => clip['status'] == statusStr)
                .toList();

            // Return the number of filtered clips
            return filteredClips.length;
          } else {
            throw Exception('Data is not a valid list');
          }
        } else {
          throw Exception('Failed to load clips: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load clips: ${response.statusCode}');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Error fetching clip count: $e');
    }
  }

  // Function to delete the video
  Future<void> deleteVideo(String videoId) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing or invalid');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/clips/$videoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete video');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Error deleting video: $e');
    }
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:warm_faces/features/profile_page/models/video_clips_model.dart';
// import 'package:warm_faces/utils/http/api.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// enum VideoClipStatus { accepted, pending, rejected, reported }

// class VideoClipRepository {
//   // Base URL for the API
//   final String _baseUrl = HttpConfig.baseUrl;

//   // Initialize Flutter Secure Storage
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Fetch clips by status
//   Future<List<VideoClipsModel>> fetchClipsByStatus(
//       VideoClipStatus status) async {
//     try {
//       // Uncomment this when you are ready to fetch the token from secure storage
//       // String? token = await _storage.read(key: 'auth_token');

//       // Temporary token for testing (replace with the real token once you uncomment)
//       String? token =
//           "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzMxZDJiOTM2NjBmMzM0ZGQwZjI3YWUiLCJuYW1lIjoiUmFqZXNoIiwiZW1haWwiOiJyYWplc2gucmFqZXNoazM5OTNAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJpYXQiOjE3MzEzMTg1MTB9.mCOuVvCv3DHdyqNWfPXNAXW1V7TVoabJXYOmfP3ni0I";

//       print("Fetched Token: $token");

//       // Uncomment this block to use real API call
//       // final statusStr = status.toString().split('.').last.toUpperCase();
//       // final response = await http.get(
//       //   Uri.parse('$_baseUrl/clips/$statusStr'),
//       //   headers: {
//       //     'Authorization': 'Bearer $token',
//       //     'Content-Type': 'application/json',
//       //   },
//       // );

//       // Simulate a real API response for testing
//       final response = {
//         "message": "Success",
//         "data": [
//           {
//             "_id": "6731d30b3660f334dd0f27b7",
//             "userId": "6731d2b93660f334dd0f27ae",
//             "url":
//                 "https://videos.pexels.com/video-files/10268420/10268420-hd_1080_1920_30fps.mp4",
//             "status": "ACCEPTED",
//             "show": true,
//             "createdAt": "2024-11-11T09:46:41.000Z",
//             "createdBy": "rajesh.rajeshk3993@gmail.com",
//             "updatedAt": "2024-11-11T09:46:41.000Z",
//             "updatedBy": "rajesh.rajeshk3993@gmail.com",
//             "__v": 0
//           },
//           {
//             "_id": "6731d30b3660f334dd0f27ba",
//             "userId": "6731d2b93660f334dd0f27ae",
//             "url": "https://www.w3schools.com/html/mov_bbb.mp4",
//             "status": "ACCEPTED",
//             "show": true,
//             "createdAt": "2024-11-11T09:46:41.000Z",
//             "createdBy": "rajesh.rajeshk3993@gmail.com",
//             "updatedAt": "2024-11-11T09:46:41.000Z",
//             "updatedBy": "rajesh.rajeshk3993@gmail.com",
//             "__v": 0
//           },
//           {
//             "_id": "6731d30b3660f334dd0f27bb",
//             "userId": "6731d2b93660f334dd0f27ae",
//             "url":
//                 "https://videos.pexels.com/video-files/27776045/12221985_360_640_24fps.mp4",
//             "status": "ACCEPTED",
//             "show": true,
//             "createdAt": "2024-11-11T09:46:41.000Z",
//             "createdBy": "rajesh.rajeshk3993@gmail.com",
//             "updatedAt": "2024-11-11T09:46:41.000Z",
//             "updatedBy": "rajesh.rajeshk3993@gmail.com",
//             "__v": 0
//           }
//         ]
//       };

//       if (response['message'] == 'Success') {
//         if (response['message'] == 'Success') {
//           var data = response['data'];

//           // Ensure data is a List and not null
//           if (data is List?) {
//             final List<dynamic> clipsJson = List<dynamic>.from(data ?? []);

//             return clipsJson
//                 .map((clip) => VideoClipsModel.fromJson(clip))
//                 .where((clip) => clip.show)
//                 .toList();
//           } else {
//             throw Exception('Data is not a valid list or is null');
//           }
//         } else {
//           throw Exception('Failed to load clips');
//         }

//         // // Check if response['data'] is a List
//         // if (response['data'] is List) {
//         //   // Safely cast response['data'] to a List<dynamic>
//         //   final List<dynamic> clipsJson = List<dynamic>.from(response['data']);

//         //   // Return a list of VideoClipsModel instances
//         //   return clipsJson
//         //       .map((clip) => VideoClipsModel.fromJson(clip))
//         //       .where(
//         //           (clip) => clip.show) // Only include clips with "show": true
//         //       .toList();
//         // } else {
//         //   throw Exception('Data is not a valid list');
//         // }
//       } else {
//         throw Exception('Failed to load clips');
//       }
//     } catch (e) {
//       throw Exception('Failed to load clips: $e');
//     }
//   }
// }





// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:warm_faces/features/profile_page/models/video_clips_model.dart';
// import 'package:warm_faces/utils/http/api.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// enum VideoClipStatus { accepted, pending, rejected, reported }

// class VideoClipRepository {
//   // Base URL for the API
//   final String _baseUrl = HttpConfig.baseUrl;

//   // Initialize Flutter Secure Storage
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Fetch clips by status
//   Future<List<VideoClipsModel>> fetchClipsByStatus(
//       VideoClipStatus status) async {
//     try {
//       // Fetch the token from secure storage
//       String? token =
//           "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzMxZDJiOTM2NjBmMzM0ZGQwZjI3YWUiLCJuYW1lIjoiUmFqZXNoIiwiZW1haWwiOiJyYWplc2gucmFqZXNoazM5OTNAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJpYXQiOjE3MzEzMTg1MTB9.mCOuVvCv3DHdyqNWfPXNAXW1V7TVoabJXYOmfP3ni0I";

//       print("Fetched Token: $token");

//       final statusStr = status.toString().split('.').last.toUpperCase();

//       // Make a GET request to fetch clips by status
//       final response = await http.get(
//         Uri.parse('$_baseUrl/clips/$statusStr'), // API endpoint
//         headers: {
//           'Authorization': 'Bearer $token', // Authorization header with token
//           'Content-Type':
//               'application/json', // Ensures the request body is JSON
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> clipsJson = data['data'];

//         // Return a list of VideoClipsModel instances
//         return clipsJson
//             .map((clip) => VideoClipsModel.fromJson(clip))
//             .where((clip) => clip.show) // Only include clips with "show": true
//             .toList();
//       } else {
//         // Handle different status codes and return specific error messages
//         if (response.statusCode == 401) {
//           throw Exception("Unauthorized access. Please log in.");
//         } else if (response.statusCode == 404) {
//           throw Exception("No clips found for the given status.");
//         } else {
//           throw Exception(
//               "Failed to load clips. Status code: ${response.statusCode}");
//         }
//       }
//     } catch (e) {
//       // Log any exceptions and rethrow them for the caller to handle
//       print('Error fetching clips: $e');
//       throw Exception('Failed to load clips: $e');
//     }
//   }
// }
