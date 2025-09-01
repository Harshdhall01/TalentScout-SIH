// screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'results_screen.dart';

class CameraScreen extends StatefulWidget {
  final String testType;
  final String testName;
  final String instructions;

  CameraScreen({
    required this.testType,
    required this.testName,
    required this.instructions,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  bool _isInitialized = false;
  int _countdown = 0;
  bool _showCountdown = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![1], // Front camera
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.testName), centerTitle: true),
      body: Column(
        children: [
          // Instructions Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(widget.instructions, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),

          // Camera Preview
          Expanded(
            child: Container(
              child: _isInitialized
                  ? Stack(
                      children: [
                        CameraPreview(_controller!),
                        if (_showCountdown)
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                _countdown.toString(),
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (_isRecording)
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'REC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ),

          // Control Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch Camera
                FloatingActionButton(
                  onPressed: _switchCamera,
                  child: Icon(Icons.switch_camera),
                  mini: true,
                ),

                // Record Button
                FloatingActionButton.extended(
                  onPressed: _isRecording ? _stopRecording : _startCountdown,
                  label: Text(_isRecording ? 'Stop' : 'Start Test'),
                  icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
                  backgroundColor: _isRecording ? Colors.red : Colors.green,
                ),

                // Gallery Button
                FloatingActionButton(
                  onPressed: _viewResults,
                  child: Icon(Icons.photo_library),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdown = 3;
    });

    _countdownTimer();
  }

  void _countdownTimer() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _countdown--;
      });

      if (_countdown > 0) {
        _countdownTimer();
      } else {
        setState(() {
          _showCountdown = false;
        });
        _startRecording();
      }
    });
  }

  void _startRecording() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${widget.testType}_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller!.startVideoRecording();

      setState(() {
        _isRecording = true;
      });
    }
  }

  void _stopRecording() async {
    if (_controller != null && _isRecording) {
      final videoFile = await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
      });

      // Save test result to Hive
      final testResultsBox = Hive.box('testResults');
      final result = {
        'testType': widget.testType,
        'testName': widget.testName,
        'videoPath': videoFile.path,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'completed',
      };

      await testResultsBox.add(result);

      // Show completion dialog
      _showCompletionDialog(videoFile.path);
    }
  }

  void _switchCamera() async {
    if (cameras != null && cameras!.length > 1) {
      final currentCamera = _controller!.description;
      final newCamera = cameras!.firstWhere(
        (camera) => camera != currentCamera,
      );

      await _controller!.dispose();
      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();
      setState(() {});
    }
  }

  void _showCompletionDialog(String videoPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Test Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                'Your ${widget.testName} test has been recorded successfully!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to test selection
              },
              child: Text('Take Another Test'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ResultsScreen()),
                );
              },
              child: Text('View Results'),
            ),
          ],
        );
      },
    );
  }

  void _viewResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultsScreen()),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
