/// Thông số map Tiled / Flame dùng chung — khớp `docs/maps-game/README.md`.
class WLMapConstants {
  /// Cạnh một ô thế giới (px). Khớp lưới `Mossy - TileSet.png` (512×512) và
  /// tile size trong `.tmx` / `TiledComponent.load`.
  static const double tileSize = 512;

  /// Số ô ngang hiển thị trên màn (gameplay). Camera không fit cả map.
  static const double visibleTilesX = 14;

  static double get visibleWorldWidth => tileSize * visibleTilesX;

  /// Cạnh atlas khi `flame_tiled` gom tileset vào một texture.
  /// Web mặc định 4096 — không đủ cho `Mossy - TileSet.png` (3584) cộng slice
  /// rocks/plants/spikes. Native mặc định đã là 8192.
  static const double tileAtlasMaxSize = 8192;

  /// Prefix asset bundle cho file map. `flame_tiled` mặc định `assets/tiles/`;
  /// project để `.tmx` dưới `assets/maps/` nên phải truyền prefix này.
  static const String mapsPrefix = 'assets/maps/';

  /// Prefix asset bundle cho panorama xa. Flame `Images` mặc định
  /// `assets/images/` — file nằm ở `assets/background/` nên phải truyền prefix này.
  static const String backgroundPrefix = 'assets/background/';

  /// Map MVP Zone 1 (Mouth of Echo): file `.tmx` relative tới [mapsPrefix].
  static const String zone1SliceFile = 'zone1_slice.tmx';

  /// Panorama xa (không collision). Parallax distant trong `WLFarView`.
  static const String farHillsAsset = 'far_hills.png';

  /// Panorama gần hơn (không collision). Parallax haze trong `WLFarView`.
  static const String midHazeAsset = 'mid_haze.png';

  /// Khoảng đệm dưới đáy map (tính theo tile) trước khi coi là rơi chết.
  static const double deathFallBufferTiles = 0.25;
}
