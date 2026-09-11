import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:wizard/core/wl_character_constants.dart';
import 'package:wizard/core/wl_map_constants.dart';
import 'package:wizard/game/characters/wl_blue_wizard.dart';
import 'package:wizard/game/input/wl_game_controls.dart';
import 'package:wizard/game/input/wl_keyboard_controls.dart';
import 'package:wizard/game/input/wl_player_input.dart';
import 'package:wizard/game/levels/wl_level_exit.dart';
import 'package:wizard/game/levels/wl_level_loader.dart';
import 'package:wizard/game/levels/wl_player_spawn.dart';
import 'package:wizard/game/overlays/wl_death_screen_fade.dart';
import 'package:wizard/game/overlays/wl_game_overlay_id.dart';
import 'package:wizard/game/overlays/wl_hitbox_debug_overlay.dart';
import 'package:wizard/game/world/wl_camera_controller.dart';
import 'package:wizard/game/world/wl_cavern_atmosphere.dart';

enum _WLDeathFadePhase {
  idle, // Trạng thái bình thường (đang sống)
  fadeOut, // Hiệu ứng biến mất (chết)
  fadeIn, // Hiệu ứng hiện lại (sống lại)
}

class WLWizardGame extends FlameGame with KeyboardEvents {
  TiledComponent? _map;
  Rect? _cameraWorldBounds; // Vùng giới hạn của camera
  WLBlueWizard? _wizard;
  WLPlayerSpawn? _playerSpawn;
  WLLevelExit? _levelExit;
  WLDeathScreenFade? _deathScreenFade;
  bool _isPlayerDead = false;
  bool _isLevelCleared = false;
  _WLDeathFadePhase _deathFadePhase = _WLDeathFadePhase.idle;
  double _deathFadeElapsed = 0;
  final ValueNotifier<int> livesNotifier =
      ValueNotifier(WLCharacterConstants.startingLives);
  final ValueNotifier<bool> hitboxDebugNotifier = ValueNotifier(false);
  final WLPlayerInput _playerInput = WLPlayerInput();

  int get livesRemaining => livesNotifier.value;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final loadedMap = await WLLevelLoader.loadZone1Slice();
    final map = loadedMap.map;
    _map = map;
    // Đọc vùng giới hạn của camera từ tệp Tiled
    _cameraWorldBounds = WLLevelLoader.readCameraBounds(map);
    for (final visual in loadedMap.visuals) {
      await world.add(visual);
    }

    await WLCavernAtmosphere.mount(
      game: this,
      worldSize: map.size,
    );

    final collisionMap = WLLevelLoader.buildCollisionMap(map);
    final spawnPoint = WLLevelLoader.readPlayerSpawn(map);
    _playerSpawn = spawnPoint;
    final wizard = await WLBlueWizard.spawn(
      game: this,
      collisionMap: collisionMap,
      input: _playerInput,
      spawnPoint: spawnPoint,
    );
    _wizard = wizard;
    await world.add(wizard);
    _levelExit = WLLevelLoader.readLevelExit(map);
    await world.add(
      WLHitboxDebugOverlay(
        wizard: wizard,
        visibleListenable: hitboxDebugNotifier,
      ),
    );

    await WLGameControls.mount(game: this, input: _playerInput);

    final deathFade = WLDeathScreenFade();
    _deathScreenFade = deathFade;
    await camera.viewport.add(deathFade);

    _configureCamera(snapToWizard: true);
  }

  @override
  void onDispose() {
    livesNotifier.dispose();
    hitboxDebugNotifier.dispose();
    super.onDispose();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateDeathFade(dt);
    _checkPlayerFallDeath();
    _checkLevelExit();
  }

  void _updateDeathFade(double dt) {
    if (_deathFadePhase == _WLDeathFadePhase.idle) {
      return;
    }

    _deathFadeElapsed += dt;
    switch (_deathFadePhase) {
      case _WLDeathFadePhase.idle:
        return;
      case _WLDeathFadePhase.fadeOut:
        _setDeathFadeOpacity(
          (_deathFadeElapsed / WLCharacterConstants.deathFadeOutSeconds)
              .clamp(0, 1),
        );
        if (_deathFadeElapsed < WLCharacterConstants.deathFadeOutSeconds) {
          return;
        }
        if (livesNotifier.value <= 0) {
          _setDeathFadeOpacity(1);
          _showGameOver();
          _deathFadePhase = _WLDeathFadePhase.idle;
          return;
        }
        _respawnAtSpawn();
        _deathFadePhase = _WLDeathFadePhase.fadeIn;
        _deathFadeElapsed = 0;
        return;
      case _WLDeathFadePhase.fadeIn:
        _setDeathFadeOpacity(
          1 -
              (_deathFadeElapsed / WLCharacterConstants.deathFadeInSeconds)
                  .clamp(0, 1),
        );
        if (_deathFadeElapsed < WLCharacterConstants.deathFadeInSeconds) {
          return;
        }
        _setDeathFadeOpacity(0);
        _wizard?.setControlEnabled(true);
        WLKeyboardControls.syncHeldKeys(_playerInput);
        _isPlayerDead = false;
        _deathFadePhase = _WLDeathFadePhase.idle;
        return;
    }
  }

  void _setDeathFadeOpacity(double opacity) {
    final fade = _deathScreenFade;
    if (fade == null) {
      return;
    }
    fade.opacity = opacity;
  }

  void _checkPlayerFallDeath() {
    if (_isPlayerDead || _isLevelCleared) {
      return;
    }

    final map = _map;
    final wizard = _wizard;
    if (map == null || wizard == null) {
      return;
    }

    final deathY = map.size.y +
        WLMapConstants.tileSize * WLMapConstants.deathFallBufferTiles;
    if (wizard.position.y > deathY) {
      onPlayerDeath();
    }
  }

  void _checkLevelExit() {
    if (_isLevelCleared || _isPlayerDead) {
      return;
    }

    final levelExit = _levelExit;
    final wizard = _wizard;
    if (levelExit == null || wizard == null) {
      return;
    }
    if (!wizard.hitboxRect.overlaps(levelExit.triggerRect)) {
      return;
    }
    onLevelCleared();
  }

  void onPlayerDeath() {
    if (_isPlayerDead || _isLevelCleared) {
      return;
    }

    _isPlayerDead = true;
    _playerInput.reset();
    _wizard?.setControlEnabled(false);
    livesNotifier.value -= 1;

    _deathFadePhase = _WLDeathFadePhase.fadeOut;
    _deathFadeElapsed = 0;
    _setDeathFadeOpacity(0);
  }

  void _showGameOver() {
    _showBlockingOverlay(WLGameOverlayId.death);
  }

  void onLevelCleared() {
    if (_isLevelCleared || _isPlayerDead) {
      return;
    }

    _isLevelCleared = true;
    _playerInput.reset();
    _wizard?.setControlEnabled(false);
    _showBlockingOverlay(WLGameOverlayId.levelClear);
  }

  void _showBlockingOverlay(String overlayId) {
    pauseEngine();
    overlays.remove(WLGameOverlayId.hud);
    overlays.removeAll(const [
      WLGameOverlayId.pause,
      WLGameOverlayId.exitConfirm,
    ]);
    overlays.add(overlayId);
  }

  void _respawnAtSpawn() {
    final spawn = _playerSpawn;
    final wizard = _wizard;
    if (spawn == null || wizard == null) {
      return;
    }

    _playerInput.reset();
    wizard.respawn(spawn);
    _configureCamera(snapToWizard: true);
  }

  void restartAfterDeath() {
    overlays.remove(WLGameOverlayId.death);
    _resetPlayState();
  }

  void restartAfterClear() {
    overlays.remove(WLGameOverlayId.levelClear);
    _resetPlayState();
  }

  void _resetPlayState() {
    livesNotifier.value = WLCharacterConstants.startingLives;
    _isPlayerDead = false;
    _isLevelCleared = false;
    _deathFadePhase = _WLDeathFadePhase.idle;
    _deathFadeElapsed = 0;
    _setDeathFadeOpacity(0);
    _respawnAtSpawn();
    overlays.add(WLGameOverlayId.hud);
    resumeEngine();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _configureCamera(snapToWizard: false);
  }
  
  /// Cấu hình camera
  void _configureCamera({required bool snapToWizard}) {
    final bounds = _cameraWorldBounds; // Vùng giới hạn của camera
    final wizard = _wizard; // Nhân vật

    // Nếu Vùng giới hạn của camera hoặc nhân vật không tồn tại, không cấu hình camera
    if (bounds == null || wizard == null) {
      return;
    }
    // Gắn camera vào nhân vật, kẹp khung nhìn trong map
    WLCameraController.attach(
      camera: camera,
      viewSize: size,
      worldBounds: bounds,
      target: wizard,
      snapToTarget: snapToWizard,
    );
  }
  
  /// Pause game
  /// Thực hiện reset input và thêm overlay pause
  void pauseGame() {
    if (paused || _isPlayerDead || _isLevelCleared) {
      return;
    }
    _playerInput.reset();
    pauseEngine();
    overlays.remove(WLGameOverlayId.hud);
    overlays.add(WLGameOverlayId.pause);
  }
  
  /// Resume game
  /// Thực hiện xóa các overlay và khôi phục game
  void resumeGame() {
    overlays.removeAll(const [
      WLGameOverlayId.exitConfirm,
      WLGameOverlayId.pause,
    ]);
    overlays.add(WLGameOverlayId.hud);
    WLKeyboardControls.syncHeldKeys(_playerInput);
    resumeEngine();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!WLKeyboardControls.isHandledKey(event.logicalKey)) {
      return KeyEventResult.ignored;
    }

    if (WLKeyboardControls.isPauseKey(event.logicalKey)) {
      if (event is KeyDownEvent) {
        handleSystemBack();
      }
      return KeyEventResult.handled;
    }

    if (paused ||
        _isPlayerDead ||
        _isLevelCleared ||
        overlays.isActive(WLGameOverlayId.death)) {
      return KeyEventResult.handled;
    }

    WLKeyboardControls.applyMovement(_playerInput, keysPressed);
    if (WLKeyboardControls.shouldJump(event)) {
      _playerInput.requestJump();
    }
    return KeyEventResult.handled;
  }

  void openExitConfirm() {
    overlays.add(WLGameOverlayId.exitConfirm, priority: 1);
  }

  void closeExitConfirm() {
    overlays.remove(WLGameOverlayId.exitConfirm);
  }

  void handleSystemBack() {
    if (overlays.isActive(WLGameOverlayId.death) ||
        overlays.isActive(WLGameOverlayId.levelClear)) {
      return;
    }
    if (overlays.isActive(WLGameOverlayId.exitConfirm)) {
      closeExitConfirm();
      return;
    }
    if (overlays.isActive(WLGameOverlayId.pause)) {
      resumeGame();
      return;
    }
    pauseGame();
  }
}
