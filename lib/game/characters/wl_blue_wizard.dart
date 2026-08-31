import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../core/wl_character_constants.dart';
import '../levels/wl_player_spawn.dart';
import '../physics/wl_tile_collision_map.dart';
import 'wl_wizard_animations.dart';

class WLBlueWizard extends SpriteAnimationGroupComponent<WLWizardAnimState> {
  WLBlueWizard({
    required Map<WLWizardAnimState, SpriteAnimation> animations,
    required Vector2 position,
    required WLTileCollisionMap collisionMap,
  })  : _collisionMap = collisionMap,
        _velocity = Vector2.zero(),
        super(
          animations: animations,
          current: WLWizardAnimState.idle,
          position: position,
          anchor: Anchor.bottomCenter,
          size: Vector2.all(WLCharacterConstants.displaySize),
          priority: 10,
        );

  final WLTileCollisionMap _collisionMap;
  final Vector2 _velocity;
  bool _grounded = false;

  int _facing = 1;

  bool get isGrounded => _grounded;

  static Future<WLBlueWizard> spawn({
    required FlameGame game,
    required WLTileCollisionMap collisionMap,
    WLPlayerSpawn? spawnPoint,
  }) async {
    final animations = await WLWizardAnimations.loadAll();
    final resolved = spawnPoint ?? WLPlayerSpawn.fallback();
    final wizard = WLBlueWizard(
      animations: animations,
      position: resolved.position,
      collisionMap: collisionMap,
    );
    wizard.setFacing(resolved.facing);
    return wizard;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final result = WLPlatformerPhysics.step(
      position: position,
      velocity: _velocity,
      grounded: _grounded,
      hitboxWidth: WLCharacterConstants.hitboxWidth,
      hitboxHeight: WLCharacterConstants.hitboxHeight,
      dt: dt,
      solids: _collisionMap.solids,
      gravity: WLCharacterConstants.gravity,
      maxFallSpeed: WLCharacterConstants.maxFallSpeed,
      skin: WLCharacterConstants.collisionSkin,
    );

    position.setFrom(result.position);
    _velocity.setFrom(result.velocity);
    _grounded = result.grounded;
    _syncAnimation();
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

  void _syncAnimation() {
    if (_grounded) {
      play(WLWizardAnimState.idle);
      return;
    }
    if (_velocity.y < 0) {
      play(WLWizardAnimState.jump);
      return;
    }
    play(WLWizardAnimState.idle);
  }
}
