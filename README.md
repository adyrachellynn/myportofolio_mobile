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


### TUGAS 8

#### Ringkasan Implementasi

Pada tugas ini, saya membuat halaman formulir Education untuk menambahkan data pendidikan atau sertifikasi.

Form Education dapat dibuka melalui kartu **Tambah Education** pada halaman utama dan menu **Add Education** pada drawer.

Form memiliki input nama pendidikan, institusi, tahun, kategori, deskripsi, serta URL gambar atau logo. Input wajib akan divalidasi sebelum data ditampilkan.

Setelah semua input valid, aplikasi akan menampilkan dialog berisi ringkasan data yang sudah dimasukkan.

Halaman utama juga menggunakan `GridView.count` agar empat kartu aksi tetap rapi dan tidak mengalami overflow.

#### Cara Menjalankan Aplikasi

Jalankan perintah berikut dari root folder project: :b

```bash
flutter pub get
flutter run -d chrome
flutter analyze
```

#### Pertanyaan Reflektif

1. `Navigator.push()` digunakan untuk membuka halaman baru tanpa menghapus halaman sebelumnya. Karena itu, pengguna masih bisa kembali menggunakan tombol back. `Navigator.pushReplacement()` digunakan untuk mengganti halaman saat ini dengan halaman baru. Sementara itu, `Navigator.pop()` digunakan untuk menutup halaman saat ini dan kembali ke halaman sebelumnya.

   Pada aplikasi saya, kartu Tambah Education menggunakan `Navigator.push()` agar pengguna dapat kembali ke Home. Menu Home pada drawer menggunakan `Navigator.pushReplacement()` agar halaman form diganti dengan halaman utama.

2. `Scaffold` digunakan sebagai struktur utama halaman karena dapat menampung `AppBar`, `Drawer`, dan isi halaman. `AppBar` membuat judul halaman terlihat konsisten. `Drawer` membantu pengguna berpindah halaman melalui menu navigasi yang sama.

   Contohnya, halaman Home dan halaman form Education sama-sama menggunakan warna indigo pada AppBar agar sesuai dengan tema portofolio.

3. Form disusun menggunakan `Column` agar semua input tersusun dari atas ke bawah. `Padding` dan `SizedBox` digunakan untuk memberi jarak antar-komponen agar form lebih rapi.

   Saya menggunakan `SingleChildScrollView` agar halaman tetap dapat di-scroll pada layar sempit atau saat keyboard muncul. Dengan begitu, tombol Simpan tetap dapat dijangkau pengguna.

4. `GlobalKey<FormState>` digunakan untuk mengakses state dari form. Setiap input memiliki `validator` untuk memeriksa data yang dimasukkan. Saat tombol Simpan ditekan, `validate()` akan menjalankan semua validator.

   Contohnya, field institusi yang hanya berisi spasi akan ditolak karena dianggap kosong. URL gambar yang tidak menggunakan `http` atau `https` juga akan ditolak. Jenis keyboard saja tidak cukup karena pengguna masih bisa memasukkan data yang tidak sesuai aturan.

#### Penggunaan AI

#### Penggunaan AI

Saya menggunakan ChatGPT dan Codex sebagai alat bantu untuk mengecek kesesuaian implementasi dengan Tutorial 09, terutama pada bagian navigasi, form, dan layout.

AI juga membantu memberi saran saat terjadi error overflow pada halaman utama. Setelah itu, saya tetap mengecek kembali kode, mengerjakan sesuai dengan tutorial, dan mencoba aplikasinya sendiri di Chrome.

Saya menguji form dari kartu dan drawer, mencoba input valid maupun tidak valid, lalu menjalankan `flutter analyze` untuk memastikan tidak ada masalah pada kode.

Contoh prompt yang digunakan:


- Jelaskan cara membuat halaman form baru di Flutter menggunakan `StatefulWidget`, `Form`, dan `GlobalKey<FormState>`.
- Bagaimana cara membuat validasi untuk input yang wajib diisi, input yang hanya berisi spasi, dan URL gambar?
- Jelaskan perbedaan penggunaan `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()` pada aplikasi Flutter.
- Bagaimana cara menggunakan `GridView.count` agar kartu pada halaman utama tersusun rapi saat jumlahnya bertambah?
- Jelaskan fungsi `SingleChildScrollView` pada halaman form Flutter.
