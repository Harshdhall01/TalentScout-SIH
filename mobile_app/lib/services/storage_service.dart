import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/test_result.dart';
import '../models/user_data.dart';

class StorageService {
  static late Box<Map> _userBox;
  static late Box<Map> _testResultsBox;
  static late Box<Map> _settingsBox;
  static SharedPreferences? _prefs;

  // Initialize Hive and boxes
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters if needed
      // Hive.registerAdapter(TestResultAdapter());
      // Hive.registerAdapter(UserDataAdapter());
      
      // Open boxes
      _userBox = await Hive.openBox<Map>('user_data');
      _testResultsBox = await Hive.openBox<Map>('test_results');
      _settingsBox = await Hive.openBox<Map>('settings');
      
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      if (kDebugMode) {
        print('Storage Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Storage Service: $e');
      }
    }
  }

  // User Data Methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _userBox.put('current_user', userData);
      await _prefs?.setBool('user_registered', true);
      if (kDebugMode) {
        print('User data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  static Map<String, dynamic>? getUserData() {
    try {
      final userData = _userBox.get('current_user');
      return userData?.cast<String, dynamic>();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  static Future<bool> isUserRegistered() async {
    try {
      return _prefs?.getBool('user_registered') ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user registration: $e');
      }
      return false;
    }
  }

  // Test Results Methods
  static Future<void> saveTestResult(Map<String, dynamic> result) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      result['timestamp'] = timestamp;
      result['id'] = timestamp.toString();
      
      await _testResultsBox.add(result);
      if (kDebugMode) {
        print('Test result saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving test result: $e');
      }
    }
  }

  static List<Map<String, dynamic>> getTestResults() {
    try {
      final results = <Map<String, dynamic>>[];
      for (int i = 0; i < _testResultsBox.length; i++) {
        final result = _testResultsBox.getAt(i);
        if (result != null) {
          results.add(result.cast<String, dynamic>());
        }
      }
      // Sort by timestamp (newest first)
      results.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting test results: $e');
      }
      return [];
    }
  }

  static Future<void> deleteTestResult(String id) async {
    try {
      for (int i = 0; i < _testResultsBox.length; i++) {
        final result = _testResultsBox.getAt(i);
        if (result != null && result['id'] == id) {
          await _testResultsBox.deleteAt(i);
          break;
        }
      }
      if (kDebugMode) {
        print('Test result deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting test result: $e');
      }
    }
  }

  // Settings Methods
  static Future<void> saveSettings({String? language, bool? notifications, String? theme}) async {
    try {
      final currentSettings = getSettings() ?? <String, dynamic>{};
      
      if (language != null) currentSettings['language'] = language;
      if (notifications != null) currentSettings['notifications'] = notifications;
      if (theme != null) currentSettings['theme'] = theme;
      
      await _settingsBox.put('app_settings', currentSettings);
      
      // Also save to SharedPreferences for quick access
      if (language != null) {
        await _prefs?.setString('app_language', language);
      }
      
      if (kDebugMode) {
        print('Settings saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving settings: $e');
      }
    }
  }

  static Map<String, dynamic>? getSettings() {
    try {
      final settings = _settingsBox.get('app_settings');
      return settings?.cast<String, dynamic>() ?? {
        'language': 'en',
        'notifications': true,
        'theme': 'light',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting settings: $e');
      }
      return {
        'language': 'en',
        'notifications': true,
        'theme': 'light',
      };
    }
  }

  // Video Storage Methods
  static Future<String?> saveVideoFile(File videoFile, String testType) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDirectory = Directory('${directory.path}/videos');
      
      if (!await videoDirectory.exists()) {
        await videoDirectory.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${testType}_$timestamp.mp4';
      final savedPath = '${videoDirectory.path}/$fileName';
      
      await videoFile.copy(savedPath);
      
      if (kDebugMode) {
        print('Video saved to: $savedPath');
      }
      
      return savedPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving video file: $e');
      }
      return null;
    }
  }

  static Future<void> deleteVideoFile(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Video file deleted: $videoPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting video file: $e');
      }
    }
  }

  // Cache Management
  static Future<void> clearCache() async {
    try {
      await _testResultsBox.clear();
      if (kDebugMode) {
        print('Cache cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  static Future<void> clearAllData() async {
    try {
      await _userBox.clear();
      await _testResultsBox.clear();
      await _settingsBox.clear();
      await _prefs?.clear();
      
      if (kDebugMode) {
        print('All data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all data: $e');
      }
    }
  }

  // Backup and Restore
  static Future<String?> exportData() async {
    try {
      final userData = getUserData();
      final testResults = getTestResults();
      final settings = getSettings();
      
      final exportData = {
        'user_data': userData,
        'test_results': testResults,
        'settings': settings,
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
      };
      
      return json.encode(exportData);
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting data: $e');
      }
      return null;
    }
  }

  static Future<bool> importData(String jsonData) async {
    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;
      
      // Import user data
      if (data['user_data'] != null) {
        await saveUserData(data['user_data']);
      }
      
      // Import test results
      if (data['test_results'] != null) {
        final results = data['test_results'] as List;
        for (final result in results) {
          await saveTestResult(result as Map<String, dynamic>);
        }
      }
      
      // Import settings
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        await saveSettings(
          language: settings['language'],
          notifications: settings['notifications'],
          theme: settings['theme'],
        );
      }
      
      if (kDebugMode) {
        print('Data imported successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing data: $e');
      }
      return false;
    }
  }

  // Statistics and Analytics
  static Map<String, dynamic> getStatistics() {
    try {
      final testResults = getTestResults();
      final totalTests = testResults.length;
      
      // Count tests by type
      final testTypeCount = <String, int>{};
      for (final result in testResults) {
        final testType = result['test_type'] as String? ?? 'unknown';
        testTypeCount[testType] = (testTypeCount[testType] ?? 0) + 1;
      }
      
      // Calculate average scores if available
      final averageScores = <String, double>{};
      for (final testType in testTypeCount.keys) {
        final typeResults = testResults.where((r) => r['test_type'] == testType);
        if (typeResults.isNotEmpty) {
          final scores = typeResults
              .map((r) => (r['score'] as num?)?.toDouble() ?? 0.0)
              .where((score) => score > 0);
          if (scores.isNotEmpty) {
            averageScores[testType] = scores.reduce((a, b) => a + b) / scores.length;
          }
        }
      }
      
      return {
        'total_tests': totalTests,
        'test_type_count': testTypeCount,
        'average_scores': averageScores,
        'last_test_date': testResults.isNotEmpty 
            ? DateTime.fromMillisecondsSinceEpoch(testResults.first['timestamp'] ?? 0).toIso8601String()
            : null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting statistics: $e');
      }
      return {};
    }
  }
}