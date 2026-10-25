import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/course.dart';
import '../providers/course_state.dart';

class ProfilePage extends StatelessWidget {
  final List<Course> courses;

  const ProfilePage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Profil Mahasiswa',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(
                    Icons.person_rounded,
                    size: 46,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  studentName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('NIM: $studentId'),
                const SizedBox(height: 6),
                const Text(studyProgram, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('Program Studi'),
                  subtitle: Text(studyProgram),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Jumlah Mata Kuliah'),
                  subtitle: Text('${courses.length} mata kuliah'),
                ),
                Consumer<CourseState>(
                  builder: (context, state, child) => ListTile(
                    leading: const Icon(Icons.favorite, color: Color(0xFFE11D48)),
                    title: const Text('Mata Kuliah Favorit'),
                    subtitle: Text('${state.favoriteCount} mata kuliah'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
