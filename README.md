# Tugasku - Panduan Menjalankan Proyek

Panduan langkah demi langkah untuk menjalankan backend REST API (Dart Shelf) dan client mobile (Flutter).

---

## 1. Menjalankan Server Backend (Dart Shelf)

Buka terminal (PowerShell / Command Prompt), lalu arahkan ke folder `server`:

```powershell
# Masuk ke direktori server
cd server

# Unduh dependensi shelf
dart pub get

# Jalankan server API
dart run bin/server.dart

```

> **Verifikasi:** Server aktif dan siap menerima request jika muncul pesan:
> `Server berjalan di port :8080` (Akses tes di browser: `http://localhost:8080/tugas`).

---

## 2. Menjalankan Aplikasi Flutter

Buka jendela terminal baru (jangan tutup terminal server), lalu arahkan ke folder `app`:

```powershell
# Masuk ke direktori aplikasi Flutter
cd app

# Unduh dependensi Flutter
flutter pub get

```

Jalankan perintah berikut sesuai perangkat target yang digunakan:
> Pastikan emulator android / HP sudah tersambung

```powershell
# Emulator Android default
flutter run --dart-define=API_URL=http://10.0.2.2:8080

# Atau perangkat fisik / desktop
flutter run --dart-define=API_URL=http://localhost:8080
```

---

## 3. Menjalankan Pengujian (Testing) & Analisis Kode

Jalankan perintah berikut di dalam direktori `app`:

- **Pemeriksaan Kualitas Kode (Analyze):**

```powershell
flutter analyze
```

- **Menjalankan Seluruh Unit & Widget Test:**

```powershell
flutter test
```

---

## 4. Pembagian Tugas Anggota Kelompok

| Anggota | Endpoint Server (Dart Shelf) | Layar / UI Flutter | Jenis Automated Test |
| :--- | :--- | :--- | :--- |
| **Anggota 1** | `POST /tugas` | Form Tambah Tugas + DatePicker | 1 Widget Test (Form) |
| **Anggota 2** | `GET /tugas` | Tab Tugas & Hari Ini (List + Checkbox) | 1 Widget Test (Card/List) |
| **Anggota 3** | `GET /tugas/<id>` | Halaman Detail Tugas | 1 Widget Test (Detail) |
| **Anggota 4** | `GET /jadwal` | Tab Jadwal (Kelompok per hari) | 1 MockClient Service Test |
| **Anggota 5** | `GET /profil` | Tab Profil + Root NavigationBar (4 Tab) | Integrasi & QA Test |

---

## 5. Tabel Pemenuhan Fitur (Rubrik UTS P01–P07)

| Poin | File:baris | Keterangan |
| :--- | :--- | :--- |
| **P01 & P02** Project & Launcher | `app/pubspec.yaml:1`, `app/lib/main.dart:18` | Nama aplikasi Tugasku, package id.ac.telkomuniversity.tugasku |
| **P03** Widget dasar & input | `app/lib/ui/task_form/task_form_page.dart:141` | TextField, TextEditingController.dispose, SegmentedButton, SnackBar |
| **P04** Model & Navigasi Bawah | `app/lib/ui/root_navigation.dart:73` | NavigationBar 4 tab (Hari Ini, Tugas, Jadwal, Profil) & IndexedStack |
| **P04** Model Data | `app/lib/data/models/tugas.dart:1` | Model Tugas 7 field termasuk DateTime tenggat dan bool selesai |
| **P05** Navigasi & Result Pop | `app/lib/ui/task_form/task_form_page.dart:108` | Navigator.pop(context, createdTask) dengan async/await & mounted check |
| **P05** Widget Tests | `app/test/root_navigation_test.dart:40`, `app/test/profile_page_test.dart:58` | Widget tests lulus uji navigasi 4 tab & render profil |
| **P06** Tema Material 3 & Aset | `app/lib/theme.dart:11`, `app/pubspec.yaml:26` | ColorScheme.fromSeed (Light & Dark), font PlusJakartaSans, aset avatar.png |
| **P07** Server Dart Shelf | `server/bin/server.dart:97` | Server Shelf & Router, data awal 12 item JSON, endpoint GET /profil |
| **P07** FutureBuilder 3 State | `app/lib/ui/profile/profile_page.dart:55` | Menangani kondisi memuat (loading), gagal (error + tombol Coba lagi), dan sukses |
| **P07** Membaca API_URL | `app/lib/data/services/api_service.dart:23` | Mengambil base URL dari String.fromEnvironment('API_URL') |

