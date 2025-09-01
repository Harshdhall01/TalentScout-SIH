import 'package:hive/hive.dart';

// Remove the part declaration temporarily since we don't have generated files
// part 'test_result.g.dart';

@HiveType(typeId: 0)
class TestResult {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String testType;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String videoPath;

  @HiveField(4)
  final Map<String, dynamic> results;

  @HiveField(5)
  final double? score;

  @HiveField(6)
  final int? repetitions;

  @HiveField(7)
  final double? duration;

  @HiveField(8)
  final Map<String, dynamic>? metadata;

  TestResult({
    required this.id,
    required this.testType,
    required this.timestamp,
    required this.videoPath,
    required this.results,
    this.score,
    this.repetitions,
    this.duration,
    this.metadata,
  });

  // Convert to Map for easy storage and API calls
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'test_type': testType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'video_path': videoPath,
      'results': results,
      'score': score,
      'repetitions': repetitions,
      'duration': duration,
      'metadata': metadata,
    };
  }

  // Create from Map (for API responses and storage)
  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'] ?? '',
      testType: map['test_type'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      videoPath: map['video_path'] ?? '',
      results: Map<String, dynamic>.from(map['results'] ?? {}),
      score: map['score']?.toDouble(),
      repetitions: map['repetitions']?.toInt(),
      duration: map['duration']?.toDouble(),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() => toMap();

  // Create from JSON (for API responses)
  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult.fromMap(json);

  // Create a copy with updated values
  TestResult copyWith({
    String? id,
    String? testType,
    DateTime? timestamp,
    String? videoPath,
    Map<String, dynamic>? results,
    double? score,
    int? repetitions,
    double? duration,
    Map<String, dynamic>? metadata,
  }) {
    return TestResult(
      id: id ?? this.id,
      testType: testType ?? this.testType,
      timestamp: timestamp ?? this.timestamp,
      videoPath: videoPath ?? this.videoPath,
      results: results ?? this.results,
      score: score ?? this.score,
      repetitions: repetitions ?? this.repetitions,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TestResult(id: $id, testType: $testType, timestamp: $timestamp, score: $score, repetitions: $repetitions, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestResult &&
        other.id == id &&
        other.testType == testType &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^ testType.hashCode ^ timestamp.hashCode;
  }

  // Helper methods for different test types
  bool get isSitUpTest => testType.toLowerCase() == 'situps';
  bool get isVerticalJumpTest => testType.toLowerCase() == 'vertical_jump';
  bool get isShuttleRunTest => testType.toLowerCase() == 'shuttle_run';

  // Get formatted test type name
  String get formattedTestType {
    switch (testType.toLowerCase()) {
      case 'situps':
        return 'Sit-ups Test';
      case 'vertical_jump':
        return 'Vertical Jump Test';
      case 'shuttle_run':
        return 'Shuttle Run Test';
      default:
        return testType;
    }
  }

  // Get formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Get performance level based on score
  String get performanceLevel {
    if (score == null) return 'Unknown';
    
    if (score! >= 90) return 'Excellent';
    if (score! >= 80) return 'Very Good';
    if (score! >= 70) return 'Good';
    if (score! >= 60) return 'Average';
    return 'Needs Improvement';
  }

  // Get performance color based on score
  String get performanceColor {
    if (score == null) return '#9E9E9E';
    
    if (score! >= 90) return '#4CAF50'; // Green
    if (score! >= 80) return '#8BC34A'; // Light Green
    if (score! >= 70) return '#FF9800'; // Orange
    if (score! >= 60) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }
}