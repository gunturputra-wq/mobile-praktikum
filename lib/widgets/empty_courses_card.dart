import 'package:flutter/material.dart';

class EmptyCoursesCard extends StatelessWidget {
  const EmptyCoursesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Data mata kuliah tidak ditemukan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
