import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Nền parallax: 0 = dính camera, 1 = cuộn cùng map.
class WLPanoramaLayer extends SpriteComponent
    with HasGameReference<FlameGame> {
  WLPanoramaLayer({
    required Image image,
    required Vector2 worldSize,
    required this.factorX,
    required this.factorY,
    super.priority,
  }) : worldSize = worldSize.clone(),
       super(
         sprite: Sprite(image),
         anchor: Anchor.topLeft,
       );

  final Vector2 worldSize;
  final double factorX;
  final double factorY;

  static const double _edgeBleed = 0.5;

  @override
  void update(double dt) {
    super.update(dt);
    final visible = game.camera.visibleWorldRect;
    if (visible.width <= 0 || visible.height <= 0) {
      return;
    }
    _fitToParallaxTravel(visible);
    _followCamera(visible);
  }

  void _fitToParallaxTravel(Rect visible) {
    final currentSprite = sprite;
    if (currentSprite == null) {
      return;
    }
    final src = currentSprite.srcSize;
    if (src.x <= 0 || src.y <= 0) {
      return;
    }

    final needed = _neededSize(visible);
    final aspect = src.x / src.y;
    var width = needed.x;
    var height = needed.y;
    if (width / height > aspect) {
      height = width / aspect;
    } else {
      width = height * aspect;
    }
    size.setValues(width, height);
  }

  Vector2 _neededSize(Rect visible) {
    final travelX = max(worldSize.x - visible.width, 0.0);
    final travelY = max(worldSize.y - visible.height, 0.0);
    final bleedX = visible.width * _edgeBleed;
    final bleedY = visible.height * _edgeBleed;
    return Vector2(
      visible.width + travelX * factorX + bleedX * 2,
      visible.height + travelY * factorY + bleedY * 2,
    );
  }

  void _followCamera(Rect visible) {
    final bleedX = visible.width * _edgeBleed;
    final bleedY = visible.height * _edgeBleed;
    position.setValues(
      visible.left * (1 - factorX) - bleedX,
      visible.top * (1 - factorY) - bleedY,
    );
  }
}
