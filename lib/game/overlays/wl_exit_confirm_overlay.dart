import 'package:flutter/material.dart';

import '../../routes/navigate.dart';
import '../../ui/wl_menu_button.dart';
import '../../ui/wl_menu_overlay.dart';
import '../wl_wizard_game.dart';

class WLExitConfirmOverlay extends StatelessWidget {
  const WLExitConfirmOverlay({super.key, required this.game});

  final WLWizardGame game;

  @override
  Widget build(BuildContext context) {
    return WLMenuOverlay(
      title: 'Bạn có chắc muốn thoát game?',
      actions: [
        WLMenuButton(
          label: 'Huỷ',
          variant: WLMenuButtonVariant.secondary,
          onPressed: game.closeExitConfirm,
        ),
        WLMenuButton(
          label: 'Đồng ý',
          onPressed: () => WLNavigate.exitGame(context),
        ),
      ],
    );
  }
}
