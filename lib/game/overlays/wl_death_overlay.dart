import 'package:flutter/material.dart';

import '../../routes/navigate.dart';
import '../../ui/wl_menu_button.dart';
import '../../ui/wl_menu_overlay.dart';
import '../wl_wizard_game.dart';

class WLDeathOverlay extends StatelessWidget {
  const WLDeathOverlay({super.key, required this.game});

  final WLWizardGame game;

  @override
  Widget build(BuildContext context) {
    return WLMenuOverlay(
      title: 'Bạn đã chết',
      actions: [
        WLMenuButton(
          label: 'Chơi lại',
          onPressed: game.restartAfterDeath,
        ),
        WLMenuButton(
          label: 'Thoát game',
          variant: WLMenuButtonVariant.secondary,
          onPressed: () => WLNavigate.exitGame(context),
        ),
      ],
    );
  }
}
