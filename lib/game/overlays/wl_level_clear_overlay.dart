import 'package:flutter/material.dart';

import 'package:wizard/game/wl_wizard_game.dart';
import 'package:wizard/routes/navigate.dart';
import 'package:wizard/ui/wl_menu_button.dart';
import 'package:wizard/ui/wl_menu_overlay.dart';

class WLLevelClearOverlay extends StatelessWidget {
  const WLLevelClearOverlay({super.key, required this.game});

  final WLWizardGame game;

  @override
  Widget build(BuildContext context) {
    return WLMenuOverlay(
      title: 'Bạn đã qua màn',
      actions: [
        WLMenuButton(
          label: 'Chơi lại',
          onPressed: game.restartAfterClear,
        ),
        WLMenuButton(
          label: 'Về menu',
          variant: WLMenuButtonVariant.secondary,
          onPressed: () => WLNavigate.exitGame(context),
        ),
      ],
    );
  }
}
