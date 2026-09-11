import 'dart:ui';

import 'package:flame_tiled/flame_tiled.dart';

import 'package:wizard/core/wl_map_constants.dart';
import 'package:wizard/game/levels/wl_level_exit.dart';

class WLLevelExitReader {
  WLLevelExitReader._();

  static const String layerName = 'obj_exits';
  static const String objectKind = 'level_exit';

  static WLLevelExit? read(TiledComponent map) {
    final layer = map.tileMap.getLayer<ObjectGroup>(layerName);
    if (layer == null) {
      return null;
    }

    for (final object in layer.objects) {
      if (_objectKind(object) != objectKind) {
        continue;
      }
      return WLLevelExit(triggerRect: _triggerRect(object));
    }
    return null;
  }

  static Rect _triggerRect(TiledObject object) {
    if (object.width > 0 && object.height > 0) {
      return Rect.fromLTWH(
        object.x,
        object.y,
        object.width,
        object.height,
      );
    }

    final size = WLMapConstants.tileSize;
    return Rect.fromLTWH(
      object.x - size / 2,
      object.y - size,
      size,
      size,
    );
  }

  static String _objectKind(TiledObject object) {
    if (object.class_.isNotEmpty) {
      return object.class_;
    }
    return object.type;
  }
}
