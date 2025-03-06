import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warm_faces/features/homepage/models/display_daily_clip_model.dart';
import 'package:warm_faces/utils/http/api.dart';

class DisplayDailyClipRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  // Base URL for the API. Replace with your actual API URL.
  final String _baseUrl = HttpConfig.baseUrl;

  Future<DailyClipModel> fetchDailyClip() async {
    // Create a Stopwatch for more accurate timing
    final stopwatch = Stopwatch()..start(); // Start the stopwatch

    try {
      // Get the current token
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User is not logged in');
      }

      // Start the API call (set up the request)
      final startRequestTime = stopwatch.elapsedMilliseconds;
      // Make the API call to daily clip endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/daily/clips'), // API endpoint
        headers: {
          'Authorization': 'Bearer $token', // Include token in the header
        },
      );

      // Measure the response time
      final apiCallDuration = stopwatch.elapsedMilliseconds - startRequestTime;

      // Parse the response (time for decoding)
      final parseStartTime = stopwatch.elapsedMilliseconds;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final parseDuration = stopwatch.elapsedMilliseconds - parseStartTime;

        stopwatch.stop(); // Stop the stopwatch when done

        // Log the full timing details
        log('API Call Time: ${apiCallDuration}ms');
        log('Response Parsing Time: ${parseDuration}ms');
        log('Total Elapsed Time: ${stopwatch.elapsedMilliseconds}ms');

        return DailyClipModel.fromJson(data);
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
            errorMessage = errorMessage;
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
      // } else if (response.statusCode == 403) {
      //   // LogoutRepository().deActiveUser(c);
      //   throw Exception(response.statusCode);
      // } else {
      //   throw Exception('Failed to load video: ${response.statusCode}');
      // }
    } catch (e) {
      stopwatch.stop(); // Ensure we stop the stopwatch in case of errors
      log('Error: $e');

      // // Handle specific SocketException
      // if (e is SocketException) {
      //   throw Exception(
      //       'Could not connect to the server. Please check your internet connection.');
      // }

      // 1. SocketException: Occurs when there is a network connectivity issue, like no internet
      if (e is SocketException) {
        // This is important to notify the user that their internet connection is unavailable
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }

      // 2. TimeoutException: Occurs when the API request takes too long to respond
      else if (e is TimeoutException) {
        // Timeout exceptions can happen when the server takes too long to respond. It's important to give the user feedback that the request timed out.
        throw Exception('The request timed out. Please try again.');
      }

      // 3. FormatException: Occurs when there is an issue parsing the response (e.g., invalid JSON)
      else if (e is FormatException) {
        // This exception is crucial when the response data format is not what we expected (for example, if the server sends malformed JSON).
        // Providing this message will help users know the response couldn't be processed.
        throw Exception('Error parsing the response. Please try again later.');
      }

      // 4. HttpException: Occurs for non-2xx status codes (e.g., 404 Not Found, 500 Internal Server Error)
      else if (e is HttpException) {
        // It's important to handle HTTP exceptions since they represent server-side or response-related issues.
        // We can notify the user that something went wrong with the server (such as a missing resource or a server failure).
        throw Exception(
            'There was a problem with the server response. Please try again.');
      }

      // 5. RangeError: Occurs when you try to access an invalid index or range (for example, accessing an index out of bounds in a list)
      else if (e is RangeError) {
        // Range errors can happen if you're accessing data that doesn't exist (e.g., array out of bounds).
        // It's important to notify the user about an invalid operation on data.
        throw Exception('Error accessing the data. Please try again later.');
      }

      // 6. RedirectException: Occurs if there’s an HTTP redirect (like 3xx status codes)
      else if (e is RedirectException) {
        // Redirect exceptions occur when the resource being requested has been moved permanently or temporarily (HTTP 301, 302, etc.).
        // You might not always want to handle redirects automatically, so it's useful to let users know the resource has moved.
        throw Exception('The requested resource has moved. Please try again.');
      }

      // // 7. General exception handler: Any other unexpected errors that don't fall into the above categories
      // else {
      //   // It's a good practice to have a fallback catch-all for any unknown errors.
      //   // This ensures that no error goes unnoticed, and the user gets some feedback on the failure.
      //   throw Exception('An unknown error occurred: $e');
      // }
      rethrow;
      // throw Exception('Error fetching video: $e');
    }
  }

  Future<Map<String, bool>> checkBeforeAndAfterRatingStatus(
      String videoId) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User is not logged in');
      }

      // Make the API call to check both ratings
      final response = await http.get(
        Uri.parse('$_baseUrl/rating/check/$videoId'), // API endpoint
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool beforeRating = data['data']['beforeRating'];
        bool afterRating = data['data']['afterRating'];
        return {
          'beforeRating': beforeRating,
          'afterRating': afterRating,
        };
      } else {
        throw Exception(
            'Failed to check rating status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Error checking rating status: $e');
    }
  }

  // Add rating (before or after)
  Future<void> submitRating(
      String clipId, String ratingType, String rating) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User is not logged in');
      }

      // Prepare the body for the request
      final requestBody = json.encode({
        'clipId': clipId,
        'ratingType': ratingType,
        'rating': rating,
      });

      // Print the body to check it before sending
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/rating'), // POST request to /rating endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
        // body: json.encode({
        //   'clipId': clipId,
        //   'ratingType': ratingType,
        //   'rating': rating,
        // }),
      );

      if (response.statusCode == 200) {
        print('Rating submitted successfully');
      } else {
        throw Exception('Failed to submit rating: ${response.statusCode}');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Error submitting rating: $e');
    }
  }

  // API to count views
  Future<void> incrementViewCount(String videoId) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User is not logged in');
      }

      // Make the API call to increment the video view count
      final response = await http.post(
        Uri.parse('$_baseUrl/view/$videoId'), // API endpoint to count view
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('View count incremented successfully');
      } else {
        throw Exception(
            'Failed to increment view count: ${response.statusCode}');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Error incrementing view count: $e');
    }
  }

  // Function to submit a report
  Future<void> submitReport(
      String clipId, List<String> selectedReasons, String description) async {
    try {
      // Get the current token
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User is not logged in');
      }

      // Convert the selected reasons to JSON format
      String reasonsJson = jsonEncode(selectedReasons);

      // Prepare the body of the request
      final Map<String, dynamic> reportData = {
        'clipId': clipId,
        'status': 'reported',
        'reason': reasonsJson, // Attach reasons as JSON array
        'description':
            description.isEmpty ? 'No additional description' : description,
      };
      print("reportData  : $reportData");

      // Make the API request to submit the report
      final response = await http.put(
        Uri.parse('$_baseUrl/clips/status'), // API endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(reportData),
      );

      if (response.statusCode == 200) {
        print('Report submitted successfully');
      } else {
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Error submitting report: $e');
    }
  }
  // /// Checks if the video requires a rating before being played.
  // Future<bool> checkBeforeRatingStatus(String videoId) async {
  //   try {
  //     // Get the current token
  //     final token = await storage.read(key: 'jwt_token');
  //     if (token == null) {
  //       throw Exception('User is not logged in');
  //     }

  //     // Make the API call to daily clip endpoint
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/rating/check/$videoId'), // API endpoint
  //       headers: {
  //         'Authorization': 'Bearer $token', // Include token in the header
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       bool beforeRating = data['data']['beforeRating'];
  //       return beforeRating;
  //     } else {
  //       throw Exception(
  //           'Failed to check rating status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error checking rating status: $e');
  //   }
  // }
}
