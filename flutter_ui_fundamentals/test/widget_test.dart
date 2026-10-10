import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ui_fundamentals/main.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

void main() {
  testWidgets('Pengujian Tampilan Identitas Mahasiswa Tahap 13', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CourseState>(
        create: (_) => CourseState(
          CourseRepository(CourseService()),
        ),
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
