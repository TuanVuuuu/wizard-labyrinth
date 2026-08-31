import 'dart:ui';

import 'package:flame/cache.dart';

/// [Images] cho map Tiled — chuẩn hóa path `../` trước khi load.
///
/// `flame_tiled` với tileset 1 ảnh dùng trực tiếp `source` trong `.tsx`
/// (ví dụ `../mossy-tileset/...`). Prefix `assets/maps/` + `../` →
/// `assets/mossy-tileset/...` (404 trên web). Cần gộp thành
/// `mossy-tileset/...` dưới `assets/maps/`.
class WLMapImages extends Images {
  WLMapImages({required super.prefix});

  @override
  Future<Image> load(String fileName, {String? key, String? package}) {
    final normalized = WLMapAssetPaths.normalize(fileName);
    return super.load(
      normalized,
      key: key ?? fileName,
      package: package,
    );
  }
}

class WLMapAssetPaths {
  WLMapAssetPaths._();

  static String normalize(String path) {
    final parts = <String>[];
    for (final segment in path.split('/')) {
      if (segment.isEmpty || segment == '.') {
        continue;
      }
      if (segment == '..') {
        if (parts.isNotEmpty) {
          parts.removeLast();
        }
        continue;
      }
      parts.add(segment);
    }
    return parts.join('/');
  }

  /// Giống logic map path trong `flame_tiled` [TiledAtlas].
  static String resolveTileImageSource({
    required String imageSource,
    String? tilesetSource,
  }) {
    if (tilesetSource == null || tilesetSource.isEmpty) {
      return normalize(imageSource);
    }

    final tilesetParts = tilesetSource.split('/');
    final imageParts = imageSource.split('/');
    if (tilesetParts.length == imageParts.length) {
      return normalize(imageSource);
    }

    return normalize([
      ...tilesetParts.sublist(0, tilesetParts.length - 1),
      ...imageParts,
    ].join('/'));
  }
}
