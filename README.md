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

### Opsi A: Menggunakan Emulator Android

Emulator Android menggunakan alamat loopback `10.0.2.2` untuk terhubung ke localhost mesin host (laptop/PC):

```powershell
flutter run --dart-define=API_URL=[http://10.0.2.2:8080](http://10.0.2.2:8080)

```

### Opsi B: Menggunakan Handphone Fisik (Wi-Fi yang Sama)

Pastikan laptop dan HP terhubung ke jaringan Wi-Fi yang sama. Cek IP lokal laptop Anda melalui PowerShell (`ipconfig`), lalu jalankan:

```powershell
# Ganti 192.168.x.x dengan alamat IPv4 laptop Anda
flutter run --dart-define=API_URL=[http://192.168.](http://192.168.)x.x:8080

```

_Alternatif Kabel USB:_ Jika menggunakan kabel USB dengan USB Debugging aktif:

```powershell
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=API_URL=http://localhost:8080

```

### Opsi C: Menggunakan Windows Desktop

Jika menguji langsung pada aplikasi desktop Windows:

```powershell
flutter run -d windows --dart-define=API_URL=http://localhost:8080

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

````

---

### Cara Cepat Membuat Kedua File di PowerShell Windows

Jalankan perintah berikut langsung dari direktori `tugasku_project`:

```powershell
# Membuat file kosong
New-Item -Path .gitignore -ItemType File
New-Item -Path README.md -ItemType File

````

Buka kedua file tersebut di VS Code atau Notepad, lalu tempel kode di atas.
