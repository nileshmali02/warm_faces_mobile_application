import 'dart:convert'; // Import to parse JSON
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:warm_faces/features/give/screens/give_screen.dart';
import 'package:warm_faces/utils/http/api.dart';
import 'package:http/http.dart' as http;

class GiveScreenRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String _baseUrl = HttpConfig.baseUrl;
  int verifyUpload = 0;

  // Future<String?> uploadVideo(File videoFile) async {
  //   final uri = Uri.parse('$_baseUrl/upload');
  //   final token = await storage.read(key: 'jwt_token');
  //   if (token == null || token.isEmpty) {
  //     throw Exception('User is not logged in');
  //   }
  //   const chunkSize = 5 * 1024 * 1024; // 5 MB
  //   final videoSize = videoFile.lengthSync();
  //   final totalChunks = (videoSize / chunkSize).ceil();
  //   final requestHeaders = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'multipart/form-data',
  //   };
  //   for (int i = 0; i < totalChunks; i++) {
  //     final start = i * chunkSize;
  //     final end = start + chunkSize > videoSize ? videoSize : start + chunkSize;
  //     final chunk = videoFile.openSync().readSync(end - start);
  //     final chunkRequest = http.MultipartRequest('POST', uri);
  //     chunkRequest.headers.addAll(requestHeaders);
  //     chunkRequest.fields['chunkIndex'] = i.toString();
  //     chunkRequest.fields['totalChunks'] = totalChunks.toString();
  //     chunkRequest.files.add(
  //       http.MultipartFile.fromBytes(
  //         'file',
  //         chunk,
  //         filename: 'chunk_$i',
  //         contentType: MediaType('application', 'octet-stream'),
  //       ),
  //     );
  //     final response = await chunkRequest.send();
  //     if (response.statusCode != 200) {
  //       throw Exception('Chunk upload failed: ${response.statusCode}');
  //     } else {
  //       // Parse the response body to get the video URL
  //       final responseData = await response.stream.bytesToString();
  //       final videoUrl = _parseVideoUrl(responseData);
  //       print('VideoURL : $videoUrl');
  //       return videoUrl;
  //     }
  //   }
  //   print('Upload complete!');
  //   return null;
  // }

  // Function to upload the video
  Future<String?> uploadVideo(File videoFile) async {
    final uri = Uri.parse('$_baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);

    try {
      // Get the current token from secure storage
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        throw Exception('User is not logged in');
      }

      // Print the size of the video file in MB
      final videoSizeInBytes = videoFile.lengthSync();
      final videoSizeInMB = videoSizeInBytes / 1048576; // Convert bytes to MB
      print('Video size: ${videoSizeInMB.toStringAsFixed(2)} MB');

      // Add the Authorization header with Bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Check the video file extension and handle if it's not mp4 (e.g., MOV)
      String fileExtension = videoFile.path.split('.').last.toLowerCase();
      if (fileExtension != 'mp4') {
        // Convert MOV to MP4 if necessary (you need a converter plugin for that, for example using ffmpeg)
        // For now, assuming the file is either mp4 or mov (you can extend this logic further)
        if (fileExtension == 'mov') {
          // Handle conversion logic (Use an ffmpeg plugin or similar if required)
          // For now, we assume MOV is accepted as-is, or you can add conversion code here.
        }
      }

      // Attach the video file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'clip',
        videoFile.path,
        contentType: MediaType('video', fileExtension),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response body to get the video URL
        final responseData = await response.stream.bytesToString();
        final videoUrl = _parseVideoUrl(responseData);
        print('VideoURL : $videoUrl');

        return videoUrl;
      } else if (response.statusCode == 400) {
        // If status code is 400, handle the error message in the response body
        final responseData = await response.stream.bytesToString();
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception('Error: $errorMessage');
      } else if (response.statusCode == 413) {
        // If status code is 413, the file is too large
        throw Exception('Video size too big');
      } else if (response.statusCode == 403) {
        // If status code is 413, the file is too large
        throw Exception(
            'You can only upload 1 clips per day. Please try again tomorrow.');
      } else {
        throw Exception(
            'Failed to upload video, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      // throw Exception('Unknown error during request');
      rethrow; // Re-throws the exception to propagate it to the calling function
    }
  }

// Helper method to extract the video URL from the response body
  String _parseVideoUrl(String responseBody) {
    // Assuming the API returns the video URL in the response, clean up extra characters
    final urlRegex = RegExp(r'https?://[^\s]+'); // Match the URL
    final match = urlRegex.firstMatch(responseBody);

    if (match != null) {
      // Trim any unwanted characters like extra quotes or braces
      return match.group(0)?.trim().replaceAll(RegExp(r'[^\w\s:/.-]'), '') ??
          '';
    }

    return '';
  }

  // Helper method to extract error message from the response body
  String _parseErrorMessage(String responseBody) {
    try {
      final responseJson = json.decode(responseBody);
      return responseJson['message'] ?? 'Unknown error';
    } catch (e) {
      return 'Error parsing error message';
    }
  }

  // Function to send the video URL to the second API
  Future<void> sendVideoUrlToApi(String videoUrl) async {
    // final uri = Uri.parse('$_baseUrl/clips');

    try {
      // Get the current token from secure storage
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        throw Exception('User is not logged in');
      }

      // // Add the Authorization header with Bearer token
      // final response = await http.post(
      //   uri,
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token', // Include token in the header
      //   },
      //   body: '{"url": "$videoUrl"}',
      // );

      final response = await http.post(
        Uri.parse('$_baseUrl/clips'), // POST request to /rating endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'url': videoUrl,
        }),
      );

      if (response.statusCode == 200) {
        print('Video URL sent successfully');
      } else {
        print('Failed to send video URL');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      print('Error sending video URL: $e');
    }
  }

  // api call to check is video uploded or not in 24 hrs
  Future<void> verifyUploadVideo(BuildContext context) async {
    try {
      // Get the current token from secure storage
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        throw Exception('User is not logged in');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/verify-upload'), // POST request to verify upload
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        verifyUpload = response.statusCode;
        print('You can upload video');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GiveScreen(),
          ),
        );
      } else if (response.statusCode == 400) {
        verifyUpload = response.statusCode;
        print('You have exceed your daily limit');
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Daily Limit Alert!'),
              content: const Text(
                  'You can upload only 1 clip per day. Please try again tomorrow.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('unable to send request');
      }
    } catch (e) {
      // Handle specific SocketException
      if (e is SocketException) {
        throw Exception(
            'Could not connect to the server. Please check your internet connection.');
      }
      print('Error fetching upload data: $e');
    }
  }

//   import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:video_compress/video_compress.dart'; // Import video_compress package
// // Function to upload the video
// Future<String?> uploadVideo(File videoFile) async {
//   final uri = Uri.parse('$_baseUrl/upload');
//   final request = http.MultipartRequest('POST', uri);
//   try {
//     // Get the current token from secure storage
//     final token = await storage.read(key: 'jwt_token');
//     if (token == null || token.isEmpty) {
//       throw Exception('User is not logged in');
//     }
//     // Compress the video
//     final compressedVideo = await _compressVideo(videoFile);
//     if (compressedVideo == null) {
//       throw Exception('Failed to compress the video');
//     }
//     // Print the size of the compressed video file in MB
//     final videoSizeInBytes = compressedVideo.lengthSync();
//     final videoSizeInMB = videoSizeInBytes / 1048576; // Convert bytes to MB
//     print('Compressed video size: ${videoSizeInMB.toStringAsFixed(2)} MB');
//     // Add the Authorization header with Bearer token
//     request.headers['Authorization'] = 'Bearer $token';
//     // Check the video file extension and handle if it's not mp4 (e.g., MOV)
//     String fileExtension = compressedVideo.path.split('.').last.toLowerCase();
//     if (fileExtension != 'mp4') {
//       // Convert MOV to MP4 if necessary (you need a converter plugin for that, for example using ffmpeg)
//       // For now, assuming the file is either mp4 or mov (you can extend this logic further)
//       if (fileExtension == 'mov') {
//         // Handle conversion logic (Use an ffmpeg plugin or similar if required)
//       }
//     }
//     // Attach the compressed video file to the request
//     request.files.add(await http.MultipartFile.fromPath(
//       'clip',
//       compressedVideo.path,
//       contentType: MediaType('video', fileExtension),
//     ));
//     final response = await request.send();
//     if (response.statusCode == 200) {
//       // Parse the response body to get the video URL
//       final responseData = await response.stream.bytesToString();
//       final videoUrl = _parseVideoUrl(responseData);
//       print('VideoURL : $videoUrl');
//       return videoUrl;
//     } else if (response.statusCode == 400) {
//       // If status code is 400, handle the error message in the response body
//       final responseData = await response.stream.bytesToString();
//       final errorMessage = _parseErrorMessage(responseData);
//       throw Exception('Error: $errorMessage');
//     } else if (response.statusCode == 413) {
//       // If status code is 413, the file is too large
//       throw Exception('Video size too big');
//     } else if (response.statusCode == 403) {
//       // If status code is 403, the user exceeded the upload limit
//       throw Exception('You can only upload 5 clips per day. Please try again tomorrow.');
//     } else {
//       throw Exception('Failed to upload video, status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error: $e');
//     // Handle specific SocketException
//     if (e is SocketException) {
//       throw Exception('Could not connect to the server. Please check your internet connection.');
//     }
//     rethrow; // Re-throws the exception to propagate it to the calling function
//   }
// }
// // Helper function to compress the video
//   Future<File?> _compressVideo(File videoFile) async {
//     try {
//       final MediaInfo? info = await VideoCompress.compressVideo(
//         videoFile.path,
//         quality: VideoQuality.MediumQuality, // Choose the desired quality
//         deleteOrigin:
//             false, // Set to true if you want to delete the original file after compression
//       );
//       if (info == null || info.file == null) {
//         throw Exception('Failed to compress the video');
//       }
//       return info.file; // Return the compressed video file
//     } catch (e) {
//       print('Error compressing video: $e');
//       return null;
//     }
//   }
}
