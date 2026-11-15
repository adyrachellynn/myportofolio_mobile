# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### TUGAS 7

1. Menurut saya, widget tree itu bisa dianggap sebagai susunan atau “pohon” dari semua widget yang membentuk tampilan aplikasi Flutter. Widget paling luar akan punya widget lain di dalamnya sebagai child. Misalnya, pada project ini `MaterialApp` membungkus `MyHomePage`, lalu di dalamnya ada `Scaffold`, `AppBar`, `Column`, sampai ke `InfoCard` dan `ItemCard`. Jadi, hubungan parent-child ini membuat setiap bagian tampilan punya posisi dan tugas yang jelas.

2. Widget yang saya gunakan pada project ini antara lain:
   - `MaterialApp` untuk pembungkus utama aplikasi dan pengaturan tema.
   - `MyHomePage` untuk halaman utama aplikasi.
   - `Scaffold` sebagai kerangka halaman, termasuk bagian app bar dan body.
   - `AppBar` untuk menampilkan judul MyPortfolio di bagian atas.
   - `Column` untuk menyusun isi halaman secara vertikal.
   - `Row` untuk menampilkan tiga kartu identitas secara sejajar.
   - `InfoCard` untuk menampilkan informasi NPM, nama, dan kelas saya.
   - `GridView.count` untuk menyusun tiga tombol aksi dalam bentuk grid.
   - `ItemCard` untuk membuat kartu tombol Lihat Proyek, Tambah Proyek, dan Logout.
   - `Material` untuk memberi warna dan bentuk pada masing-masing kartu aksi.
   - `InkWell` supaya kartu bisa ditekan dan memiliki efek interaksi.
   - `Icon` dan `Text` untuk menampilkan ikon serta tulisan pada kartu.
   - `SnackBar` untuk memberikan pesan setelah salah satu kartu ditekan.

3. `MaterialApp` berfungsi sebagai pembungkus utama aplikasi Flutter yang menggunakan Material Design. Widget ini mengatur hal-hal dasar seperti tema, warna, halaman awal, dan navigasi aplikasi. `MaterialApp` biasanya diletakkan sebagai root widget karena widget lain seperti `Scaffold`, `AppBar`, dan `SnackBar` membutuhkan konfigurasi Material agar bisa digunakan dengan baik.

4. Perbedaan utamanya ada pada state. `StatelessWidget` tidak punya data internal yang berubah-ubah, jadi tampilannya cenderung tetap setelah dibuat. Sementara itu, `StatefulWidget` punya state yang bisa berubah dan tampilannya dapat diperbarui menggunakan `setState()`. Pada tugas ini saya memakai `StatelessWidget` karena halaman utama hanya menampilkan informasi dan tombol. Kalau nanti ada fitur seperti form, data dari API, atau tombol yang mengubah tampilan halaman, saya akan menggunakan `StatefulWidget`.

5. `BuildContext` adalah informasi mengenai letak widget di dalam widget tree. Context penting karena Flutter menggunakannya untuk mencari widget atau data dari parent widget. Pada project ini, context digunakan di dalam method `build`, salah satunya pada `ScaffoldMessenger.of(context)` untuk menampilkan `SnackBar` saat tombol pada `ItemCard` ditekan.

6. Hot reload digunakan untuk menerapkan perubahan kode tanpa menutup aplikasi dan tanpa menghapus state yang sedang berjalan. Biasanya saya pakai hot reload kalau hanya mengubah tampilan, misalnya warna kartu, teks, icon, atau padding. Hot restart menjalankan ulang aplikasi dan menghapus state yang tersimpan. Sementara full restart berarti aplikasi dihentikan lalu dijalankan lagi dari awal. Hot reload tidak selalu cukup, misalnya saat mengubah bagian `main()`, menambah dependency, mengubah konfigurasi aplikasi, atau saat perubahan belum terlihat. Dalam kondisi seperti itu, saya perlu memakai hot restart atau full restart.

## AI Disclosure

Saya menggunakan ChatGPT dan Codex sebagai alat bantu selama mengerjakan Tugas 7. AI digunakan untuk membantu memahami materi Flutter dari Tutorial 08, mengecek kesesuaian checklist tugas, serta membantu saat saya mengalami kendala pada implementasi warna `ItemCard` dan README.

Contoh prompt yang saya gunakan:

> bantu cek dong implementasi kode warna setiap ItemCard sudah sesuai checklist Tugas 7 apa blm.”

Saya tetap meninjau perubahan kode, menjalankan aplikasi di Chrome, mencoba setiap tombol untuk memastikan SnackBar muncul, serta menjalankan `flutter analyze` hingga mendapatkan hasil `No issues found!`. Saya juga membandingkan hasil akhir dengan Tutorial 08 dan instruksi tugas sebelum melakukan commit.