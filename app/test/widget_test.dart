import 'package:flutter_test/flutter_test.dart';
import 'package:buta_cockpit/main.dart';

void main() {
  testWidgets('ButaAI Cockpit smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ButaCockpitApp());
    expect(find.text('ButaAI'), findsOneWidget);
  });
}
