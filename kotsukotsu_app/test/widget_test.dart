import 'package:flutter_test/flutter_test.dart';
import 'package:kotsukotsu_practice_engine/kotsukotsu_practice_engine.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const KotsuKotsuPracticeApp());
    expect(find.byType(KotsuKotsuPracticeApp), findsOneWidget);
  });
}
