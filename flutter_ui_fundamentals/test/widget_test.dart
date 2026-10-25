
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui_fundamentals/main.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';

class FakeCourseApiService extends CourseApiService {
  FakeCourseApiService() : super('http://localhost:8000/api');

  @override
  Future<List<Course>> getCourses() async {
    return [
      Course(
        id: 1,
        code: 'TEST01',
        title: 'Pengujian Widget',
        credits: 2,
      ),
    ];
  }
}

void main() {
  testWidgets('Pengujian Tampilan Identitas Mahasiswa Tahap 13', (
    WidgetTester tester,
  ) async {
    final repository = CourseRepository(FakeCourseApiService());

    await tester.pumpWidget(
      ChangeNotifierProvider<CourseState>(
        create: (_) => CourseState(repository)..loadCourses(),
        child: const CourseExplorerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.textContaining('I Ketut Guntur Putra Dangin'),
      findsWidgets,
    );

    expect(
      find.textContaining('2415051056'),
      findsWidgets,
    );
  });
}
