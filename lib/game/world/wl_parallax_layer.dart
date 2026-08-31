import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

/// Lớp world cuộn chậm hơn camera. `factor` 0 = dính màn, 1 = bám map.
class WLParallaxLayer extends PositionComponent
    with HasGameReference<FlameGame> {
  WLParallaxLayer({
    required this.factorX,
    required this.factorY,
    Color? tint,
    double blurSigma = 0,
    super.priority,
  }) {
    if (blurSigma > 0) {
      decorator.addLast(PaintDecorator.blur(blurSigma));
    }
    if (tint != null) {
      decorator.addLast(PaintDecorator.tint(tint));
    }
  }

  final double factorX;
  final double factorY;

  @override
  void update(double dt) {
    super.update(dt);
    final cameraPos = game.camera.viewfinder.position;
    position.setValues(
      cameraPos.x * (1 - factorX),
      cameraPos.y * (1 - factorY),
    );
  }
}
