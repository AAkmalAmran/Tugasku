# DESIGN.md — Tugasku (Mobile App Design)

| Info                 | Detail                                                      |
| :------------------- | :---------------------------------------------------------- |
| **Project**          | Project 6 — Tugasku: Class Schedule and Assignment Reminder |
| **Group**            | Group 03 — BBK4DBB3 Mobile Application Development          |
| **Platform**         | Android, Flutter Material 3 (Light & Dark)                  |
| **Related document** | `PRD.md`                                                    |
| **Author**           | Member 1 (Project Lead)                                     |
| **Deadline**         | Thursday, 12 November 2026, 23:59 WIB                       |

This document is the **shared visual and behavioral reference** for all five members. Every module (`form_tambah`, `tugas`, `detail`, `jadwal`, `profil`) must follow the tokens, components, and patterns here so the UI stays consistent even though five people build it.

> **Language note:** The app's user-facing text stays in **Indonesian** (the PRD mandates tab names such as _Hari Ini_, _Tugas_, _Jadwal_, _Profil_). Indonesian UI strings appear in quotes below, with English glosses where helpful. Code identifiers follow the PRD (`judul`, `mataKuliah`, `tenggat`, etc.).

---

## 1. Design Principles

1. **Calm first, urgent second.** A soft cream background and generous whitespace; red appears _only_ for things that need attention (deadline under 24 hours, High priority, the primary action).
2. **One screen, one purpose.** Today = what to do now. Tasks = everything. Schedule = classes by day. Profile = summary.
3. **Color is never the only signal.** Priority and deadlines always come with text or an icon.
4. **All colors come from `colorScheme`.** No hex values outside `tema.dart` (rubric P06).
5. **Four mandatory states** on every data-driven screen: loading, error (+ _Coba lagi_ / Retry), empty, success.

---

## 2. Lightweight UX Research

With limited time, research is kept lightweight but still drives design decisions.

### 2.1 Problem Statement

> **Identify** how **university students** can see their most urgent task and today's classes **in under 10 seconds** after opening the app.

### 2.2 Concise Persona

|                  |                                                                                                        |
| :--------------- | :----------------------------------------------------------------------------------------------------- |
| **Name**         | Rani, 3rd-semester student                                                                             |
| **Context**      | 6–8 courses; assignments arrive from many lecturers and channels (LMS, WhatsApp groups)                |
| **Goals**        | Never miss a task; know when and where the next class is                                               |
| **Frustrations** | Deadlines buried in chats; realizes only when it is almost due; must open another app for the schedule |
| **Behavior**     | Opens the app briefly between classes, often one-handed                                                |

**Design implications:** the list must be scannable, primary actions must be within thumb reach (bottom navigation, FAB or bottom buttons), and urgency markers must be very clear.

### 2.3 Jobs to Be Done

- When **I get a new assignment**, I want to **record it in under 30 seconds** so I do not forget.
- When **I open the app in the morning**, I want to **see what is urgent today** so I can decide my priorities.
- When **I finish a task**, I want to **mark it with one tap** so the list stays relevant.
- When **I am walking to campus**, I want to **see the next class time and room** without searching.

### 2.4 Usability Test Plan (Guerrilla, 3–5 classmates)

Run once the debug APK is available (target 10–11 Nov). The facilitator must **not** be the member who built the feature being tested.

|  #  | Task scenario                                           | Success if                                                      | Metrics                 |
| :-: | :------------------------------------------------------ | :-------------------------------------------------------------- | :---------------------- |
|  1  | "Find the task with the nearest deadline."              | Points to the card with the < 24 h badge / top card in Hari Ini | Time, pass/fail         |
|  2  | "Mark one task as done."                                | Checkbox ticked and title struck through                        | Time, mis-taps          |
|  3  | "Add a Database task due Friday, high priority."        | Task saved and visible in the list                              | Time, validation errors |
|  4  | "What class do you have on Tuesday, and in which room?" | States the correct course and room                              | Time                    |
|  5  | "(Server is off) What happened? Try to reload."         | Taps _Coba lagi_ without help                                   | Pass/fail               |

After each session, collect a **SEQ** score (1–7) per task. Log findings by severity — **Critical / High / Moderate / Low** — and fix Critical and High issues before recording the demo video.

---

## 3. Visual Foundations (Perceptual Patterns)

### 3.1 Brand Color Palette

Source: Color Hunt `e62727-f3f2ec-dcdcdc-1e93ab`.

| Global token  | Hex       | Main role                                                             |
| :------------ | :-------- | :-------------------------------------------------------------------- |
| `brand-red`   | `#E62727` | **Seed** for `ColorScheme.fromSeed` → primary (main actions, urgency) |
| `brand-cream` | `#F3F2EC` | Screen background (surface) in light mode                             |
| `brand-gray`  | `#DCDCDC` | Dividers, outlines, inactive chips, skeletons                         |
| `brand-teal`  | `#1E93AB` | Secondary accent: information, completed status, schedule             |

> **Important:** `fromSeed` does not use the hex as `primary` verbatim; it derives a _tonal palette_ from the seed. The result still reads as red and passes contrast checks. That is why the app must **never** use raw hex in components — always `Theme.of(context).colorScheme.*`.

### 3.2 Token Architecture (3 tiers)

| Tier      | Token                       | Value / Reference                                       |
| :-------- | :-------------------------- | :------------------------------------------------------ |
| Global    | `brand-red/cream/gray/teal` | Hex above (exists only in `tema.dart`)                  |
| Semantic  | `action-primary`            | → `colorScheme.primary`                                 |
|           | `on-action-primary`         | → `colorScheme.onPrimary`                               |
|           | `screen-background`         | → `colorScheme.surface` (cream in light mode)           |
|           | `card`                      | → `colorScheme.surfaceContainerLowest`                  |
|           | `line`                      | → `colorScheme.outlineVariant` (gray in light mode)     |
|           | `info` / `done`             | → `colorScheme.secondary` / `secondaryContainer` (teal) |
|           | `urgent`                    | → `colorScheme.primary` + `onPrimary`                   |
|           | `system-error`              | → `colorScheme.error` / `errorContainer`                |
| Component | `task-card-bg`              | → `card`                                                |
|           | `deadline-badge-bg`         | → `urgent`                                              |
|           | `chip-priority-high`        | → `primaryContainer` / `onPrimaryContainer`             |
|           | `chip-priority-medium`      | → `secondaryContainer` / `onSecondaryContainer`         |
|           | `chip-priority-low`         | → `surfaceContainerHighest` / `onSurfaceVariant`        |

### 3.3 Color Role Mapping (Light Mode)

| UI element                                       | Color from                                                |
| :----------------------------------------------- | :-------------------------------------------------------- |
| Scaffold background                              | `surface` (cream)                                         |
| Task card                                        | `surfaceContainerLowest` + `outlineVariant` border (gray) |
| `FilledButton` Save, FAB, selected nav indicator | `primary` / `onPrimary` (red)                             |
| `OutlinedButton` Cancel                          | `outline` border, `primary` text                          |
| "< 24 jam" badge                                 | `primary` / `onPrimary`                                   |
| Priority High / Medium / Low                     | red tint / teal tint / gray (see 3.2)                     |
| Checked checkbox                                 | `secondary` (teal)                                        |
| Completed task title (struck through)            | `onSurfaceVariant`                                        |
| Schedule: day header                             | `secondary` (teal)                                        |
| Divider, loading skeleton                        | `outlineVariant` (gray)                                   |
| Error state                                      | `errorContainer` + icon + _Coba lagi_ button              |

### 3.4 Dark Mode

Generated automatically by `ColorScheme.fromSeed(brightness: Brightness.dark)` from the same seed, so the red–teal identity is preserved. Rules:

- Do not hardcode dark colors; let `colorScheme` do the work.
- Test **every screen** in both modes before taking screenshots.
- Badges and chips must stay readable in dark mode (check manually).

### 3.5 Color Contrast & Accessibility (estimates — verify with a contrast checker)

| Pair                             |     Approx. ratio      | Decision                                                  |
| :------------------------------- | :--------------------: | :-------------------------------------------------------- |
| Dark text on cream               |        ≈ 15 : 1        | Safe for all text                                         |
| White on `#E62727`               | ≈ 4.5 : 1 (borderline) | Use `onPrimary` from the scheme; bold button text, ≥ 14sp |
| `#E62727` as small text on cream |       ≈ 4.0 : 1        | **Do not** use for small text                             |
| `#1E93AB` on cream/white         |     ≈ 3.2–3.6 : 1      | Icons / UI elements needing ≥ 3:1 only, not small text    |
| Dark text on `#1E93AB`           |       ≈ 4.8 : 1        | Safe                                                      |

Therefore **raw teal and red are not used as small-text colors**; use the `on*` and `*Container` variants from `colorScheme`.

### 3.6 Note on the Semantics of Red

Red serves three meanings: primary action, urgency, and (via `error`) failure. To avoid confusion:

- Urgency is **always** a badge with a clock icon + the text "< 24 jam".
- Errors are **always** an `errorContainer` card with a warning icon + message + button.
- Only **one** primary action per screen.

### 3.7 Typography

**Custom font: Plus Jakarta Sans** (via `google_fonts`; for offline demos, download it, place it in `assets/fonts/`, and register it in `pubspec.yaml`).

| M3 role         | Size / Weight | Used for                   |
| :-------------- | :------------ | :------------------------- |
| `headlineSmall` | 24 / 700      | Screen titles ("Hari Ini") |
| `titleMedium`   | 16 / 600      | Task titles, course names  |
| `bodyMedium`    | 14 / 400      | Notes, body text           |
| `labelLarge`    | 14 / 600      | Button text                |
| `labelSmall`    | 11 / 600      | Chips, badges              |

Rules: task titles max **2 lines** (`maxLines: 2`, `overflow: ellipsis`); notes on the card max 1 line.

### 3.8 Spacing, Shape, Elevation

- **4 dp spacing grid:** 4, 8, 12, 16, 24, 32. Horizontal screen margin **16 dp**.
- **Radius:** cards 16, buttons & fields 12, chips & badges 8 (not full pills).
- **Elevation:** cards at elevation 0 + `outlineVariant` border (flat, cleaner); `SnackBar` floats.
- **Minimum touch target 48×48 dp.**

### 3.9 Iconography & Motion

- Icons: Material **Rounded** `Icons.*`, size 24 (20 inside chips).
- Motion: default Material page transitions; ticking the checkbox animates the strikethrough with `AnimatedDefaultTextStyle` (150–200 ms). No decorative animation.

---

## 4. Component Specifications (Functional Patterns)

### 4.1 `KartuTugas` / Task Card (Member 2) — custom card must use `Row`, `Column`, `Expanded`, `Stack`

```text
┌──────────────────────────────────────┐
│ ☐  Laporan Praktikum Basis Data   [<24 jam]  ← Stack: badge in top-right corner
│    Basis Data                         │
│    [Tinggi]  📅 Kam, 12 Nov · 23.59   │
└──────────────────────────────────────┘
```

| Part (anatomy) | Widget                                            | Notes                                               |
| :------------- | :------------------------------------------------ | :-------------------------------------------------- |
| Wrapper        | `Card` → `InkWell`                                | Tap → `Navigator.push` to Detail                    |
| Layout         | `Stack` > `Row` > `Checkbox` + `Expanded(Column)` | Badge is `Positioned` inside the `Stack`            |
| Checkbox       | `Checkbox`                                        | `setState` → toggle `selesai`, show `SnackBar`      |
| Title          | `Text`                                            | `lineThrough` when `selesai`                        |
| Course         | `Text`                                            | `bodyMedium`, `onSurfaceVariant`                    |
| Priority chip  | small `Container` / `Chip`                        | Tint per 3.2 + **text label**                       |
| Deadline       | `Row(Icon + Text)`                                | Format "Kam, 12 Nov 2026 · 23.59"                   |
| < 24 h badge   | `Positioned` + `Container`                        | `primary`/`onPrimary`, `schedule` icon + "< 24 jam" |

**States:** default · done (title struck through, card slightly faded via `onSurface` at ~0.6 opacity) · urgent (badge) · pressed (ripple).
**Accessibility:** wrap with `Semantics(label: 'Task {title}, due {date}, priority {p}, {status}')`.

### 4.2 `PriorityChip` (read-only) & `FilterChip` (interactive)

- Read-only: label "Rendah / Sedang / Tinggi" (Low / Medium / High), colors per 3.2.
- Filter on the Tugas screen: `FilterChip` — **Semua · Belum selesai · Selesai · Tinggi** (All · Not done · Done · High). Single row, horizontally scrollable (`SingleChildScrollView`). The selected chip uses `secondaryContainer`.

### 4.3 Buttons (≥ 2 M3 types)

| Button               | Used for                           | Rule                       |
| :------------------- | :--------------------------------- | :------------------------- |
| `FilledButton`       | Save, primary action               | Max 1 per screen           |
| `OutlinedButton`     | Cancel                             | Sits beside Save           |
| `FilledButton.tonal` | Mark as done (Detail), _Coba lagi_ | Important secondary action |
| `IconButton`         | Back, edit                         | 48×48 area                 |

### 4.4 `TextField` & Form (Member 1)

- `OutlineInputBorder`, radius 12, floating label, `helperText` when needed.
- Every `TextEditingController` **must be `dispose()`d** in `State.dispose()` (rubric P03).
- Inline errors beneath the field, not only a `SnackBar`.
- Deadline field: `readOnly` + calendar icon; tap → `showDatePicker`.

### 4.5 Priority `SegmentedButton`

Three segments: **Rendah · Sedang · Tinggi**, default **Sedang**, `showSelectedIcon: true` (a check icon so it does not rely on color alone).

### 4.6 `SnackBar`

`behavior: floating`, 3-second duration. Short Indonesian copy:

- "Tugas ditambahkan" (Task added)
- "Ditandai selesai" / "Ditandai belum selesai" (+ **Urungkan** / Undo action where feasible)
- "Gagal menyimpan. Coba lagi." (Failed to save. Try again.)

### 4.7 `NavigationBar` + `IndexedStack` (Member 5)

| Tab | Icon (unselected / selected)                 | Label    |
| :-- | :------------------------------------------- | :------- |
| 1   | `today_outlined` / `today`                   | Hari Ini |
| 2   | `checklist_outlined` / `checklist`           | Tugas    |
| 3   | `calendar_month_outlined` / `calendar_month` | Jadwal   |
| 4   | `person_outline` / `person`                  | Profil   |

Labels are always visible. The selected indicator uses the default M3 color from `colorScheme`. `IndexedStack` preserves each tab's state (scroll position and filters are kept).

### 4.8 Data State Patterns (used by Members 2 & 4)

| State       | Appearance                                                                                                                                                                                                      |
| :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Loading** | Centered `CircularProgressIndicator`, or 3 gray skeleton cards (`outlineVariant`)                                                                                                                               |
| **Error**   | `cloud_off` icon, title "Gagal memuat data" (Failed to load data), subtext "Periksa koneksi atau server lalu coba lagi." (Check your connection or server, then try again.), `FilledButton.tonal` **Coba lagi** |
| **Empty**   | Large muted icon + "Belum ada tugas. Ketuk + untuk menambah." (No tasks yet. Tap + to add one.)                                                                                                                 |
| **Success** | List (`ListView.builder`)                                                                                                                                                                                       |

_Coba lagi_ re-invokes the `Future` (reassign it inside `setState`).

---

## 5. Screen Specifications

### 5.1 Shell (Root Navigation)

```text
┌──────────────────────────┐
│  (active tab content)    │
│                          │
│                          │
├──────────────────────────┤
│ Hari Ini Tugas Jadwal Profil │  ← NavigationBar
└──────────────────────────┘
```

### 5.2 **Hari Ini** Tab (Member 2)

Purpose: focus on what is urgent. _(The PRD does not detail this tab; this is an assumption — see section 9.)_

```text
Hari Ini                    Mon, 9 Nov
┌──────────────────────────────────┐
│ ⚠ 2 tasks due in < 24 hours      │  ← summary (secondaryContainer)
└──────────────────────────────────┘
Urgent
 [KartuTugas] [KartuTugas]
Due today
 [KartuTugas]
```

- Content: **unfinished** tasks due today or in under 24 hours, sorted by nearest deadline.
- Uses the same `KartuTugas` as the Tugas tab (one component, two contexts).
- Empty: "Tidak ada tugas mendesak." (No urgent tasks.)

### 5.3 **Tugas** Tab (Member 2)

```text
Tugas
[Semua][Belum selesai][Selesai][Tinggi]   ← FilterChip, horizontal scroll
┌────────────────────────────────┐
│ KartuTugas                      │
├────────────────────────────────┤
│ KartuTugas                      │
└────────────────────────────────┘
                          ( + )     ← FAB → Add Form
```

- `FutureBuilder` with 3 states + `RefreshIndicator` (pull to refresh, +2 bonus).
- Default order: unfinished first, then nearest deadline.
- The FAB `+` opens the **Add Form**; the `Navigator.pop(context, dataBaru)` result is added to the list and triggers a "Tugas ditambahkan" `SnackBar`.

### 5.4 **Task Detail** (Member 3)

```text
←  Detail Tugas
Laporan Praktikum Basis Data       ← headlineSmall (struck through if done)
[Tinggi]   [Belum selesai]
─────────────────────────────────
Mata kuliah   Basis Data
Tenggat       Kamis, 12 Nov 2026 · 23.59
              ⏱ 2 days 3 hours left
Status        Belum selesai
Catatan
Kerjakan bab 1–3, kumpulkan lewat LMS...
─────────────────────────────────
[ Tandai selesai ]   [ Kembali ]
```

- Opened via `Navigator.push` from a card; data from `GET /tugas/<id>` (loading/error/success).
- Primary button `FilledButton`/`.tonal` "Tandai selesai" ↔ "Tandai belum selesai"; secondary `OutlinedButton` "Kembali".
- Changing status returns the result to the list so both stay in sync.

### 5.5 **Add Task Form** (Member 1)

```text
✕  Tambah Tugas
Judul *            [______________________]
Mata kuliah *      [______________________]
Prioritas          [ Rendah | Sedang | Tinggi ]
Tenggat *          [ Pilih tanggal      📅 ]
Catatan            [______________________]
                   [______________________]
─────────────────────────────────
[ Batal ]                     [ Simpan ]
```

**Behavior & validation**
| Rule | Detail |
| :-- | :-- |
| Required | Title, course, deadline |
| **Simpan** (Save) button | Disabled (`onPressed: null`) until all required fields are filled (basis for the Widget Test) |
| Priority | Default **Sedang** |
| Deadline | `showDatePicker` (`firstDate` = today); time is automatically set to **23:59** on the chosen date so the "< 24 hours" logic works |
| Submit | `POST /tugas` → show a small `CircularProgressIndicator` in the button, button disabled |
| After `await` | `if (!mounted) return;` → `SnackBar` "Tugas ditambahkan" → `Navigator.pop(context, dataBaru)` |
| Submit failure | Stay on the form, `SnackBar` "Gagal menyimpan. Coba lagi.", input is preserved |
| Cancel | `Navigator.pop(context)` with no data |

Keyboard: title field uses `textInputAction.next`; notes are multiline (3–5 lines), `TextInputType.multiline`. Wrap the form in a `SingleChildScrollView` so the keyboard does not cover fields.

### 5.6 **Jadwal** (Schedule) Tab (Member 4)

```text
Jadwal Kuliah
MONDAY                                ← day header (secondary)
┌────────────────────────────────┐
│ 07.30 – 09.10   Basis Data      │
│ Ruang: TULT-0605                │
└────────────────────────────────┘
TUESDAY
┌────────────────────────────────┐
│ 10.00 – 11.40   Pemrograman Mobile │
│ Ruang: GKU-2.01                 │
└────────────────────────────────┘
```

- `FutureBuilder` with 3 states; `ListView.builder` with alternating items: a day header followed by that day's cards (Monday–Friday/Saturday).
- Each card: **start–end time**, **course name**, **room code** (`meeting_room` icon).
- Today is marked ("Hari ini" on the header, `secondary` color) — optional.
- A day with no classes shows the row "Tidak ada kuliah" (No classes).

### 5.7 **Profil** (Profile) Tab (Member 5)

```text
        (  local asset avatar/logo  )
           Student Name
           Student ID · Study Program
┌────────┬────────┬────────┐
│ 12     │ 7      │ 5      │
│ Total  │ Belum  │ Selesai│   ← task count summary
└────────┴────────┴────────┘
Academic info (semester, academic advisor, etc.)
```

- Local asset image registered in `pubspec.yaml`.
- Summary numbers are computed from task data (and/or from `GET /profil`).

---

## 6. Content & Tone

- Indonesian, friendly-polite tone, short sentences, verbs first on buttons: **Simpan, Batal, Coba lagi, Tandai selesai**.
- Error messages explain what happened **and** what the user can do.
- Date format: "Kam, 12 Nov 2026"; 24-hour time with a dot: "23.59".
- Avoid technical terms in user-facing text ("500", "Exception") — show friendly messages.

---

## 7. Accessibility (minimum target WCAG 2.2 AA)

- [ ] Text contrast ≥ 4.5:1 (large text ≥ 3:1) in light **and** dark mode.
- [ ] Touch targets ≥ 48×48 dp (Checkbox, chips, IconButton).
- [ ] Status never by color alone: priority = text, urgency = icon + text, done = strikethrough + check.
- [ ] `Semantics` / `tooltip` for icon-only controls.
- [ ] Support system font scaling up to 200% (no `maxLines` that cuts essential info; screens can scroll).
- [ ] Logical focus/reading order (top → bottom, left → right).
- [ ] Focus is not trapped in dialogs / the date picker.

---

## 8. Flutter Implementation

### 8.1 `lib/tema.dart` (owner: Member 1 — foundation, **built first**)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors. May ONLY be used in this file.
class _Merek {
  static const merah = Color(0xFFE62727);
  static const krem = Color(0xFFF3F2EC);
  static const abu = Color(0xFFDCDCDC);
  static const teal = Color(0xFF1E93AB);
}

ThemeData _bangunTema(Brightness kecerahan) {
  final merah = ColorScheme.fromSeed(
    seedColor: _Merek.merah,
    brightness: kecerahan,
  );
  final teal = ColorScheme.fromSeed(
    seedColor: _Merek.teal,
    brightness: kecerahan,
  );

  // primary = red (action/urgency), secondary = teal (info/done)
  var skema = merah.copyWith(
    secondary: teal.primary,
    onSecondary: teal.onPrimary,
    secondaryContainer: teal.primaryContainer,
    onSecondaryContainer: teal.onPrimaryContainer,
  );

  if (kecerahan == Brightness.light) {
    skema = skema.copyWith(
      surface: _Merek.krem,
      outlineVariant: _Merek.abu,
    );
  }

  final dasar = ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    brightness: kecerahan,
  );

  return dasar.copyWith(
    scaffoldBackgroundColor: skema.surface,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(dasar.textTheme),
    cardTheme: CardThemeData(
      elevation: 0,
      color: skema.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: skema.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

final ThemeData temaTerang = _bangunTema(Brightness.light);
final ThemeData temaGelap = _bangunTema(Brightness.dark);
```

```dart
// main.dart
MaterialApp(
  title: 'Tugasku',
  theme: temaTerang,
  darkTheme: temaGelap,
  themeMode: ThemeMode.system,
  home: const RootNavigation(),
);
```

> Version note: `surfaceContainerLowest` and `CardThemeData` require a recent Flutter version (≥ 3.27). If `flutter analyze` complains, change `CardThemeData` → `CardTheme`, or align every member's Flutter version (`flutter --version`).

### 8.2 Using colors in widgets

```dart
final warna = Theme.of(context).colorScheme;

// correct
Container(color: warna.primary);
Text('Mendesak', style: TextStyle(color: warna.onPrimary));

// wrong (violates P06)
Container(color: const Color(0xFFE62727));
Colors.red
```

### 8.3 Assets & Identity (Member 5)

- Launcher icon: **red `#E62727`** base with a cream `#F3F2EC` check/book glyph (optional teal accent) via `flutter_launcher_icons`.
- Launcher name: **Tugasku** (`AndroidManifest.xml` → `android:label`).
- At least 1 local asset (avatar/logo), registered in `pubspec.yaml`.

---

## 9. Assumptions & Decisions for the Team to Agree On

|  #  | Topic                           | Proposal in this document                                      | Reason                                                        |
| :-: | :------------------------------ | :------------------------------------------------------------- | :------------------------------------------------------------ |
|  1  | Content of the **Hari Ini** tab | Unfinished tasks due today / in < 24 h                         | The PRD only names the tab                                    |
|  2  | Deadline time                   | Automatically 23:59 on the chosen date                         | `showDatePicker` picks a date only, but "< 24 h" needs a time |
|  3  | Role of red                     | Seed + primary action + urgency                                | Follows palette order; mitigated with icon + text             |
|  4  | Teal                            | `secondary` for info/done/schedule                             | Contrasts with red and feels calming                          |
|  5  | Date format                     | Needs the `intl` package (`id_ID`) or a manual format function | Formatted dates appear on cards and in Detail                 |
|  6  | Font                            | Plus Jakarta Sans, preferably bundled in `assets/fonts/`       | Safe for demos without internet                               |
|  7  | Overdue tasks                   | Shown with the same badge (they are < 24 h)                    | Keeps the PRD rule simple                                     |

---

## 10. UI File Ownership per Member

| Member | Module                                    | Main components from this document       |
| :----: | :---------------------------------------- | :--------------------------------------- |
|   1    | `tema.dart`, `form_tambah/`               | Section 3 (tokens & theme), 4.3–4.6, 5.5 |
|   2    | `tugas/` (+ Hari Ini)                     | 4.1, 4.2, 4.8, 5.2, 5.3                  |
|   3    | `detail/`                                 | 4.3, 5.4                                 |
|   4    | `jadwal/`                                 | 4.8, 5.6                                 |
|   5    | `root_navigation.dart`, `profil/`, assets | 4.7, 5.1, 5.7, 8.3                       |

**Team rule:** Member 1 merges `tema.dart` + the shell first so everyone uses the same theme; nobody creates their own styling outside `colorScheme`.

---

## 11. Design ↔ UTS Rubric Checklist

| Code             | Satisfied by this design through                                                                               |  ✔  |
| :--------------- | :------------------------------------------------------------------------------------------------------------- | :-: |
| P03              | 4.2–4.6 (chips, buttons, `TextField` + dispose, `SnackBar`, `setState`)                                        | [ ] |
| P04              | 4.1 card with `Row/Column/Expanded/Stack`, 5.3 `ListView.builder`, 4.7 `NavigationBar` 4 tabs + `IndexedStack` | [ ] |
| P05              | 5.4 Detail, 5.5 Form + `showDatePicker` + `mounted` check                                                      | [ ] |
| P06              | Sections 3 & 8 (`fromSeed` light/dark, colors from `colorScheme`, custom font, launcher icon, local asset)     | [ ] |
| P07              | 4.8 _loading/error/success_ states + _Coba lagi_                                                               | [ ] |
| Khas (Signature) | 4.1 (checkbox, strikethrough, < 24 h badge), 5.6 (schedule by day)                                             | [ ] |
| Bonus            | 5.5 (POST to server), 5.3 (_pull-to-refresh_)                                                                  | [ ] |

### Visual QA Checklist Before Screenshots

- [ ] Every screen checked in light **and** dark mode
- [ ] No hex / `Colors.*` outside `tema.dart` (search with `grep -rn "Color(0x" lib/` and `grep -rn "Colors\." lib/`)
- [ ] All four tabs render correctly; tab state is kept when switching
- [ ] Error state + _Coba lagi_ recorded for the demo
- [ ] The < 24 h badge appears on at least one test data item
- [ ] ≥ 4 screenshots saved in `screenshots/`
