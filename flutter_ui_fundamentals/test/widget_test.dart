import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/main.dart';

void main() {
  testWidgets('Pengujian Tampilan Identitas Mahasiswa Tahap 13', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('I Ketut Guntur Putra Dangin'), findsWidgets);
    expect(find.textContaining('2415051056'), findsWidgets);
  });
}