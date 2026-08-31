# Load map trong Flame (`flame_tiled`)

Package đã có trong `pubspec.yaml`: `flame_tiled`. Map file phải nằm trong asset bundle (xem [README §3](./README.md)).

`TiledComponent` mặc định tìm file dưới `assets/tiles/`. Project này để map ở `assets/maps/` — **phải** truyền `prefix`.

---

## 1. Load `.tmx`

```dart
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

final map = await TiledComponent.load(
  'zone1_slice.tmx',
  Vector2.all(512),
  prefix: 'assets/maps/',
);

await world.add(map);
```

`Vector2.all(512)` = dest tile size (khớp Tiled). Zoom camera để ~12–16 tile ngang, không đổi số 512 trừ khi downsample tileset.

`.tsx` external: Flame resolve path **relative từ file `.tmx`**, rồi load ảnh qua Flutter assets. Thiếu `assets/maps/mossy-tileset/` trong `pubspec` → tile trống.

---

## 2. Camera

```dart
camera.viewfinder.zoom = /* sao cho ~12–16 tile ngang viewport */;
camera.follow(player);
camera.setBounds(/* Rect từ map width/height hoặc object camera_bounds */);
```

Map 80×30 tile × 512px = world rất lớn; zoom nhỏ, **không** render full map scale 1:1.

Parallax: `bg_far` / `MossyHills` có thể không đi qua tilemap mà dùng `ParallaxComponent` (cùng PNG). MVP: để Tiled vẽ `bg_far` cho nhanh.

---

## 3. Collision từ tile

Hai nguồn (ưu tiên shape Tiled nếu có):

1. **Tile Collision Editor** trên `mossy_ground.tsx` — polygon/rect theo tile.
2. Fallback: mọi ô khác 0 trên layer `ground` và `platforms` = AABB 512×512 (thô, rêu sẽ “dính” chân).

Loader chỉ collide `ground` + `platforms`. `deco` / `bg_*` / `fg` bỏ qua.

Platform one-way: property trên layer hoặc tile `one_way = true`; runtime chỉ collide khi `vy > 0` và chân cắt mép trên.

Physics player: AABB swept theo trục — [`ARCHITECTURE.md`](../ARCHITECTURE.md) §4.2.

---

## 4. Object → component

`LevelLoader` duyệt object group theo **tên layer**, rồi `switch` theo Class:

```dart
import 'package:flame_tiled/flame_tiled.dart';

void spawnFrom(TiledComponent map) {
  _spawnLayer(map, 'obj_spawn');
  _spawnLayer(map, 'obj_checkpoints');
  _spawnLayer(map, 'obj_spikes');
  _spawnLayer(map, 'obj_hazards');
  _spawnLayer(map, 'obj_enemies');
  _spawnLayer(map, 'obj_tablets');
  _spawnLayer(map, 'obj_meta');
}

void _spawnLayer(TiledComponent map, String name) {
  final layer = map.tileMap.getLayer<ObjectGroup>(name);
  if (layer == null) return;

  for (final obj in layer.objects) {
    final kind = obj.class_.isNotEmpty ? obj.class_ : obj.type;
    switch (kind) {
      case 'player_spawn':
        // PlayerComponent.fromTiled(obj)
        break;
      case 'checkpoint':
        break;
      case 'spike':
        break;
      case 'fake_floor':
      case 'wind_zone':
      case 'gravity_zone':
        break;
      case 'slime':
        break;
      case 'tablet':
        break;
      case 'segment':
      case 'camera_bounds':
        break;
      default:
        break;
    }
  }
}
```

Tọa độ Tiled: gốc **trên-trái**, Y xuống — cùng Flame. `obj.x`, `obj.y`, `obj.width`, `obj.height` là world px (đã × 512 nếu object căn tile).

Đọc property an toàn (không dùng `!`):

```dart
String stringProp(TiledObject obj, String key, String fallback) {
  final value = obj.properties.getValue<String>(key);
  return value ?? fallback;
}

int intProp(TiledObject obj, String key, int fallback) {
  final value = obj.properties.getValue<int>(key);
  return value ?? fallback;
}
```

API `properties.getValue` có thể khác nhẹ theo version `tiled` — giữ null-aware, khớp package đang pin.

**Tái sử dụng:** mỗi entity một `fromTiled(TiledObject)`. Thêm trap = thêm `case` + class, không nhét logic vào loader.

---

## 5. Gai: visual ≠ hitbox

- Art gai: tile/sprite trên `deco` (hoặc object tile).
- Chết: `RectangleHitbox` từ object `spike` (nhỏ hơn sprite).

Không tạo hitbox từ kích thước tile 512 của sheet hazard.

---

## 6. Skeleton `WizardGame` (map only)

Chưa cần player đủ: load map + camera pan để **verify tile + path**.

```dart
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class WizardGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final map = await TiledComponent.load(
      'zone1_slice.tmx',
      Vector2.all(512),
      prefix: 'assets/maps/',
    );
    await world.add(map);

    camera.viewfinder.zoom = 0.2;
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}
```

Zoom 0.2 chỉ để nhìn slice lúc debug; chốt ~12–16 tile ngang khi có player.

---

## 7. Lỗi thường gặp

| Triệu chứng | Nguyên nhân | Cách xử |
|-------------|-------------|---------|
| Map trắng / không tile | Path tuyệt đối trong `.tsx`, hoặc thiếu folder trong `pubspec` | Relative path; thêm `assets/maps/mossy-tileset/` |
| `Unable to load asset` | Prefix sai (`assets/tiles/`) | `prefix: 'assets/maps/'` |
| Layer object rỗng | Sai tên layer | Khớp [README §5](./README.md) |
| Object không spawn | Trống Class | Class = `spike`, `checkpoint`, … |
| Player rơi xuyên sàn | Chưa đọc collision / sai layer `ground` | Collision Editor + collide đúng layer |
| Chân “dính” rêu | AABB full 512 | Inset collision trên tileset |
| Gai không giết | Object size 0 hoặc nhầm layer | Rect rõ trên `obj_spikes` |
| Hot reload không thấy map mới | Asset `.tmx` không reload | Hot **restart** |
| Web 404 map | Mở `file://` hoặc path `/Users/...` | `fvm flutter run -d chrome`; path relative |
| Web giật / sai màu tile | HTML renderer | Để CanvasKit/Skwasm mặc định |

Chi tiết web/audio/FVM: [`SETUP_AND_MAP_GUIDE.md`](../SETUP_AND_MAP_GUIDE.md) Phần A / C.

---

## 8. Thứ tự implement (sau khi `.tmx` có spawn + ground)

1. `TiledComponent.load` + zoom debug — thấy hang rêu.
2. Collision `ground` + player prototype.
3. `player_spawn` + `checkpoint`.
4. `spike` + rewind.
5. Platform / fake_floor / slime theo object.

Không viết hitbox cứng trong Dart cho từng màn — mọi số chỉnh trên Tiled properties.
