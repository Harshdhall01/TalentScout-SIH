// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this URL when backend is deployed
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // For iOS simulator
  // static const String baseUrl = 'https://your-app.herokuapp.com'; // For production

  // Submit user details to backend
  static Future<Map<String, dynamic>> submitUserDetails({
    required String name,
    required int age,
    required String phone,
    required String gender,
    required double weight,
    required double height,
    required List<String> interestedSports,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'age': age,
          'phone': phone,
          'gender': gender,
          'weight': weight,
          'height': height,
          'interestedSports': interestedSports.join(', '),
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User details submitted successfully',
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit user details: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Upload video to backend
  static Future<Map<String, dynamic>> uploadVideo({
    required String videoPath,
    required String testType,
    required String userName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload'),
      );

      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath(
          'fitnessVideo', // This matches backend's expected field name
          videoPath,
        ),
      );

      // Add additional data
      request.fields['testType'] = testType;
      request.fields['userName'] = userName;
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Video uploaded successfully',
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload video: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Upload error: $e'};
    }
  }

  // Get AI analysis results (for future integration)
  static Future<Map<String, dynamic>> getAnalysisResults(String videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/analysis/$videoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to get analysis: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Analysis error: $e'};
    }
  }

  // Get user leaderboard
  static Future<Map<String, dynamic>> getLeaderboard({
    String testType = 'all',
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/leaderboard?testType=$testType&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to get leaderboard: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Leaderboard error: $e'};
    }
  }

  // Submit performance data with AI analysis
  static Future<Map<String, dynamic>> submitPerformanceData({
    required String testType,
    required Map<String, dynamic> performanceMetrics,
    required String videoPath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/performance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'testType': testType,
          'metrics': performanceMetrics,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to submit performance: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Performance submission error: $e'};
    }
  }

  // Get user profile and statistics
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to get profile: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Profile error: $e'};
    }
  }

  // Check backend connection
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        timeout: Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Backend connection failed: $e');
      return false;
    }
  }

  // Get app version and updates
  static Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to get app info'};
      }
    } catch (e) {
      return {'success': false, 'message': 'App info error: $e'};
    }
  }
}
