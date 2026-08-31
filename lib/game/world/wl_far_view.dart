import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';

import '../../core/wl_colors.dart';
import '../../core/wl_map_constants.dart';
import 'wl_atmosphere_stamp.dart';
import 'wl_parallax_layer.dart';

class WLFarView {
  WLFarView._();

  static const double _distantFactorX = 0.22;
  static const double _distantFactorY = 0.08;
  static const double _hazeFactorX = 0.42;
  static const double _hazeFactorY = 0.14;

  static Future<void> mount({
    required World world,
    required Vector2 worldSize,
    required Images mapImages,
  }) async {
    final hills = await mapImages.load(WLMapConstants.hillsSheet);
    final moss = await mapImages.load(
      WLMapConstants.backgroundDecorationSheet,
    );
    final plants = await mapImages.load(WLMapConstants.hangingPlantsSheet);
    final vines = await mapImages.load(WLMapConstants.decorationsSheet);

    final distant = WLParallaxLayer(
      factorX: _distantFactorX,
      factorY: _distantFactorY,
      tint: WLColors.farSilhouette,
      blurSigma: 16,
      priority: -40,
    );
    distant.addAll(_distantStamps(worldSize, hills, moss));
    await world.add(distant);

    final haze = WLParallaxLayer(
      factorX: _hazeFactorX,
      factorY: _hazeFactorY,
      tint: WLColors.hazeSilhouette,
      blurSigma: 6,
      priority: -28,
    );
    haze.addAll(_hazeStamps(worldSize, moss, plants, vines));
    await world.add(haze);
  }

  static List<Component> _distantStamps(
    Vector2 worldSize,
    Image hills,
    Image moss,
  ) {
    const ridge = [88.0, 1512.0, 1260.0, 352.0];
    const oval = [652.0, 620.0, 1232.0, 852.0];
    const mound = [720.0, 40.0, 1096.0, 404.0];
    const hillock = [2400.0, 2364.0, 1680.0, 1708.0];
    const shelf = [2388.0, 1412.0, 1676.0, 860.0];
    const clump = [1460.0, 1584.0, 528.0, 300.0];

    return [
      ..._alongX(
        hills,
        src: ridge,
        worldSize: worldSize,
        nx: const [0.06, 0.28, 0.52, 0.76],
        ny: 0.62,
        scale: 3.0,
        opacity: 0.70,
      ),
      ..._alongX(
        hills,
        src: oval,
        worldSize: worldSize,
        nx: const [0.16, 0.48, 0.82],
        ny: 0.50,
        scale: 2.6,
        opacity: 0.58,
      ),
      ..._alongX(
        moss,
        src: hillock,
        worldSize: worldSize,
        nx: const [0.10, 0.40, 0.70],
        ny: 0.66,
        scale: 1.25,
        opacity: 0.52,
      ),
      ..._alongX(
        moss,
        src: shelf,
        worldSize: worldSize,
        nx: const [0.22, 0.58, 0.90],
        ny: 0.58,
        scale: 1.35,
        opacity: 0.48,
      ),
      _stamp(
        hills,
        src: mound,
        at: _pos(worldSize, 0.34, 0.44),
        scale: 2.4,
        opacity: 0.50,
      ),
      _stamp(
        hills,
        src: clump,
        at: _pos(worldSize, 0.88, 0.42),
        scale: 2.5,
        opacity: 0.42,
      ),
    ];
  }

  static List<Component> _hazeStamps(
    Vector2 worldSize,
    Image moss,
    Image plants,
    Image vines,
  ) {
    const tallPillar = [20.0, 48.0, 1044.0, 4024.0];
    const midPillar = [1196.0, 48.0, 1032.0, 2344.0];
    const cloudMound = [2676.0, 128.0, 1084.0, 960.0];
    const smallMound = [1220.0, 2616.0, 916.0, 600.0];
    const vineColumn = [2140.0, 2792.0, 364.0, 1064.0];
    const vineTwist = [2644.0, 2772.0, 388.0, 988.0];
    const clusterA = [240.0, 2088.0, 284.0, 684.0];
    const clusterB = [752.0, 2096.0, 284.0, 676.0];
    const frond = [624.0, 632.0, 152.0, 452.0];
    const curvedLeaf = [1228.0, 2360.0, 532.0, 384.0];

    return [
      ..._alongX(
        moss,
        src: tallPillar,
        worldSize: worldSize,
        nx: const [0.04, 0.96],
        ny: 0.52,
        scale: 1.0,
        opacity: 0.74,
      ),
      ..._alongX(
        moss,
        src: midPillar,
        worldSize: worldSize,
        nx: const [0.20, 0.80],
        ny: 0.40,
        scale: 1.1,
        opacity: 0.66,
      ),
      ..._alongX(
        moss,
        src: cloudMound,
        worldSize: worldSize,
        nx: const [0.12, 0.38, 0.64, 0.88],
        ny: 0.58,
        scale: 1.45,
        opacity: 0.70,
      ),
      ..._alongX(
        moss,
        src: smallMound,
        worldSize: worldSize,
        nx: const [0.26, 0.52, 0.78],
        ny: 0.62,
        scale: 1.6,
        opacity: 0.64,
      ),
      _stamp(
        vines,
        src: vineColumn,
        at: _pos(worldSize, 0.14, 0.46),
        scale: 1.8,
        opacity: 0.52,
      ),
      _stamp(
        vines,
        src: vineTwist,
        at: _pos(worldSize, 0.86, 0.44),
        scale: 1.7,
        opacity: 0.50,
      ),
      ..._hangingAlongX(
        plants,
        src: clusterA,
        worldSize: worldSize,
        nx: const [0.10, 0.42, 0.74],
        ny: 0.08,
        scale: 2.4,
        opacity: 0.62,
      ),
      ..._hangingAlongX(
        plants,
        src: clusterB,
        worldSize: worldSize,
        nx: const [0.26, 0.58, 0.90],
        ny: 0.06,
        scale: 2.5,
        opacity: 0.58,
      ),
      ..._hangingAlongX(
        plants,
        src: frond,
        worldSize: worldSize,
        nx: const [0.18, 0.50, 0.82],
        ny: 0.10,
        scale: 2.7,
        opacity: 0.50,
      ),
      _hanging(
        plants,
        src: curvedLeaf,
        at: _pos(worldSize, 0.66, 0.12),
        scale: 2.0,
        opacity: 0.55,
      ),
    ];
  }

  static List<WLAtmosphereStamp> _alongX(
    Image image, {
    required List<double> src,
    required Vector2 worldSize,
    required List<double> nx,
    required double ny,
    required double scale,
    required double opacity,
  }) {
    return [
      for (final x in nx)
        _stamp(
          image,
          src: src,
          at: _pos(worldSize, x, ny),
          scale: scale,
          opacity: opacity,
        ),
    ];
  }

  static List<WLAtmosphereStamp> _hangingAlongX(
    Image image, {
    required List<double> src,
    required Vector2 worldSize,
    required List<double> nx,
    required double ny,
    required double scale,
    required double opacity,
  }) {
    return [
      for (final x in nx)
        _hanging(
          image,
          src: src,
          at: _pos(worldSize, x, ny),
          scale: scale,
          opacity: opacity,
        ),
    ];
  }

  static WLAtmosphereStamp _stamp(
    Image image, {
    required List<double> src,
    required Vector2 at,
    required double scale,
    required double opacity,
  }) {
    return WLAtmosphereStamp(
      image: image,
      srcPosition: Vector2(src[0], src[1]),
      srcSize: Vector2(src[2], src[3]),
      position: at,
      scale: scale,
      opacity: opacity,
    );
  }

  static WLAtmosphereStamp _hanging(
    Image image, {
    required List<double> src,
    required Vector2 at,
    required double scale,
    required double opacity,
  }) {
    return WLAtmosphereStamp(
      image: image,
      srcPosition: Vector2(src[0], src[1]),
      srcSize: Vector2(src[2], src[3]),
      position: at,
      scale: scale,
      opacity: opacity,
      anchor: Anchor.topCenter,
    );
  }

  static Vector2 _pos(Vector2 worldSize, double nx, double ny) {
    return Vector2(worldSize.x * nx, worldSize.y * ny);
  }
}
