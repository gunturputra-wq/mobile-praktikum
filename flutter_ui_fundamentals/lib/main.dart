import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// IDENTITAS MAHASISWA
const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

Future<Map<String, dynamic>> loadStudentData() async {
final jsonString = await rootBundle.loadString(
  'assets/data/student_data_salah.json',
);

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  // SUMMARY CARD
  Widget buildSummaryCard(
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  // COURSE CARD
  Widget buildCourseCard(Map<String, dynamic> course) {
    final status = course['status'] as String;

    IconData statusIcon;
    String statusText;

    if (status == 'done') {
      statusIcon = Icons.check_circle;
      statusText = 'Selesai';
    } else if (status == 'active') {
      statusIcon = Icons.play_circle;
      statusText = 'Sedang Dipelajari';
    } else {
      statusIcon = Icons.schedule;
      statusText = 'Direncanakan';
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            course['code']
                .toString()
                .replaceAll('MOB', ''),
          ),
        ),
        title: Text(
          course['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${course['code']} • ${course['credits']} SKS\n'
          '${course['category']}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          // LOADING STATE
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR STATE
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // DATA STATE
          final data = snapshot.data!;

          final student =
              data['student'] as Map<String, dynamic>;

          final courses =
              data['courses'] as List<dynamic>;

          final totalCourses = courses.length;

          final totalCredits = courses.fold<int>(
            0,
            (sum, course) =>
                sum + (course['credits'] as int),
          );

          return SafeArea(
            child: Column(
              children: [
                // PROFILE / IDENTITY CARD
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 42,
                            backgroundImage: AssetImage(
                              'assets/images/profile.jpg',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  student['nim'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Mahasiswa Pendidikan Teknik Informatika',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SUMMARY
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
  children: [
    const Icon(Icons.info),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        '$studentId - $studentName - Ini adalah teks yang sangat panjang untuk menguji layout',
      ),
    ),
  ],
),
                ),

                const SizedBox(height: 8),

                // COURSE LIST
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar Materi Pembelajaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course =
                          courses[index]
                              as Map<String, dynamic>;

                      return buildCourseCard(course);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}