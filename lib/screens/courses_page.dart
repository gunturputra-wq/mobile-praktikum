import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_courses_card.dart';

class CoursesPage extends StatefulWidget {
  final List<Course> courses;

  const CoursesPage({super.key, required this.courses});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final String query = searchQuery.toLowerCase();

    final filteredCourses = widget.courses.where((course) {
      return course.title.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Daftar Mata Kuliah',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('${widget.courses.length} mata kuliah tersedia'),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari mata kuliah...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFE11D48)),
                const SizedBox(width: 10),
                Expanded(child: Text('${state.favoriteCount} mata kuliah favorit')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filteredCourses.isEmpty)
          const EmptyCoursesCard()
        else
          ...filteredCourses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(course: course),
            ),
          ),
      ],
    );
  }
}
