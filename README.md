# Savora

Savora adalah aplikasi web pencatat keuangan pribadi untuk mahasiswa. Aplikasi
ini dipakai untuk mencatat pemasukan, pengeluaran, kategori transaksi, riwayat
transaksi, dan laporan bulanan sederhana.

Project ini dibuat untuk tugas besar Pemrograman Berorientasi Objek. Struktur
kodenya dipisah per layer supaya model, repository, service, session, utility,
screen, dan widget punya tanggung jawab masing-masing.

## Tech Stack

- Flutter
- Dart
- Hive dan hive_flutter untuk penyimpanan lokal
- crypto untuk hash password SHA-256
- intl untuk format Rupiah dan tanggal Indonesia
- setState untuk state management sederhana

Tidak ada backend, Firebase, database online, atau API eksternal. Semua data
disimpan lokal di browser/perangkat.

## Fitur

- Registrasi dan login user
- Akun demo bawaan
- Dashboard total pemasukan, pengeluaran, dan saldo
- Tambah, edit, hapus, dan lihat riwayat transaksi
- Filter transaksi berdasarkan tipe, kategori, bulan, dan tahun
- Manajemen kategori pemasukan dan pengeluaran
- Laporan bulanan
- Logout
- Tampilan responsif untuk desktop browser dan browser HP Android
- Data tetap tersimpan setelah aplikasi ditutup

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
