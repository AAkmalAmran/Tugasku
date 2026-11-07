# Product Requirements Document (PRD)

## Proyek 6: Tugasku — Jadwal Kuliah dan Pengingat Tugas

| Informasi Proyek        | Detail                                                          |
| :---------------------- | :-------------------------------------------------------------- |
| **Mata Kuliah**         | Pengembangan Aplikasi Bergerak (BBK4DBB3)                       |
| **Kelompok**            | Kelompok 03                                                     |
| **Tema Proyek**         | Proyek 6 — Tugasku (Asisten Akademik Pribadi)                   |
| **Package / Org ID**    | `id.ac.telkomuniversity.tugasku`                                |
| **Tech Stack**          | Flutter (Material 3) & Dart REST API (`shelf` + `shelf_router`) |
| **Tenggat Pengumpulan** | Kamis, 12 November 2026 pukul 23.59 WIB                         |

---

## 1. Visi & Deskripsi Produk

**Tugasku** adalah aplikasi asisten akademik pribadi berbasis Android yang membantu mahasiswa mengelola daftar tugas kuliah, memantau tenggat waktu (_deadline_), dan melihat jadwal perkuliahan mingguan secara terstruktur. Aplikasi ini terhubung ke server REST API lokal berbasis Dart Shelf dan mendukung tema terang (_light mode_) serta gelap (_dark mode_) Material 3.

---

## 2. Spesifikasi Teknis & Arsitektur

### 2.1 Standar Proyek Flutter (`app/`)

- **Inisialisasi:** Dibuat menggunakan `flutter create --org id.ac.telkomuniversity --project-name tugasku app` (bukan `com.example`).
- **Identitas Aplikasi:** Nama aplikasi pada launcher adalah **Tugasku**, dilengkapi ikon kustom via `flutter_launcher_icons`, font kustom (`google_fonts` atau `assets/fonts/`), dan minimal 1 gambar aset lokal di `pubspec.yaml`.
- **Tema Material 3:** Menggunakan `ThemeData` dengan `ColorScheme.fromSeed` untuk mode terang (`theme`) dan gelap (`darkTheme`). Seluruh komponen wajib mengambil warna dari `Theme.of(context).colorScheme`.
- **Konsumsi API:** Menggunakan paket `http` dengan alamat dasar server yang dibaca secara dinamis melalui `--dart-define=API_URL=...` (default emulator: `http://10.0.2.2:8080`).
- **Kualitas Kode:** `flutter analyze` wajib bersih (**0 error, 0 warning**).

### 2.2 Standar Backend Server (`server/`)

- **Framework:** Dart menggunakan pustaka `shelf` dan `shelf_router`.
- **Sumber Data Awal:** Berkas `server/data/tugasku.json` yang memuat minimal **12 item** data tugas awal, data jadwal kuliah 1 minggu, dan data profil.

### 2.3 Struktur Direktori Repositori

```text
tugasku_project/
├─ app/                        # Proyek Aplikasi Flutter
│  ├─ assets/                  # Gambar lokal & font
│  ├─ lib/
│  │  ├─ data/
│  │  │  ├─ models/            # tugas.dart, jadwal.dart
│  │  │  └─ services/          # api_service.dart
│  │  ├─ ui/
│  │  │  ├─ root_navigation.dart
│  │  │  ├─ form_tambah/       # Fitur Anggota 1
│  │  │  ├─ tugas/             # Fitur Anggota 2
│  │  │  ├─ detail/            # Fitur Anggota 3
│  │  │  ├─ jadwal/            # Fitur Anggota 4
│  │  │  └─ profil/            # Fitur Anggota 5
│  │  ├─ tema.dart             # Konfigurasi Material 3
│  │  └─ main.dart             # Entry point aplikasi
│  ├─ test/                    # ≥ 3 Widget Test + 1 MockClient Test
│  └─ pubspec.yaml
├─ server/                     # Server REST API Dart Shelf
│  ├─ bin/server.dart
│  ├─ data/tugasku.json        # Dataset awal (≥ 12 item tugas)
│  └─ pubspec.yaml
├─ screenshots/                # ≥ 4 tangkapan layar dari perangkat/emulator
├─ PRD.md                      # Dokumen spesifikasi produk ini
└─ README.md                   # Panduan run, daftar anggota, & tabel fitur

```

---

## 3. Spesifikasi Model Data & Kontrak API

### 3.1 Model Utama: `Tugas`

Wajib memiliki minimal 6 _field_ (termasuk `DateTime` dan `bool`) serta metode `fromJson` dan `toJson`:

| Field        | Tipe Data  | Keterangan                                           |
| ------------ | ---------- | ---------------------------------------------------- |
| `id`         | `int`      | ID unik tugas                                        |
| `judul`      | `String`   | Nama atau judul tugas                                |
| `mataKuliah` | `String`   | Nama mata kuliah terkait                             |
| `prioritas`  | `String`   | Tingkat prioritas: `Rendah`, `Sedang`, atau `Tinggi` |
| `tenggat`    | `DateTime` | Waktu batas pengumpulan (ISO-8601 string di JSON)    |
| `selesai`    | `bool`     | Status penyelesaian tugas (`true` / `false`)         |
| `catatan`    | `String`   | Rincian atau deskripsi tambahan tugas                |

### 3.2 Daftar Endpoint REST API (`server/bin/server.dart`)

| Method   | Endpoint      | PIC       | Deskripsi & Respons                                                                                                    |
| -------- | ------------- | --------- | ---------------------------------------------------------------------------------------------------------------------- |
| **POST** | `/tugas`      | Anggota 1 | Menerima payload JSON tugas baru, memberi `id` unik, menyimpan ke list server, dan mengembalikan status `201 Created`. |
| **GET**  | `/tugas`      | Anggota 2 | Mengembalikan seluruh daftar tugas (`200 OK` - JSON Array).                                                            |
| **GET**  | `/tugas/<id>` | Anggota 3 | Mengembalikan detail 1 tugas berdasarkan `id` (`200 OK` atau `404 Not Found`).                                         |
| **GET**  | `/jadwal`     | Anggota 4 | **[Endpoint Khas]** Mengembalikan daftar jadwal kuliah selama 1 minggu (`200 OK`).                                     |
| **GET**  | `/profil`     | Anggota 5 | Mengembalikan informasi profil mahasiswa dan ringkasan akademik (`200 OK`).                                            |

---

## 4. Kebutuhan Fungsional & Pembagian Tugas (Feature Slice)

Setiap anggota bertanggung jawab penuh secara vertikal atas **1 Endpoint Backend**, **1 Modul Tampilan (UI)**, dan **Pengujian (Testing)**.

### 4.1 Anggota 1 (Project Lead): Inisiasi, `POST /tugas`, & Form Tambah Tugas

- **Backend:** Mengimplementasikan endpoint `POST /tugas` untuk menyimpan tugas baru ke server (**Nilai Tambah +5**).
- **Frontend (`lib/ui/form_tambah/`):**
- Membangun halaman Form Tambah Tugas berisi input: `judul`, `mataKuliah`, `prioritas`, `tenggat`, dan `catatan`.
- Menggunakan `TextField` dengan `TextEditingController` yang wajib di-`dispose()` dengan benar.
- Menggunakan `ChoiceChip` / `SegmentedButton` untuk memilih prioritas (`Rendah`, `Sedang`, `Tinggi`).
- Mengintegrasikan `showDatePicker` untuk memilih tanggal tenggat waktu.
- Menyediakan minimal 2 jenis tombol Material 3 (`FilledButton` untuk Simpan, `OutlinedButton` untuk Batal).
- Mengirim data ke server via `POST`, memeriksa `if (!mounted) return;` setelah `await`, menampilkan `SnackBar` konfirmasi, dan kembali ke layar sebelumnya dengan `Navigator.pop(context, dataBaru)`.

- **Testing:** 1 Widget Test untuk menguji input form dan validasi tombol simpan.

### 4.2 Anggota 2: `GET /tugas`, Tab Hari Ini & Tab Tugas, serta Fitur Khas

- **Backend:** Mengimplementasikan endpoint `GET /tugas` dengan minimal 12 data awal di `tugasku.json`.
- **Frontend (`lib/ui/tugas/`):**
- Menampilkan daftar tugas menggunakan `FutureBuilder` yang menangani 3 keadaan secara eksplisit: **Memuat (_loading_)**, **Gagal (_error_)** disertai tombol _Coba lagi_, dan **Berhasil**.
- Merender daftar menggunakan `ListView.builder`.
- Membuat widget kartu tugas kustom (`StatelessWidget`/`StatefulWidget`) yang memadukan `Row`, `Column`, `Expanded`, dan `Stack`.
- **Fitur Khas 1:** Komponen `Checkbox` interaktif dengan `setState` untuk menandai tugas selesai.
- **Fitur Khas 2:** Teks judul tugas otomatis dicoret (`TextDecoration.lineThrough`) jika `selesai == true`.
- **Fitur Khas 3:** Menampilkan penanda/lencana visual khusus (di dalam `Stack`) apabila tenggat tugas kurang dari 24 jam dari waktu sekarang.
- **Filter/Interaksi:** Menyediakan `FilterChip` atau `ChoiceChip` untuk memfilter prioritas/status tugas serta umpan balik `SnackBar` saat status berubah.
- **Nilai Tambah (+2):** Membungkus daftar dengan `RefreshIndicator` untuk fitur _Pull-to-refresh_.

- **Testing:** 1 Widget Test untuk menguji render kartu tugas, interaksi checkbox, dan penanda tenggat < 24 jam.

### 4.3 Anggota 3: `GET /tugas/<id>` & Halaman Detail Tugas

- **Backend:** Mengimplementasikan endpoint `GET /tugas/<id>` untuk mengambil satu tugas spesifik.
- **Frontend (`lib/ui/detail/`):**
- Membangun Halaman Detail Tugas yang dibuka melalui `Navigator.push` saat kartu tugas diketuk.
- Menampilkan seluruh atribut tugas secara lengkap (judul, mata kuliah, prioritas, tenggat waktu terformat, status selesai, dan catatan lengkap).
- Menyediakan tombol aksi Material 3 (misal `FilledButton` / `IconButton`) untuk mengubah status selesai atau kembali ke daftar.

- **Testing:** 1 Widget Test untuk memverifikasi Halaman Detail berhasil merender informasi tugas dengan benar.

### 4.4 Anggota 4: `GET /jadwal` (Endpoint Khas) & Tab Jadwal Kuliah

- **Backend:** Mengimplementasikan endpoint khas `GET /jadwal` yang menyajikan data jadwal kuliah satu minggu.
- **Frontend (`lib/ui/jadwal/`):**
- Mengonsumsi data dari `GET /jadwal` menggunakan `FutureBuilder` (lengkap dengan 3 keadaan: _loading_, _error_ + tombol _Coba lagi_, dan _berhasil_).
- **Fitur Khas 4:** Mengelompokkan tampilan jadwal kuliah per hari (Senin s.d. Jumat/Sabtu) menggunakan `ListView.builder`, menampilkan nama mata kuliah, jam mulai–selesai, dan kode ruangan.

- **Testing:** 1 Unit/Service Test menggunakan `MockClient` (`package:http/testing.dart`) untuk menguji pengambilan & parsing data API tanpa server sungguhan.

### 4.5 Anggota 5: `GET /profil`, Navigasi Utama (`NavigationBar`), Aset & Deliverables

- **Backend:** Mengimplementasikan endpoint `GET /profil` untuk data identitas mahasiswa.
- **Frontend (`lib/ui/root_navigation.dart` & `lib/ui/profil/`):**
- Membangun kerangka navigasi bawah menggunakan `NavigationBar` Material 3 dan `IndexedStack` dengan **4 tab wajib**: **Hari Ini**, **Tugas**, **Jadwal**, dan **Profil**.
- Membangun **Tab Profil** yang memuat gambar aset lokal (logo/avatar yang terdaftar di `pubspec.yaml`), identitas mahasiswa, serta ringkasan jumlah tugas.

- **Konfigurasi Visual & QA:**
- Mengonfigurasi `flutter_launcher_icons` dan font kustom.
- Memastikan seluruh fitur terintegrasi, `flutter analyze` menghasilkan 0 issue, dan seluruh test lulus.
- Mengambil minimal 4 tangkapan layar aplikasi di folder `screenshots/`, melengkapi tabel pemenuhan fitur (`File:baris`) di `README.md`, mem-build `APK debug`, dan menyiapkan video demo 3–5 menit.

---

## 5. Daftar Periksa Pemenuhan Rubrik UTS (Checklist P01–P07)

| Kode        | Kriteria Wajib                                                                                                                                                                               | Status | PIC             |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | --------------- |
| **P01–P02** | Organisasi `id.ac.telkomuniversity`, nama launcher sesuai tema, ≥ 4 screenshot perangkat, `flutter analyze` bersih (0 error/warning)                                                         | [ ]    | Anggota 1 & 5   |
| **P03**     | `StatelessWidget` & `StatefulWidget` + `setState`, `TextField` + `TextEditingController.dispose()`, ≥ 2 jenis tombol M3, `ChoiceChip`/`FilterChip`/`SegmentedButton`, `SnackBar`             | [ ]    | Anggota 1 & 2   |
| **P04**     | Model `Tugas` ≥ 6 field (ada `DateTime` & `bool`), kartu kustom (`Row`, `Column`, `Expanded`, `Stack`), `ListView.builder`, `NavigationBar` 4 tab + `IndexedStack`                           | [ ]    | Anggota 2 & 5   |
| **P05**     | Halaman Detail, Form Tambah + hasil tampil di daftar, `showDatePicker`, `async`/`await` + cek `mounted`, ≥ 3 Widget Test                                                                     | [ ]    | Anggota 1, 2, 3 |
| **P06**     | `ThemeData` + `ColorScheme.fromSeed` (Light & Dark mode), warna dari `colorScheme`, font kustom, `flutter_launcher_icons`, ≥ 1 gambar aset lokal                                             | [ ]    | Anggota 1 & 5   |
| **P07**     | Server Dart Shelf (`≥ 12` item JSON), ≥ 3 endpoint `GET`, paket `http` + `--dart-define=API_URL`, `fromJson`/`toJson`, `FutureBuilder` 3 keadaan + tombol _Coba lagi_, ≥ 1 test `MockClient` | [ ]    | Seluruh Tim     |
| **Khas**    | Checkbox selesai, teks dicoret, penanda tenggat < 24 jam, tab Jadwal dikelompokkan per hari, endpoint `GET /jadwal`                                                                          | [ ]    | Anggota 2 & 4   |
| **Bonus**   | Pengiriman form tambah ke server via `POST /tugas` (+5) & _Pull-to-refresh_ (+2)                                                                                                             | [ ]    | Anggota 1 & 2   |

---

## 6. Skenario Wajib Video Demo (3–5 Menit)

1. Menjalankan server Dart Shelf di terminal (`dart run bin/server.dart`).

2. Menjalankan aplikasi Flutter dan memperlihatkan proses pemuatan data awal dari server.

3. Mematikan server untuk mendemonstrasikan tampilan **Keadaan Gagal (_Error State_)**, menyalakan server kembali, lalu menekan tombol **Coba lagi** hingga data berhasil dimuat.

4. Menjelajahi keempat tab (`Hari Ini`, `Tugas`, `Jadwal` per hari, dan `Profil`) serta fitur khas (mencentang `Checkbox` hingga teks tercoret dan melihat indikator tugas `< 24 jam`).

5. Mengetuk salah satu kartu tugas untuk membuka **Halaman Detail Tugas**.

6. Membuka **Form Tambah Tugas**, memilih tanggal lewat `DatePicker`, menyimpan tugas baru via `POST`, hingga tugas tersebut muncul di daftar utama.

7. Menampilkan hasil eksekusi `flutter test` dan `flutter analyze` di terminal yang lulus tanpa error.
