import 'package:flutter_test/flutter_test.dart';
import 'package:skincare/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkincareApp());
    expect(find.text('Skincare'), findsOneWidget);
  });
}
