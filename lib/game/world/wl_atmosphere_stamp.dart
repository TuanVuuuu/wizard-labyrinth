import 'dart:ui';

import 'package:flame/components.dart';

class WLAtmosphereStamp extends SpriteComponent {
  WLAtmosphereStamp({
    required Image image,
    required Vector2 srcPosition,
    required Vector2 srcSize,
    required Vector2 position,
    required double scale,
    double opacity = 1,
    Anchor anchor = Anchor.center,
  }) : super(
          sprite: Sprite(
            image,
            srcPosition: srcPosition,
            srcSize: srcSize,
          ),
          size: srcSize,
          position: position,
          scale: Vector2.all(scale),
          anchor: anchor,
        ) {
    this.opacity = opacity;
  }
}
