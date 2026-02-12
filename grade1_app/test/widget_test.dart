import 'package:flutter_test/flutter_test.dart';
import 'package:kotsukotsu_practice_engine/kotsukotsu_practice_engine.dart';

void main() {
  testWidgets('grade1 app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const Grade1PracticeApp());
    expect(find.byType(Grade1PracticeApp), findsOneWidget);
  });
}
