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
    return const MaterialApp(
      home: StageFourPage(),
    );
  }
}

class StageFourPage extends StatelessWidget {
  const StageFourPage({super.key});

  final List<String> skills = const [
    'Flutter',
    'Dart',
    'Responsive Layout',
    'Navigation',
    'State Management',
    'Git & GitHub',
    'UI/UX Design',
    'REST API',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 4 - Expanded, Flexible & Wrap'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas Mahasiswa
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            // 1. Penerapan Expanded dengan Flex Ratio 2:1
            const Text(
              '1. Perbandingan Expanded (Flex 2 : 1)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade200,
                    child: const Text(
                      'Panel A (flex: 2)\nMengambil 2/3 ruang',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade400,
                    child: const Text(
                      'Panel B (flex: 1)\nMengambil 1/3 ruang',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Penerapan Wrap untuk Chip Skill
            const Text(
              '2. Demonstrasi Wrap vs Row',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wrap secara otomatis memindahkan Chip ke baris baru ketika lebar layar tidak mencukupi:',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0, // Jarak horizontal antar chip
              runSpacing: 8.0, // Jarak vertikal antar baris
              children: skills
                  .map(
                    (skill) => Chip(
                      avatar: const Icon(Icons.check_circle, size: 18),
                      label: Text(skill),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}