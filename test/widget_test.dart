import 'package:flutter_test/flutter_test.dart';
import 'package:tamil_srt_app/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TamilSubtitleApp());

    expect(find.text('Tamil AI Subtitle'), findsOneWidget);
    expect(find.text('Tamil → English Subtitles'), findsOneWidget);
  });
}