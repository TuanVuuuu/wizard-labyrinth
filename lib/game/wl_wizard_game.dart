import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../core/wl_map_constants.dart';
import 'levels/wl_level_loader.dart';
import 'characters/wl_blue_wizard.dart';
import 'world/wl_cavern_atmosphere.dart';

class WLWizardGame extends FlameGame with PanDetector {
  TiledComponent? _map;

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
      spawnPoint: spawnPoint,
    );
    await world.add(wizard);

    _applyGameplayCamera(resetPosition: true);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _applyGameplayCamera(resetPosition: false);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final zoom = camera.viewfinder.zoom;
    if (zoom <= 0) {
      return;
    }
    camera.viewfinder.position -= info.delta.global / zoom;
    _clampCameraToMap();
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
      final halfViewX = view.x / (camera.viewfinder.zoom * 2);
      camera.viewfinder.position = Vector2(halfViewX, map.size.y / 2);
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
