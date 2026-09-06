import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

/// Danh sách vùng đặc (solids: hình chữ nhật không đi xuyên được) lấy từ bản đồ Tiled.
class WLTileCollisionMap {
  WLTileCollisionMap._(this.solids);

  /// Các hình chữ nhật đặc dùng để chặn nhân vật.
  final List<Rect> solids;

  /// Tên các layer Tiled được coi là nền/sàn, dùng để dựng va chạm.
  static const List<String> collisionLayerNames = ['ground', 'platforms'];

  /// Đọc layer (lớp) va chạm trên bản đồ Tiled rồi gom thành danh sách hình chữ nhật đặc.
  static WLTileCollisionMap fromTiledMap(TiledComponent map) {
    final solids = <Rect>[];
    final tileMap = map.tileMap;
    final tiledMap = tileMap.map;
    final destTileSize = tileMap.destTileSize;

    for (final layerName in collisionLayerNames) {
      final layer = tileMap.getLayer<TileLayer>(layerName);
      if (layer == null) {
        continue;
      }
      _collectLayerSolids(
        layer: layer,
        tiledMap: tiledMap,
        destTileSize: destTileSize,
        solids: solids,
      );
    }

    return WLTileCollisionMap._(solids);
  }

  /// Duyệt từng ô trên một layer, thêm hình chữ nhật va chạm vào danh sách.
  static void _collectLayerSolids({
    required TileLayer layer,
    required TiledMap tiledMap,
    required Vector2 destTileSize,
    required List<Rect> solids,
  }) {
    final tileData = layer.tileData;
    if (tileData == null) {
      return;
    }

    for (var row = 0; row < tileData.length; row++) {
      for (var col = 0; col < tileData[row].length; col++) {
        final gid = tileData[row][col];
        if (gid.tile == 0) {
          continue;
        }

        final tile = tiledMap.tileByGid(gid.tile);
        if (tile == null || tile.isEmpty) {
          continue;
        }

        final tileset = tiledMap.tilesetByTileGId(gid.tile);
        final sourceTileWidth =
            tileset.tileWidth?.toDouble() ?? destTileSize.x;
        final sourceTileHeight =
            tileset.tileHeight?.toDouble() ?? destTileSize.y;
        final scaleX = destTileSize.x / sourceTileWidth;
        final scaleY = destTileSize.y / sourceTileHeight;
        final tileX = col * destTileSize.x + layer.offsetX;
        final tileY = row * destTileSize.y + layer.offsetY;

        final objectGroup = tile.objectGroup;
        if (objectGroup is ObjectGroup && objectGroup.objects.isNotEmpty) {
          _addTileObjectSolids(
            objectGroup: objectGroup,
            tileX: tileX,
            tileY: tileY,
            scaleX: scaleX,
            scaleY: scaleY,
            solids: solids,
          );
          continue;
        }

        solids.add(
          Rect.fromLTWH(tileX, tileY, destTileSize.x, destTileSize.y),
        );
      }
    }
  }

  /// Thêm hình chữ nhật va chạm từ object (vùng vẽ sẵn) gắn trên từng ô tile.
  static void _addTileObjectSolids({
    required ObjectGroup objectGroup,
    required double tileX,
    required double tileY,
    required double scaleX,
    required double scaleY,
    required List<Rect> solids,
  }) {
    for (final object in objectGroup.objects) {
      if (!object.isRectangle || object.width <= 0 || object.height <= 0) {
        continue;
      }
      solids.add(
        Rect.fromLTWH(
          tileX + object.x * scaleX,
          tileY + object.y * scaleY,
          object.width * scaleX,
          object.height * scaleY,
        ),
      );
    }
  }
}
