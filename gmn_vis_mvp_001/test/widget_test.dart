// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:gmn_vis_mvp_001/main.dart';

void main() {
  testWidgets('Vision Demo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VisionDemoApp());

    // Verify that the app starts with the camera screen
    expect(find.text('Vision Demo'), findsOneWidget);
  });
}
