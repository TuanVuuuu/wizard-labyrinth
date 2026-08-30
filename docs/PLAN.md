# Wizard: Mê Lộ — Kế hoạch dự án

> Game platformer / metroidvania hang động dùng **Flutter + Flame** (SDK qua **FVM 3.44.8**).  
> Application ID / Bundle Identifier: `com.vunt.wizard`

---

## 1. Tổng quan sản phẩm

| Mục | Chi tiết |
|-----|----------|
| **Tên app** | Wizard: Mê Lộ |
| **Package** | `com.vunt.wizard` |
| **Engine** | Flutter + Flame (+ flame_tiled, flame_audio); CLI qua **FVM**, SDK **3.44.8** |
| **Thể loại** | 2D side-view platformer, time-loop cavern, rage-trap |
| **Nền tảng mục tiêu** | Android, iOS, **Web** (cùng codebase); desktop tùy chọn sau |
| **Phong cách** | Pixel art hang động tối, pháp thuật, u tối dần theo độ sâu |

### Pitch ngắn

Pháp sư trẻ bị kẹt trong **Vòng lặp không gian** (Time-loop Cavern) vì cổ vật ma thuật vỡ. Mỗi lần “chết” không phải kết thúc — nhân vật bị kéo ngược về **tượng lưu** gần nhất. Người chơi khám phá hang, đọc bia đá / hồn ma, và học kỹ năng để phá vòng lặp — trong khi map đầy cạm bẫy “ức chế” cố tình gây cay cú.

---

## 2. Cốt truyện & Lore

### 2.1 Tiền đề

- Nhân vật: pháp sư trẻ (tên tạm: **Ashen** — có thể đổi sau).
- Bị mắc kẹt trong hang động bị nguyền rủa do **cổ vật thời gian** vỡ.
- Hang không muốn kẻ xâm nhập sống sót; vòng lặp là cả nhà tù lẫn vũ khí.

### 2.2 Cơ chế dẫn truyện (không cutscene dài)

| Hình thức | Vai trò |
|-----------|---------|
| **Bia đá cổ** | Mảnh ký ức cố định; unlock lore khi tương tác |
| **Hồn ma bản thân** | Echo từ lần chết trước — tip cơ học hoặc lời thì thầm u ám |
| **Hồn ma pháp sư đi trước** | Thế giới sống; gợi ý bí mật phá vòng lặp |
| **Tượng Save Point** | Mốc thời gian + cảm giác “được sống sót tạm thời” |

### 2.3 Arc lore theo độ sâu

| Tầng / Zone | Tone | Nội dung hé lộ |
|-------------|------|----------------|
| **Zone 1 — Mouth of Echo** | Kỳ bí, hơi hy vọng | Hang bị nguyền vì cổ vật; thầy gửi học trò “thử thách” |
| **Zone 2 — Spire of Thorns** | Căng thẳng, phản bội ló dạng | Thầy cố ý đẩy học trò vào vòng lặp để “thanh tẩy” |
| **Zone 3 — Gravity Vein** | U tối, gió và trọng lực loạn | Hang “ăn” nỗi sợ và thời gian của nạn nhân |
| **Zone 4 — Heart of Loop** | Bi kịch / lựa chọn | Bí mật phá vòng lặp; kết thúc A/B (phá / chấp nhận / trả thù thầy) |

> Càng vào sâu, copy lore càng tối — không dump hết ở đầu game.

### 2.4 Mục tiêu narrative MVP

- [ ] 6–10 bia đá Zone 1–2
- [ ] 1 ending tạm (phá vòng lặp) + stub cho ending 2
- [ ] Hồn ma tip chết (1–2 dòng, có cooldown để không spam)

---

## 3. Gameplay & Rage Mechanics

### 3.1 Core loop

```
Chơi → Chết / Chạm gai → Rewind về Checkpoint → Học pattern → Tiến sâu hơn → Lore + skill → Boss / phá loop
```

### 3.2 Điều khiển cơ bản (MVP)

| Action | Gợi ý input | Ghi chú |
|--------|-------------|---------|
| Move | A/D hoặc joystick | Acceleration nhẹ, không sticky quá |
| Jump | Tap / Space | Coyote time + jump buffer (bắt buộc) |
| Dash | Double-tap / nút riêng | I-frame ngắn hoặc không — cân bằng rage |
| Interact | E / nút | Bia đá, tượng, cửa |
| Pause | Esc / nút | Menu, settings |

### 3.3 Cạm bẫy “Ức chế” (thiết kế bắt buộc)

#### A. Fake Safe Zones (Gai ẩn / bệ giả)

- Tile nhìn như sàn an toàn; sau N frame đứng hoặc khi land → rêu sạt / gai đâm từ dưới.
- Telegraphed nhẹ lần đầu (particle bụi) — lần sau có thể “câm” hơn ở zone sâu.
- **Data-driven**: flag trên Tiled (`trap:fake_floor`, `delay_ms`).

#### B. Pixel-Perfect / Last-Frame Dash

- Gap chỉ qua được nếu dash đúng timing cuối trước khi rơi.
- Không làm 100% frame-perfect trên mobile: dùng **generous hitbox dash** nhưng **visual gap hẹp** để vẫn cảm giác gắt.
- Tutorial zone dạy 1 lần rõ ràng trước khi spam.

#### C. Slime = bệ nhảy ảo

- Slime patrol ngang.
- Khi player land trên slime → bounce lên với vector phụ thuộc **góc / velocity**.
- Bounce lệch → đập trần gai.
- Config: `bounce_force`, `angle_tolerance`, `ceiling_spike_y`.

#### D. Wind / Gravity inversion

- Zone sâu: vùng gió đẩy ngược hướng di chuyển → jump/dash bị lệch đà.
- Gravity flip đoạn ngắn (đảo trần/sàn) — gắn visual rõ (particle + tint).
- Lưu ý: luôn có **telegraph** (cờ gió, runes) để fair-rage, không pure RNG.

#### E. Checkpoint xa xỉ

- Checkpoint thưa; chết gần cuối “đường đua” về đầu segment.
- **Mitigation chống churn**: optional “ghost path” xem lần chết trước; hoặc soft-checkpoint ẩn sau N lần chết liên tiếp cùng đoạn (accessibility toggle).

### 3.4 Nguyên tắc rage fair

1. Chết vì **skill / đọc map**, không vì hitbox ẩn không telegraph.
2. Mỗi trap mới được **dạy một lần** trước khi kết hợp.
3. Settings: giảm độ khó trap / thêm coyote / gần checkpoint hơn (mode “Scholar”).

---

## 4. Tiến trình & Systems

### 4.1 Player

- HP: 1 hit kill (pure rage) **hoặc** 2–3 HP + i-frame sau hit (dễ ship hơn) — **đề xuất MVP: 1 hit = rewind**.
- Skills unlock theo zone: Dash → Wall cling → Wind resist charm → Gravity anchor.
- Animation states: idle, run, jump, fall, dash, death/rewind, interact.

### 4.2 Checkpoint / Time Rewind

1. Player chạm `Hazard` hoặc rơi khỏi map.
2. Freeze ngắn + VFX rewind.
3. Teleport về `Checkpoint` gần nhất đã activate.
4. Reset transient traps trong segment (fake floor respawn, slime position).
5. Spawn optional “death echo” tại chỗ chết.

### 4.3 Save / Persist

- Local save: zone, checkpoint id, lore flags, settings, death count.
- Dùng `shared_preferences` hoặc `hive` / `isar`.
- Không cần account online cho MVP.

### 4.4 Audio

- BGM theo zone (càng sâu càng trống / dissonant).
- SFX: jump, dash, spike, rewind, stone tablet, slime bounce, wind.
- Package: `flame_audio` / `audioplayers`.

---

## 5. Công nghệ & Architecture

### 5.1 Stack

| Layer | Choice |
|-------|--------|
| UI shell | Flutter (menu, settings, pause overlay) |
| Game runtime | Flame `FlameGame` |
| Map | Tiled (`.tmx`) + `flame_tiled` |
| Physics | Flame collision (AABB) + custom platformer controller |
| State | Riverpod hoặc ChangeNotifier nhẹ — **đề xuất: Riverpod** |
| Assets | Pixel tileset + spines (đã có sẵn trong kế hoạch asset) |

### 5.2 Cấu trúc thư mục đề xuất

```
lib/
  main.dart
  app.dart                          # MaterialApp, routes
  core/
    constants.dart
    theme.dart
    audio_manager.dart
  game/
    wizard_game.dart                # FlameGame root
    world/
      cavern_world.dart
      camera_controller.dart
    player/
      player_component.dart
      player_controller.dart
      player_state.dart
    components/
      hazards/                      # spike, fake_floor, wind_zone, gravity_zone
      enemies/                      # slime
      interactables/                # tablet, checkpoint, door
      vfx/
    systems/
      rewind_system.dart
      lore_system.dart
      checkpoint_system.tsx
    levels/
      level_loader.dart
      level_data.dart
  ui/
    menus/
    hud/
    overlays/
  data/
    saves/
    lore/
assets/
  images/
  audio/
  tiles/
  maps/
```

### 5.3 Map pipeline

1. Design level trong **Tiled**.
2. Object layers: `player_spawn`, `checkpoints`, `hazards`, `lore_tablets`, `wind_zones`, `enemies`.
3. Custom properties → factory spawn component trong `level_loader.dart`.
4. Mỗi zone = 1–N file `.tmx` + room transitions.

---

## 6. Roadmap theo phase

### Phase 0 — Project bootstrap (0.5–1 tuần)

- [ ] `fvm use 3.44.8` rồi `fvm flutter create --org com.vunt --project-name wizard --platforms=android,ios,web`
- [ ] Đặt applicationId / bundleId: `com.vunt.wizard`
- [ ] Thêm deps: `flame`, `flame_tiled`, `flame_audio`, state mgmt
- [ ] Folder structure + CI analyze cơ bản
- [ ] Splash / title screen placeholder “Wizard: Mê Lộ”

### Phase 1 — Vertical Slice (2–3 tuần) — **ưu tiên cao nhất**

Mục tiêu: **1 màn chơi được từ đầu đến checkpoint, chết rewind, có 2 loại trap**.

- [ ] Player move / jump / coyote / buffer
- [ ] Tile collision từ Tiled
- [ ] Spike hazard + death rewind
- [ ] Checkpoint activate + respawn
- [ ] Fake safe floor (1 biến thể)
- [ ] 1 bia đá lore + overlay text
- [ ] HUD tối giản (death count, zone name)
- [ ] Pause menu

**Definition of Done:** người chơi ngoài team chơi được 3–5 phút và hiểu “chết = rewind về tượng”.

### Phase 2 — Rage kit đầy đủ (2–3 tuần)

- [ ] Dash + last-gap challenge room
- [ ] Slime bounce + ceiling spikes
- [ ] Wind zone
- [ ] Gravity inversion segment ngắn
- [ ] Checkpoint spacing “xa xỉ” trên 1 speedrun corridor
- [ ] Death echo / ghost tip
- [ ] Settings: Scholar mode (dễ hơn)

### Phase 3 — Content Zone 1–2 (3–4 tuần)

- [ ] Zone 1 full layout + polish
- [ ] Zone 2 thorns / betrayal lore
- [ ] Skill unlocks (dash nếu chưa có từ đầu; wall cling)
- [ ] BGM/SFX pass
- [ ] Save/load ổn định
- [ ] Tutorial prompts không phá immersion

### Phase 4 — Deep cavern + climax (3–4 tuần)

- [ ] Zone 3 wind/gravity identity
- [ ] Zone 4 Heart of Loop
- [ ] Mini-boss hoặc puzzle phá cổ vật
- [ ] Ending A (+ stub B)
- [ ] Juice: screen shake, rewind VFX, particles

### Phase 5 — Ship (2 tuần)

- [ ] Performance (60fps mid-range Android + Chrome web)
- [ ] Localization VI (primary) + EN stub
- [ ] Store assets, privacy, age rating; bản web `fvm flutter build web`
- [ ] Soft launch / playtest nội bộ
- [ ] Fix crash, input bugs, soft-lock

---

## 7. Level Design guidelines

### 7.1 Pacing một “segment”

1. Safe teach (trap mới, không phạt nặng)
2. Combine 2 mechanics
3. Long run không checkpoint (rage peak)
4. Lore beat / breath room
5. Checkpoint tượng

### 7.2 Tiled naming convention

| Layer / Object | Ý nghĩa |
|----------------|---------|
| `ground` | Collision tiles |
| `deco` | Không collision |
| `spikes` | Hazard |
| `obj_checkpoints` | Save statues |
| `obj_tablets` | Lore |
| `obj_hazards` | Fake floors, wind AABB, gravity AABB |
| `obj_enemies` | Slime spawns |

### 7.3 Difficulty knobs (data)

Mỗi trap object nên có properties chỉnh được không cần code:

- `telegraph` (bool)
- `delay_ms`
- `force`
- `active_once` / `respawn_on_rewind`

---

## 8. UI / UX

| Màn | Nội dung |
|-----|----------|
| Title | Logo “Wizard: Mê Lộ”, New / Continue / Settings |
| HUD in-game | Tối giản; hiện death count tùy chọn |
| Lore overlay | Panel đá cổ, text VI, typewriter nhẹ |
| Death/Rewind | Full-screen ngắn, không menu dài |
| Pause | Resume, Settings, Return to title |
| Settings | Audio, controls, Scholar mode, language |

Tonality UI: tối, đá / rune, tránh dashboard dày — một composition rõ mỗi màn menu.

---

## 9. Asset plan

### Có sẵn / ưu tiên dùng

- Tileset hang động
- Spikes / spines
- (Dự kiến) slime, wizard sprites — bổ sung nếu thiếu

### Cần bổ sung theo phase

| Phase | Asset |
|-------|-------|
| 1 | Player idle/run/jump, spike, checkpoint statue, 1 tablet |
| 2 | Dash VFX, slime, wind particles, gravity rune |
| 3–4 | Zone tiles variants, boss/cổ vật, ending art |
| All | SFX + BGM loops theo zone |

### Tech art rules

- Tile size thống nhất (đề xuất **16×16** hoặc **32×32** — chốt 1 và không đổi).
- Player collision box hẹp hơn sprite (fair platforming).
- Spike hitbox hơi nhỏ hơn visual (feel tốt hơn pixel-perfect ức chế).

---

## 10. Metrics & Playtest

Theo dõi nội bộ (không cần analytics nặng lúc đầu):

- Death count / segment
- Time to clear segment
- Quit rate sau death streak ≥ 5
- Lore tablet read rate

Playtest câu hỏi:

1. Có hiểu rewind không?
2. Trap nào “bẩn” (không đọc được)?
3. Checkpoint có quá xa đến mức bỏ game?

---

## 11. Rủi ro & giảm thiểu

| Rủi ro | Giảm thiểu |
|--------|------------|
| Rage → churn | Scholar mode, soft checkpoint sau N death |
| Mobile control kém | Virtual pad lớn + dash button riêng; coyote/buffer |
| Scope phình | Bám Vertical Slice Phase 1 trước khi làm Zone 3–4 |
| Physics inconsist | Fixed timestep, không mix nhiều physics engine |
| Lore bị bỏ qua | Bia đá gần đường đi chính, không bắt sidepath xa |

---

## 12. Definition of MVP (shippable demo)

Game gọi là **MVP** khi:

1. Chạy được trên Android (`com.vunt.wizard`) **và** Web (`fvm flutter run -d chrome` / `build/web`).
2. Chơi được ≥ 1 zone hoàn chỉnh với rewind + checkpoint.
3. Có đủ 3 trap: spike thường, fake floor, slime bounce **hoặc** dash gap.
4. ≥ 4 bia đá lore mạch tiền đề + phản bội hé lộ.
5. Save/continue hoạt động.
6. Không crash trên flow chính.

---

## 13. Việc làm ngay (Next actions)

1. Bootstrap bằng FVM (SDK 3.44.8): `fvm flutter create` (`com.vunt.wizard`, platforms android + ios + web).
2. Import tileset + tạo map Tiled “Zone1_Slice”.
3. Implement player controller + tile collision.
4. Implement spike → rewind → checkpoint.
5. Thêm fake floor + 1 tablet lore.
6. Playtest nội bộ và chỉnh feel jump/dash trước khi mở rộng map.

---

## 14. Glossaries nhanh

| Thuật ngữ | Nghĩa trong game |
|-----------|------------------|
| Time-loop Cavern | Hang vòng lặp không gian/thời gian |
| Save Statue | Checkpoint vật lý trong world |
| Rewind | Respawn về tượng, không “game over” truyền thống |
| Fake Safe Zone | Bệ giả / gai ẩn |
| Scholar mode | Mode giảm ức chế cho accessibility |
| Death Echo | Hồn ma / dấu vết lần chết |

---

*Tài liệu sống — cập nhật khi chốt tile size, HP model, và tên nhân vật chính thức.*
