import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../core/wl_map_constants.dart';

class WLCavernAtmosphere {
  WLCavernAtmosphere._();

  static Future<void> mount({
    required FlameGame game,
    required Vector2 worldSize,
    required Images mapImages,
  }) async {
    game.camera.backdrop.add(WLCavernSky());
    await _addDistantHills(game.world, worldSize, mapImages);
    await game.world.add(WLMoteField(worldSize: worldSize));
    game.camera.viewport.add(WLVignette());
  }
  
  // Thêm đồi rêu xa vào background
  static Future<void> _addDistantHills(
    World world,
    Vector2 worldSize,
    Images mapImages,
  ) async {
    final sheet = await mapImages.load(WLMapConstants.hillsSheet);
    final stamps = <WLHillStamp>[
      WLHillStamp(
        image: sheet,
        srcPosition: Vector2(632, 608),
        srcSize: Vector2(1265, 865),
        position: Vector2(worldSize.x * 0.50, worldSize.y * 0.42),
        scale: Vector2.all(2.4),
        opacity: 0.22,
      ),
      WLHillStamp(
        image: sheet,
        srcPosition: Vector2(48, 1496),
        srcSize: Vector2(1345, 481),
        position: Vector2(worldSize.x * 0.22, worldSize.y * 0.38),
        scale: Vector2.all(1.9),
        opacity: 0.28,
      ),
      WLHillStamp(
        image: sheet,
        srcPosition: Vector2(680, 24),
        srcSize: Vector2(1169, 513),
        position: Vector2(worldSize.x * 0.78, worldSize.y * 0.34),
        scale: Vector2.all(1.7),
        opacity: 0.24,
      ),
      WLHillStamp(
        image: sheet,
        srcPosition: Vector2(56, 560),
        srcSize: Vector2(401, 385),
        position: Vector2(worldSize.x * 0.36, worldSize.y * 0.18),
        scale: Vector2.all(2.2),
        opacity: 0.18,
      ),
    ];
    await world.addAll(stamps);
  }
}

// Thêm sky background
class WLCavernSky extends Component with HasGameReference<FlameGame> {
  @override
  int get priority => -100;

  @override
  void render(Canvas canvas) {
    final size = game.size;
    if (size.x <= 0 || size.y <= 0) {
      return;
    }
    final paint = Paint()
      ..shader = Gradient.radial(
        Offset(size.x * 0.5, size.y * 0.42),
        size.x * 0.72,
        const [
          Color(0xFF2A8A96),
          Color(0xFF12485A),
          Color(0xFF071820),
        ],
        const [0.0, 0.42, 1.0],
      );
    canvas.drawRect(Offset.zero & Size(size.x, size.y), paint);
  }
}

// Thêm vignette effect
class WLVignette extends Component with HasGameReference<FlameGame> {
  @override
  int get priority => 1000;

  @override
  void render(Canvas canvas) {
    final size = game.size;
    if (size.x <= 0 || size.y <= 0) {
      return;
    }
    final paint = Paint()
      ..shader = Gradient.radial(
        Offset(size.x * 0.5, size.y * 0.48),
        size.x * 0.74,
        const [
          Color(0x00000000),
          Color(0xA0051018),
        ],
        const [0.48, 1.0],
      );
    canvas.drawRect(Offset.zero & Size(size.x, size.y), paint);
  }
}

// Thêm stamp đồi rêu xa
class WLHillStamp extends SpriteComponent {
  WLHillStamp({
    required Image image,
    required Vector2 srcPosition,
    required Vector2 srcSize,
    required Vector2 position,
    required Vector2 scale,
    required double opacity,
  }) : super(
          sprite: Sprite(
            image,
            srcPosition: srcPosition,
            srcSize: srcSize,
          ),
          size: srcSize,
          position: position,
          scale: scale,
          anchor: Anchor.center,
          priority: -20,
        ) {
    this.opacity = opacity;
  }
}


// Thêm môt field vào background
class WLMoteField extends Component {
  WLMoteField({
    required this.worldSize,
    this.count = 56,
  }) : super(priority: 8);

  final Vector2 worldSize;
  final int count;
  final Random _rng = Random(11);
  final List<_WLMote> _motes = [];
  final Paint _paint = Paint()..blendMode = BlendMode.plus;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < count; i++) {
      _motes.add(_WLMote.spawn(_rng, worldSize));
    }
  }

  @override
  void update(double dt) {
    for (final mote in _motes) {
      mote.y -= mote.drift * dt;
      mote.x += mote.sway * dt;
      if (mote.y < -20) {
        mote.y = worldSize.y + 20;
        mote.x = _rng.nextDouble() * worldSize.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (final mote in _motes) {
      _paint.color = Color.fromRGBO(230, 255, 255, mote.opacity);
      canvas.drawCircle(Offset(mote.x, mote.y), mote.radius, _paint);
    }
  }
}

// Thêm môt field vào background
class _WLMote {
  _WLMote({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.drift,
    required this.sway,
  });

  factory _WLMote.spawn(Random rng, Vector2 worldSize) {
    return _WLMote(
      x: rng.nextDouble() * worldSize.x,
      y: rng.nextDouble() * worldSize.y,
      radius: 3.5 + rng.nextDouble() * 7,
      opacity: 0.12 + rng.nextDouble() * 0.35,
      drift: 12 + rng.nextDouble() * 28,
      sway: (rng.nextDouble() - 0.5) * 10,
    );
  }

  double x;
  double y;
  final double radius;
  final double opacity;
  final double drift;
  final double sway;
}
