import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../core/wl_colors.dart';
import 'wl_far_view.dart';

class WLCavernAtmosphere {
  WLCavernAtmosphere._();

  static Future<void> mount({
    required FlameGame game,
    required Vector2 worldSize,
    required Images mapImages,
  }) async {
    game.camera.backdrop.add(WLCavernSky());
    await WLFarView.mount(
      world: game.world,
      worldSize: worldSize,
      mapImages: mapImages,
    );
    await game.world.add(
      WLMoteField(
        worldSize: worldSize,
        count: 36,
        minRadius: 8,
        maxRadius: 22,
        minOpacity: 0.10,
        maxOpacity: 0.28,
        minDrift: 6,
        maxDrift: 16,
        seed: 3,
        priority: -22,
      ),
    );
    await game.world.add(
      WLMoteField(
        worldSize: worldSize,
        count: 48,
        minRadius: 2.5,
        maxRadius: 7,
        minOpacity: 0.14,
        maxOpacity: 0.40,
        minDrift: 12,
        maxDrift: 30,
        seed: 11,
        priority: 8,
      ),
    );
    game.camera.viewport.add(WLVignette());
  }
}

class WLCavernSky extends Component with HasGameReference<FlameGame> {
  @override
  int get priority => -100;

  @override
  void render(Canvas canvas) {
    final size = game.size;
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final center = Offset(size.x * 0.5, size.y * 0.42);
    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()
        ..shader = Gradient.radial(
          center,
          size.x * 0.78,
          const [
            WLColors.cavernMistGlow,
            WLColors.cavernGlow,
            WLColors.cavernMid,
            WLColors.cavernDeep,
          ],
          const [0.0, 0.28, 0.62, 1.0],
        ),
    );
  }
}

class WLVignette extends Component with HasGameReference<FlameGame> {
  @override
  int get priority => 1000;

  @override
  void render(Canvas canvas) {
    final size = game.size;
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()
        ..shader = Gradient.radial(
          Offset(size.x * 0.5, size.y * 0.48),
          size.x * 0.76,
          const [
            Color(0x00000000),
            Color(0xB0051018),
          ],
          const [0.42, 1.0],
        ),
    );
  }
}

class WLMoteField extends Component {
  WLMoteField({
    required this.worldSize,
    this.count = 56,
    this.minRadius = 3.5,
    this.maxRadius = 10.5,
    this.minOpacity = 0.12,
    this.maxOpacity = 0.47,
    this.minDrift = 12,
    this.maxDrift = 40,
    int seed = 11,
    int priority = 8,
  })  : _rng = Random(seed),
        super(priority: priority);

  final Vector2 worldSize;
  final int count;
  final double minRadius;
  final double maxRadius;
  final double minOpacity;
  final double maxOpacity;
  final double minDrift;
  final double maxDrift;
  final Random _rng;
  final List<_WLMote> _motes = [];
  final Paint _paint = Paint()..blendMode = BlendMode.plus;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < count; i++) {
      _motes.add(_WLMote.spawn(this, _rng));
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

class _WLMote {
  _WLMote({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.drift,
    required this.sway,
  });

  factory _WLMote.spawn(WLMoteField field, Random rng) {
    return _WLMote(
      x: rng.nextDouble() * field.worldSize.x,
      y: rng.nextDouble() * field.worldSize.y,
      radius: field.minRadius +
          rng.nextDouble() * (field.maxRadius - field.minRadius),
      opacity: field.minOpacity +
          rng.nextDouble() * (field.maxOpacity - field.minOpacity),
      drift: field.minDrift +
          rng.nextDouble() * (field.maxDrift - field.minDrift),
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
