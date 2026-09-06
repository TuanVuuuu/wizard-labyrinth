import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import 'package:wizard/core/wl_colors.dart';
import 'package:wizard/game/characters/wl_blue_wizard.dart';

class WLHitboxDebugOverlay extends Component {
  WLHitboxDebugOverlay({
    required WLBlueWizard wizard,
    required ValueListenable<bool> visibleListenable,
  })  : _wizard = wizard,
        _visibleListenable = visibleListenable;

  final WLBlueWizard _wizard;
  final ValueListenable<bool> _visibleListenable;

  static const double _strokeWidth = 16;

  @override
  int get priority => 20;

  @override
  void render(Canvas canvas) {
    if (!_visibleListenable.value) {
      return;
    }

    final hitbox = _wizard.hitboxRect;
    canvas.drawRect(
      hitbox,
      Paint()
        ..color = WLColors.lifeHeart.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      hitbox,
      Paint()
        ..color = WLColors.lifeHeart
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }
}
