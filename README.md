# Savora

Savora adalah aplikasi web pencatat keuangan pribadi untuk mahasiswa. Aplikasi
ini dibuat untuk tugas besar Pemrograman Berorientasi Objek (PBO) dengan fokus pada
structure kode yang clean dan maintainable.

Di mata kuliah PBO, kami belajar tentang abstraksi, inheritance, encapsulation, dan
polymorphism. Savora adalah aplikasi nyata yang mengaplikasikan konsep-konsep tersebut.
Alih-alih membuat kode yang monolithic, kami split logic ke dalam layer:
**model, repository, service, session, utility, screen, dan widget**.
Setiap layer punya tanggung jawab sendiri (Single Responsibility Principle).

### Motivasi

Saya ingin membuat aplikasi yang:
- Mudah di-maintain dan di-extend
- Bisa offline (tidak perlu internet)
- Sederhana tapi tidak over-engineered
- Bisa diakses dari desktop dan mobile browser

## Tech Stack

- **Flutter & Dart** - Framework cross-platform, compiled to web
- **Hive & hive_flutter** - NoSQL database lokal yang cepat
- **crypto** - Hash password SHA-256 untuk security
- **intl** - Format mata uang dan tanggal sesuai lokale Indonesia
- **setState** - Simple state management (no BLoC/Provider complexity)

Tanpa backend, Firebase, atau API eksternal. Semua data disimpan lokal di browser.

## Fitur

- ✅ Registrasi dan login user
- ✅ Akun demo bawaan (username: `demo`, password: `demo`)
- ✅ Dashboard dengan ringkasan pemasukan, pengeluaran, dan saldo
- ✅ Tambah, edit, hapus, dan lihat riwayat transaksi
- ✅ Filter transaksi by type, kategori, bulan, tahun
- ✅ Manajemen kategori pemasukan dan pengeluaran
- ✅ Laporan bulanan dengan breakdown
- ✅ Logout & session management
- ✅ Responsive design untuk desktop dan mobile
- ✅ Data persistent (tersimpan setelah tutup app)

### Demo Account

Sudah ada akun demo yang bisa langsung dicoba:
- **Username:** `demo`
- **Password:** `demo`

## Challenge & Lessons Learned

### Offline-First Architecture

Awalnya saya pikir perlu backend untuk skalabilitas. Tapi untuk konteks tugas besar
PBO, offline-first lebih sederhana dan masih cukup powerful. Hive adalah NoSQL database
yang cepat dan mudah dipelajari untuk mahasiswa.

### State Management

Saya gunakan `setState` yang simple daripada BLoC/Provider. Alasannya:
- Ini tugas besar, bukan production app
- Perlu mudah dipahami pas presentasi/review dosen
- Scope kompleksitas sudah cukup dengan layering architecture

Kalau nanti scale up, bisa refactor ke Provider atau GetX tanpa perlu ubah banyak.

### Security Concerns

Password disimpan dengan SHA-256 hash, bukan plaintext. Walau aplikasi offline,
tetap perlu encrypt data. Kalau user lupa password, mereka harus clear browser cache
dan registrasi ulang (tradeoff offline storage).

### Responsive Design Challenge

Flutter web rendering di desktop vs mobile sangat berbeda. Sempat struggle dengan
layout yang harus responsive tanpa library khusus. Akhirnya pakai `MediaQuery` untuk
detect screen width dan adjust layout accordingly.

## Struktur Folder

```text
savora/
|-- README.md
|-- pubspec.yaml
|-- lib/
|   |-- main.dart
|   |-- app.dart
|   |-- models/
|   |-- repositories/
|   |-- services/
|   |-- session/
|   |-- utils/
|   |-- screens/
|   `-- widgets/
|-- test/
`-- web/
```

Ringkasan tanggung jawab:

- models: representasi data dan serialisasi Map untuk Hive
- repositories: akses data lokal dan operasi CRUD
- services: logika bisnis seperti login, register, dan perhitungan keuangan
- session: menyimpan user yang sedang login selama aplikasi berjalan
- utils: helper format Rupiah, tanggal, hash password, dan id
- screens: halaman utama aplikasi
- widgets: komponen UI yang dipakai ulang

## Cara Menjalankan

Masuk ke folder project:

```bash
cd savora
```

Install dependency:

```bash
flutter pub get
```

Jalankan di browser:

```bash
flutter run -d chrome
```

Untuk dicoba dari browser HP Android, jalankan web server Flutter:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Lalu buka alamat komputer/laptop dari browser HP, misalnya:

```text
http://192.168.1.10:8080
```

Pastikan laptop dan HP berada di jaringan Wi-Fi yang sama.

## Akun Default

```text
Username: admin
Password: admin123
```

Password disimpan sebagai hash SHA-256, bukan teks asli.

## Konfigurasi Untuk LMS

Savora tidak memakai RDBMS seperti MySQL/PostgreSQL dan tidak memakai backend.
Data aplikasi disimpan secara lokal di browser menggunakan Hive, jadi tidak ada
file export database `.sql` yang perlu dilampirkan.

Konfigurasi yang perlu diketahui:

- Jalankan dari folder `savora`
- Install dependency dengan `flutter pub get`
- Jalankan di browser dengan `flutter run -d chrome`
- Untuk build deploy web gunakan `flutter build web --pwa-strategy=none`
- Hasil build web berada di folder `build/web`

Akun untuk mencoba aplikasi:

```text
Role: User / Mahasiswa
Username: admin
Password: admin123
```

## Kategori Default

Pemasukan:

- Uang Saku
- Beasiswa
- Kerja Sampingan
- Lainnya

Pengeluaran:

- Makan
- Transportasi
- Kuliah
- Hiburan
- Belanja
- Lainnya

## Catatan Penyimpanan

Savora memakai Hive sebagai penyimpanan lokal browser. Data bisa berbeda antara
browser laptop dan browser HP karena masing-masing punya storage sendiri.
Aplikasi tidak memakai auto-login permanen, jadi user perlu login lagi setelah
aplikasi dibuka ulang.
