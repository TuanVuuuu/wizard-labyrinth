import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:wizard/core/wl_colors.dart';
import 'package:wizard/game/world/wl_far_view.dart';
import 'package:wizard/game/world/wl_mote_field.dart';

class WLCavernAtmosphere {
  WLCavernAtmosphere._();

  static Future<void> mount({
    required FlameGame game,
    required Vector2 worldSize,
  }) async {
    game.camera.backdrop.add(WLCavernSky());
    await WLFarView.mount(
      world: game.world,
      worldSize: worldSize,
    );
    await game.world.add(
      WLMoteField(
        worldSize: worldSize,
        count: 72, // Số lượng mote
        minRadius: 8,
        maxRadius: 22,
        minOpacity: 0.14,
        maxOpacity: 0.34,
        minDrift: 12, // Tốc độ lơ lửng nhỏ nhất
        maxDrift: 28, // Tốc độ lơ lửng lớn nhất
        seed: 3,
        priority: -22,
      ),
    );
    await game.world.add(
      WLMoteField(
        worldSize: worldSize,
        count: 96,
        minRadius: 2.5,
        maxRadius: 7,
        minOpacity: 0.20,
        maxOpacity: 0.52,
        minDrift: 24,
        maxDrift: 58,
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
