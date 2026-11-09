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
flutter run

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
