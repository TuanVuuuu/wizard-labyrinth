# Dùng Tiled trên macOS — Wizard: Mê Lộ

Hướng dẫn **cài và dùng [Tiled Map Editor](https://www.mapeditor.org/)** trên Mac để chỉnh map của project. Game đọc file `.tmx` lúc chạy; bạn vẽ trong Tiled, lưu, rồi hot restart Flutter.

Yêu cầu: Tiled **≥ 1.10** (Tiled 1.9+ dùng trường **Class** cho object, không còn nhãn Type).

Quy ước layer, Class object, collision: [`../maps-game/TILED.md`](../maps-game/TILED.md). Catalog PNG: [`../maps-game/ASSET_CATALOG.md`](../maps-game/ASSET_CATALOG.md).

---

## 1. Cài Tiled

Chọn **một** cách.

### Homebrew (nhanh nếu đã có `brew`)

```bash
brew install --cask tiled
```

App nằm tại `/Applications/Tiled.app`. Cập nhật: `brew upgrade --cask tiled`.

### Tải `.dmg` từ trang chủ

1. Mở [mapeditor.org](https://www.mapeditor.org/) → **Download**.
2. Chọn bản **macOS** (Apple Silicon hoặc Intel — khớp chip: Apple menu → **About This Mac**).
3. Mở `.dmg` → kéo **Tiled** vào thư mục **Applications**.
4. Eject disk image.

### Lần mở đầu (Gatekeeper)

macOS có thể báo *“Tiled can’t be opened because it is from an unidentified developer”*.

1. Finder → **Applications**.
2. **Control-click** (hoặc tap hai ngón) vào **Tiled** → **Open**.
3. Xác nhận **Open**. Lần sau mở bình thường từ Spotlight (`Cmd + Space`, gõ `Tiled`) hoặc Dock.

Không chạy Tiled từ thư mục **Downloads** lâu dài — copy vào Applications trước.

---

## 2. Mở map của project

Map đang chơi:

```
WizardLabyrinth/assets/maps/zone1_slice.tmx
```

Cách mở:

- Kéo file `.tmx` thả vào icon Tiled trên Dock, **hoặc**
- Tiled → **File → Open…** (`Cmd + O`) → chọn `zone1_slice.tmx`, **hoặc**
- Finder: Control-click file → **Open With → Tiled**.

Giữ file **trong** `assets/maps/`. **Save As** ra Desktop / iCloud sẽ làm game không thấy map (và path ảnh dễ thành tuyệt đối).

Tileset địa hình đã **embed** trong `zone1_slice.tmx`. Map mới: **Map → Add External Tileset…** → `assets/maps/tilesets/mossy_ground.tsx`.

---

## 3. Cửa sổ Tiled trên Mac

Nếu thiếu panel: menu **View** → bật **Tilesets**, **Layers**, **Properties**, **Minimap**.

| Panel | Việc dùng |
|-------|-----------|
| **Tilesets** (thường dưới / phải) | Chọn ô hoặc kéo chọn khối 3×3 rồi stamp |
| **Layers** | Phải chọn đúng layer trước khi vẽ — vẽ nhầm `deco` thì không có sàn |
| **Properties** | Class object (`player_spawn`, `checkpoint`, …) và custom property |
| **Map view** (giữa) | Canvas thế giới |

Tile nguồn **512×512**: map trông rất lớn. Zoom **ra** ngay (`Cmd + -` hoặc pinch trackpad) để thấy cả slice.

Ẩn layer nền khi Tiled giật: click icon mắt cạnh `bg_far` / `deco` trong panel Layers.

---

## 4. Vẽ địa hình

1. Panel **Layers** → chọn `ground` (sàn, cột) hoặc `platforms` (bệ nổi).
2. Panel **Tilesets** → chọn `mossy_ground`.
3. Công cụ **Stamp Brush** (phím `B`).
4. Kéo chuột trên tileset để chọn **cả khối** (ví dụ platform 3×3), rồi click lên map.

Đừng ghép từng ô lệch hàng — hở collision / hở art.

**Eraser** (`E`): xóa **ô trên layer đang chọn** — không xóa layer khác, không xóa object (`spawn`, `cp_mouth`).

Thứ tự xóa tile:

1. Click vào canvas map một lần (để focus không nằm ở panel Properties).
2. Panel **Layers** → chọn đúng layer có ô đó: sàn/cột = `ground`, bệ nổi = `platforms`. Layer `bg_far` đang trống — xóa ở đây không đổi gì trên map.
3. Click icon **Eraser** trên toolbar (hình cục tẩy hồng), hoặc bấm `E` khi canvas đang focus. Icon tẩy phải **sáng** (Stamp Brush tắt).
4. Click từng ô, hoặc giữ chuột kéo.

Nếu `E` không đổi tool: đang gõ trong Properties — click ra map rồi bấm `E` lại, hoặc click icon tẩy.

Xóa nhãn `spawn` / `checkpoint`: đó là **object**, không phải tile. Chọn layer `obj_spawn` (hoặc `obj_checkpoints`) → công cụ **Select Objects** (`S`) → click object → `Delete` / `Backspace`.

**Rectangular Stamp** (`R`): tô hình chữ nhật cùng một tile.  
**Bucket Fill** (`F`): tô vùng liền — ít dùng với hang rêu (dễ tô nhầm).

Undo: `Cmd + Z`. Redo: `Cmd + Shift + Z`.

**Không đổi tên layer.** Flame đọc đúng chuỗi `ground`, `platforms`, `obj_spawn`, … — xem bảng trong [`../maps-game/README.md`](../maps-game/README.md) §5.

---

## 5. Object (spawn, checkpoint, gai)

1. Chọn object layer, ví dụ `obj_spawn`.
2. Toolbar: **Insert Rectangle** (hoặc menu **Insert → Rectangle**).
3. Kéo một hình trên map (đủ lớn để thấy; tile 512 nên rect ~64×96 trở lên).
4. Panel **Properties**:
   - **Class** = `player_spawn` / `checkpoint` / `spike` / … (bắt buộc, không để trống).
   - Thêm property (`facing`, `id`, `is_default`, …) như [`../maps-game/TILED.md`](../maps-game/TILED.md) §6.

Đúng **một** `player_spawn`. Checkpoint đầu map: `is_default` = `true`.

Di chuyển object: công cụ **Select Objects** (`S`), kéo. Xóa: `Delete` / `Backspace`.

---

## 6. Phím tắt macOS (hay dùng)

| Phím | Việc |
|------|------|
| `Cmd + O` | Mở map |
| `Cmd + S` | Lưu |
| `Cmd + Z` / `Cmd + Shift + Z` | Undo / Redo |
| `B` | Stamp Brush |
| `E` | Eraser |
| `R` | Rectangular Stamp |
| `F` | Bucket Fill |
| `S` | Select Objects |
| `Cmd + +` / `Cmd + -` | Zoom |
| `Cmd + 0` | Zoom vừa khung (nếu có) |
| Giữ `Space` + kéo | Pan canvas |
| Pinch trackpad | Zoom |
| Hai ngón kéo | Pan (tùy Preference trackpad) |

Tiled dùng **phím công cụ không cần Cmd** (`B`, `E`, …). `Cmd` dành cho lệnh file.

---

## 7. Path ảnh — lỗi hay gặp trên Mac

Trong `.tmx` / `.tsx`, `image source` phải **relative**, ví dụ:

```text
mossy-tileset/Mossy - TileSet.png
../mossy-tileset/Mossy - TileSet.png
```

**Không** để path kiểu `/Users/tên/dev/game/...`. Web và máy khác sẽ trắng map.

Nếu Tiled tự ghi path tuyệt đối:

1. Chọn tileset → **Tileset → Tileset Properties**.
2. **Image** → chọn lại PNG **từ thư mục project** (`assets/maps/mossy-tileset/`).
3. **File → Save**. Mở `.tmx` bằng text editor: không còn `/Users/`.

Không đổi tên file PNG nguồn (có dấu cách: `Mossy - TileSet.png`). Game và Tiled đang trỏ đúng tên đó.

---

## 8. Lưu và xem trong game

```
1. Cmd + S trong Tiled
2. Quay app Flutter đang chạy
3. Hot restart — không dùng hot reload
```

Hot reload **không** chắc nạp lại `.tmx`.

**Đổi kích thước map** (Resize Map) hoặc sửa `.tmx` lớn: **dừng hẳn app** rồi chạy lại `fvm flutter run` — hot restart (`R`) có thể vẫn dùng bản asset cũ trong `build/` (ví dụ map vẫn 18 ô dù file nguồn đã 36 ô).

| Nơi chạy | Hot restart |
|----------|-------------|
| Terminal `fvm flutter run` | gõ `R` (chữ hoa) |
| Cursor / VS Code | nút Restart (không phải Reload) |
| Chrome | sau restart, click lại canvas nếu cần |

Chạy lần đầu (từ thư mục repo):

```bash
cd /Users/tuanvu/dev/game/WizardLabyrinth
fvm flutter run -d chrome
```

Kéo chuột trên game để pan map. Camera zoom ~14 ô ngang (không nhét cả map vào một màn).

**Không** sửa trong Tiled các thứ Flame vẽ thêm: chấm sáng, gradient trời, đồi mờ — nằm ở `lib/game/world/wl_cavern_atmosphere.dart`.

---

## 9. Map mới / đổi kích thước

**Kéo dài map hiện tại** (không tạo file mới): Tiled → **Map → Resize Map…**

- **Width**: tăng số ô ngang (ví dụ 18 → **80**). Một màn điện thoại chỉ thấy ~12–16 ô; phần còn lại đi bộ / pan tới.
- **Height**: giữ 11 hoặc tăng nếu cần hang cao hơn (zone đầy đủ ~**30**).
- **Offset**: để **0 / 0** để địa hình cũ nằm **góc trên-trái**; ô mới trống bên phải / dưới.
- Không bật Infinite.

Rồi vẽ tiếp `ground` sang phải (hành lang liên tục từ spawn tới cuối). `Cmd + S` → hot restart.

**File → New → New Map…**

- Orientation: **Orthogonal**
- Tile size: **512 × 512** (khớp Mossy; đừng mix 128 với 512)
- Infinite: **tắt**
- Map size: slice hiện tại ~**18 × 11**; zone dài hơn có thể ~**80 × 30**

**Save As** → `assets/maps/…` (quy ước tên: [`../maps-game/README.md`](../maps-game/README.md) §7).

Đổi tên file `.tmx` thì phải sửa `WLMapConstants.zone1SliceFile` trong `lib/core/wl_map_constants.dart`. Thêm folder asset mới thì khai báo `pubspec.yaml` rồi `fvm flutter pub get`.

---

## 10. Lỗi thường gặp (Mac)

| Hiện tượng | Cách xử |
|------------|---------|
| Gatekeeper chặn mở Tiled | Control-click → Open; app phải trong Applications |
| Map trắng / mất tile trong Tiled | Path ảnh tuyệt đối — chọn lại PNG trong project |
| Sửa map nhưng game không đổi | Chưa Save, hoặc mới hot reload — cần **hot restart** |
| Vẽ xong không thấy sàn | Đang đứng layer `deco` / `bg_*` — chọn `ground` |
| Bấm `E` không xóa được ô | Đang chọn `bg_far` (trống) hoặc Stamp Brush vẫn bật — chọn `ground`/`platforms`, click icon tẩy, rồi click ô. Object thì dùng Select (`S`) + `Delete` |
| Tiled giật, zoom chậm | Ẩn `bg_*` / `deco`; tile 512 rất nặng trên Retina |
| File `.tmx` trên iCloud/Desktop | Game không bundle — chỉ làm việc trong `assets/maps/` |
| `Unable to load asset` lúc chạy | `pubspec.yaml` thiếu `assets/maps/mossy-tileset/` |

---

## 11. Checklist trước khi đóng Tiled

- [ ] Đã `Cmd + S`
- [ ] Path ảnh trong file vẫn relative
- [ ] Layer `ground` / `platforms` không đổi tên
- [ ] Còn đúng 1 `player_spawn`; checkpoint có Class
- [ ] Hot restart và nhìn lại trong Chrome / device

Xong một đoạn: commit **cùng lúc** `.tmx` và `.tsx` (nếu có sửa tileset).
