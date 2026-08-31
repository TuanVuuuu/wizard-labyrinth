/// Thông số nhân vật BlueWizard — khớp atlas từ `scripts/pack_spritesheet.py`.
class WLCharacterConstants {
  WLCharacterConstants._();

  static const String assetsPrefix = 'assets/';

  static const String idleSheet = 'atlas/wizard_idle.png';
  static const String walkSheet = 'atlas/wizard_walk.png';
  static const String jumpSheet = 'atlas/wizard_jump.png';

  static const double frameSize = 512;

  static const int idleFrameCount = 20;
  static const int walkFrameCount = 20;
  static const int jumpFrameCount = 8;

  static const double idleStepTime = 0.08;
  static const double walkStepTime = 0.06;
  static const double jumpStepTime = 0.07;

  /// Scale cả frame gốc lên 2× tile. Body thực ≈ 556px (~109% tile 512).
  static const double displaySize = frameSize * 2;

  static const double gravity = 2800;
  static const double maxFallSpeed = 2000;

  /// Hitbox hẹp hơn sprite (fair platforming).
  static const double hitboxWidth = displaySize * 0.28;
  static const double hitboxHeight = displaySize * 0.55;
  static const double collisionSkin = 1.5;

  /// Vị trí spawn mặc định khi map không có `player_spawn`.
  static const double defaultSpawnTileX = 2.5;
  static const double defaultSpawnTileY = 8;
}
