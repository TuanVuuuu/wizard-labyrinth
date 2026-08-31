# Tạo map — Wizard: Mê Lộ (Flame + Tiled)

> Pipeline: **Tiled (`.tmx` / `.tsx`) → `flame_tiled` → Flame**.  
> Asset nguồn: [`assets/maps/mossy-tileset/`](../../assets/maps/mossy-tileset/).  
> Game: platformer side-view, hang rêu, rage-trap (xem [`PLAN.md`](../PLAN.md)).

Tài liệu này hướng dẫn **tạo map chơi được** từ pack Mossy, không lặp lại phần bootstrap project ([`SETUP_AND_MAP_GUIDE.md`](../SETUP_AND_MAP_GUIDE.md) Phần A).

| File | Nội dung |
|------|----------|
| [ASSET_CATALOG.md](./ASSET_CATALOG.md) | 6 PNG: kích thước, vai trò, lưới vs stamp |
| [TILED.md](./TILED.md) | Cài Tiled, tạo tileset `.tsx`, vẽ map `.tmx` |
| [FLAME.md](./FLAME.md) | Load map trong Flame, collision, object spawn |

---

## 1. Pipeline

```
assets/maps/mossy-tileset/*.png     ← art nguồn (đã có)
        │
        ▼
Tiled:  tilesets/*.tsx              ← cắt / gán collision / terrain
        zone1_slice.tmx             ← layer + object (spawn, gai, slime…)
        │
        ▼
Flame:  TiledComponent.load(...)    ← vẽ tile
        LevelLoader                 ← object → component (player, hazard)
```

Designer chỉnh map và property trên Tiled. Code chỉ đọc **tên layer / class object / custom properties** — không hardcode vị trí trap.

---

## 2. Công cụ

| Công cụ | Vai trò |
|---------|---------|
| [Tiled](https://www.mapeditor.org/) ≥ 1.10 | Vẽ `.tmx`, tileset `.tsx` |
| Flutter + Flame (`flame_tiled`) | Load map lúc chạy |
| FVM → Flutter **3.44.8** | Mọi lệnh: `fvm flutter` / `fvm dart` |

Không bắt buộc cắt sprite bằng editor ảnh cho **bước 1** (địa hình lưới). Các sheet không lưới (platform, gai, deco) dùng **Collection of Images** hoặc **object + sprite** — chi tiết trong [TILED.md](./TILED.md).

---

## 3. Thư mục map (chuẩn project)

```
assets/maps/
  mossy-tileset/                      # art nguồn — không đổi tên file
    Mossy - TileSet.png               # địa hình lưới 512 (collision)
    Mossy - FloatingPlatforms.png     # platform nổi (không lưới đều)
    Mossy - Decorations&Hazards.png   # gai, đá, cây
    Mossy - BackgroundDecoration.png  # khối rêu nền
    Mossy - MossyHills.png            # đồi parallax
    Mossy - Hanging Plants.png        # cây treo trần
  tilesets/                           # .tsx Tiled (tạo khi vẽ map)
    mossy_ground.tsx
    mossy_platforms.tsx
    mossy_hazards.tsx
    mossy_deco.tsx
  zone1_slice.tmx                     # map MVP đầu tiên
```

**Path trong `.tmx` / `.tsx` phải relative** (ví dụ `../mossy-tileset/Mossy - TileSet.png`). Không dùng `/Users/...` — web và device sẽ fail.

**Flutter không bundle thư mục con tự động.** `pubspec.yaml` cần khai báo từng folder:

```yaml
flutter:
  assets:
    - assets/maps/
    - assets/maps/mossy-tileset/
    - assets/maps/tilesets/
```

`assets/maps/` **không** kéo theo file trong `mossy-tileset/`. Thiếu dòng con → map trắng / asset not found.

---

## 4. Chuẩn thế giới (chốt, không đổi giữa các map)

| Thông số | Giá trị | Ghi chú |
|----------|---------|---------|
| Orientation | Orthogonal | Side-view |
| Tile size trong Tiled | **512 × 512** | Khớp `Mossy - TileSet.png` (3584² = 7×7) |
| Map type | Finite (tắt Infinite) | Dễ clamp camera |
| Map MVP (Zone 1 slice) | ~**80 × 30** tile | Vertical slice chơi được |
| Runtime zoom | ~**12–16 tile** ngang màn | `viewfinder.zoom` trong Flame; không downsample art trừ khi Tiled quá nặng |
| Fill hang | Nền tối / đen | Tâm tile “rỗng” của tileset là khoảng tối hang, không phải lỗ collision |

Nếu Tiled giật với tile 512: downsample **mọi** sheet cùng hệ số (ví dụ 0.25 → tile 128) rồi đổi Tile size. Không mix 512 và 128 trên cùng một map.

---

## 5. Layer & object (tên bắt buộc)

Code đọc **đúng chuỗi tên** dưới đây. Đổi tên layer = trap/player không spawn.

### Tile layers (dưới → trên)

| Tên | Collision | Nội dung |
|-----|-----------|----------|
| `bg_far` | Không | `MossyHills` / khối rêu xa |
| `bg_near` | Không | Cột đá nền, hanging plants xa |
| `ground` | **Có** | Sàn, tường, trần đặc (`TileSet.png`) |
| `platforms` | **Có** (one-way nếu cần) | Platform nổi |
| `deco` | Không | Cỏ, rêu, cây trang trí |
| `fg` | Không | Cây treo / deco che player (tùy chọn) |

### Object layers

| Tên | Class / Type object | Mục đích |
|-----|---------------------|----------|
| `obj_spawn` | `player_spawn` | Đúng **1** điểm vào màn |
| `obj_checkpoints` | `checkpoint` | Tượng lưu |
| `obj_spikes` | `spike` | Hitbox gai (hẹp hơn art) |
| `obj_hazards` | `fake_floor`, `wind_zone`, `gravity_zone` | Bẫy đặc biệt |
| `obj_enemies` | `slime` | Slime patrol / bounce |
| `obj_tablets` | `tablet` | Bia đá lore |
| `obj_meta` | `segment`, `camera_bounds` | ID đoạn, giới hạn cam |

Custom properties (delay, force, lore_id, …) xem [TILED.md § Properties](./TILED.md).

---

## 6. Việc làm ngay (map đầu tiên)

1. Cài Tiled ≥ 1.10.
2. Tạo tileset `mossy_ground.tsx` từ `Mossy - TileSet.png` (512×512) — [TILED.md](./TILED.md).
3. Tạo map `zone1_slice.tmx` (80×30, orthogonal, tile 512).
4. Thêm đủ layer đúng tên (§5).
5. Vẽ một hành lang `ground` liên tục (không lỗ 1 tile).
6. Đặt 1 `player_spawn`, 1 `checkpoint` (`is_default = true`), vài `spike`.
7. Khai báo `assets/maps/mossy-tileset/` trong `pubspec.yaml` → `fvm flutter pub get`.
8. Load bằng `TiledComponent` — [FLAME.md](./FLAME.md).

Map “chơi được” = spawn + sàn + 1 checkpoint + 1 hazard. Chưa cần parallax / slime / wind.

---

## 7. Quy ước đặt tên file map

```
assets/maps/
  zone1_slice.tmx          # vertical slice MVP
  zone1_a_mouth.tmx        # Mouth of Echo
  zone1_b_echo.tmx
  zone2_spire.tmx
```

`zone{N}_{id}_{tên ngắn}.tmx`. Commit `.tmx` + `.tsx` cùng nhau (path ảnh relative).

---

*Đồng bộ với [`ARCHITECTURE.md`](../ARCHITECTURE.md) §3.5 / §6 và [`PLAN.md`](../PLAN.md) §7.*
