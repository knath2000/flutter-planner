// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planner/main.dart';
// Import the mock setup
import './mock_firebase_setup.dart';

void main() async {
  // Make main async
  // Ensure bindings are initialized BEFORE Firebase setup
  TestWidgetsFlutterBinding.ensureInitialized();
  // Setup mock Firebase handlers for testing
  await setupFirebaseCoreMocks();

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize Firebase before pumping the widget
    await Firebase.initializeApp();
    // Build our app and trigger a frame.
    // Pump the widget wrapped in ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

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
