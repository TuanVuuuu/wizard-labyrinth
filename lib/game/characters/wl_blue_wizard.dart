import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../core/wl_character_constants.dart';
import '../levels/wl_player_spawn.dart';
import 'wl_wizard_animations.dart';

class WLBlueWizard extends SpriteAnimationGroupComponent<WLWizardAnimState> {
  WLBlueWizard({
    required Map<WLWizardAnimState, SpriteAnimation> animations,
    required Vector2 position,
  }) : super(
          animations: animations,
          current: WLWizardAnimState.idle,
          position: position,
          anchor: Anchor.bottomCenter,
          size: Vector2.all(WLCharacterConstants.displaySize),
          priority: 10,
        );

  int _facing = 1;

  static Future<WLBlueWizard> spawn({
    required FlameGame game,
    WLPlayerSpawn? spawnPoint,
  }) async {
    final animations = await WLWizardAnimations.loadAll();
    final resolved = spawnPoint ?? WLPlayerSpawn.fallback();
    final wizard = WLBlueWizard(
      animations: animations,
      position: resolved.position,
    );
    wizard.setFacing(resolved.facing);
    return wizard;
  }

  void play(WLWizardAnimState state) {
    if (current == state) {
      return;
    }
    current = state;
  }

  void setFacing(int direction) {
    if (direction == 0) {
      return;
    }
    final nextFacing = direction > 0 ? 1 : -1;
    if (_facing == nextFacing) {
      return;
    }
    _facing = nextFacing;
    scale.x = _facing.toDouble();
  }

  int get facing => _facing;
}
