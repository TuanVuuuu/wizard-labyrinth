import 'package:flutter_test/flutter_test.dart';
import 'package:wizard/game/wl_wizard_game.dart';
import 'package:wizard/main.dart';

void main() {
  test('WLWizardGame can be constructed', () {
    expect(WLWizardGame(), isA<WLWizardGame>());
  });

  testWidgets('app hosts the game widget', (tester) async {
    await tester.pumpWidget(const WLApp());
    expect(find.byType(WLGamePage), findsOneWidget);
  });
}
