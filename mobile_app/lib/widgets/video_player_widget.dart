// widgets/video_player_widget.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final String testName;
  final bool showControls;
  final double? height;

  const VideoPlayerWidget({
    Key? key,
    required this.videoPath,
    required this.testName,
    this.showControls = true,
    this.height,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (!File(widget.videoPath).existsSync()) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video file not found';
        });
        return;
      }

      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller!.initialize();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading video: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return _buildVideoPlayer();
  }

  Widget _buildErrorWidget() {
    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Video Error',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading ${widget.testName} video...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),

            if (widget.showControls) _buildVideoControls(),

            // Video info overlay
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.testName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black26, Colors.black54],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Play/Pause Button
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.blue,
                      bufferedColor: Colors.grey[300]!,
                      backgroundColor: Colors.grey[600]!,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Time stamps and controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller!.value.position),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: _replayVideo,
                            child: Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleMute,
                            child: Icon(
                              _controller!.value.volume > 0
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        _formatDuration(_controller!.value.duration),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _replayVideo() {
    _controller!.seekTo(Duration.zero);
    _controller!.play();
  }

  void _toggleMute() {
    setState(() {
      _controller!.setVolume(_controller!.value.volume > 0 ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
