import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:flutter/material.dart';

const MaterialColor kTechyBlue = MaterialColor(
  _techyBluePrimaryValue,
  <int, Color>{
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(_techyBluePrimaryValue),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  },
);
const int _techyBluePrimaryValue = 0xFF2196F3;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowFrame FFmpeg Web',
      theme: ThemeData(
        primarySwatch: kTechyBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _end = 30.0; // Default end time for video trimming

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlowFrame FFmpeg Web'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kTechyBlue[800], // Text color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: () => pickFile(context), // Passing context from widget
              child: Text('Choose Video'),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Welcome to FlowFrame',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTechyBlue[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickFile(BuildContext context) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/*'; // Accept only video files
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        html.File file = files[0];
        print("✅ File selected: ${file.name}");

        _fetchVideoDuration(file).then((duration) {
          print("✅ Video duration fetched: $duration seconds");

          _showVideoOptions(context, file); // Open the dialog with options
        }).catchError((error) {
          print("❌ Error fetching video duration: $error");
        });
      } else {
        print("❌ No file selected");
      }
    });
  }

  void _showVideoOptions(BuildContext context, html.File file) {
    _fetchVideoDuration(file).then((duration) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose an action'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Video Duration: ${duration.toStringAsFixed(2)} seconds'),
                  GestureDetector(
                    child: Text('Trim Video'),
                    onTap: () {
                      Navigator.of(context)
                          .pop(); // Close dialog before processing
                      _trimVideo(file, duration);
                    },
                  ),
                  // Additional actions
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _trimVideo(html.File file, double duration) async {
    setState(() {
      _end = duration; // Update the state with the video duration
      print(duration);
    });

    final FFmpeg ffmpeg = createFFmpeg(CreateFFmpegParam(log: true));
    await ffmpeg.load();

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader
        .onLoad.first; // Ensure the file is fully loaded before proceeding

    final Uint8List data = reader.result as Uint8List;
    ffmpeg.writeFile('input.mp4', data);

    String command = '-i input.mp4 -ss 00:00:10 -to $_end -c copy output.mp4';
    await ffmpeg.runCommand(command);

    final Uint8List outputData = ffmpeg.readFile('output.mp4');
    print('Trimming complete. Output size: ${outputData.length} bytes.');
    print('FFmpeg command used: $command');

    // Cleanup files if necessary
    ffmpeg.unlink('input.mp4');
    ffmpeg.unlink('output.mp4');
  }

  Future<double> _fetchVideoDuration(html.File file) async {
    final FFmpeg ffmpeg = createFFmpeg(CreateFFmpegParam(log: true));
    await ffmpeg.load();

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final Uint8List data = reader.result as Uint8List;
    ffmpeg.writeFile('temp_video.mp4', data);

    await ffmpeg.runCommand(
        '-i temp_video.mp4 -show_entries format=duration -v quiet -of csv="p=0"');
    final String output = ffmpeg.readFile('ffprobe_output.txt').toString();
    ffmpeg.unlink('temp_video.mp4'); // Clean up

    double duration = double.tryParse(output.trim()) ?? 0.0;
    return duration;
  }
}
