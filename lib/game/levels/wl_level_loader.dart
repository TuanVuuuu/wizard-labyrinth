import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../../core/wl_deploy_config.dart';
import '../../core/wl_map_constants.dart';
import '../physics/wl_tile_collision_map.dart';
import 'wl_map_images.dart';
import 'wl_map_tmx_reader.dart';
import 'wl_player_spawn.dart';

class WLLoadedMap {
  const WLLoadedMap({
    required this.map,
    required this.visuals,
  });

  final TiledComponent map;
  final List<TiledComponent> visuals;
}

class WLLevelLoader {
  WLLevelLoader._();

  static final Images mapImages =
      WLMapImages(prefix: WLMapConstants.mapsPrefix);

  static Future<WLLoadedMap> loadZone1Slice() async {
    final assetPath =
        '${WLMapConstants.mapsPrefix}${WLMapConstants.zone1SliceFile}';
    final contents = await readMapTmx(assetPath, WLDeployConfig.version);
    final visuals = await _loadVisualParts(contents);
    if (visuals.isEmpty) {
      final fallback = await _buildPart(
        contents: contents,
        layerName: null,
        tilesetName: null,
        priority: 0,
      );
      return WLLoadedMap(map: fallback, visuals: [fallback]);
    }
    return WLLoadedMap(map: visuals.first, visuals: visuals);
  }

  static Future<List<TiledComponent>> _loadVisualParts(String contents) async {
    final template = await _parseMap(contents);
    final tilesets = _sortedTilesets(template);
    final parts = <TiledComponent>[];
    TiledComponent? collisionSource;

    for (var layerIndex = 0; layerIndex < template.layers.length; layerIndex++) {
      final layer = template.layers[layerIndex];
      if (layer is! TileLayer) {
        continue;
      }

      final usedTilesets = _tilesetsUsedInLayer(layer, tilesets);
      if (usedTilesets.isEmpty) {
        continue;
      }

      for (final tileset in usedTilesets) {
        final name = tileset.name;
        if (name?.isEmpty ?? true) {
          continue;
        }
        final part = await _buildPart(
          contents: contents,
          layerName: layer.name,
          tilesetName: name,
          priority: layerIndex,
        );
        if (layer.name == 'ground') {
          collisionSource = part;
        }
        parts.add(part);
      }
    }

    if (collisionSource != null && parts.first != collisionSource) {
      parts.remove(collisionSource);
      parts.insert(0, collisionSource);
    }

    return parts;
  }

  static Future<TiledComponent> _buildPart({
    required String contents,
    required String? layerName,
    required String? tilesetName,
    required int priority,
  }) async {
    final tiledMap = await _parseMap(contents);
    if (layerName != null) {
      _showOnlyTileLayer(tiledMap, layerName);
    }
    if (tilesetName != null) {
      _keepOnlyTileset(tiledMap, tilesetName);
    }
    final tileMap = await RenderableTiledMap.fromTiledMap(
      tiledMap,
      Vector2.all(WLMapConstants.tileSize),
      images: mapImages,
      atlasMaxX: WLMapConstants.tileAtlasMaxSize,
      atlasMaxY: WLMapConstants.tileAtlasMaxSize,
      tsxPackingFilter: (tileset) {
        if (tilesetName == null) {
          return true;
        }
        return tileset.name == tilesetName;
      },
    );
    return TiledComponent(tileMap, priority: priority);
  }

  static Future<TiledMap> _parseMap(String contents) async {
    final tiledMap = await TiledMap.fromString(
      contents,
      (key) => FlameTsxProvider.parse(
        key,
        null,
        WLMapConstants.mapsPrefix,
      ),
    );
    tiledMap.backgroundColor = null;
    tiledMap.backgroundColorHex = null;
    return tiledMap;
  }

  static List<Tileset> _sortedTilesets(TiledMap map) {
    final tilesets = [...map.tilesets];
    tilesets.sort((left, right) {
      return (left.firstGid ?? 0).compareTo(right.firstGid ?? 0);
    });
    return tilesets;
  }

  static List<Tileset> _tilesetsUsedInLayer(
    TileLayer layer,
    List<Tileset> tilesets,
  ) {
    final used = <Tileset>{};
    final tileData = layer.tileData;
    if (tileData == null) {
      return const [];
    }

    for (final row in tileData) {
      for (final gid in row) {
        if (gid.tile == 0) {
          continue;
        }
        final tileset = _tilesetForGid(tilesets, gid.tile);
        if (tileset != null) {
          used.add(tileset);
        }
      }
    }
    return used.toList();
  }

  static Tileset? _tilesetForGid(List<Tileset> tilesets, int gid) {
    Tileset? current;
    for (final tileset in tilesets) {
      final firstGid = tileset.firstGid ?? 0;
      if (gid < firstGid) {
        break;
      }
      current = tileset;
    }
    return current;
  }

  static void _showOnlyTileLayer(TiledMap map, String layerName) {
    for (final layer in map.layers) {
      layer.visible = layer is TileLayer && layer.name == layerName;
    }
  }

  static void _keepOnlyTileset(TiledMap map, String tilesetName) {
    final tilesets = _sortedTilesets(map);
    final index = tilesets.indexWhere((tileset) => tileset.name == tilesetName);
    if (index < 0) {
      return;
    }

    final firstGid = tilesets[index].firstGid ?? 0;
    final lastGid = index + 1 < tilesets.length
        ? (tilesets[index + 1].firstGid ?? 0x7fffffff)
        : 0x7fffffff;

    for (final layer in map.layers) {
      if (layer is! TileLayer) {
        continue;
      }
      final tileData = layer.tileData;
      if (tileData == null) {
        continue;
      }
      for (final row in tileData) {
        for (var column = 0; column < row.length; column++) {
          final gid = row[column].tile;
          if (gid == 0) {
            continue;
          }
          if (gid < firstGid || gid >= lastGid) {
            row[column] = const Gid(0, Flips.defaults());
          }
        }
      }
    }
  }

  static WLPlayerSpawn readPlayerSpawn(TiledComponent map) {
    return WLPlayerSpawnReader.read(map);
  }

  static WLTileCollisionMap buildCollisionMap(TiledComponent map) {
    return WLTileCollisionMap.fromTiledMap(map);
  }
}
