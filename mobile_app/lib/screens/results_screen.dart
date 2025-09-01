// screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Map<String, dynamic>> testResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestResults();
  }

  Future<void> _loadTestResults() async {
    final testResultsBox = Hive.box('testResults');
    final results = testResultsBox.values.cast<Map<String, dynamic>>().toList();

    // Sort by timestamp (newest first)
    results.sort(
      (a, b) => DateTime.parse(
        b['timestamp'],
      ).compareTo(DateTime.parse(a['timestamp'])),
    );

    setState(() {
      testResults = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Test Results'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadTestResults),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _showClearDataDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : testResults.isEmpty
          ? _buildEmptyState()
          : _buildResultsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.add),
        tooltip: 'Take New Test',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 100, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'No Test Results Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Complete some fitness tests to see your results here',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.fitness_center),
            label: Text('Start Your First Test'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        // Summary Card
        _buildSummaryCard(),

        // Results List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: testResults.length,
            itemBuilder: (context, index) {
              final result = testResults[index];
              return _buildResultCard(result, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalTests = testResults.length;
    final testTypes = testResults.map((r) => r['testType']).toSet().length;
    final recentTest = testResults.isNotEmpty ? testResults[0] : null;

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Tests',
                  totalTests.toString(),
                  Icons.assignment,
                ),
                _buildSummaryItem(
                  'Test Types',
                  testTypes.toString(),
                  Icons.category,
                ),
                _buildSummaryItem(
                  'Latest Test',
                  recentTest != null ? recentTest['testName'] : 'None',
                  Icons.schedule,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, int index) {
    final timestamp = DateTime.parse(result['timestamp']);
    final formattedDate =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTestColor(result['testType']),
          child: _getTestIcon(result['testType']),
        ),
        title: Text(
          result['testName'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$formattedDate at $formattedTime'),
        trailing: _buildStatusBadge(result['status']),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Test Type', result['testType']),
                    ),
                    Expanded(
                      child: _buildDetailItem('Status', result['status']),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _playVideo(result['videoPath']),
                      icon: Icon(Icons.play_arrow),
                      label: Text('Play Video'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _analyzeVideo(result),
                      icon: Icon(Icons.analytics),
                      label: Text('Analyze'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _deleteResult(index),
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'analyzing':
        color = Colors.orange;
        icon = Icons.analytics;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTestColor(String testType) {
    switch (testType) {
      case 'situps':
        return Colors.blue;
      case 'vertical_jump':
        return Colors.orange;
      case 'shuttle_run':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _getTestIcon(String testType) {
    IconData icon;
    switch (testType) {
      case 'situps':
        icon = Icons.fitness_center;
        break;
      case 'vertical_jump':
        icon = Icons.keyboard_arrow_up;
        break;
      case 'shuttle_run':
        icon = Icons.directions_run;
        break;
      default:
        icon = Icons.help;
    }

    return Icon(icon, color: Colors.white);
  }

  void _playVideo(String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: videoPath),
      ),
    );
  }

  void _analyzeVideo(Map<String, dynamic> result) {
    // This will connect to AI/ML analysis later
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI Analysis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your performance...'),
            SizedBox(height: 8),
            Text(
              'AI will process your ${result['testName']} video and provide detailed feedback.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteResult(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Test Result'),
        content: Text(
          'Are you sure you want to delete this test result? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _confirmDelete(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) async {
    final testResultsBox = Hive.box('testResults');

    // Delete video file
    final videoPath = testResults[index]['videoPath'];
    if (videoPath != null && File(videoPath).existsSync()) {
      await File(videoPath).delete();
    }

    // Delete from storage
    await testResultsBox.deleteAt(index);

    // Reload results
    _loadTestResults();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test result deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'This will delete all test results and user data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _clearAllData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearAllData() async {
    final testResultsBox = Hive.box('testResults');
    final userBox = Hive.box('userBox');

    // Delete all video files
    for (var result in testResults) {
      final videoPath = result['videoPath'];
      if (videoPath != null && File(videoPath).existsSync()) {
        await File(videoPath).delete();
      }
    }

    // Clear storage
    await testResultsBox.clear();
    await userBox.clear();

    setState(() {
      testResults = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All data cleared successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  VideoPlayerScreen({required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (File(widget.videoPath).existsSync()) {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Video'),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          _controller!.seekTo(Duration.zero);
                        },
                        icon: Icon(Icons.replay, color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.blue,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.black,
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
