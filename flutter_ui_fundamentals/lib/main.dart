import 'package:flutter/material.dart';

// Identitas Mahasiswa
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
      debugShowCheckedModeBanner: false,
      title: 'Tahap 3 - Lifting State Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ParentCoursePage(),
    );
  }
}

// 1. PARENT WIDGET (Single Source of Truth)
class ParentCoursePage extends StatefulWidget {
  const ParentCoursePage({super.key});

  @override
  State<ParentCoursePage> createState() => _ParentCoursePageState();
}

class _ParentCoursePageState extends State<ParentCoursePage> {
  // State disimpan tunggal di sini (Parent)
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 3: Single Source of Truth'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas Praktikan
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '$studentId - $studentName',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Child 1: Menerima data favorite count dari Parent
            CourseSummaryCard(totalFavorites: _isFavorite ? 1 : 0),

            const SizedBox(height: 16),

            // Child 2: Menerima status data & callback action dari Parent
            CourseItemCard(
              title: 'Pemrograman Mobile (Flutter)',
              isFavorite: _isFavorite,
              onToggleFavorite: _toggleFavorite, // Callback ke Parent
            ),
          ],
        ),
      ),
    );
  }
}

// 2. CHILD WIDGET 1: Halaman Ringkasan (Hanya menerima data via constructor)
class CourseSummaryCard extends StatelessWidget {
  final int totalFavorites;

  const CourseSummaryCard({super.key, required this.totalFavorites});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Favorit Ditambahkan:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Chip(
              avatar: const Icon(Icons.favorite, color: Colors.red, size: 18),
              label: Text(
                '$totalFavorites Item',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. CHILD WIDGET 2: Item Kartu (Menerima data & mengirimkan aksi via callback)
class CourseItemCard extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onToggleFavorite; // Callback function

  const CourseItemCard({
    super.key,
    required this.title,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.blue),
        title: Text(title),
        subtitle: const Text('Lifting State Up + Single Source of Truth'),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onToggleFavorite, // Memanggil callback saat diklik
        ),
      ),
    );
  }
}