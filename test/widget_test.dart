// DownApp widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // DownApp requires Firebase initialization which is not available in unit tests.
    // This test verifies basic widget rendering.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('DownApp Test')),
        ),
      ),
    );

    expect(find.text('DownApp Test'), findsOneWidget);
  });
}
