import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../core/wl_map_constants.dart';
import 'characters/wl_blue_wizard.dart';
import 'input/wl_game_controls.dart';
import 'input/wl_player_input.dart';
import 'levels/wl_level_loader.dart';
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

    _applyGameplayCamera(resetPosition: true);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _applyGameplayCamera(resetPosition: false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _followWizard();
  }

  void _followWizard() {
    final map = _map;
    final wizard = _wizard;
    if (map == null || wizard == null) {
      return;
    }
    final zoom = camera.viewfinder.zoom;
    if (zoom <= 0) {
      return;
    }
    final halfView = size / zoom / 2;
    final current = camera.viewfinder.position;
    camera.viewfinder.position = Vector2(
      _clampCamAxis(wizard.position.x, halfView.x, map.size.x),
      _clampCamAxis(current.y, halfView.y, map.size.y),
    );
  }

  void _applyGameplayCamera({required bool resetPosition}) {
    final map = _map;
    if (map == null) {
      return;
    }
    final view = size;
    if (view.x <= 0 || view.y <= 0) {
      return;
    }
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = view.x /
        (WLMapConstants.tileSize * WLMapConstants.visibleTilesX);
    if (resetPosition) {
      final wizard = _wizard;
      final halfViewX = view.x / (camera.viewfinder.zoom * 2);
      final targetX = wizard?.position.x ?? halfViewX;
      camera.viewfinder.position = Vector2(
        _clampCamAxis(targetX, halfViewX, map.size.x),
        map.size.y / 2,
      );
    }
    _clampCameraToMap();
  }

  void _clampCameraToMap() {
    final map = _map;
    if (map == null) {
      return;
    }
    final zoom = camera.viewfinder.zoom;
    if (zoom <= 0) {
      return;
    }
    final halfView = size / zoom / 2;
    final pos = camera.viewfinder.position;
    camera.viewfinder.position = Vector2(
      _clampCamAxis(pos.x, halfView.x, map.size.x),
      _clampCamAxis(pos.y, halfView.y, map.size.y),
    );
  }

  double _clampCamAxis(double value, double halfView, double mapExtent) {
    if (mapExtent <= halfView * 2) {
      return mapExtent / 2;
    }
    return value.clamp(halfView, mapExtent - halfView);
  }
}
