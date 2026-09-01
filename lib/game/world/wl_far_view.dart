import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';

import '../../core/wl_map_constants.dart';
import 'wl_panorama_layer.dart';

class WLFarView {
  WLFarView._();

  static final Images images = Images(prefix: WLMapConstants.backgroundPrefix);

  static const double _distantFactorX = 0.18;
  static const double _distantFactorY = 0.06;
  static const double _hazeFactorX = 0.52;
  static const double _hazeFactorY = 0.18;

  static Future<void> mount({
    required World world,
    required Vector2 worldSize,
  }) async {
    final farHills = await images.load(WLMapConstants.farHillsAsset);
    final midHaze = await images.load(WLMapConstants.midHazeAsset);

    await world.add(
      WLPanoramaLayer(
        image: farHills,
        worldSize: worldSize,
        factorX: _distantFactorX,
        factorY: _distantFactorY,
        priority: -40,
      ),
    );
    await world.add(
      WLPanoramaLayer(
        image: midHaze,
        worldSize: worldSize,
        factorX: _hazeFactorX,
        factorY: _hazeFactorY,
        priority: -28,
      ),
    );
  }
}
