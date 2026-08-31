import 'package:flutter/material.dart';

import '../../core/wl_colors.dart';
import '../../core/wl_font.dart';
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: game.livesNotifier,
                builder: (context, lives, _) {
                  return _WLLivesIndicator(lives: lives);
                },
              ),
              const SizedBox(width: 12),
              _WLPauseHudButton(onPressed: game.pauseGame),
            ],
          ),
        ),
      ),
    );
  }
}

class _WLLivesIndicator extends StatelessWidget {
  const _WLLivesIndicator({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: WLColors.teal.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: WLColors.mist.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_rounded,
            color: WLColors.lifeHeart,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '$lives',
            style: WLFont.large.bold,
          ),
        ],
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
