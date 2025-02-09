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
              onPressed: () {
                // Your file processing function
              },
              child: Text('Process Video'),
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
}

void pickFile() {
  // Trigger file pick
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.mp4';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files!.length == 1) {
      processVideo(files[0]);
    }
  });
}

void processVideo(html.File fil) {}
