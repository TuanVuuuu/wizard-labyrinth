import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:wizard/core/wl_colors.dart';

class WLMoteField extends Component {
  WLMoteField({
    required this.worldSize,
    this.count = 56, // Số lượng mote
    this.minRadius = 3.5, // Bán kính nhỏ nhất
    this.maxRadius = 10.5, // Bán kính lớn nhất
    this.minOpacity = 0.12, // Độ trong nhất
    this.maxOpacity = 0.47, // Độ trong lớn nhất
    this.minDrift = 12, // Tốc độ lơ lửng nhỏ nhất
    this.maxDrift = 40, // Tốc độ lơ lửng lớn nhất
    int seed = 11, // Seed cho random
    int priority = 8, // Độ ưu tiên
  })  : _rng = Random(seed), // Random seed
        super(priority: priority); // Độ ưu tiên

  static const double _wrapPadding = 28;

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
      _advanceMote(mote, dt);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final mote in _motes) {
      _drawMote(canvas, mote);
    }
  }

  void _advanceMote(_WLMote mote, double dt) {
    mote.age += dt;
    final wave = mote.age * 1.7 + mote.phase;
    mote.x += (mote.sway + sin(wave) * mote.wobbleX) * dt;
    mote.y += (-mote.drift + cos(wave * 0.85) * mote.wobbleY) * dt;
    _wrapMote(mote);
  }

  void _wrapMote(_WLMote mote) {
    if (mote.y < -_wrapPadding) {
      mote.y = worldSize.y + _wrapPadding;
      mote.x = _rng.nextDouble() * worldSize.x;
    }
    if (mote.x < -_wrapPadding) {
      mote.x = worldSize.x + _wrapPadding;
      return;
    }
    if (mote.x > worldSize.x + _wrapPadding) {
      mote.x = -_wrapPadding;
    }
  }

  void _drawMote(Canvas canvas, _WLMote mote) {
    final glow = mote.glow;
    final center = Offset(mote.x, mote.y);
    _drawHalo(canvas, center, mote.radius, glow);
    _drawCore(canvas, center, mote.radius, glow);
  }

  void _drawHalo(Canvas canvas, Offset center, double radius, double glow) {
    _paint.color = WLColors.cavernGlow.withValues(alpha: glow * 0.38);
    canvas.drawCircle(center, radius * 3.6, _paint);
    _paint.color = WLColors.cavernMistGlow.withValues(alpha: glow * 0.28);
    canvas.drawCircle(center, radius * 2.1, _paint);
  }

  void _drawCore(Canvas canvas, Offset center, double radius, double glow) {
    _paint.color = WLColors.cavernMistGlow.withValues(alpha: glow);
    canvas.drawCircle(center, radius * 0.72, _paint);
    _paint.color = WLColors.mist.withValues(alpha: glow * 0.9);
    canvas.drawCircle(center, radius * 0.28, _paint);
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
    required this.wobbleX,
    required this.wobbleY,
    required this.phase,
    required this.pulseSpeed,
    required this.loopDuration,
    required this.age,
  });

  factory _WLMote.spawn(WLMoteField field, Random rng) {
    return _WLMote(
      x: rng.nextDouble() * field.worldSize.x,
      y: rng.nextDouble() * field.worldSize.y,
      radius: _between(rng, field.minRadius, field.maxRadius),
      opacity: _between(rng, field.minOpacity, field.maxOpacity),
      drift: _between(rng, field.minDrift, field.maxDrift),
      sway: (rng.nextDouble() - 0.5) * 42,
      wobbleX: _between(rng, 16, 38),
      wobbleY: _between(rng, 5, 12),
      phase: rng.nextDouble() * pi * 2,
      pulseSpeed: _between(rng, 1.2, 2.8),
      loopDuration: _between(rng, 2.8, 5.6),
      age: rng.nextDouble() * 20,
    );
  }

  static double _between(Random rng, double min, double max) {
    return min + rng.nextDouble() * (max - min);
  }

  double x;
  double y;
  double age;
  final double radius;
  final double opacity;
  final double drift;
  final double sway;
  final double wobbleX;
  final double wobbleY;
  final double phase;
  final double pulseSpeed;
  final double loopDuration;

  double get glow {
    final pulse = 0.55 + 0.45 * sin(age * pulseSpeed + phase);
    final loop = 0.5 + 0.5 * sin(age * (pi * 2 / loopDuration) + phase);
    return opacity * pulse * (0.35 + 0.65 * loop);
  }
}
