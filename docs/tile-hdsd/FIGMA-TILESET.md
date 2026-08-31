# Tạo tileset PNG trên Figma — Wizard: Mê Lộ

Hướng dẫn **tự làm file `*-tileset.png` + `.tsx`** từ sheet Mossy (ví dụ `Mossy - MossyHills.png`), để import vào Tiled **không bị lệch lưới**.

Phím tắt dưới đây ưu tiên **macOS**. Windows ghi trong ngoặc `(Win: …)` khi khác.

Quy ước layer map: [`../maps-game/TILED.md`](../maps-game/TILED.md). Dùng Tiled sau khi export: [`MAC.md`](./MAC.md).

---

## 1. Mục tiêu & chuẩn file

### Bạn đang làm gì?

| Khái niệm | Giải thích |
|-----------|------------|
| **Sheet gốc** | PNG lớn nhiều sprite (`Mossy - MossyHills.png`, …) |
| **Tileset atlas** | PNG mới: sprite xếp **lưới đều**, mỗi ô một tile |
| **`.tsx`** | File Tiled trỏ tới atlas + kích thước ô |

### Chuẩn atlas (bắt buộc)

- Mỗi ô **cùng kích thước**: **1024×1024** (đồi, cột, gai) hoặc **512×512** (chỉ khi sprite nhỏ như sàn).
- Kích thước frame = `số_cột × cell` × `số_hàng × cell` (ví dụ 4×2×1024 → **4096×2048**).
- Nền **trong suốt** (không flatten nền đen sheet gốc).
- Sprite **căn giữa** ô, chừa **padding ~32–48 px** mỗi mép.
- Thứ tự tile id: **trái → phải**, **trên → xuống** (ô (0,0) = id 0).

### Ví dụ đã có trong project

| Atlas | Kích thước | Ô | Tileset |
|-------|------------|---|---------|
| `MossyHills-tileset.png` | 4096×2048 | 1024 | `tilesets/mossy_hills.tsx` |
| `MossyDecorationsHazards-tileset.png` | 4096×8192 | 1024 | `tilesets/mossy_decorations_hazards.tsx` |

Lưu atlas vào: `assets/maps/mossy-tileset/`.  
Lưu `.tsx` vào: `assets/maps/tilesets/`.

---

## 2. Cài & mở Figma

1. Trình duyệt → [figma.com](https://www.figma.com) → đăng nhập (bản **Free** đủ dùng).
2. **macOS:** cài app Figma Desktop (tùy chọn, mượt hơn web).
3. **New design file** → đặt tên: `Wizard — Mossy tilesets`.

### Phím tắt Figma thường dùng (tra cứu nhanh)

| Thao tác | macOS | Windows |
|----------|-------|---------|
| Zoom in | `Cmd` + `+` | `Ctrl` + `+` |
| Zoom out | `Cmd` + `-` | `Ctrl` + `-` |
| Zoom 100% | `Cmd` + `0` | `Ctrl` + `0` |
| Zoom vừa selection | `Shift` + `2` | `Shift` + `2` |
| Pan canvas | `Space` + kéo chuột | `Space` + kéo |
| Undo | `Cmd` + `Z` | `Ctrl` + `Z` |
| Redo | `Cmd` + `Shift` + `Z` | `Ctrl` + `Shift` + `Z` |
| Copy | `Cmd` + `C` | `Ctrl` + `C` |
| Paste | `Cmd` + `V` | `Ctrl` + `V` |
| Duplicate | `Cmd` + `D` | `Ctrl` + `D` |
| Delete | `Delete` / `Backspace` | `Delete` |
| Select all | `Cmd` + `A` | `Ctrl` + `A` |
| Deselect | `Esc` | `Esc` |
| Group | `Cmd` + `G` | `Ctrl` + `G` |
| Ungroup | `Cmd` + `Shift` + `G` | `Ctrl` + `Shift` + `G` |
| Lock selection | `Cmd` + `Shift` + `L` | `Ctrl` + `Shift` + `L` |
| Hide selection | `Cmd` + `Shift` + `H` | `Ctrl` + `Shift` + `H` |
| Rename layer | `Cmd` + `R` | `Ctrl` + `R` |
| Frame tool | `F` | `F` |
| Rectangle | `R` | `R` |
| Move | `V` | `V` |
| Scale (kéo góc) | `K` rồi kéo | `K` |
| Measure distance | giữ `Alt` khi hover | giữ `Alt` |
| Pixel preview (nếu bật) | menu **View** | menu **View** |

---

## 3. Import sheet gốc

1. Trên canvas trống: **`Cmd` + `Shift` + `K`** (Place image) **hoặc** kéo file PNG từ Finder vào Figma.
2. Chọn file, ví dụ:  
   `assets/maps/mossy-tileset/Mossy - MossyHills.png`
3. Click đặt ảnh lên canvas.
4. Panel phải → đổi tên layer: `SOURCE — MossyHills`.
5. Chọn layer → **`Cmd` + `Shift` + `L`** (Lock) để không kéo nhầm khi crop.

**Lặp** cho từng sheet cần làm (Decorations, BackgroundDecoration, …). Mỗi sheet một vùng riêng trên page hoặc mỗi sheet một **Page** (`+` cạnh tên page).

---

## 4. Crop từng sprite từ sheet

Có **hai cách**. Dùng **Cách A** nếu mới bắt đầu.

### Cách A — Duplicate + Crop (khuyên dùng)

1. Chọn layer sheet gốc (đã lock thì **`Cmd` + `Shift` + `L`** unlock tạm).
2. **`Cmd` + `D`** duplicate.
3. Kéo bản duplicate sang vùng trống (tránh đè sheet gốc).
4. Chọn bản duplicate → double-click vào ảnh **hoặc** nhấn **`Enter`** để vào chế độ crop (Crop mode).
5. Kéo handle crop bao **trọn một sprite** (sát viền xanh rêu, **không** lấy nền đen thừa).
6. **`Enter`** xác nhận crop.
7. **`Cmd` + `R`** → đặt tên: `sprite_large_oval` (tên có nghĩa).
8. Lặp bước 2–7 cho **từng** sprite trên sheet.

**Mẹo zoom:** `Cmd` + cuộn chuột hoặc `Cmd` + `+` để zoom 200–400% khi crop mép.

### Cách B — Mask bằng Rectangle

1. **`R`** → vẽ rectangle bao sprite.
2. Đưa rectangle **dưới** ảnh trong layer panel (ảnh trên, rect dưới).
3. Chọn cả hai → chuột phải → **Use as mask** (hoặc `Cmd` + `Alt` + `M` tùy bản Figma).
4. **`Cmd` + `G`** group → đặt tên sprite.

---

## 5. Tạo frame atlas (lưới)

Ví dụ **7 sprite** → lưới **4 cột × 2 hàng**, cell **1024**.

1. **`F`** (Frame tool).
2. Kéo frame trên canvas (chưa cần đúng size).
3. Panel phải **Design**:
   - **W:** `4096`
   - **H:** `2048`
4. **Fill:** không màu / transparent (bỏ fill nếu có).
5. **`Cmd` + `R`** → tên frame: `EXPORT — MossyHills-tileset`.

### Bật layout grid 1024

1. Chọn frame `EXPORT — MossyHills-tileset`.
2. Panel phải → **Layout grid** → **`+`**.
3. Chọn kiểu **Grid** (không phải Columns):
   - **Size:** `1024`
   - **Color:** xám, opacity ~10% (chỉ để căn).
4. Bật **Snap to layout grid** (icon nam châm trên toolbar hoặc trong menu khi kéo object).

**Decorations (29 sprite):** frame **4096 × 8192** (4×8×1024).

---

## 6. Xếp sprite vào từng ô

1. Kéo sprite `sprite_large_oval` **vào trong** frame export (thả khi viền frame highlight).
2. Căn giữa ô (0,0) — cột 0, hàng 0:
   - Chọn sprite.
   - Giữ **`Alt`** → kéo; Figma hiện khoảng cách tới mép frame (căn thủ công).
   - Hoặc chọn sprite + **`Shift` + `2`** zoom vào, chỉnh bằng mũi tên **`↑` `↓` `←` `→`** (nudge 1px; **`Shift` + mũi tên** = 10px).
3. Sprite quá lớn:
   - Chọn sprite → kéo góc **giữ `Shift`** (giữ tỉ lệ).
   - Hoặc **`K`** (Scale) → kéo.
   - Thu nhỏ đến khi còn ~40px trống mỗi mép trong ô 1024.
4. Đặt sprite tiếp theo vào ô (1,0), (2,0), … theo bảng id:

```
(0,0)=0  (1,0)=1  (2,0)=2  (3,0)=3
(0,1)=4  (1,1)=5  (2,1)=6  (3,1)=7
```

5. Ghi chú: tạo **Text** (`T`) bên cạnh frame liệt kê `id → tên` (không export text — để ngoài frame hoặc layer ẩn).

### Căn nhiều sprite cùng lúc

1. **`Shift` + click** chọn nhiều sprite trong cùng hàng.
2. Toolbar trên → **Align horizontal centers** / **Distribute horizontal spacing** (nếu cần).

---

## 7. Kiểm tra trước khi export

Checklist (zoom `Cmd` + `0` rồi `Shift` + `2` từng ô):

- [ ] Mỗi sprite nằm **trong** frame export, không tràn ra ngoài frame.
- [ ] Không có fill trắng/đen trên frame.
- [ ] Sheet gốc (`SOURCE — …`) **không** nằm trong frame export (hoặc **ẩn** layer: `Cmd` + `Shift` + `H`).
- [ ] Kích thước frame đúng công thức `cols × cell`, `rows × cell`.
- [ ] Ô trống cuối lưới (nếu sprite lẻ) — **bình thường**, Tiled vẫn đọc được.

---

## 8. Export PNG

1. Chọn **frame** `EXPORT — MossyHills-tileset` (click viền frame, không chọn sprite lẻ).
2. Panel phải → cuộn xuống **Export**.
3. **`+`** thêm preset:
   - Format: **PNG**
   - Scale: **1x** (quan trọng — không dùng 0.5x).
4. **`Export MossyHills-tileset`** (hoặc **Export** nếu đã đặt tên file).
5. Lưu vào:  
   `WizardLabyrinth/assets/maps/mossy-tileset/MossyHills-tileset.png`

**Xác minh:** mở PNG bằng Preview — nền caro (trong suốt). Kích thước file = đúng W×H frame (ví dụ 4096×2048).

### Export lại sau khi sửa

1. Sửa sprite trong frame `.fig`.
2. Chọn frame → **Export** lại (cùng preset 1x PNG).
3. Ghi đè file cũ trong `mossy-tileset/`.
4. Tiled: **Save** map → Flutter **hot restart**.

---

## 9. Tạo `.tsx` trong Tiled

1. Mở Tiled → `zone1_slice.tmx` (xem [`MAC.md`](./MAC.md)).
2. **Map → New Tileset…** (hoặc tilesets panel → trang +).
3. **Name:** `mossy_hills`
4. **Type:** Based on Tileset Image
5. **Image:** chọn `MossyHills-tileset.png` vừa export
6. **Tile width / height:** `1024` / `1024` (khớp Figma)
7. **Embed in map:** **tắt**
8. **Save As:** `assets/maps/tilesets/mossy_hills.tsx`
9. **Map → Add External Tileset…** → chọn `.tsx` nếu chưa có trên map.

**Path ảnh trong `.tsx` phải relative:**

```xml
<image source="../mossy-tileset/MossyHills-tileset.png" width="4096" height="2048"/>
```

Nếu Tiled ghi path tuyệt đối `/Users/...` → mở Tileset Properties → chọn lại ảnh từ thư mục project.

---

## 10. Vẽ lên map

| Layer | Tileset gợi ý | Ghi chú |
|-------|----------------|---------|
| `bg_far` | `mossy_hills`, `mossy_bg_deco` | Đồi xa, khối lớn |
| `bg_near` | `mossy_decorations_hazards`, hanging, … | Cột, cây, đá |
| `ground` | `mossy_ground` (512) | Sàn — **không** thay bằng hills |

Trong Tiled: chọn layer → Stamp Brush **`B`** → stamp.  
**Lưu:** `Cmd` + `S`.

> **Lưu ý game:** Hiện code có thể chưa đọc `bg_far` / `bg_near` từ Tiled (nền parallax vẫn do `wl_far_view.dart`). Vẽ trong Tiled vẫn đúng quy trình; in-game hiện layout khi loader được gắn.

---

## 11. Gợi ý kích thước frame theo sheet

| Sheet gốc | Sprite ~ước lượng | Frame (4 cột × cell 1024) |
|-----------|-------------------|-----------------------------|
| `Mossy - MossyHills.png` | 7 | 4096 × 2048 |
| `Mossy - Decorations&Hazards.png` | ~29 | 4096 × 8192 |
| `Mossy - BackgroundDecoration.png` | ~6 | 4096 × 2048 |
| `Mossy - Hanging Plants.png` | ~10–15 | 4096 × 4096 (4×4) |
| `Mossy - FloatingPlatforms.png` | ~8–12 | 4096 × 3072 (4×3) — hoặc layer `platforms` |

Đếm sprite thực tế trên Figma rồi chỉnh: `rows = ceil(số_sprite / 4)`.

---

## 12. Lỗi thường gặp

| Triệu chứng | Nguyên nhân | Cách xử |
|-------------|-------------|---------|
| Tiled cắt lệch / cắt xuyên sprite | Tile size ≠ lưới Figma | Tile 1024 nếu grid 1024 |
| Viền tile “dính” tile kế bên | Không padding | Thu nhỏ sprite trong ô |
| Game nền đen thay vì trong suốt | Export có nền / flatten đen | Bỏ fill frame; crop bỏ nền đen sheet |
| PNG mờ | Export 0.5x hoặc scale frame | Export **1x**; W×H đúng pixel |
| `.tsx` không load ảnh | Path tuyệt đối | Chọn lại ảnh relative trong Tiled |
| Sửa Figma không thấy trong game | Chưa export / chưa restart | Export đè PNG → hot **restart** Flutter |

---

## 13. Cấu trúc file Figma gợi ý

```
📄 Wizard — Mossy tilesets
├── Page: Hills
│   ├── SOURCE — MossyHills (locked)
│   ├── sprites… (crop riêng)
│   └── EXPORT — MossyHills-tileset (4096×2048)
├── Page: Decorations
│   ├── SOURCE — Decorations&Hazards (locked)
│   └── EXPORT — MossyDecorationsHazards-tileset
└── Page: Notes
    └── Bảng tile id → tên → layer dùng
```

Giữ file `.fig` trong repo hoặc Drive team — lần sau chỉ export lại PNG, không làm lại từ đầu.

---

## 14. Quy trình một dòng

```
Sheet gốc → Place (`Cmd+Shift+K`) → Crop từng sprite (`Cmd+D`, Enter crop)
→ Frame (`F`) + grid 1024 → xếp & căn giữa → Export PNG 1x
→ Tiled New Tileset 1024 → Save .tsx → Add External → vẽ bg_far/bg_near
```

---

*Đồng bộ với [`ASSET_CATALOG.md`](../maps-game/ASSET_CATALOG.md) và [`TILED.md`](../maps-game/TILED.md).*
