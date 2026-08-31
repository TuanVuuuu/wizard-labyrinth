# Catalog asset — `mossy-tileset`

Mọi file nằm tại `assets/maps/mossy-tileset/`. PNG là **RGBA** (vùng đen = trống / alpha). Không đổi tên file nguồn — `.tsx` trỏ relative tới các tên này.

Hai kiểu sheet:

| Kiểu | File | Cách đưa vào Tiled |
|------|------|-------------------|
| **Lưới đều** | `Mossy - TileSet.png` | Tileset “Based on Tileset Image”, tile **512×512** |
| **Stamp / không lưới** | 5 file còn lại | Collection of Images (cắt sprite) **hoặc** object layer + property sprite |

Không import 5 sheet stamp như tileset 512 — sprite lệch ô, Tiled sẽ cắt xuyên art.

---

## 1. `Mossy - TileSet.png` — địa hình chính

| | |
|--|--|
| Kích thước | **3584 × 3584** |
| Lưới | **7 × 7** ô, mỗi ô **512 × 512** (49 tile) |
| Layer Tiled | `ground` (bắt buộc), có thể stamp thêm lên `platforms` |
| Collision | **Có** — Tile Collision Editor, không dùng full 512 nếu rêu thò ra ngoài đá |

**Nội dung (theo nhóm trên sheet):**

- Khối pre-assembled: platform vuông, cột đứng, thanh ngang, khối nhỏ, khối “cửa sổ” rêu — stamp nhiều ô một lúc (Stamp Brush).
- Mảnh autotile: cạnh trên (rêu mọc lên), cạnh dưới (đá/rễ treo), cạnh trái/phải, góc lồi, góc lõm (chữ L hang).
- Vòng / cụm tròn nhỏ: bệ nhỏ hoặc deco; collision riêng nếu dùng làm sàn.

**Cách vẽ:** ưu tiên Stamp Brush cho khối có sẵn; dùng từng tile cạnh/góc khi cần hang chữ L, hốc, trần. Sheet này **không phải** bộ blob-autotile 47-tile đủ — đừng kỳ vọng Terrain bucket tô một phát ra hang kín.

**Collision:** hộp rắn **lùi vào trong** so với lưỡi rêu (~15–25% mép trên). Player đứng trên đá, không “lơ” trên ngọn rêu. Tâm đen của khối rỗng = không khí hang (nhìn xuyên xuống nền tối), không phải lỗ xuyên map — vẽ kín hành lang bằng tile đặc hoặc nền màu.

---

## 2. `Mossy - FloatingPlatforms.png` — platform nổi

| | |
|--|--|
| Kích thước | **2048 × 2048** |
| Lưới | Không (platform dài ngắn khác nhau) |
| Layer Tiled | Tile `platforms` **hoặc** object class `platform` |
| Collision | **Có** — AABB theo object / hitbox đá, không theo ngọn rêu |

**Nội dung:** thanh ngang nhiều độ dài (bo tròn hai đầu), cột đứng hẹp, cụm rêu nhỏ, mảnh chữ U (cap đầu thanh).

**Dùng cho:** gap nhảy, fake floor (trùng object `fake_floor`), hành lang “cay cú”, bệ dash.

**Cách đưa vào Tiled (chọn một):**

1. **Object (MVP nhanh):** rectangle trên `obj_hazards` hoặc layer `platforms` dạng object, class `platform`; art gán sau bằng property `sprite` hoặc vẽ tạm bằng tile `ground`.
2. **Collection of Images:** cắt từng platform ra PNG trong `assets/maps/mossy-tileset/slices/platforms/`, thêm vào `mossy_platforms.tsx`.

Không set tileset 512 trên file này: 2048 chia hết 512 nhưng sprite **không** căn ô.

---

## 3. `Mossy - Decorations&Hazards.png` — gai + deco

| | |
|--|--|
| Kích thước | **4096 × 4096** |
| Lưới | Không |
| Layer Tiled | Visual: `deco` / `fg`. Hitbox: `obj_spikes` |
| Collision | Gai = object `spike` (hẹp hơn art). Đá/cây = không, trừ khi cố ý làm tường |

**Nhóm sprite:**

| Nhóm | Vai trò gameplay |
|------|------------------|
| Đá rêu (3 khối lớn) | Deco / che spawn; không bắt buộc collide |
| **Gai / dây gai neon** (ngang, cung, cụm) | Hazard chính — rage |
| Cây nhỏ, dương xỉ, mầm phát sáng | Telegraph, breath room |
| Dây/rễ đứng (4 biến thể) | Cột nền `bg_near` hoặc `fg` |

**Gai:** luôn đặt **object rectangle** trên `obj_spikes`, class `spike`. Hitbox **hẹp hơn** cụm gai ~15–25%, căn giữa. Không collide cả tile art — player chết oan vì pixel rêu.

Property: `side` = `floor` / `ceiling` / `wall`; `lethal` = `true`.

---

## 4. `Mossy - BackgroundDecoration.png` — khối rêu nền

| | |
|--|--|
| Kích thước | **4096 × 4096** |
| Lưới | Không (6 khối organic) |
| Layer Tiled | `bg_far` hoặc `bg_near` |
| Collision | **Không** |

Khối rêu viền, ruột tối — tạo chiều sâu hang (cột, gò, đám mây rêu). Parallax chậm hơn `ground`. Không dùng làm sàn: mép lông, hitbox xấu.

---

## 5. `Mossy - MossyHills.png` — đồi xa

| | |
|--|--|
| Kích thước | **2048 × 2048** |
| Lưới | Không |
| Layer Tiled | `bg_far` (hoặc Image layer Tiled) |
| Collision | **Không** |

Khung oval rêu, dải đồi lượn, khung chữ nhật, cụm nhỏ, vòm. Layer xa nhất; Flame có thể chuyển sang `ParallaxComponent` (scroll chậm) thay vì vẽ như tilemap.

---

## 6. `Mossy - Hanging Plants.png` — cây treo

| | |
|--|--|
| Kích thước | **2048 × 2948** (không chia hết 512) |
| Lưới | Không — **cấm** tileset 512 |
| Layer Tiled | `deco` (sau player) hoặc `fg` (che player) / `bg_near` |
| Collision | **Không** |

**Nhóm:** 5 cụm dương xỉ treo (dài → ngắn), 2 dải rêu/vines dày, 3 lá đơn trên thân cong.

Gắn dưới trần `ground` / mép platform. Telegraph đoạn trần gai (cây trước, gai sau).

---

## 7. Gán file → layer (tóm tắt)

| PNG | Layer / object | Collide? |
|-----|----------------|----------|
| `Mossy - TileSet.png` | `ground` | Có |
| `Mossy - FloatingPlatforms.png` | `platforms` / object `platform` | Có |
| `Mossy - Decorations&Hazards.png` (gai) | `obj_spikes` + visual `deco` | Object spike |
| `Mossy - Decorations&Hazards.png` (đá, cây) | `deco` / `bg_near` | Không |
| `Mossy - BackgroundDecoration.png` | `bg_far` / `bg_near` | Không |
| `Mossy - MossyHills.png` | `bg_far` | Không |
| `Mossy - Hanging Plants.png` | `deco` / `fg` | Không |

---

## 8. Scale & performance

Art gốc lớn (tile 512, sheet 2k–4k). Runtime: zoom Flame ~12–16 tile ngang (~64–96px/tile trên mobile), **không** cần resize PNG lúc vẽ map.

| Rủi ro | Cách tránh |
|--------|------------|
| Tiled nặng | Tạm ẩn layer `bg_*` / `deco` khi vẽ `ground` |
| Giật in-game | Ít deco animated on-screen; cull ngoài camera |
| Web load chậm | Giữ 1 map slice; đừng nhét 4 sheet 4096 lên cùng một màn dày |

Downsample chỉ khi Tiled không dùng nổi — và **đồng bộ mọi** tileset trên map đó.
