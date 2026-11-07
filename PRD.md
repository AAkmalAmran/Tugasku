# Product Requirements Document (PRD)

## Project 6: Tugasku — Class Schedule and Assignment Reminder

| Project Information     | Detail                                                          |
| :---------------------- | :-------------------------------------------------------------- |
| **Course**              | Mobile Application Development (BBK4DBB3)                       |
| **Group**               | Group 03                                                        |
| **Project Theme**       | Project 6 — Tugasku (Personal Academic Assistant)               |
| **Package / Org ID**    | `id.ac.telkomuniversity.tugasku`                                |
| **Tech Stack**          | Flutter (Material 3) & Dart REST API (`shelf` + `shelf_router`) |
| **Submission Deadline** | Thursday, 12 November 2026, 23:59 WIB                           |
| **Document version**    | v2.3 (consistency fixes; see Appendix A)                        |
| **Companion document**  | `Design.md` (visual & UI specification)                         |

**How to read this document.** Requirements taken from the original PRD and the UTS rubric are unchanged in substance. Additions are tagged:

- **[Clarified]** — an ambiguity in v1 that is now stated explicitly.
- **[Proposed]** — a new suggestion the team should confirm (collected in Section 12).

> **Naming & language convention:** All **file names, folder names, classes, methods, variables, and branch names use English** (e.g., `theme.dart`, `task_form/`, `TaskCard`, `fetchTasks()`). The **Data Model stays in Indonesian**: model classes/files (`Tugas`, `Jadwal`, `Profil` → `tugas.dart`, `jadwal.dart`, `profil.dart`), their JSON fields (`judul`, `mataKuliah`, `tenggat`, ...), values (`Rendah`, `Sedang`, `Tinggi`), the REST paths (`/tugas`, `/jadwal`, `/profil`), and the seed file (`tugasku.json`). **UI text** is also Indonesian (tab names _Hari Ini_, _Tugas_, _Jadwal_, _Profil_).

---

## 1. Vision & Product Description

**Tugasku** is an Android-based personal academic assistant that helps university students manage coursework, track deadlines, and view their weekly class schedule in a structured way. The app connects to a local REST API server built with Dart Shelf and supports Material 3 light and dark themes.

### 1.1 Target User

University students with several courses who receive assignments from multiple lecturers and channels and need one reliable place to see what is due and where to be.

### 1.2 Goals

1. Record an assignment in under 30 seconds.
2. See the most urgent task within 10 seconds of opening the app.
3. See any day's class schedule (time and room) without leaving the app.

### 1.3 Scope

| In scope                                       | Out of scope                                                                                                     |
| :--------------------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| 4-tab app: Hari Ini, Tugas, Jadwal, Profil     | User accounts / authentication                                                                                   |
| Add task, view detail, mark done (see 4.2/4.3) | Editing or deleting tasks **[Proposed: optional]**                                                               |
| Local REST server with seed data               | Cloud deployment, database                                                                                       |
| Light & dark theme                             | Push notifications / alarms (despite the "reminder" theme, reminders are visual only: badge for deadline < 24 h) |

---

## 2. Technical Specification & Architecture

### 2.1 Flutter Project Standards (`app/`)

- **Initialization:** Created with `flutter create --org id.ac.telkomuniversity --project-name tugasku app` (not `com.example`).
- **App identity:** The launcher name is **Tugasku**, with a custom icon via `flutter_launcher_icons`, a custom font (Plus Jakarta Sans bundled in `assets/fonts/`; `google_fonts` is the fallback option), and at least 1 local image asset in `pubspec.yaml`.
- **Material 3 theme:** `ThemeData` with `ColorScheme.fromSeed` for light (`theme`) and dark (`darkTheme`) modes. **Every** component must take its colors from `Theme.of(context).colorScheme`. Palette and roles are defined in `Design.md`.
- **API consumption:** Uses the `http` package. The server base URL is read at build time via `--dart-define=API_URL=...` (emulator default: `http://10.0.2.2:8080`).
- **Code quality:** `flutter analyze` must be clean (**0 errors, 0 warnings**; target 0 issues of any kind).

### 2.2 Backend Server Standards (`server/`)

- **Framework:** Dart with `shelf` and `shelf_router`.
- **Seed data:** `server/data/tugasku.json` containing at least **12 task items**, one week of class-schedule data, and profile data.
- **[Clarified] Persistence:** Tasks created via `POST /tugas` are kept **in memory** (the list loaded from JSON at startup). Restarting the server resets to the seed data. Writing back to the JSON file is optional.
- **[Clarified] ID generation:** `id = (max existing id) + 1`.

### 2.3 Repository Structure

```text
tugasku_project/
├─ app/                        # Flutter app
│  ├─ assets/
│  │  ├─ images/               # Logo / avatar (≥ 1, registered in pubspec.yaml)
│  │  └─ fonts/                # Plus Jakarta Sans (bundled)
│  ├─ lib/
│  │  ├─ data/
│  │  │  ├─ models/            # tugas.dart, jadwal.dart, profil.dart
│  │  │  ├─ services/          # api_service.dart
│  │  │  └─ state/             # tasks_store.dart  [Proposed, see 2.6]
│  │  ├─ ui/
│  │  │  ├─ root_navigation.dart
│  │  │  ├─ widgets/           # shared widgets, e.g. priority chip  [Proposed]
│  │  │  ├─ task_form/         # Member 1 feature
│  │  │  ├─ tasks/             # Member 2 feature (incl. Hari Ini tab)
│  │  │  ├─ detail/            # Member 3 feature
│  │  │  ├─ schedule/          # Member 4 feature
│  │  │  └─ profile/           # Member 5 feature
│  │  ├─ theme.dart            # Material 3 configuration
│  │  └─ main.dart             # App entry point
│  ├─ test/                    # ≥ 3 Widget Tests + 1 MockClient Test
│  │  ├─ task_form_test.dart   # Member 1
│  │  ├─ task_card_test.dart   # Member 2
│  │  ├─ detail_page_test.dart # Member 3
│  │  └─ api_service_test.dart # Member 4 (MockClient)
│  └─ pubspec.yaml
├─ server/                     # Dart Shelf REST API server
│  ├─ bin/server.dart
│  ├─ data/tugasku.json        # Seed data (≥ 12 tasks)
│  └─ pubspec.yaml
├─ screenshots/                # ≥ 4 screenshots from a device/emulator
├─ .gitignore                  # build/, .dart_tool/, android/.gradle/
├─ PRD.md                      # This document
├─ Design.md                   # Visual & UI specification
└─ README.md                   # Run guide, member list & feature table
```

### 2.4 Dependencies **[Clarified]**

| Where     | Package                                                          | Purpose                                                       |
| :-------- | :--------------------------------------------------------------- | :------------------------------------------------------------ |
| app       | `http`                                                           | REST calls (and `package:http/testing.dart` for `MockClient`) |
| app       | `google_fonts` _(optional; not needed when the font is bundled)_ | Custom font (fallback option)                                 |
| app       | `intl` **[Proposed]**                                            | Indonesian date formatting (`id_ID`)                          |
| app (dev) | `flutter_launcher_icons`                                         | Launcher icon                                                 |
| app (dev) | `flutter_test`                                                   | Widget & unit tests                                           |
| server    | `shelf`, `shelf_router`                                          | HTTP server & routing                                         |

### 2.5 Networking & Environment **[Clarified]**

Items that commonly break demos:

| Concern             | Requirement                                                                                                                                              |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Emulator → host     | `http://10.0.2.2:8080` (default)                                                                                                                         |
| Physical device     | Run with `--dart-define=API_URL=http://<PC-LAN-IP>:8080`; phone and PC on the same Wi-Fi                                                                 |
| Server binding      | Bind to `InternetAddress.anyIPv4` (not loopback only) so devices can reach it                                                                            |
| Cleartext HTTP      | Android blocks `http://` by default on newer versions; set `android:usesCleartextTraffic="true"` (or a network security config) in `AndroidManifest.xml` |
| Internet permission | `<uses-permission android:name="android.permission.INTERNET"/>` must exist in the **main** manifest (required for the release/APK build, not only debug) |
| Port                | Default `8080`; allow override via `PORT` environment variable                                                                                           |
| Run commands        | Server: `dart run bin/server.dart` · App: `flutter run --dart-define=API_URL=...`                                                                        |

### 2.6 Cross-Module Integration Contract **[Proposed]**

Because tabs are kept alive by `IndexedStack`, an action in one tab (adding a task, ticking a checkbox) will **not** automatically refresh the others. To keep Hari Ini, Tugas, and Profil consistent:

1. **`ApiService`** is the only class that talks to the network. It takes an optional `http.Client` in its constructor (`ApiService({http.Client? client})`) so tests can inject a `MockClient`. Base URL: `String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080')`.
2. Method signatures (created as stubs by Member 1; each member implements their own):

   | Method                                                 | Owner    |
   | :----------------------------------------------------- | :------- |
   | `Future<Tugas> createTask(Tugas task)` → `POST /tugas` | Member 1 |
   | `Future<List<Tugas>> fetchTasks()` → `GET /tugas`      | Member 2 |
   | `Future<Tugas> fetchTask(int id)` → `GET /tugas/<id>`  | Member 3 |
   | `Future<List<Jadwal>> fetchSchedule()` → `GET /jadwal` | Member 4 |
   | `Future<Profil> fetchProfile()` → `GET /profil`        | Member 5 |

3. **`TasksStore extends ChangeNotifier`** (core Flutter, no extra package) holds the task list's `Future` and a `load()` method that reloads it. Tugas, Hari Ini, and Profil listen to it; Form Tambah and Detail call it after changes. _Alternative:_ pass `onChanged` callbacks down from `RootNavigation`. **Ownership:** Member 1 creates the skeleton in the scaffold; Member 2 implements it; Member 5 creates the single instance in `RootNavigation` and passes it to every tab through constructors (no extra package).
4. **Testability rule:** UI widgets receive their data or dependencies through constructors (e.g., `TaskCard(task: ...)`, `DetailPage(task: ..., ...)`) so Widget Tests can run without a server.

---

## 3. Data Model Specification & API Contract

### 3.1 Main Model: `Tugas`

Must have at least 6 fields (including a `DateTime` and a `bool`) plus `fromJson` and `toJson`. **[Clarified]** The model below has **7** fields.

| Field        | Data Type  | Description                                   |
| :----------- | :--------- | :-------------------------------------------- |
| `id`         | `int`      | Unique task ID                                |
| `judul`      | `String`   | Task name/title                               |
| `mataKuliah` | `String`   | Related course name                           |
| `prioritas`  | `String`   | Priority: `Rendah`, `Sedang`, or `Tinggi`     |
| `tenggat`    | `DateTime` | Submission deadline (ISO-8601 string in JSON) |
| `selesai`    | `bool`     | Completion status (`true` / `false`)          |
| `catatan`    | `String`   | Additional details or description             |

### 3.2 Model: `Jadwal` **[Clarified]**

| Field        | Type     | Description / example                                   |
| :----------- | :------- | :------------------------------------------------------ |
| `id`         | `int`    | Unique schedule entry ID                                |
| `hari`       | `String` | `Senin`, `Selasa`, `Rabu`, `Kamis`, `Jumat`, or `Sabtu` |
| `mataKuliah` | `String` | Course name                                             |
| `jamMulai`   | `String` | Start time `"HH:mm"`, e.g. `"07:30"`                    |
| `jamSelesai` | `String` | End time `"HH:mm"`, e.g. `"09:10"`                      |
| `ruangan`    | `String` | Room code, e.g. `"TULT-0605"` (sample)                  |

### 3.3 Model: `Profil` **[Clarified]**

| Field            | Type     | Description           |
| :--------------- | :------- | :-------------------- |
| `nama`           | `String` | Student name          |
| `nim`            | `String` | Student ID number     |
| `programStudi`   | `String` | Study program         |
| `semester`       | `int`    | Current semester      |
| `dosenWali`      | `String` | Academic advisor      |
| `sksSemesterIni` | `int`    | Credits this semester |

The **task-count summary** on the Profile tab (total / not done / done) is **computed on the client** from the task list; it is not stored in `/profil`.

### 3.4 Seed File Shape (`server/data/tugasku.json`) **[Clarified]**

```json
{
  "tugas": [
    {
      "id": 1,
      "judul": "Laporan Praktikum Basis Data",
      "mataKuliah": "Basis Data",
      "prioritas": "Tinggi",
      "tenggat": "2026-11-12T23:59:00+07:00",
      "selesai": false,
      "catatan": "Kerjakan bab 1-3, kumpulkan lewat LMS."
    }
  ],
  "jadwal": [
    {
      "id": 1,
      "hari": "Senin",
      "mataKuliah": "Basis Data",
      "jamMulai": "07:30",
      "jamSelesai": "09:10",
      "ruangan": "TULT-0605"
    }
  ],
  "profil": {
    "nama": "Nama Mahasiswa",
    "nim": "1234567890",
    "programStudi": "S1 Teknologi Informasi",
    "semester": 3,
    "dosenWali": "Nama Dosen",
    "sksSemesterIni": 20
  }
}
```

Seed-data requirements:

- ≥ 12 tasks, mixing all three priorities and both `selesai` values.
- **At least 2 tasks with a deadline < 24 h from the demo/recording time**, so the signature badge is visible. _[Proposed]_ either edit the dates right before recording, or have the server shift seed dates relative to its start time.
- **At least 1 unfinished task already overdue**, so the "Terlambat" badge (3.6) is visible.
- Schedule covers Monday–Friday (Saturday optional), ≥ 2 entries on some days and at least one day with none (to show the empty row).

### 3.5 REST API Endpoints (`server/bin/server.dart`)

| Method   | Endpoint      | PIC      | Description & Responses                                                                                                                                                                                                                      |
| :------- | :------------ | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **POST** | `/tugas`      | Member 1 | Accepts a new task JSON payload, assigns a unique `id`, stores it in the server list, and returns `201 Created` with the created task as the body. **[Clarified]** `400 Bad Request` if the body is not valid JSON or lacks required fields. |
| **GET**  | `/tugas`      | Member 2 | Returns the full task list (`200 OK` — JSON array).                                                                                                                                                                                          |
| **GET**  | `/tugas/<id>` | Member 3 | Returns one task by `id` (`200 OK` or `404 Not Found`). **[Clarified]** A non-integer `id` returns `400`.                                                                                                                                    |
| **GET**  | `/jadwal`     | Member 4 | **[Signature endpoint]** Returns one week of class schedule (`200 OK` — JSON array).                                                                                                                                                         |
| **GET**  | `/profil`     | Member 5 | Returns student profile information (`200 OK` — JSON object).                                                                                                                                                                                |

**[Clarified] Conventions for all endpoints**

- Response header `Content-Type: application/json; charset=utf-8`.
- Error body shape: `{ "message": "Tugas tidak ditemukan" }`.
- JSON field names exactly as in Sections 3.1–3.3 (camelCase).

**Example — `POST /tugas`**

Request body (`id` omitted; the server assigns it):

```json
{
  "judul": "Proposal Proyek",
  "mataKuliah": "Pemrograman Mobile",
  "prioritas": "Sedang",
  "tenggat": "2026-11-14T16:59:00Z",
  "selesai": false,
  "catatan": ""
}
```

Response `201 Created`: the same object plus `"id": 13`.

**[Proposed — optional]** `PATCH /tugas/<id>` with `{"selesai": true}` to persist the completion state. Not required by the rubric; see Risk R3.

### 3.6 Date & Time Conventions **[Clarified]**

| Topic                 | Rule                                                                                                                                                                            |
| :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Wire format           | ISO-8601 strings. Seed data may use `+07:00`; the client sends UTC (`tenggat.toUtc().toIso8601String()`).                                                                       |
| Parsing               | `DateTime.parse(json['tenggat'])` then `.toLocal()` for display and comparisons.                                                                                                |
| Date picker           | `showDatePicker` returns a date only; the app sets the time to **23:59** local on the chosen date.                                                                              |
| "Due within 24 hours" | `0 ≤ (tenggat − now) < 24 h` **and** `selesai == false`.                                                                                                                        |
| Overdue tasks         | **[Proposed]** `tenggat < now` and `selesai == false` are urgent as well: same badge style but with the text "Terlambat" (not "< 24 jam"), and they appear in the Hari Ini tab. |

### 3.7 Client Error Handling **[Clarified]**

- Network failure, timeout (suggest 10 s), or non-2xx status → `ApiService` throws an exception; `FutureBuilder` shows the **Error** state with **Coba lagi**.
- Do not show raw exceptions or status codes to users; show a friendly message (see `Design.md`, section 4.8).

---

## 4. Functional Requirements & Task Division (Feature Slices)

Each member is fully and vertically responsible for **1 backend endpoint**, **1 UI module**, and **testing**.

### 4.1 Member 1 (Project Lead): Initiation, `POST /tugas`, & Add Task Form

- **Project setup (lead responsibilities) [Clarified]:** create the repository and both projects, `theme.dart` (from `Design.md`), `ApiService` and `Tugas` skeleton (Section 2.6), server skeleton with five route stubs, and branch rules (Section 10) **before** other members start feature work.
- **Backend:** Implement `POST /tugas` to store new tasks on the server (**Bonus +5**).
- **Frontend (`lib/ui/task_form/`):**
  - Build the Add Task form page with inputs: `judul`, `mataKuliah`, `prioritas`, `tenggat`, and `catatan`.
  - Use `TextField` with `TextEditingController`s that are properly `dispose()`d.
  - Use `ChoiceChip` / `SegmentedButton` to choose priority (`Rendah`, `Sedang`, `Tinggi`).
  - Integrate `showDatePicker` to choose the deadline date.
  - Provide at least 2 kinds of Material 3 buttons (`FilledButton` for Save, `OutlinedButton` for Cancel).
  - Send data to the server via `POST`, check `if (!mounted) return;` after `await`, show a confirmation `SnackBar`, and return to the previous screen with `Navigator.pop(context, newTask)`.
  - **[Clarified]** `newTask` is the `Tugas` returned by the server (including its assigned `id`), so the list can show it immediately. The caller (the Tugas screen) must receive it with `await Navigator.push<Tugas>(...)` and insert it into the visible list at once (official P05 wording). Per the official brief, keeping the item in app memory already satisfies P05; the `POST` itself is the +5 bonus.
  - **[Clarified]** Required fields: `judul`, `mataKuliah`, `tenggat`. The Save button stays disabled until they are filled. Default priority: `Sedang`.
- **Testing:** 1 Widget Test covering form input and Save-button validation.
- **Acceptance criteria:** the new task appears in the Tugas list without restarting the app; a failed submit keeps the user's input; the controllers are disposed.

### 4.2 Member 2: `GET /tugas`, Hari Ini & Tugas Tabs, plus Signature Features

- **Backend:** Implement `GET /tugas` with at least 12 seed items in `tugasku.json`.
- **Frontend (`lib/ui/tasks/`):**
  - Display the task list using `FutureBuilder` that handles 3 states explicitly: **Loading**, **Error** with a _Coba lagi_ button, and **Success**.
  - Render the list with `ListView.builder`.
  - Build a custom task card widget (`StatelessWidget`/`StatefulWidget`) combining `Row`, `Column`, `Expanded`, and `Stack`.
  - **Signature Feature 1:** An interactive `Checkbox` using `setState` to mark a task as done.
  - **Signature Feature 2:** The task title is automatically struck through (`TextDecoration.lineThrough`) when `selesai == true`.
  - **Signature Feature 3:** Show a special visual marker/badge (inside the `Stack`) when the task deadline is less than 24 hours from now (rule in 3.6).
  - **Filter/Interaction:** Provide `FilterChip` or `ChoiceChip` to filter by priority/status, and `SnackBar` feedback when a status changes.
  - **Bonus (+2):** Wrap the list in a `RefreshIndicator` for pull-to-refresh.
  - **Bonus (+3) [Clarified — official brief]:** `Hero` animation between the task card and the Detail page (tag `'task-<source>-<id>'` where `<source>` is `today` or `list`, e.g., on the title or priority chip). The two tabs live together in the `IndexedStack`, so a tag without `<source>` would be duplicated and throw a Hero error. The tag is passed to `DetailPage` through its constructor (`heroTag`). Coordinate with Member 3, who owns the Detail side.
  - **[Clarified — P05]** The FAB opens the form with `final newTask = await Navigator.push<Tugas>(...)`, checks `if (!mounted) return;`, and inserts the result into the list immediately.
  - **[Clarified] Hari Ini tab:** shows unfinished tasks that are overdue or due within 24 hours (this includes everything due later today), sorted by nearest deadline, using the same task card as the Tugas tab. Empty state: "Tidak ada tugas mendesak."
- **Testing:** 1 Widget Test covering task-card rendering, checkbox interaction, and the < 24 h marker.
- **Acceptance criteria:** the three states are reachable (kill the server to see Error); ticking a task strikes the title and shows a SnackBar; at least one seed task shows the badge; filters combine sensibly with the list.

### 4.3 Member 3: `GET /tugas/<id>` & Task Detail Page

- **Backend:** Implement `GET /tugas/<id>` to retrieve one specific task.
- **Frontend (`lib/ui/detail/`):**
  - Build a Task Detail page opened via `Navigator.push` when a task card is tapped.
  - Show all task attributes completely (title, course, priority, formatted deadline, completion status, and full notes).
  - Provide Material 3 action buttons (e.g., `FilledButton` / `IconButton`) to change completion status or return to the list.
  - **[Clarified — P05]** The page **receives the `Tugas` object through its constructor** (the official brief requires this) and renders it immediately. `GET /tugas/<id>` (`ApiService.fetchTask(id)`) may refresh the data in the background, with an error message and _Coba lagi_ if it fails; the page must still render from the constructor object when the server is unreachable. Changing the completion status returns the result to the list so both stay in sync (see Risk R3 for persistence).
  - **Bonus (+3):** the matching `Hero` on the Detail side, using the `heroTag` received through the constructor (see 4.2).
- **Testing:** 1 Widget Test verifying that the Detail page renders task information correctly.
- **Acceptance criteria:** every field is visible; a long note wraps or scrolls without overflow; a `404` shows a friendly message.

### 4.4 Member 4: `GET /jadwal` (Signature Endpoint) & Class Schedule Tab

- **Backend:** Implement the signature endpoint `GET /jadwal`, which serves one week of class schedule data.
- **Frontend (`lib/ui/schedule/`):**
  - Consume `GET /jadwal` using `FutureBuilder` (with all 3 states: loading, error + _Coba lagi_ button, and success).
  - **Signature Feature 4:** Group the schedule view by day (Monday to Friday/Saturday) using `ListView.builder`, showing course name, start–end time, and room code.
  - **[Clarified]** Days are shown in weekday order; a day with no classes shows "Tidak ada kuliah"; entries within a day are sorted by start time.
- **Testing:** 1 Unit/Service Test using `MockClient` (`package:http/testing.dart`) to test API data retrieval and parsing without a real server. **[Clarified]** Cover at least the success case and one error case (non-200 status).
- **Acceptance criteria:** grouping by day is correct; the error state recovers via _Coba lagi_; the test passes with no network.

### 4.5 Member 5: `GET /profil`, Main Navigation (`NavigationBar`), Assets & Deliverables

- **Backend:** Implement `GET /profil` for student identity data.
- **Frontend (`lib/ui/root_navigation.dart` & `lib/ui/profile/`):**
  - Build the bottom navigation shell using Material 3 `NavigationBar` and `IndexedStack` with **4 mandatory tabs**: **Hari Ini**, **Tugas**, **Jadwal**, and **Profil**.
  - Build the **Profile Tab** containing a local asset image (logo/avatar registered in `pubspec.yaml`), student identity, and a task-count summary (computed per 3.3).
- **Visual Configuration & QA:**
  - Configure `flutter_launcher_icons` and the custom font.
  - Ensure all features are integrated, `flutter analyze` reports 0 issues, and all tests pass.
  - Take at least 4 app screenshots into the `screenshots/` folder, complete the requirement-fulfillment table (`File:line`) in `README.md`, build the **debug APK**, and prepare the 3–5 minute demo video.
- **Acceptance criteria:** switching tabs preserves state; the profile shows the asset image and correct counts; the APK installs and runs against the server.

### 4.6 Shared Responsibilities **[Clarified]**

- **Everyone:** follow `Design.md`; no hex colors or `Colors.*` outside `theme.dart`; keep `flutter analyze` clean on your own branch before opening a pull request.
- **Test ownership:** Members 1, 2, 3 → one Widget Test each (3 total). Member 4 → the `MockClient` test. The rubric minimum is therefore met by the team as a whole.
- **[Proposed] Safety margin:** add a 4th Widget Test (e.g., Jadwal grouping by Member 4, or the Profile summary by Member 5). With exactly 3, a single failing test breaks the "≥ 3 widget tests, all passing" checkpoint.

---

## 5. Non-Functional Requirements **[Clarified]**

| Area           | Requirement                                                                                   |
| :------------- | :-------------------------------------------------------------------------------------------- |
| Code quality   | `flutter analyze`: 0 errors, 0 warnings; `flutter test`: all green                            |
| Theming        | Light & dark both fully usable; all colors from `colorScheme`                                 |
| Accessibility  | Targets in `Design.md`, section 7 (contrast, 48 dp touch targets, status not by color alone)  |
| Responsiveness | No overflow on small phones (360 dp wide) or with larger system font sizes                    |
| Resilience     | Server down, slow, or returning errors never crashes the app                                  |
| Language       | UI text in Indonesian, consistent with `Design.md`, section 6                                 |
| Performance    | Lists use `ListView.builder`; no network calls inside `build()` (store the `Future` in state) |

---

## 6. UTS Rubric Compliance Checklist (P01–P07)

| Code          | Mandatory Criteria                                                                                                                                                                                 | Status | PIC              |
| :------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :--------------- |
| **P01–P02**   | `id.ac.telkomuniversity` organization, launcher name matches the theme, ≥ 4 device screenshots, clean `flutter analyze` (0 errors/warnings)                                                        |  [ ]   | Members 1 & 5    |
| **P03**       | `StatelessWidget` & `StatefulWidget` + `setState`, `TextField` + `TextEditingController.dispose()`, ≥ 2 kinds of M3 buttons, `ChoiceChip`/`FilterChip`/`SegmentedButton`, `SnackBar`               |  [ ]   | Members 1 & 2    |
| **P04**       | `Tugas` model with ≥ 6 fields (including `DateTime` & `bool`), custom card (`Row`, `Column`, `Expanded`, `Stack`), `ListView.builder`, `NavigationBar` 4 tabs + `IndexedStack`                     |  [ ]   | Members 2 & 5    |
| **P05**       | Detail page, Add form + result shown in the list, `showDatePicker`, `async`/`await` + `mounted` check, ≥ 3 Widget Tests                                                                            |  [ ]   | Members 1, 2, 3  |
| **P06**       | `ThemeData` + `ColorScheme.fromSeed` (Light & Dark), colors from `colorScheme`, custom font, `flutter_launcher_icons`, ≥ 1 local image asset                                                       |  [ ]   | Members 1 & 5    |
| **P07**       | Dart Shelf server (≥ 12 JSON items), ≥ 3 `GET` endpoints, `http` package + `--dart-define=API_URL`, `fromJson`/`toJson`, `FutureBuilder` with 3 states + _Coba lagi_ button, ≥ 1 `MockClient` test |  [ ]   | Whole team       |
| **Signature** | Done checkbox, struck-through text, < 24 h deadline marker, Schedule tab grouped by day, `GET /jadwal` endpoint                                                                                    |  [ ]   | Members 2 & 4    |
| **Bonus**     | Add-form submission to server via `POST /tugas` (+5), _Pull-to-refresh_ (+2) & `Hero` animation card → detail (+3); maximum +10                                                                    |  [ ]   | Members 1, 2 & 3 |

### 6.1 Weights and Penalties (official brief) **[Clarified]**

| Component                                                        |                 Weight                 |
| :--------------------------------------------------------------- | :------------------------------------: |
| P01–P02 (project, device, clean analyze)                         |                  10%                   |
| P03 (basic widgets, input, interaction)                          |                  15%                   |
| P04 (model, layout, bottom navigation)                           |                  15%                   |
| P05 (detail, form + result, async, ≥ 3 tests)                    |                  15%                   |
| P06 (light/dark theme, font, icon, assets)                       |                  10%                   |
| P07 (server, 3 endpoints, http, JSON, FutureBuilder, MockClient) |                  20%                   |
| Signature features (Section 4 items marked "Signature")          |                  10%                   |
| README, screenshots, demo video                                  |                   5%                   |
| **Bonus (max +10)**                                              | POST +5 · pull-to-refresh +2 · Hero +3 |

**Penalties:** README commands do not run the project **−20** · `flutter analyze` has errors **−10** · copying Temuin or another group's work → **0** for the related component.

Consequence: P07 is the heaviest item, and a README that does not work on a clean machine costs more than any single feature is worth (see R9).

---

## 7. Mandatory Demo Video Scenario (3–5 Minutes)

1. Run the Dart Shelf server in a terminal (`dart run bin/server.dart`).
2. Run the Flutter app and show the initial data loading from the server.
3. Stop the server to demonstrate the **Error State**, start it again, then tap **Coba lagi** until the data loads.
4. Explore all four tabs (`Hari Ini`, `Tugas`, `Jadwal` by day, and `Profil`) and the signature features (tick a `Checkbox` until the text is struck through, and show the `< 24 hours` indicator).
5. Tap a task card to open the **Task Detail page**.
6. Open the **Add Task Form**, pick a date via `DatePicker`, save the new task via `POST`, and show it appearing in the main list.
7. Show the results of `flutter test` and `flutter analyze` in the terminal, passing without errors.

**[Proposed] Recording tips**

- Rehearse once; the whole run fits in 4 minutes.
- Because tasks are in memory (2.2), stopping the server in step 3 is safe _before_ step 6; avoid restarting the server after adding data you want to keep showing.
- Refresh the seed dates beforehand so the < 24 h badge is visible (3.4).
- Record at a readable text size; show light and dark mode briefly if time allows.

---

## 8. Deliverables & Submission Checklist **[Clarified]**

- [x] Repository link (GitHub/GitLab) — **public, or invite the lecturer** — containing `app/`, `server/`, `screenshots/`, `PRD.md`, `Design.md`, `README.md`
- [ ] **Zip file** of the repository contents **without** `build/`, `.dart_tool/`, and `android/.gradle/` (official requirement; applies to both `app/` and `server/`)
- [ ] `README.md` (official brief, Section 6) containing: (1) group name (Kelompok 03), theme (Tugasku), and members with **name, NIM, and each member's task**; (2) how to run — the command that starts the server and `flutter run --dart-define=API_URL=...`; (3) ≥ 4 screenshots; (4) a **feature-fulfillment table with one row per checkpoint** in Section 3 of the official list (about 29 rows: P01–P02 ×5, P03 ×5, P04 ×4, P05 ×4, P06 ×5, P07 ×6) with columns **Poin · File:baris · Keterangan**, e.g. `P04 NavigationBar ≥ 3 tabs | lib/ui/root_navigation.dart:48 | Tabs Hari Ini, Tugas, Jadwal, Profil`
- [ ] ≥ 4 screenshots in `screenshots/` (include dark mode, the Detail page, and the Error state)
- [ ] Debug APK (`flutter build apk --debug`) built and tested on a device/emulator
- [ ] Demo video, 3–5 minutes, following Section 7
- [ ] `flutter analyze` and `flutter test` outputs clean (screenshot or log)
- [ ] Demo video uploaded to **YouTube (unlisted) or Google Drive**, with the link accessible to the lecturer
- [ ] **One member** uploads everything on behalf of the group to the UTS assignment in the LMS (Pertemuan 8 section); decide who by Wed 11 Nov
- [ ] **Commit history shows a contribution from every member** (each person commits their own slice from their own account); members without contributions can be graded separately
- [ ] Everything submitted before Thursday, 11 November 2026, 23:59 WIB unless the LMS announces otherwise (**[Proposed]** internal cut-off: 18:00 the same day)

---

## 9. Proposed Timeline **[Proposed]**

| Date           | Milestone                                                                                                                                                 |
| :------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Sun 8 Nov**  | Member 1: repo, scaffolds, `theme.dart`, `ApiService` + model skeleton, server skeleton, seed JSON (≥ 12 tasks). Team agrees on this PRD and `Design.md`. |
| **Mon 9 Nov**  | Each member builds their endpoint + UI slice against the agreed contract (use hard-coded sample data until the server routes land).                       |
| **Tue 10 Nov** | Finish slices and their tests; open pull requests; merge in the order from Section 10.                                                                    |
| **Wed 11 Nov** | Integration pass, quick usability test (3 classmates), bug fixes, `flutter analyze`/`test` clean, screenshots, APK, README table.                         |

---

## 10. Collaboration Rules **[Proposed]**

- **Branches:** `main` is always runnable. One branch per member: `feat/member1-task-form`, `feat/member2-tasks`, etc. Merge through pull requests reviewed by at least one other member.
- **Merge order:** Member 1 scaffold → Member 5 shell (`root_navigation.dart`, assets) → Members 2, 3, 4 (in any order) → final integration.
- **Conflict hotspots:** `pubspec.yaml`, `main.dart`, `api_service.dart`, `server.dart`. Member 1 pre-creates stubs for each member's method/route so each person edits only their own block; add dependencies in a single early commit.
- **Commits:** short imperative messages, prefixed with the area (`form:`, `tasks:`, `server:`).
- **Definition of Done (per slice):** feature works against the real server; `flutter analyze` clean; the slice's test passes; screenshots captured if the slice appears in the README table.

---

## 11. Risks & Mitigations **[Proposed]**

| ID  | Risk                                                                                                                             | Mitigation                                                                                                                                                    |
| :-: | :------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| R1  | App cannot reach the server on a device (wrong IP, cleartext blocked, loopback-only binding)                                     | Follow Section 2.5; test on a device on day 2, not on demo day                                                                                                |
| R2  | Tabs show stale data after adding/changing a task                                                                                | `TasksStore` or callbacks (Section 2.6)                                                                                                                       |
| R3  | Checkbox state is lost on pull-to-refresh because it exists only on the client (there is no update endpoint)                     | Either add the optional `PATCH /tugas/<id>`, or keep a local override map by `id` in `TasksStore` that is re-applied after each reload. Decide before Monday. |
| R4  | The < 24 h badge is invisible during the demo because seed dates are stale                                                       | Refresh dates before recording, or shift them at server startup (3.4)                                                                                         |
| R5  | `flutter analyze` warnings accumulate across five branches                                                                       | Run it before every pull request; run again on `main` after each merge                                                                                        |
| R6  | Member 5 carries most integration and delivery work                                                                              | Others help with screenshots, README rows, and the APK on Wednesday; Member 1 supports as lead                                                                |
| R7  | Different Flutter/Dart versions among members cause theme or API errors                                                          | Agree on one Flutter version (`flutter --version`) and note it in the README                                                                                  |
| R8  | Last-day failures (build or recording)                                                                                           | Internal cut-off at 18:00; record the video at least once on Wednesday as a backup                                                                            |
| R9  | README commands fail on a clean machine (−20 penalty)                                                                            | On Wednesday, clone the repo into a fresh folder and follow the README word for word (server, then `flutter run --dart-define=...`)                           |
| R10 | Zip contains `build/`, `.dart_tool/`, or `android/.gradle/`, or is missing required items                                        | Build the zip from the checklist in Section 8; check its size and contents before uploading                                                                   |
| R11 | The same task appears in Hari Ini and Tugas (both alive in `IndexedStack`), so `Hero(tag: 'task-<id>')` is duplicated and throws | Use `'task-<source>-<id>'` (4.2) and pass `heroTag` to `DetailPage`                                                                                           |

---

## 12. Open Decisions for the Team **[Proposed items to confirm]**

|  #  | Decision                        | Proposal                                                                       |
| :-: | :------------------------------ | :----------------------------------------------------------------------------- |
|  1  | Content of the **Hari Ini** tab | Unfinished tasks overdue / due in < 24 h (4.2)                                 |
|  2  | Persistence of "done" status    | Local override map in `TasksStore` (default); `PATCH` only if time allows (R3) |
|  3  | Shared state mechanism          | `TasksStore` (`ChangeNotifier`)                                                |
|  4  | Deadline time-of-day            | 23:59 on the selected date                                                     |
|  5  | Treatment of overdue tasks      | Badge "Terlambat", same style as the < 24 h badge                              |
|  6  | Date formatting                 | `intl` with `id_ID`                                                            |
|  7  | Seed-date freshness             | Edit before recording, or shift at server start                                |
|  8  | Font delivery                   | Bundle in `assets/fonts/` for offline demos                                    |
|  9  | UI language                     | Indonesian (as in the PRD tab names)                                           |

---

## Appendix A — Changes from v1

| Area        | Change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| :---------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Structure   | Added scope, goals, non-functional requirements, deliverables, timeline, collaboration rules, risks, and open decisions                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| Data & API  | Added `Jadwal` and `Profil` models, the seed JSON shape, status codes (`400`/`404`), error body, date/time and "< 24 h" rules, and sample payloads                                                                                                                                                                                                                                                                                                                                                                                                           |
| Gaps closed | Defined the **Hari Ini** tab; assigned ownership of `api_service.dart`, models, and `theme.dart`; clarified what `newTask` is; stated the Profile count summary is computed client-side                                                                                                                                                                                                                                                                                                                                                                      |
| Engineering | Added networking pitfalls (cleartext HTTP, INTERNET permission, server binding, physical-device URL); `http.Client` injection so the `MockClient` test is possible; constructor-based data passing for Widget Tests                                                                                                                                                                                                                                                                                                                                          |
| Integration | Identified the stale-tab and checkbox-reset problems (R2, R3) and proposed solutions                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Fixes       | Corrected "minimum 6 fields" wording (the model has 7); fixed the broken code fence in the directory tree; added `Design.md` and `profil.dart` to the structure; removed duplicated wording; added acceptance criteria per member                                                                                                                                                                                                                                                                                                                            |
| Preserved   | All rubric items P01–P07, signature features, bonuses, member slices, and the demo scenario are kept in substance                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| v2.1        | Cross-check with the official UTS brief: added the Hero bonus (+3); Detail now receives the model through its constructor (P05); explicit `await Navigator.push` in the Tugas screen; weights and penalties (6.1); README contents (NIM, one row per checkpoint); LMS packaging (zip exclusions, public/invited repo, video hosting, single uploader, per-member commits); extra Widget Test as safety margin; risks R9–R10                                                                                                                                  |
| v2.2        | **English naming convention:** files, folders, classes, methods, and branches renamed to English (`theme.dart`, `task_form/`, `tasks/`, `schedule/`, `profile/`, `TasksStore`, `TaskCard`, `DetailPage`, `createTask` / `fetchTasks` / `fetchTask` / `fetchSchedule` / `fetchProfile`); error body field `pesan` → `message`; Data Model (`Tugas`, `Jadwal`, `Profil`, JSON fields, values, REST paths, seed file) intentionally left in Indonesian; fixed references to non-existent `DESIGN_EN.md` (now `Design.md`)                                       |
| v2.3        | **Consistency fixes:** repaired corrupted characters in this appendix; removed the last Indonesian identifier (`dataBaru` → `newTask`); overdue tasks now get their own "Terlambat" badge and appear in Hari Ini (the "< 24 jam" text was wrong for them); Hero tag now `task-<source>-<id>` to avoid duplicate tags across `IndexedStack` tabs (R11); font decision: bundled Plus Jakarta Sans; `TasksStore` ownership defined; default for "done" persistence = local override; test file names and `assets/` layout added to the tree; `.gitignore` added |
