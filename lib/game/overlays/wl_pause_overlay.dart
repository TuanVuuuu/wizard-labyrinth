import 'package:flutter/material.dart';

import '../../ui/wl_menu_button.dart';
import '../../ui/wl_menu_overlay.dart';
import '../wl_wizard_game.dart';

class WLPauseOverlay extends StatelessWidget {
  const WLPauseOverlay({super.key, required this.game});

  final WLWizardGame game;

  @override
  Widget build(BuildContext context) {
    return WLMenuOverlay(
      title: 'Tạm dừng',
      actions: [
        WLMenuButton(
          label: 'Tiếp tục',
          onPressed: game.resumeGame,
        ),
        WLMenuButton(
          label: 'Thoát game',
          variant: WLMenuButtonVariant.secondary,
          onPressed: game.openExitConfirm,
        ),
      ],
    );
  }
}
