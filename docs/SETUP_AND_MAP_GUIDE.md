# Hướng dẫn: Tạo project + Vẽ map

> **Wizard: Mê Lộ** (`com.vunt.wizard`)  
> SDK: **FVM → Flutter 3.44.8** (`fvm flutter` / `fvm dart`, không dùng CLI global)  
> Asset nguồn: `../MossyCavern`  
> Tham chiếu: [`PLAN.md`](./PLAN.md) · [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Phần A — Tạo project Flutter + Flame

Nền tảng mục tiêu: **Android, iOS, Web** (Chrome / Edge). Cùng một codebase Flutter + Flame; không fork logic theo platform.

Mọi lệnh Flutter/Dart **đi qua FVM** (`fvm flutter …`, `fvm dart …`). Không gọi `flutter` / `dart` global — SDK pin **3.44.8**.

### A1. Yêu cầu môi trường

| Công cụ | Ghi chú |
|---------|---------|
| [FVM](https://fvm.app/) | Bắt buộc; pin SDK trong `.fvm/fvm_config.json` |
| Flutter SDK | **3.44.8** qua FVM; `fvm flutter doctor` sạch |
| Android Studio / Xcode | Build Android / iOS |
| Chrome (hoặc Edge) | Chạy & debug **web**; `fvm flutter devices` phải thấy `Chrome` |
| [Tiled Map Editor](https://www.mapeditor.org/) | **≥ 1.10**, vẽ `.tmx` |
| [Free Texture Packer](https://free-tex-packer.com/) | Gộp frame → `texture.png` + `texture.json` |

**Cài FVM + pin SDK (làm một lần, trước `create`):**

```bash
# macOS
brew tap leoafarias/fvm
brew install fvm
# hoặc: dart pub global activate fvm

cd /Users/tuanvu/dev/game/WizardLabyrinth
fvm install 3.44.8
fvm use 3.44.8
fvm flutter doctor
fvm flutter config --enable-web
```

> `fvm use 3.44.8` tạo `.fvm/` + `.fvmrc`. Commit các file pin này để cả team cùng SDK.

### A2. Tạo project (lần đầu)

Pin FVM **trong** `WizardLabyrinth` trước, rồi tạo project tại chỗ (giữ `PLAN.md` / `ARCHITECTURE.md`):

```bash
cd /Users/tuanvu/dev/game/WizardLabyrinth

fvm flutter create \
  --org com.vunt \
  --project-name wizard \
  --platforms=android,ios,web \
  .
```

> Dấu `.` tạo project vào thư mục hiện tại. Flutter có thể hỏi xác nhận vì thư mục không trống — chọn Yes / dùng flag phù hợp phiên bản.

Nếu repo đang trống và muốn tạo thư mục tạm rồi chuyển file:

```bash
cd /Users/tuanvu/dev/game

fvm spawn 3.44.8 flutter create \
  --org com.vunt \
  --project-name wizard \
  --platforms=android,ios,web \
  wizard_tmp
```

Sau đó copy vào `WizardLabyrinth` và chạy `fvm use 3.44.8` trong repo.

Nếu project **đã tạo** chỉ với `android,ios`, bổ sung web (không ghi đè `lib/`):

```bash
cd /Users/tuanvu/dev/game/WizardLabyrinth
fvm flutter create --platforms=web .
```

**Kiểm tra Application ID / Bundle ID / Web:**

- Android: `android/app/build.gradle` → `applicationId "com.vunt.wizard"`
- iOS: Xcode / `ios/Runner.xcodeproj` → Bundle Identifier `com.vunt.wizard`
- Web: không dùng applicationId; title nằm ở `web/index.html` và `web/manifest.json`

Đổi tên hiển thị app:

- Android: `android/app/src/main/AndroidManifest.xml` → `android:label="Wizard: Mê Lộ"`
- iOS: `CFBundleDisplayName` = `Wizard: Mê Lộ`
- Web: `web/index.html` → `<title>Wizard: Mê Lộ</title>`; `web/manifest.json` → `name` / `short_name` = `Wizard: Mê Lộ`

### A3. Dependencies

Trong `pubspec.yaml`:

```yaml
name: wizard
description: Wizard - Me Lo
publish_to: "none"

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.19.0
  flame_tiled: ^1.21.0
  flame_audio: ^2.10.0
  shared_preferences: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/tiles/
    - assets/images/characters/
    - assets/images/slimes/
    - assets/images/plants/
    - assets/audio/
    - assets/maps/
    - assets/atlas/
```

Cài package:

```bash
fvm flutter pub get
```

> Số version có thể chỉnh theo bản mới nhất lúc setup (`fvm flutter pub outdated`).

### A4. Cấu trúc thư mục đề xuất

```
WizardLabyrinth/
  PLAN.md
  ARCHITECTURE.md
  SETUP_AND_MAP_GUIDE.md      ← file này
  .fvm/  .fvmrc               # FVM pin Flutter 3.44.8
  pubspec.yaml
  android/  ios/  web/        # 3 platform từ fvm flutter create
  lib/
    main.dart
    app.dart
    game/
      wizard_game.dart
      world/
      player/
      actors/
      hazards/
      interactables/
      systems/
      levels/
    assets/
      atlas/                  # FreeTexAtlas loader
    ui/
    data/
  assets/
    images/
      tiles/                  # Mossy tileset PNGs
      characters/             # BlueWizard (hoặc atlas)
      slimes/
      plants/
    atlas/                    # texture.png + texture.json
    maps/                     # *.tmx + *.tsx
    audio/
  tools/                      # script copy asset (optional)
```

### A5. Copy asset từ MossyCavern

```bash
ASSET_SRC="/Users/tuanvu/dev/game/MossyCavern"
ASSET_DST="/Users/tuanvu/dev/game/WizardLabyrinth/assets"

mkdir -p \
  "$ASSET_DST/images/tiles" \
  "$ASSET_DST/images/characters" \
  "$ASSET_DST/images/slimes" \
  "$ASSET_DST/images/plants" \
  "$ASSET_DST/atlas" \
  "$ASSET_DST/maps"

# Tileset
cp "$ASSET_SRC/Mossy Tileset/"*.png "$ASSET_DST/images/tiles/"

# Slime atlas (Free Texture Packer)
cp "$ASSET_SRC/Slimes/texture.png" "$ASSET_DST/atlas/slime_green.png"
cp "$ASSET_SRC/Slimes/texture.json" "$ASSET_DST/atlas/slime_green.json"

# (Tùy chọn) giữ frame gốc để pack lại
cp -R "$ASSET_SRC/Slimes/SlimeGreen" "$ASSET_DST/images/slimes/"
cp -R "$ASSET_SRC/Slimes/SlimeOrange" "$ASSET_DST/images/slimes/"
cp -R "$ASSET_SRC/BlueWizard" "$ASSET_DST/images/characters/"
cp -R "$ASSET_SRC/Plant Animations" "$ASSET_DST/images/plants/"
```

**Lưu ý đường dẫn trong `texture.json`:** field `"image": "texture.png"` — đổi tên file atlas thì sửa JSON cho khớp, hoặc giữ tên `texture.png` trong cùng thư mục.

### A6. Pack thêm atlas bằng Free Texture Packer

1. Mở [Free Texture Packer](https://free-tex-packer.com/).
2. Add folder frame (ví dụ `BlueWizard/2BlueWizardIdle`).
3. Export:
   - Format: **JSON (Hash)** (giống slime hiện tại)
   - Padding: 2
   - Trim: tùy (nếu trim = true, loader phải đọc `spriteSourceSize`)
4. Xuất vào `assets/atlas/` với tên rõ: `wizard_idle.png` + `wizard_idle.json`.

Khuyến nghị pack riêng theo nhóm: `wizard_idle`, `wizard_walk`, `wizard_jump`, `wizard_dash`, `slime_orange`, `plant_wind_1`, …

### A7. Skeleton Flame tối thiểu

`lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/wizard_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GameWidget(
      game: WizardGame(),
      overlayBuilderMap: {
        // 'pause': ...,
        // 'lore': ...,
      },
    ),
  );
}
```

`lib/game/wizard_game.dart`:

```dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';

class WizardGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    // TODO: load atlas, load level .tmx, add player
  }
}
```

### A8. Chạy thử

```bash
cd /Users/tuanvu/dev/game/WizardLabyrinth
fvm dart analyze
# Chỉ chạy khi bạn chủ động muốn:
# fvm flutter run                 # device mặc định (máy ảo / USB)
# fvm flutter run -d chrome       # web — khuyến nghị lúc iterate map
```

### A9. Web (Chrome) — chạy, build, lưu ý Flame

Cùng `lib/` với mobile. Web là môi trường **iterate map nhanh** (hot restart, bàn phím A/D / Space) và cũng là **nền tảng phát hành**.

**Chạy debug:**

```bash
cd /Users/tuanvu/dev/game/WizardLabyrinth
fvm flutter devices                 # phải có Chrome
fvm flutter run -d chrome
# fvm flutter run -d chrome --web-port=8080
# fvm flutter run -d web-server     # chỉ in URL (LAN / máy khác), không mở Chrome
```

**Build phát hành** (thư mục tĩnh `build/web/`):

```bash
fvm flutter build web --release
```

Host `build/web/` bằng bất kỳ static server nào (nginx, Firebase Hosting, GitHub Pages, `python3 -m http.server` trong folder đó). Không mở `index.html` bằng `file://` — asset `.tmx` / atlas sẽ fail.

**Renderer:** game 2D (tile, atlas, collision) dùng **CanvasKit / Skwasm** (mặc định Flutter mới). Không chuyển sang HTML renderer — tile/atlas dễ sai màu, giật, hoặc không vẽ.

**Input:**

| Nguồn | Web | Ghi chú |
|-------|-----|---------|
| Keyboard | A/D, Space, dash, E, Esc | Cần **click canvas** một lần để focus (browser không gửi phím khi tab chưa focus) |
| Touch / chuột | Overlay joystick + click | Giữ overlay mobile; trên desktop ưu tiên phím |
| Gamepad | Tùy chọn sau | Flame hỗ trợ; không bắt buộc MVP |

Trong `main.dart`, đảm bảo `GameWidget` nhận focus (ví dụ bọc `Focus` / click-to-focus). `HasKeyboardHandlerComponents` trên `WizardGame` dùng chung web và desktop.

**Audio (`flame_audio`):** trình duyệt chặn autoplay. Chỉ `play` BGM/SFX **sau gesture đầu** (tap nút Start / click canvas). Gọi `AudioPlayer.audioCache` / load atlas audio trong `onLoad`, nhưng `play()` sau khi user tương tác.

**Asset & map:**

- Mọi path trong `.tmx` / `.tsx` phải **relative** (`../images/tiles/...`). Web không đọc được `/Users/...`.
- Khai báo đủ folder trong `pubspec.yaml` — Flutter web serve asset từ cùng origin, không CORS khi chạy `fvm flutter run` / host `build/web`.
- File map lớn + tile 512: lần load đầu trên web chậm hơn native; zoom runtime vẫn ~12–16 tile ngang (màn desktop rộng hơn thì camera clamp theo map, không kéo thêm tile on-screen nếu chưa tối ưu).

**Cấu trúc thêm sau `fvm flutter create --platforms=web`:**

```
web/
  index.html          # title, canvas, PWA meta
  manifest.json       # name, icons
  favicon.png
  icons/
```

---

## Phần B — Hướng dẫn vẽ map (Tiled)

### B1. Chuẩn thế giới (chốt 1 lần, không đổi)

| Thông số | Giá trị đề xuất | Lý do |
|----------|-----------------|-------|
| Tile nguồn asset | **512 × 512** | `Mossy - TileSet.png` = 3584² → lưới 7×7 tile |
| Tile trong Tiled (MVP) | **512 × 512** | Khớp file gốc, đơn giản |
| Tile runtime (scale) | Zoom Flame sao cho ~**12–16 tile** ngang màn | Mobile đọc map dễ; web/desktop clamp camera theo cùng số tile (không “nhìn xa hơn” để giữ độ khó) |
| Orientation | Orthogonal | Side-view platformer |
| Map type | Infinite **tắt** (MVP) | Dễ clamp camera |
| Size map Zone1 slice | ~**80 × 30** tile | Vertical slice chơi được |

> Nếu Tiled nặng với tile 512: downsample tileset còn **128×128** (scale 0.25) bằng editor ảnh, rồi đặt Tile size = 128. **Phải đồng bộ** mọi tileset/deco cùng hệ số.

### B2. Cài Tiled & tạo map mới

1. Cài [Tiled](https://www.mapeditor.org/).
2. **File → New → New Map…**
   - Orientation: Orthogonal  
   - Tile size: `512 × 512` (hoặc 128 nếu đã downsample)  
   - Map size: `80 × 30`  
3. **Save As** →  
   `assets/maps/zone1_slice.tmx`

### B3. Thêm tileset vào map

**Map → Add External Tileset…** hoặc **New Tileset**:

| Tileset name | Ảnh nguồn | Tile W×H | Ghi chú |
|--------------|-----------|----------|---------|
| `mossy_ground` | `Mossy - TileSet.png` | 512×512 | Collision chính |
| `mossy_platforms` | `Mossy - FloatingPlatforms.png` | tùy cắt | Platform / fake floor visual |
| `mossy_hazards` | `Mossy - Decorations&Hazards.png` | object / tile | Gai, deco |
| `mossy_bg` | `Mossy - MossyHills.png` + BackgroundDecoration | — | Layer nền (không collide) |

Với ảnh **không chia đều lưới** (Decorations&Hazards): dùng **Tileset type = Collection of Images** hoặc vẽ hazard bằng **Object** + sprite property thay vì tile.

**Export / đường dẫn ảnh:** để Tiled dùng relative path:

```
assets/maps/zone1_slice.tmx
assets/images/tiles/Mossy - TileSet.png
```

Trong `.tsx`/`.tmx`, path kiểu `../images/tiles/Mossy - TileSet.png`.

### B4. Layers bắt buộc (đặt tên đúng — code đọc theo tên)

#### Tile layers (từ dưới lên)

| Tên layer | Collision? | Nội dung |
|-----------|------------|----------|
| `bg_far` | Không | Hills / background xa |
| `bg_near` | Không | Cột đá, hanging plants |
| `ground` | **Có** | Sàn, tường đặc |
| `platforms` | **Có** (one-way nếu cần) | Floating platforms |
| `deco` | Không | Cỏ, rêu trang trí |
| `spikes_tile` | Optional | Gai gắn tile (hoặc dùng object) |

#### Object layers

| Tên layer | Type object | Mục đích |
|-----------|-------------|----------|
| `obj_spawn` | `player_spawn` | Điểm vào màn |
| `obj_checkpoints` | `checkpoint` | Tượng lưu |
| `obj_spikes` | `spike` | Hitbox gai |
| `obj_hazards` | `fake_floor`, `wind_zone`, `gravity_zone` | Bẫy đặc biệt |
| `obj_enemies` | `slime` | Slime bounce / patrol |
| `obj_tablets` | `tablet` | Bia đá lore |
| `obj_meta` | `segment`, `camera_bounds` | ID đoạn, giới hạn cam |

### B5. Custom properties (data-driven)

Gắn trên **object** (và map nếu cần). LevelLoader đọc properties → không hardcode trong Dart.

#### Map properties

| Property | Type | Ví dụ |
|----------|------|-------|
| `zone_id` | string | `zone1` |
| `zone_name` | string | `Mouth of Echo` |
| `bgm` | string | `zone1_loop` |

#### `player_spawn`

| Property | Type | Mặc định |
|----------|------|----------|
| `facing` | int | `1` (phải) |

#### `checkpoint`

| Property | Type | Mặc định |
|----------|------|----------|
| `id` | string | `cp_01` |
| `is_default` | bool | `false` (spawn đầu = true) |

#### `spike`

| Property | Type | Mặc định |
|----------|------|----------|
| `side` | string | `floor` / `ceiling` / `wall` |
| `lethal` | bool | `true` |

#### `fake_floor`

| Property | Type | Mặc định |
|----------|------|----------|
| `delay_ms` | int | `200` |
| `telegraph` | bool | `true` |
| `respawn_on_rewind` | bool | `true` |

#### `wind_zone`

| Property | Type | Mặc định |
|----------|------|----------|
| `dir_x` | float | `-1` |
| `dir_y` | float | `0` |
| `strength` | float | `400` |

#### `gravity_zone`

| Property | Type | Mặc định |
|----------|------|----------|
| `scale` | float | `-1` |

#### `slime`

| Property | Type | Mặc định |
|----------|------|----------|
| `color` | string | `green` / `orange` |
| `patrol_left` | float | offset world/px hoặc tile |
| `patrol_right` | float | |
| `base_force` | float | `600` |
| `lateral_force` | float | `280` |

#### `tablet`

| Property | Type | Mặc định |
|----------|------|----------|
| `lore_id` | string | `z1_01` |

#### `segment` (object rect bao cả đoạn chơi)

| Property | Type | Mặc định |
|----------|------|----------|
| `id` | string | `seg_intro` |
| `soft_checkpoint_after_deaths` | int | `5` |

### B6. Cách vẽ từng loại nội dung

#### 1) Địa hình (`ground`)

1. Chọn brush / stamp trên layer `ground`.
2. Vẽ sàn liên tục; tránh “pixel hole” 1 tile lỗ (player kẹt).
3. Đánh dấu tile solid: trong Tileset Editor → chọn tile → **Class / Type** = `solid` **hoặc** dùng collision shapes của Tiled (hỗ trợ `flame_tiled`).

**Khuyến nghị MVP:** cả layer `ground` đều solid; không cần per-tile type phức tạp.

#### 2) Floating platform

- Vẽ trên `platforms`.
- Gap để luyện jump: rộng **1.5–3 tile** (tùy zoom).
- Fake safe: đặt object `fake_floor` **trùng** visual platform + property `delay_ms`.

#### 3) Gai (rage)

- Đặt object rectangle trên `obj_spikes`, type `spike`.
- Hitbox **hẹp hơn** art ~15–25% (căn giữa cụm gai).
- Trần gai phía trên slime bounce: để cách đỉnh bounce “an toàn” ~0.5 tile — lệch góc mới chết.

#### 4) Slime

1. Object type `slime`, kích thước ~ hitbox (không cần full 376px).
2. Đặt trên sàn patrol.
3. Thêm 2 điểm hoặc dùng `patrol_left` / `patrol_right`.
4. Phía trên: cụm `spike` ceiling.

#### 5) Dash gap (last-frame)

1. Hai mép platform, khoảng trống ≈ quãng dash (xem ARCHITECTURE §5.4).
2. Dưới gap: chết (void hoặc gai) → rewind.
3. Teach room: gap dễ hơn 10–15% trước khi vào gap thật.

#### 6) Wind / Gravity

- Object **hình chữ nhật** bao vùng ảnh hưởng.
- Type `wind_zone` / `gravity_zone`.
- Deco gần zone: tile/plant wind (layer `deco`) làm telegraph.

#### 7) Checkpoint & lore

- `checkpoint`: đặt **thưa** (xa xỉ) — sau teach + sau rage peak.
- `tablet`: gần đường chính, không bắt sidepath xa.
- Checkpoint đầu map: `is_default = true`.

### B7. Pacing một segment (checklist khi vẽ)

```
[ ] Spawn + 2–3 jump an toàn
[ ] Dạy 1 trap mới (telegraph rõ)
[ ] Kết hợp 2 cơ chế
[ ] Đoạn dài không checkpoint (rage)
[ ] Breath room + tablet lore
[ ] Checkpoint tượng
```

Lặp pattern này cho mỗi `segment`.

### B8. Quy ước đặt tên file map

```
assets/maps/
  zone1_slice.tmx          # vertical slice / MVP
  zone1_a_mouth.tmx
  zone1_b_echo.tmx
  zone2_spire.tmx
  templates/               # object templates Tiled (optional)
  tilesets/
    mossy_ground.tsx
    mossy_platforms.tsx
```

### B9. Load map trong Flame (`flame_tiled`)

```dart
import 'package:flame_tiled/flame_tiled.dart';

final map = await TiledComponent.load(
  'zone1_slice.tmx',
  Vector2.all(512), // hoặc 128 nếu downsample
  prefix: 'assets/maps/',
);

await world.add(map);

// Duyệt object layers:
final checkpoints = map.tileMap.getLayer<ObjectGroup>('obj_checkpoints');
for (final obj in checkpoints?.objects ?? const []) {
  if (obj.type == 'checkpoint' || obj.class_ == 'checkpoint') {
    // spawn CheckpointComponent(obj)
  }
}
```

> Tiled 1.9+ dùng field **Class** (trước đây Type). Trong code kiểm tra cả `type` và `class_` tùy version `tiled` package.

### B10. Checklist trước khi coi map “chơi được”

- [ ] Có đúng 1 `player_spawn`
- [ ] Có ≥ 1 `checkpoint` (`is_default` cho tượng đầu)
- [ ] Layer `ground` không thủng lỗ gây soft-lock
- [ ] Mọi `spike` / `slime` / `fake_floor` có type đúng
- [ ] Void dưới map có kill (fallback death Y)
- [ ] Camera bounds không để nhìn ngoài ý muốn (hoặc clamp theo map size)
- [ ] File `.tmx` + ảnh tileset path relative, chạy được trên **device và web** (không absolute `/Users/...`)
- [ ] App load được: khai báo đúng `assets/maps/` trong `pubspec.yaml`
- [ ] Web: `fvm flutter run -d chrome` load map + bàn phím sau khi click canvas

### B11. Workflow hàng ngày (designer ↔ code)

```
1. Sửa map trong Tiled → Save .tmx
2. Hot restart (web: Chrome; mobile: device/emulator) — Flame load lại level
3. Playtest đoạn vừa sửa (web dùng phím cho iterate nhanh)
4. Chỉ đổi property trên Tiled (force, delay…) trước khi nhờ sửa code
5. Commit map + tileset .tsx cùng nhau
```

---

## Phần C — Lỗi thường gặp

| Triệu chứng | Nguyên nhân | Cách xử |
|-------------|-------------|---------|
| Map trắng / không thấy tile | Sai path ảnh trong `.tmx` | Dùng relative path từ `assets/maps/` |
| Asset not found | Chưa khai báo `pubspec` | Thêm folder + `fvm flutter pub get` |
| Player rơi xuyên sàn | Layer không tên `ground` / chưa gắn collision | Đúng tên layer; loader chỉ collide `ground`+`platforms` |
| Object không spawn | Sai `type`/`class` | Khớp bảng B4–B5 |
| Giật / lag | Tile 512 + quá nhiều animated | Scale zoom; giảm deco animated on-screen |
| Gai không giết | Hitbox object = 0 hoặc layer sai | Vẽ rect rõ trên `obj_spikes` |
| `fvm flutter devices` không có Chrome | Web chưa bật / chưa cài Chrome | `fvm flutter config --enable-web` rồi `fvm flutter doctor`; cài Chrome |
| Web: phím không điều khiển | Canvas chưa focus | Click vào game một lần; bọc `GameWidget` nhận focus |
| Web: không có tiếng | Autoplay bị chặn | `play()` sau tap/click Start, không play trong `onLoad` |
| Web: map/atlas 404 | Mở `file://` hoặc path tuyệt đối | `fvm flutter run -d chrome` hoặc host `build/web/`; path relative trong `.tmx` |
| Web: tile vẽ sai / giật nặng | HTML renderer | Để mặc định CanvasKit/Skwasm; không dùng `--web-renderer html` |
| Sai phiên bản Flutter / lệnh không nhận | Gọi `flutter` global thay vì FVM | Luôn `fvm flutter …` / `fvm dart …` trong repo; kiểm tra `fvm list` = 3.44.8 |

---

## Phần D — Việc làm ngay (checklist)

1. [ ] Cài FVM, `fvm use 3.44.8`, `fvm flutter doctor`
2. [ ] `fvm flutter create` với org `com.vunt` → id `com.vunt.wizard`, **platforms `android,ios,web`**
3. [ ] Title web: `web/index.html` + `web/manifest.json` = `Wizard: Mê Lộ`
4. [ ] Thêm `flame`, `flame_tiled`, assets trong `pubspec.yaml` → `fvm flutter pub get`
5. [ ] Copy Mossy tileset + slime atlas vào `assets/`
6. [ ] Cài Tiled, tạo `zone1_slice.tmx` (80×30, tile 512)
7. [ ] Tạo đủ layer đúng tên (B4)
8. [ ] Đặt spawn, 1 checkpoint, vài spike, 1 đoạn ground
9. [ ] Load `.tmx` bằng `TiledComponent` trong `WizardGame`
10. [ ] Chạy thử **web**: `fvm flutter run -d chrome` (click canvas, phím A/D)
11. [ ] Tiếp: player + collision + rewind (theo ARCHITECTURE §9) — dùng chung mobile và web

---

*Cập nhật file này khi chốt tile size runtime (512 vs 128), version Flame chính thức, và cách host bản web.*
