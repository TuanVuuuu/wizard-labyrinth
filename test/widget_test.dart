import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizard/game/wl_wizard_game.dart';
import 'package:wizard/main.dart';
import 'package:wizard/pages/wl_home_page.dart';

void main() {
  test('WLWizardGame can be constructed', () {
    expect(WLWizardGame(), isA<WLWizardGame>());
  });

  testWidgets('app opens home with play button', (tester) async {
    await tester.pumpWidget(const WLApp());
    expect(find.byType(WLHomePage), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('web game button shows on mobile app', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });
    await tester.pumpWidget(const WLApp());
    expect(find.text('Web game'), findsOneWidget);
  });
}
