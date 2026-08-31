import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../core/wl_map_constants.dart';
import 'characters/wl_blue_wizard.dart';
import 'input/wl_game_controls.dart';
import 'input/wl_player_input.dart';
import 'levels/wl_level_loader.dart';
import 'overlays/wl_game_overlay_id.dart';
import 'world/wl_cavern_atmosphere.dart';

class WLWizardGame extends FlameGame {
  TiledComponent? _map;
  WLBlueWizard? _wizard;
  final WLPlayerInput _playerInput = WLPlayerInput();

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
    if (paused) {
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
