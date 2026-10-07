import 'package:flutter/material.dart';

const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tahap 1 - Non-Responsive Layout'),
        ),
        body: Center(
          // Container dengan lebar tetap (hard-coded) 500
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Text(
              '$studentId - $studentName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}