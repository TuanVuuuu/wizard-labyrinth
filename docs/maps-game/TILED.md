# Vẽ map trong Tiled

Làm theo thứ tự. File map và tileset lưu dưới `assets/maps/` để Flutter bundle được.

Tiled: [mapeditor.org](https://www.mapeditor.org/) ≥ **1.10**. Tiled 1.9+ dùng **Class** (cũ: Type) — điền Class cho object; Flame kiểm tra cả `class_` và `type`.

---

## 1. Tạo tileset địa hình (`mossy_ground.tsx`)

1. **File → New → New Tileset…**
2. Tileset name: `mossy_ground`
3. Type: **Based on Tileset Image**
4. Image: `assets/maps/mossy-tileset/Mossy - TileSet.png`
5. Tile width / height: **512 / 512**
6. Margin / Spacing: **0**
7. **Embed in map**: tắt — **Save As**  
   `assets/maps/tilesets/mossy_ground.tsx`

Trong `.tsx`, `image source` phải relative, ví dụ:

```xml
<image source="../mossy-tileset/Mossy - TileSet.png" width="3584" height="3584"/>
```

Nếu Tiled ghi path tuyệt đối: Tileset → Tileset Properties → Image → chọn lại file từ thư mục project.

### Collision từng tile

1. Mở `mossy_ground.tsx` trong Tileset Editor.
2. **View → Collision Editor** (hoặc nút Collision trên tile đã chọn).
3. Vẽ **rectangle** (hoặc polygon đơn) cho phần **đá đặc**, thụt vào so với rêu.
4. Tile trống / chỉ deco: **không** vẽ collision.
5. Có thể gán Class tile = `solid` cho ô có collision (loader dự phòng nếu chưa đọc shape).

MVP: mọi tile đã stamp trên layer `ground` đều solid theo collision shape; không cần type phức tạp hơn.

### Stamp Brush

Khối platform/cột trên sheet gồm **nhiều ô 512** kề nhau. Chọn vùng (kéo trên tileset) → Stamp lên map. Đừng vẽ từng ô lệch hàng — sẽ hở collision.

---

## 2. Tileset stamp (platform, hazard, deco)

Năm PNG còn lại **không** import kiểu lưới 512.

### Cách A — Collection of Images (nên dùng khi đã cắt sprite)

1. Cắt từng sprite → `assets/maps/mossy-tileset/slices/...` (giữ RGBA).
2. **New Tileset** → **Collection of Images** → Add Images.
3. Save:
   - `tilesets/mossy_platforms.tsx`
   - `tilesets/mossy_hazards.tsx`
   - `tilesets/mossy_deco.tsx`
4. Kéo tile vào layer `platforms` / `deco` như tileset thường. Object tile vẫn có `gid` để Flame vẽ.

### Cách B — Object + property (MVP, chưa cắt sprite)

1. Không cần `.tsx` stamp.
2. Vẽ visual tạm bằng `mossy_ground` hoặc để trống.
3. Đặt rectangle đúng kích thước chơi trên object layer, Class = `platform` / `spike` / …
4. Property `sprite` = tên logic (`platform_long`, `spike_floor`, …). Code map tên → `Sprite` (src rect trên sheet).

Map đầu tiên: **Cách B cho gai + spawn**; **Cách A hoặc stamp `mossy_ground` cho sàn**.

---

## 3. Tạo map mới

1. **File → New → New Map…**
   - Orientation: **Orthogonal**
   - Tile layer format: CSV (mặc định)
   - Tile size: **512 × 512**
   - Map size: **80 × 30** (Zone 1 slice)
   - Infinite: **tắt**
2. **Save As** → `assets/maps/zone1_slice.tmx` (cùng cây `assets/maps/` với `tilesets/`).
3. **Map → Add External Tileset…** → `tilesets/mossy_ground.tsx`

### Map properties (Map → Map Properties)

| Property | Type | Ví dụ |
|----------|------|--------|
| `zone_id` | string | `zone1` |
| `zone_name` | string | `Mouth of Echo` |
| `bgm` | string | `zone1_loop` |

---

## 4. Tạo layer đúng tên

**Layer → Add** theo thứ tự dưới → trên (layer trên cùng vẽ đè).

Tile layers: `bg_far`, `bg_near`, `ground`, `platforms`, `deco`, `fg` (fg tùy chọn).

Object layers: `obj_spawn`, `obj_checkpoints`, `obj_spikes`, `obj_hazards`, `obj_enemies`, `obj_tablets`, `obj_meta`.

Tên **khớp từng ký tự** với [README §5](./README.md). Sai tên = Flame không tìm thấy layer.

---

## 5. Vẽ địa hình (`ground`)

1. Chọn layer `ground`, tileset `mossy_ground`.
2. Vẽ sàn liên tục từ spawn tới checkpoint; **cấm lỗ 1 ô** (player kẹt / rơi soft-lock).
3. Trần và tường: stamp góc lõm/lồi cho hang chữ L.
4. Dưới map: để void (rơi = chết) **hoặc** gai — runtime cần `deathY` fallback.
5. Kiểm tra Collision Editor đã có shape trên mọi ô đã dùng làm sàn/tường.

**Gap nhảy:** 1.5–3 tile (tùy zoom 12–16 ô ngang). Teach room hẹp hơn 10–15% so với gap “thật”.

**Fake floor:** vẽ platform bình thường trên `platforms`; thêm object `fake_floor` **trùng** AABB, `delay_ms` = 200, `telegraph` = true.

---

## 6. Object — Class và properties

Chọn object → **Class** (không để trống). Rectangle đủ lớn để thấy trên map 512.

### `player_spawn` — layer `obj_spawn`

Đúng **một** object. Đặt chân trên sàn `ground` (không cắm vào tường).

| Property | Type | Mặc định |
|----------|------|----------|
| `facing` | int | `1` (phải), `-1` trái |

### `checkpoint` — `obj_checkpoints`

| Property | Type | Mặc định |
|----------|------|----------|
| `id` | string | `cp_01` |
| `is_default` | bool | `false` — tượng **đầu map** = `true` |

Checkpoint **thưa**: sau teach + sau rage peak, không mỗi 5 ô một tượng.

### `spike` — `obj_spikes`

| Property | Type | Mặc định |
|----------|------|----------|
| `side` | string | `floor` / `ceiling` / `wall` |
| `lethal` | bool | `true` |

Hitbox hẹp hơn art. Trần gai trên slime: cách đỉnh bounce an toàn ~0.5 tile.

### `fake_floor` — `obj_hazards`

| Property | Type | Mặc định |
|----------|------|----------|
| `delay_ms` | int | `200` |
| `telegraph` | bool | `true` |
| `respawn_on_rewind` | bool | `true` |

### `wind_zone` — `obj_hazards`

| Property | Type | Mặc định |
|----------|------|----------|
| `dir_x` | float | `-1` |
| `dir_y` | float | `0` |
| `strength` | float | `400` |

Rectangle bao vùng gió. Telegraph: plant wind / deco trên `deco`.

### `gravity_zone` — `obj_hazards`

| Property | Type | Mặc định |
|----------|------|----------|
| `scale` | float | `-1` |

Segment ngắn; có rune / tint — không flip giữa dash.

### `slime` — `obj_enemies`

| Property | Type | Mặc định |
|----------|------|----------|
| `color` | string | `green` / `orange` |
| `patrol_left` | float | offset world (px) |
| `patrol_right` | float | |
| `base_force` | float | `600` |
| `lateral_force` | float | `280` |

Object ≈ hitbox (không full 376px art). Đặt trên sàn patrol.

### `tablet` — `obj_tablets`

| Property | Type | Mặc định |
|----------|------|----------|
| `lore_id` | string | `z1_01` |

Gần đường chính, không nhét sidepath xa.

### `segment` — `obj_meta`

Rectangle bao cả đoạn chơi.

| Property | Type | Mặc định |
|----------|------|----------|
| `id` | string | `seg_intro` |
| `soft_checkpoint_after_deaths` | int | `5` |

### `camera_bounds` — `obj_meta`

Rectangle clamp camera. Không có thì clamp theo kích thước map.

---

## 7. Pacing một segment

Khi vẽ xong một đoạn, checklist:

```
[ ] Spawn + 2–3 jump an toàn
[ ] Dạy 1 trap mới (telegraph rõ)
[ ] Kết hợp 2 cơ chế
[ ] Đoạn dài không checkpoint (rage)
[ ] Breath room + tablet lore
[ ] Checkpoint tượng
```

Lặp pattern cho mọi `segment`. Chi tiết rage-fair: [`PLAN.md`](../PLAN.md) §3 / §7.

---

## 8. Checklist map “chơi được”

- [ ] Path ảnh trong `.tsx` / `.tmx` **relative** (không `/Users/...`)
- [ ] `mossy_ground.tsx` + `zone1_slice.tmx` nằm dưới `assets/maps/`
- [ ] Đủ layer đúng tên
- [ ] Đúng 1 `player_spawn`; ≥ 1 `checkpoint` có `is_default`
- [ ] `ground` không thủng lỗ soft-lock
- [ ] Mọi spike / slime / fake_floor có **Class** đúng
- [ ] Void hoặc `deathY` dưới map
- [ ] `pubspec.yaml` có `assets/maps/` **và** `assets/maps/mossy-tileset/` (+ `tilesets/` nếu dùng `.tsx` rời)

---

## 9. Workflow hàng ngày

```
1. Sửa map trong Tiled → Save .tmx / .tsx
2. Hot restart (Chrome hoặc device) — Flame load lại file asset
3. Playtest đoạn vừa sửa
4. Đổi delay / force / side trên Tiled trước khi nhờ sửa Dart
5. Commit .tmx + .tsx cùng nhau
```

Hot reload Flutter **không** luôn reload `.tmx`. Dùng **hot restart**.
