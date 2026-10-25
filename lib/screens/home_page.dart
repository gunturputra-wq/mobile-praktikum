import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/course.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/empty_courses_card.dart';

class HomePage extends StatelessWidget {
  final List<Course> courses;
  final ValueNotifier<int> counter;
  final ValueChanged<int> onNavigate;

  const HomePage({
    super.key,
    required this.courses,
    required this.counter,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final int favoriteCount = context.watch<CourseState>().favoriteCount;
    final int totalCredits = courses.fold<int>(
      0,
      (sum, course) => sum + course.credits,
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.waving_hand_rounded, color: Colors.white, size: 34),
              SizedBox(height: 16),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(studentName, style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text('NIM: $studentId', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 12),
              Text(studyProgram, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ringkasan Akademik',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth >= 650 ? 3 : 1;
            final double cardWidth =
                (constraints.maxWidth - (columns - 1) * 12) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DashboardStatCard(
                  width: cardWidth,
                  title: 'Mata Kuliah',
                  value: '${courses.length}',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF4F46E5),
                ),
                DashboardStatCard(
                  width: cardWidth,
                  title: 'Favorit',
                  value: '$favoriteCount',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFE11D48),
                ),
                DashboardStatCard(
                  width: cardWidth,
                  title: 'Total SKS',
                  value: '$totalCredits',
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFF0891B2),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ValueNotifier Counter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Contoh pengelolaan state sederhana.'),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: counter,
                  builder: (context, value, child) => Row(
                    children: [
                      Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (value > 0) counter.value = value - 1;
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => counter.value = value + 1,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Mata Kuliah Terbaru',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => onNavigate(1),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          const EmptyCoursesCard()
        else
          ...courses.take(3).map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(course: course),
            ),
          ),
      ],
    );
  }
}
