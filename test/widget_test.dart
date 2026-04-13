import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project/main.dart';


/// Run this to check errors in the app.
/// 
/// Treat it like a test. It just runs the app and checks for errors in the console.
/// It executes the app without any screens, so it won't show anything, 
/// but it will check for errors in the console.
/// 
/// For this, it checks the widget (+ icon) that increments the counter, 
/// but it doesn't check the counter itself,
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
