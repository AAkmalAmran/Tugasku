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


---

## 4. Tabel Pemenuhan Rubrik UTS (Anggota 3)

| Poin Rubrik | File:baris | Keterangan |
| :--- | :--- | :--- |
| **P05** Halaman Detail Tugas | `app/lib/ui/detail/detail_page.dart:13` | Menampilkan seluruh data atribut tugas (judul, mata kuliah, prioritas, tenggat, status, catatan) |
| **P05** Tombol Interaktif Ubah Status | `app/lib/ui/detail/detail_page.dart:88` | Interaksi toggle status selesai (Checkbox & `FilledButton.tonal`) + SnackBar konfirmasi |
| **P05** Widget Test Member 3 | `app/test/detail_page_test.dart:36` | 3 widget test untuk DetailPage (render atribut & badge, toggle status, mock fetch) |
| **P07** Endpoint `GET /tugas/<id>` | `server/bin/server.dart:86` | Mengembalikan 200 OK jika ditemukan, 404 jika tidak ada, 400 jika ID bukan integer |
| **P07** Client REST Service | `app/lib/data/services/api_service.dart:75` | Method `fetchTask(int id)` untuk konsumsi REST API |
| **Signature** Badge Deadline < 24 Jam & Terlambat | `app/lib/ui/detail/detail_page.dart:121` | Badge indikator jika sisa tenggat < 24 jam atau jika sudah terlambat |
| **Bonus (+3)** Hero Animation | `app/lib/ui/detail/detail_page.dart:259` | Animasi transisi `Hero` judul tugas ke halaman detail |
