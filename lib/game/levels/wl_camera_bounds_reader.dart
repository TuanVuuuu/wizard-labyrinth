import 'dart:ui';

import 'package:flame_tiled/flame_tiled.dart';


/// Đọc vùng giới hạn của camera từ tệp Tiled
class WLCameraBoundsReader {
  WLCameraBoundsReader._();

  static const String layerName = 'obj_meta';
  static const String objectKind = 'camera_bounds';
  
  /// Đọc vùng giới hạn của camera từ tệp Tiled
  static Rect read(TiledComponent map) {
    return _fromMetaLayer(map) ?? _fromMapSize(map);
  }
  
  /// Đọc vùng giới hạn của camera từ lớp meta
  static Rect? _fromMetaLayer(TiledComponent map) {
    final layer = map.tileMap.getLayer<ObjectGroup>(layerName);
    if (layer == null) {
      return null;
    }

    for (final object in layer.objects) {
      final bounds = _fromObject(object);
      if (bounds != null) {
        return bounds;
      }
    }
    return null;
  }
  
  /// Đọc vùng giới hạn của camera từ đối tượng
  static Rect? _fromObject(TiledObject object) {
    if (_kind(object) != objectKind) {
      return null;
    }
    if (object.width <= 0 || object.height <= 0) {
      return null;
    }
    return Rect.fromLTWH(object.x, object.y, object.width, object.height);
  }
  
  /// Đọc vùng giới hạn của camera từ kích thước bản đồ
  static Rect _fromMapSize(TiledComponent map) {
    return Rect.fromLTWH(0, 0, map.size.x, map.size.y);
  }
  
  /// Lấy loại đối tượng
  static String _kind(TiledObject object) {
    if (object.class_.isNotEmpty) {
      return object.class_;
    }
    return object.type;
  }
}
