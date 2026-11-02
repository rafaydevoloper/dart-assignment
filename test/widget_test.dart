
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_voice_recorder/main.dart';

void main() {
  testWidgets('Voice recorder app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const VoiceRecorderApp());

    expect(find.text('BlueWave'), findsOneWidget);
    expect(find.text('Captured perfectly.'), findsOneWidget);
  });
}
