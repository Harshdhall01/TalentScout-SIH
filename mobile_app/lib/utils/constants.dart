// utils/constants.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'constants.dart';
class AppConstants {
  // App Information
  static const String appName = 'TalentScout';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered sports talent assessment';

  // Test Types
  static const String testTypeSitups = 'situps';
  static const String testTypeVerticalJump = 'vertical_jump';
  static const String testTypeShuttleRun = 'shuttle_run';

  // Test Durations (in seconds)
  static const int situpsTestDuration = 60; // 1 minute
  static const int verticalJumpAttempts = 3;
  static const int shuttleRunDistance = 20; // meters

  // Video Settings
  static const int maxVideoLengthSeconds = 120; // 2 minutes
  static const int videoQuality = 720; // 720p
  static const String videoFormat = 'mp4';

  // Storage Keys
  static const String userBoxKey = 'userBox';
  static const String testResultsBoxKey = 'testResults';
  static const String settingsBoxKey = 'settings';

  // API Endpoints (will be updated when backend is deployed)
  static const String devBaseUrl = 'http://localhost:3000';
  static const String prodBaseUrl = 'https://your-app-url.com';
  
  // File Paths
  static const String videosFolder = 'videos';
  static const String modelsFolder = 'models';
  static const String tempFolder = 'temp';

  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी'},
  ];

  // Performance Benchmarks (age and gender based)
  static const Map<String, Map<String, Map<String, double>>> benchmarks = {
    'situps': {
      'male': {
        '10-15': 25.0,
        '16-20': 35.0,
        '21-25': 40.0,
        '26-30': 35.0,
        '31+': 30.0,
      },
      'female': {
        '10-15': 20.0,
        '16-20': 30.0,
        '21-25': 35.0,
        '26-30': 30.0,
        '31+': 25.0,
      },
    },
    'vertical_jump': {
      'male': {
        '10-15': 45.0, // cm
        '16-20': 55.0,
        '21-25': 60.0,
        '26-30': 55.0,
        '31+': 50.0,
      },
      'female': {
        '10-15': 35.0,
        '16-20': 45.0,
        '21-25': 50.0,
        '26-30': 45.0,
        '31+': 40.0,
      },
    },
  };

  // Achievement Thresholds
  static const Map<String, List<Map<String, dynamic>>> achievements = {
    'first_test': [
      {
        'title': 'First Step',
        'description': 'Complete your first test',
        'icon': 'star',
        'threshold': 1,
      }
    ],
    'consistency': [
      {
        'title': 'Weekly Warrior',
        'description': 'Complete 3 tests in a week',
        'icon': 'local_fire_department',
        'threshold': 3,
      },
      {
        'title': 'Monthly Champion',
        'description': 'Complete 10 tests in a month',
        'icon': 'emoji_events',
        'threshold': 10,
      }
    ],
    'improvement': [
      {
        'title': 'Getting Better',
        'description': 'Improve your score by 10%',
        'icon': 'trending_up',
        'threshold': 0.1,
      }
    ],
  };
}

// utils/helpers.dart


class AppHelpers {
  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Format duration
  static String formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Calculate age group
  static String getAgeGroup(int age) {
    if (age >= 10 && age <= 15) return '10-15';
    if (age >= 16 && age <= 20) return '16-20';
    if (age >= 21 && age <= 25) return '21-25';
    if (age >= 26 && age <= 30) return '26-30';
    return '31+';
  }

  // Get performance grade
  static String getPerformanceGrade(double score, String testType, int age, String gender) {
    final ageGroup = getAgeGroup(age);
    final benchmark = AppConstants.benchmarks[testType]?[gender.toLowerCase()]?[ageGroup];
    
    if (benchmark == null) return 'N/A';
    
    final percentage = (score / benchmark) * 100;
    
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'D';
  }

  // Get performance color
  static Color getPerformanceColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.green[700]!;
      case 'A':
        return Colors.green;
      case 'B+':
        return Colors.lightGreen;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.deepOrange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Create unique filename
  static String createUniqueFileName(String testType, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${testType}_${timestamp}.$extension';
  }

  // Get app directory for storing videos
  static Future<String> getAppDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final appDir = Directory('${directory.path}/${AppConstants.videosFolder}');
      
      if (!appDir.existsSync()) {
        await appDir.create(recursive: true);
      }
      
      return appDir.path;
    } catch (e) {
      print('Error getting app directory: $e');
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  // Check file size
  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024); // Convert to MB
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Validate video file
  static bool isValidVideoFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;
      
      final extension = filePath.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
    } catch (e) {
      return false;
    }
  }

  // Calculate BMI
  static double calculateBMI(double weight, double height) {
    try {
      if (weight <= 0 || height <= 0) return 0.0;
      final heightInMeters = height / 100; // Convert cm to meters
      return weight / (heightInMeters * heightInMeters);
    } catch (e) {
      return 0.0;
    }
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  // Get BMI color
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }

  // Show snackbar message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Validate phone number (Indian format)
  static bool isValidIndianPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  // Get test icon
  static IconData getTestIcon(String testType) {
    switch (testType) {
      case AppConstants.testTypeSitups:
        return Icons.fitness_center;
      case AppConstants.testTypeVerticalJump:
        return Icons.keyboard_arrow_up;
      case AppConstants.testTypeShuttleRun:
        return Icons.directions_run;
      default:
        return Icons.help;
    }
  }

  // Get test color
  static Color getTestColor(String testType) {
    switch (testType) {
      case AppConstants.testTypeSitups:
        return Colors.blue;
      case AppConstants.testTypeVerticalJump:
        return Colors.orange;
      case AppConstants.testTypeShuttleRun:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Check network connectivity
  static Future<bool> hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Generate random user ID
  static String generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
  }

  // Convert seconds to readable time
  static String secondsToReadableTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }

  // Check if app needs update
  static bool needsUpdate(String currentVersion, String latestVersion) {
    try {
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final latestParts = latestVersion.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}