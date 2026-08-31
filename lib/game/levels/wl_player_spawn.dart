import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../../core/wl_character_constants.dart';
import '../../core/wl_map_constants.dart';

class WLPlayerSpawn {
  const WLPlayerSpawn({
    required this.position,
    this.facing = 1,
  });

  final Vector2 position;
  final int facing;

  static WLPlayerSpawn fallback() {
    return WLPlayerSpawn(
      position: Vector2(
        WLCharacterConstants.defaultSpawnTileX * WLMapConstants.tileSize,
        WLCharacterConstants.defaultSpawnTileY * WLMapConstants.tileSize,
      ),
      facing: 1,
    );
  }
}

class WLPlayerSpawnReader {
  WLPlayerSpawnReader._();

  static const String spawnLayerName = 'obj_spawn';
  static const String spawnObjectKind = 'player_spawn';

  static WLPlayerSpawn read(TiledComponent map) {
    final layer = map.tileMap.getLayer<ObjectGroup>(spawnLayerName);
    if (layer == null) {
      return WLPlayerSpawn.fallback();
    }

    for (final object in layer.objects) {
      final kind = _objectKind(object);
      if (kind != spawnObjectKind) {
        continue;
      }
      return WLPlayerSpawn(
        position: _resolvePosition(object),
        facing: _readFacing(object),
      );
    }

    return WLPlayerSpawn.fallback();
  }

  static String _objectKind(TiledObject object) {
    if (object.class_.isNotEmpty) {
      return object.class_;
    }
    return object.type;
  }

  /// Rectangle: đáy giữa = chân nhân vật. Point: (x, y) = chân.
  static Vector2 _resolvePosition(TiledObject object) {
    if (object.width > 0 || object.height > 0) {
      return Vector2(
        object.x + object.width / 2,
        object.y + object.height,
      );
    }
    return Vector2(object.x, object.y);
  }

  static int _readFacing(TiledObject object) {
    final value = object.properties.getValue<int>('facing');
    if (value == null || value == 0) {
      return 1;
    }
    return value > 0 ? 1 : -1;
  }
}
