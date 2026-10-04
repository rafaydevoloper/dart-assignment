import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Game'),
          ),
        ),
      ),
    );

    expect(find.text('Game'), findsOneWidget);
  });
}
