import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';

import '../core/wl_character_constants.dart';
import '../core/wl_map_constants.dart';
import 'characters/wl_blue_wizard.dart';
import 'input/wl_game_controls.dart';
import 'input/wl_player_input.dart';
import 'levels/wl_level_loader.dart';
import 'levels/wl_player_spawn.dart';
import 'overlays/wl_death_screen_fade.dart';
import 'overlays/wl_game_overlay_id.dart';
import 'world/wl_cavern_atmosphere.dart';

enum _WLDeathFadePhase {
  idle,
  fadeOut,
  fadeIn,
}

class WLWizardGame extends FlameGame {
  TiledComponent? _map;
  WLBlueWizard? _wizard;
  WLPlayerSpawn? _playerSpawn;
  WLDeathScreenFade? _deathScreenFade;
  bool _isPlayerDead = false;
  _WLDeathFadePhase _deathFadePhase = _WLDeathFadePhase.idle;
  double _deathFadeElapsed = 0;
  final ValueNotifier<int> livesNotifier =
      ValueNotifier(WLCharacterConstants.startingLives);
  final WLPlayerInput _playerInput = WLPlayerInput();

  int get livesRemaining => livesNotifier.value;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final loadedMap = await WLLevelLoader.loadZone1Slice();
    final map = loadedMap.map;
    _map = map;
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

    await WLGameControls.mount(game: this, input: _playerInput);

    final deathFade = WLDeathScreenFade();
    _deathScreenFade = deathFade;
    await camera.viewport.add(deathFade);

    _configureCamera(snapToWizard: true);
  }

  @override
  void onDispose() {
    livesNotifier.dispose();
    super.onDispose();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateDeathFade(dt);
    _checkPlayerFallDeath();
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
    if (_isPlayerDead) {
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

  void onPlayerDeath() {
    if (_isPlayerDead) {
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
    pauseEngine();
    overlays.remove(WLGameOverlayId.hud);
    overlays.removeAll(const [
      WLGameOverlayId.pause,
      WLGameOverlayId.exitConfirm,
    ]);
    overlays.add(WLGameOverlayId.death);
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
    livesNotifier.value = WLCharacterConstants.startingLives;
    _isPlayerDead = false;
    _deathFadePhase = _WLDeathFadePhase.idle;
    _deathFadeElapsed = 0;
    _setDeathFadeOpacity(0);
    _respawnAtSpawn();
    overlays.remove(WLGameOverlayId.death);
    overlays.add(WLGameOverlayId.hud);
    resumeEngine();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _configureCamera(snapToWizard: false);
  }

  void _configureCamera({required bool snapToWizard}) {
    final map = _map;
    if (map == null || size.x <= 0 || size.y <= 0) {
      return;
    }

    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = size.x / WLMapConstants.visibleWorldWidth;

    camera.setBounds(
      Rectangle.fromLTWH(0, 0, map.size.x, map.size.y),
      considerViewport: true,
    );

    final wizard = _wizard;
    if (wizard == null) {
      return;
    }

    if (snapToWizard) {
      camera.follow(wizard, snap: true);
    }
  }

  void pauseGame() {
    if (paused || _isPlayerDead) {
      return;
    }
    _playerInput.reset();
    pauseEngine();
    overlays.remove(WLGameOverlayId.hud);
    overlays.add(WLGameOverlayId.pause);
  }

  void resumeGame() {
    overlays.removeAll(const [
      WLGameOverlayId.exitConfirm,
      WLGameOverlayId.pause,
    ]);
    overlays.add(WLGameOverlayId.hud);
    resumeEngine();
  }

  void openExitConfirm() {
    overlays.add(WLGameOverlayId.exitConfirm, priority: 1);
  }

  void closeExitConfirm() {
    overlays.remove(WLGameOverlayId.exitConfirm);
  }

  void handleSystemBack() {
    if (overlays.isActive(WLGameOverlayId.death)) {
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
