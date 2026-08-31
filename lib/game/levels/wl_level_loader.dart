import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../../core/wl_deploy_config.dart';
import '../../core/wl_map_constants.dart';
import '../physics/wl_tile_collision_map.dart';
import 'wl_map_tmx_reader.dart';
import 'wl_player_spawn.dart';

class WLLevelLoader {
  WLLevelLoader._();

  static final Images mapImages = Images(prefix: WLMapConstants.mapsPrefix);

  static Future<TiledComponent> loadZone1Slice() async {
    final assetPath =
        '${WLMapConstants.mapsPrefix}${WLMapConstants.zone1SliceFile}';
    final contents = await readMapTmx(assetPath, WLDeployConfig.version);
    final tileMap = await RenderableTiledMap.fromString(
      contents,
      Vector2.all(WLMapConstants.tileSize),
      prefix: WLMapConstants.mapsPrefix,
      images: mapImages,
    );
    return TiledComponent(tileMap);
  }

  static WLPlayerSpawn readPlayerSpawn(TiledComponent map) {
    return WLPlayerSpawnReader.read(map);
  }

  static WLTileCollisionMap buildCollisionMap(TiledComponent map) {
    return WLTileCollisionMap.fromTiledMap(map);
  }
}
