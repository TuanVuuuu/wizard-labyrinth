/// Thông số map Tiled / Flame dùng chung — khớp `docs/maps-game/README.md`.
class WLMapConstants {
  /// Cạnh một ô thế giới (px). Khớp lưới `Mossy - TileSet.png` (512×512) và
  /// tile size trong `.tmx` / `TiledComponent.load`.
  static const double tileSize = 512;

  /// Số ô ngang hiển thị trên màn (gameplay). Camera không fit cả map.
  static const double visibleTilesX = 14;

  /// Prefix asset bundle cho file map. `flame_tiled` mặc định `assets/tiles/`;
  /// project để `.tmx` dưới `assets/maps/` nên phải truyền prefix này.
  static const String mapsPrefix = 'assets/maps/';

  /// Map MVP Zone 1 (Mouth of Echo): file `.tmx` relative tới [mapsPrefix].
  static const String zone1SliceFile = 'zone1_slice.tmx';

  /// Sheet đồi rêu xa (không collision). Dùng cho stamp nền `bg_far` /
  /// parallax trong `WLCavernAtmosphere`, không phải địa hình `ground`.
  static const String hillsSheet = 'mossy-tileset/Mossy - MossyHills.png';
}
