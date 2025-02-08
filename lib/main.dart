import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoProcessor(),
    );
  }
}

class VideoProcessor extends StatefulWidget {
  @override
  _VideoProcessorState createState() => _VideoProcessorState();
}

class _VideoProcessorState extends State<VideoProcessor> {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
  String _output = "";

  void _getVideoInfo() async {
    // Replace 'input.mp4' with the path to the video file want to process
    String inputVideoPath = 'input.mp4';
    await _ffmpeg.execute('-i $inputVideoPath').then((result) {
      setState(() {
        _output = "FFmpeg process exited with rc $result";
      });
    }).catchError((error) {
      setState(() {
        _output = "Failed to get video info: $error";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Processor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getVideoInfo,
              child: Text('Get Video Info'),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(_output),
            ),
          ],
        ),
      ),
    );
  }
}
