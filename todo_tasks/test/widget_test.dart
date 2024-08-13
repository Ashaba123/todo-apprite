import 'package:flutter_test/flutter_test.dart';

import 'package:todo_tasks/main.dart';

void main() {
  testWidgets('Home Screen opens', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen opens
    expect(find.text('My Todos'), findsOneWidget);
  });
}
