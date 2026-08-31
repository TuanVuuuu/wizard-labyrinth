import 'package:flutter/material.dart';

import '../../core/wl_colors.dart';
import '../input/wl_game_controls.dart';
import '../wl_wizard_game.dart';

class WLGameHud extends StatelessWidget {
  const WLGameHud({super.key, required this.game});

  final WLWizardGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: WLGameControls.hudMargin * 0.4,
            right: WLGameControls.hudMargin * 0.7,
          ),
          child: _WLPauseHudButton(onPressed: game.pauseGame),
        ),
      ),
    );
  }
}

class _WLPauseHudButton extends StatelessWidget {
  const _WLPauseHudButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: 'Tạm dừng',
      style: IconButton.styleFrom(
        backgroundColor: WLColors.teal.withValues(alpha: 0.72),
        foregroundColor: WLColors.mist,
        side: BorderSide(color: WLColors.mist.withValues(alpha: 0.7)),
        minimumSize: const Size(52, 52),
      ),
      icon: const Icon(Icons.pause_rounded, size: 28),
    );
  }
}
