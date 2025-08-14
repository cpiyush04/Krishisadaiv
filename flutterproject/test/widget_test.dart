// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutterproject/main.dart';

void main() {
  testWidgets('Crop Disease Diagnosis App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CropDiseaseApp());

    // Verify that the app title is displayed.
    expect(find.text('Crop Disease Diagnosis'), findsOneWidget);

    // Verify that the image selection buttons are present.
    expect(find.text('Pick from Gallery'), findsOneWidget);
    expect(find.text('Take Picture'), findsOneWidget);

    // Verify that the placeholder text is displayed when no image is selected.
    expect(find.text('Select an image to diagnose'), findsOneWidget);
  });
}
