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
import 'overlays/wl_game_overlay_id.dart';
import 'world/wl_cavern_atmosphere.dart';

class WLWizardGame extends FlameGame {
  TiledComponent? _map;
  WLBlueWizard? _wizard;
  WLPlayerSpawn? _playerSpawn;
  bool _isPlayerDead = false;
  int _deathSequenceToken = 0;
  final ValueNotifier<int> livesNotifier =
      ValueNotifier(WLCharacterConstants.startingLives);
  final WLPlayerInput _playerInput = WLPlayerInput();

  int get livesRemaining => livesNotifier.value;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final map = await WLLevelLoader.loadZone1Slice();
    _map = map;
    map.priority = 0;
    await world.add(map);

    await WLCavernAtmosphere.mount(
      game: this,
      worldSize: map.size,
      mapImages: WLLevelLoader.mapImages,
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

    _configureCamera(snapToWizard: true);
  }

  @override
  void onDispose() {
    _deathSequenceToken++;
    livesNotifier.dispose();
    super.onDispose();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkPlayerFallDeath();
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
    pauseEngine();
    livesNotifier.value -= 1;

    final token = ++_deathSequenceToken;
    Future.delayed(
      Duration(
        milliseconds:
            (WLCharacterConstants.deathRespawnDelaySeconds * 1000).round(),
      ),
      () => _completeDeathSequence(token),
    );
  }

  void _completeDeathSequence(int token) {
    if (token != _deathSequenceToken) {
      return;
    }

    if (livesNotifier.value <= 0) {
      _showGameOver();
      return;
    }

    _respawnAtSpawn();
    _isPlayerDead = false;
    resumeEngine();
  }

  void _showGameOver() {
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
    _deathSequenceToken++;
    livesNotifier.value = WLCharacterConstants.startingLives;
    _isPlayerDead = false;
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
    camera.viewfinder.zoom =
        size.x / (WLMapConstants.tileSize * WLMapConstants.visibleTilesX);

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
