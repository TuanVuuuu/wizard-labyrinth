import 'package:flame/components.dart';

/// Kết quả một bước vật lý: vị trí, vận tốc, và đang đứng đất hay không.
class WLPhysicsStepResult {
  const WLPhysicsStepResult({
    required this.position,
    required this.velocity,
    required this.grounded,
  });

  /// Vị trí nhân vật sau bước này (neo ở chân).
  final Vector2 position;

  /// Vận tốc (velocity: tốc độ theo trục x/y) sau bước này.
  final Vector2 velocity;

  /// True nếu chân đang đứng trên nền đặc.
  final bool grounded;
}
