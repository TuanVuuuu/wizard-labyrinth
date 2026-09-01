import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../core/wl_colors.dart';

/// Lớp phủ toàn màn hình khi chết — mờ dần / sáng dần.
class WLDeathScreenFade extends Component with HasGameReference<FlameGame> {
  double opacity = 0;

  @override
  int get priority => 2000;

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) {
      return;
    }

    final size = game.size;
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = WLColors.cavernDeep.withValues(alpha: opacity),
    );
  }
}
