# Praktikum Pemrograman Mobile — Pertemuan 1

## Flutter Fundamental

**Pertemuan 1: Pengenalan Flutter, Instalasi, dan Aplikasi Pertama**

---

## 1. Tujuan Pembelajaran

Setelah menyelesaikan praktikum Pertemuan 1, mahasiswa diharapkan mampu:

1. Menjelaskan apa itu Flutter dan Dart serta perbedaannya dengan pengembangan native.
2. Memasang Flutter SDK, editor, serta emulator atau perangkat fisik.
3. Membuat dan menjalankan proyek Flutter pertama.
4. Memahami struktur folder proyek Flutter dan konsep dasar widget.
5. Memodifikasi tampilan antarmuka sederhana serta menggunakan fitur hot reload.

---

## 2. Alat dan Bahan

Peralatan yang digunakan dalam praktikum:

- Laptop dengan RAM minimal 8 GB.
- Ruang disk minimal 10 GB.
- Flutter SDK versi stabil.
- Android Studio atau Visual Studio Code.
- Extension Flutter dan Dart pada editor.
- Android Emulator atau HP Android.
- Mode Developer dan USB Debugging apabila menggunakan HP Android.
- Koneksi internet.

---

## 3. Teori Singkat

### 3.1 Flutter

Flutter adalah UI toolkit dari Google yang digunakan untuk membangun aplikasi mobile, web, dan desktop menggunakan satu basis kode.

Salah satu konsep penting dalam Flutter adalah penggunaan **widget**. Hampir semua elemen dalam aplikasi Flutter direpresentasikan sebagai widget, seperti:

- Text
- Button
- Icon
- Layout
- Scaffold
- Bahkan aplikasi itu sendiri

### 3.2 Dart

Dart adalah bahasa pemrograman yang digunakan oleh Flutter.

Flutter menggunakan Dart untuk membuat logika aplikasi, mengatur data, serta membangun tampilan menggunakan widget.

### 3.3 Widget

Widget merupakan komponen dasar dalam Flutter.

Contoh widget yang digunakan pada praktikum:

- `MaterialApp`
- `Scaffold`
- `AppBar`
- `Center`
- `Column`
- `Text`
- `Icon`
- `SizedBox`
- `FloatingActionButton`

Widget dapat disusun membentuk sebuah **widget tree**, yaitu struktur bertingkat yang menunjukkan hubungan antara widget satu dengan widget lainnya.

### 3.4 StatelessWidget

`StatelessWidget` adalah widget yang tampilannya tidak memiliki perubahan state internal selama widget tersebut digunakan.

Contohnya digunakan untuk membuat tampilan sederhana seperti halaman Hello Flutter.

### 3.5 StatefulWidget

`StatefulWidget` adalah widget yang memiliki state yang dapat berubah selama aplikasi berjalan.

Perubahan state dapat dilakukan menggunakan `setState()` sehingga Flutter membangun kembali bagian tampilan yang berkaitan dengan state tersebut.

Pada praktikum ini `StatefulWidget` digunakan untuk membuat aplikasi counter.

### 3.6 Hot Reload

Hot reload memungkinkan perubahan kode Dart ditampilkan pada aplikasi yang sedang berjalan tanpa harus melakukan restart penuh terhadap aplikasi.

Fitur ini sangat membantu ketika mengembangkan dan menguji antarmuka Flutter.

---

# 4. Langkah Praktikum

## Bagian A — Instalasi dan Verifikasi

Bagian pertama praktikum digunakan untuk memastikan lingkungan Flutter sudah siap digunakan.

### Langkah-langkah

1. Unduh Flutter SDK dari situs resmi Flutter.
2. Ekstrak Flutter SDK.
3. Tambahkan folder `flutter/bin` ke PATH.
4. Pasang Android Studio dan Android SDK.
5. Buat emulator melalui Device Manager atau gunakan perangkat Android fisik.
6. Pasang extension Flutter dan Dart pada editor.
7. Buka terminal.
8. Jalankan perintah berikut:

```bash
flutter doctor
```

Apabila diperlukan, terima lisensi Android dengan:

```bash
flutter doctor --android-licenses
```

### Tujuan `flutter doctor`

Perintah `flutter doctor` digunakan untuk melakukan pemeriksaan terhadap lingkungan pengembangan Flutter, termasuk Flutter SDK, Android toolchain, perangkat, dan komponen pendukung lainnya.

### Checkpoint

`flutter doctor` diharapkan menampilkan tanda centang hijau pada komponen utama yang diperlukan untuk pengembangan Flutter.

---

## Bagian B — Membuat Proyek Flutter Pertama

Setelah instalasi dan verifikasi selesai, langkah berikutnya adalah membuat proyek Flutter.

Gunakan perintah:

```bash
flutter create praktikum_1
```

Masuk ke folder proyek:

```bash
cd praktikum_1
```

Kemudian jalankan aplikasi:

```bash
flutter run
```

Pilih emulator atau perangkat yang tersedia apabila diminta.

Setelah proses selesai, aplikasi counter bawaan Flutter akan tampil.

### Checkpoint

Aplikasi counter berhasil berjalan dan tombol `+` dapat digunakan untuk menambah angka.

---

## Bagian C — Mengenal Struktur Proyek

Proyek Flutter memiliki beberapa folder dan file penting.

| Folder/File | Fungsi |
|---|---|
| `lib/main.dart` | Titik masuk aplikasi dan tempat utama penulisan kode Dart |
| `pubspec.yaml` | Konfigurasi proyek, dependensi, dan aset |
| `android/` | Kode dan konfigurasi platform Android |
| `ios/` | Kode dan konfigurasi platform iOS |
| `test/` | Berkas untuk pengujian |

File yang paling sering digunakan pada awal pembelajaran adalah:

```text
lib/main.dart
```

File tersebut digunakan sebagai tempat utama untuk membuat aplikasi Flutter yang sedang dipraktikkan.

---

# Bagian D — Aplikasi "Hello Flutter"

Bagian D digunakan untuk membuat aplikasi Flutter sederhana yang menampilkan teks.

Isi `lib/main.dart` diganti dengan aplikasi sederhana yang menggunakan:

- `MaterialApp`
- `Scaffold`
- `AppBar`
- `Center`
- `Text`

Struktur sederhananya dapat dipahami sebagai:

```text
MaterialApp
└── Scaffold
    ├── AppBar
    └── Center
        └── Text
```

Konsep tersebut disebut sebagai **widget tree**.

Contoh bagian utama:

```dart
MaterialApp(
  title: 'Praktikum 1',
  home: Scaffold(
    appBar: AppBar(
      title: const Text('Hello Flutter'),
    ),
    body: const Center(
      child: Text(
        'Halo, nama saya Ilham Firmansyah!',
        style: TextStyle(fontSize: 24),
      ),
    ),
  ),
)
```

Pada bagian ini, teks nama dapat disesuaikan dengan identitas mahasiswa.

### Hal yang dipelajari

Alur widget sederhana:

```text
MaterialApp
      ↓
   Scaffold
      ↓
 ┌────┴─────┐
AppBar    Body
            ↓
          Center
            ↓
           Text
```

Setelah kode disimpan, perubahan dapat diamati menggunakan hot reload.

---

# Bagian E — Widget Layout Dasar

Pada bagian ini tampilan dikembangkan menggunakan beberapa widget sekaligus.

`body` diubah menjadi `Center` yang memiliki `Column` sebagai child.

`Column` digunakan untuk menyusun beberapa widget secara vertikal.

Widget yang digunakan:

- `Center`
- `Column`
- `Icon`
- `SizedBox`
- `Text`

Struktur sederhananya:

```text
Center
└── Column
    ├── Icon
    ├── SizedBox
    ├── Text
    └── Text
```

Contoh:

```dart
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(
        Icons.flutter_dash,
        size: 80,
        color: Colors.blue,
      ),
      SizedBox(height: 16),
      Text(
        'Halo, nama saya Ilham Firmansyah!',
        style: TextStyle(fontSize: 24),
      ),
      Text('NIM: 20240801102'),
    ],
  ),
),
```

### Fungsi widget

#### `Center`

Digunakan untuk menempatkan child di tengah area yang tersedia.

#### `Column`

Digunakan untuk menyusun beberapa widget secara vertikal.

#### `mainAxisAlignment`

Pada `Column`, properti:

```dart
mainAxisAlignment: MainAxisAlignment.center
```

digunakan untuk menempatkan isi `Column` di bagian tengah pada sumbu utama.

#### `Icon`

Digunakan untuk menampilkan ikon.

#### `SizedBox`

Digunakan untuk memberikan jarak antar-widget.

#### `Text`

Digunakan untuk menampilkan teks.

### Checkpoint

Tampilan aplikasi menampilkan:

- Ikon Flutter.
- Nama mahasiswa.
- NIM.

Semua elemen tersebut tersusun vertikal dan berada di tengah layar.

---

# Bagian F — Widget Interaktif (`StatefulWidget`)

Bagian F memperkenalkan widget interaktif menggunakan `StatefulWidget`.

Pada bagian ini dibuat aplikasi **Counter Saya**.

Konsep utamanya adalah:

```text
StatefulWidget
      ↓
     State
      ↓
   _count
      ↓
  setState()
      ↓
 UI diperbarui
```

Contoh deklarasi widget:

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}
```

State dari halaman disimpan pada:

```dart
class _CounterPageState extends State<CounterPage> {
```

Kemudian dibuat variabel:

```dart
int _count = 0;
```

Variabel tersebut menyimpan angka counter.

Ketika tombol `+` ditekan, nilai `_count` bertambah melalui:

```dart
setState(() => _count++);
```

`setState()` digunakan agar Flutter mengetahui bahwa terdapat perubahan state sehingga tampilan perlu diperbarui.

### Komponen yang digunakan

- `StatefulWidget`
- `State`
- `Scaffold`
- `AppBar`
- `Center`
- `Text`
- `FloatingActionButton`
- `setState()`

### Checkpoint

Aplikasi memiliki halaman dengan judul:

```text
Counter Saya
```

Kemudian terdapat angka di tengah layar dan tombol `+`.

Setiap tombol `+` ditekan, angka bertambah.

---

# 5. Latihan Mandiri

Setelah menyelesaikan Bagian A sampai F, dilakukan beberapa latihan mandiri.

## Latihan 1 — Mengubah Warna

Ubah warna `AppBar` dan warna teks sesuai kebutuhan.

Properti yang dapat digunakan antara lain:

```dart
backgroundColor
```

dan:

```dart
color
```

Tujuan latihan ini adalah memahami penggunaan properti warna pada widget Flutter.

---

## Latihan 2 — Menambahkan Tombol Pengurang

Tambahkan tombol kedua menggunakan ikon:

```dart
Icons.remove
```

Tombol tersebut digunakan untuk mengurangi nilai counter.

Dengan demikian aplikasi memiliki dua operasi:

```text
+  → menambah angka
-  → mengurangi angka
```

---

## Latihan 3 — Menambahkan Tombol Reset

Tambahkan tombol reset yang mengembalikan nilai counter menjadi:

```text
0
```

Contoh logikanya:

```dart
setState(() {
  _count = 0;
});
```

---

## Latihan 4 — Mencegah Nilai Menjadi Negatif

Tambahkan kondisi agar nilai counter tidak dapat kurang dari `0`.

Contohnya:

```dart
if (_count > 0) {
  _count--;
}
```

Dengan demikian:

```text
0 → tidak dapat menjadi -1
1 → dapat menjadi 0
2 → dapat menjadi 1
```

---

# 6. Tugas

## Aplikasi "Kartu Perkenalan"

Buat sebuah aplikasi **Kartu Perkenalan** dalam satu halaman.

Aplikasi harus menampilkan:

- Foto atau ikon.
- Nama.
- NIM.
- Jurusan.
- Hobi.

Widget yang digunakan:

- `Column`
- `Text`
- `Icon`
- `SizedBox`

### Konsep tampilan

Contoh struktur:

```text
Column
├── Icon / Foto
├── SizedBox
├── Nama
├── NIM
├── Jurusan
└── Hobi
```

### Pengumpulan

Tugas dikumpulkan dalam bentuk:

1. Tangkapan layar aplikasi yang sedang berjalan.
2. Tautan repository GitHub atau berkas `main.dart`.

---

# 7. Rubrik Penilaian

Penilaian pada praktikum Pertemuan 1:

| Komponen | Bobot |
|---|---:|
| Instalasi berhasil (`flutter doctor`) | 20% |
| Checkpoint Bagian B–F selesai | 40% |
| Latihan mandiri | 20% |
| Tugas Kartu Perkenalan | 20% |
| **Total** | **100%** |

---

# 8. Pertanyaan Refleksi

Setelah menyelesaikan praktikum, pahami dan jawab pertanyaan berikut.

### 1. Apa perbedaan `StatelessWidget` dan `StatefulWidget`?

`StatelessWidget` digunakan untuk widget yang tidak mengalami perubahan state internal, sedangkan `StatefulWidget` memiliki state yang dapat berubah selama aplikasi berjalan.

### 2. Mengapa perubahan variabel `_count` perlu dibungkus `setState()`?

Karena `setState()` memberitahukan Flutter bahwa state telah berubah sehingga tampilan yang berkaitan dengan state tersebut perlu diperbarui.

### 3. Apa keuntungan hot reload dibanding rebuild penuh?

Hot reload memungkinkan perubahan kode ditampilkan pada aplikasi yang sedang berjalan tanpa melakukan restart aplikasi secara penuh sehingga proses pengembangan dan pengujian menjadi lebih cepat.

---

# 9. Troubleshooting Umum

| Masalah | Solusi |
|---|---|
| `flutter` tidak dikenali | Periksa PATH dan buka kembali terminal |
| Lisensi Android belum diterima | Jalankan `flutter doctor --android-licenses` |
| Emulator lambat | Aktifkan virtualisasi seperti VT-x/AMD-V pada BIOS |
| Perangkat tidak terdeteksi | Aktifkan USB debugging dan periksa dengan `flutter devices` |

### Perintah yang berguna

Memeriksa instalasi Flutter:

```bash
flutter doctor
```

Memeriksa perangkat:

```bash
flutter devices
```

Menerima lisensi Android:

```bash
flutter doctor --android-licenses
```

Menjalankan aplikasi:

```bash
flutter run
```

---

# 10. Referensi

- Dokumentasi resmi Flutter: https://docs.flutter.dev
- Dart Language Tour: https://dart.dev/language
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets

---

# Ringkasan Pertemuan 1

Pada Pertemuan 1 dipelajari dasar-dasar Flutter, mulai dari instalasi dan verifikasi lingkungan pengembangan sampai membuat aplikasi Flutter sederhana.

Materi utama yang dipelajari:

1. Pengenalan Flutter dan Dart.
2. Konsep widget.
3. Perbedaan `StatelessWidget` dan `StatefulWidget`.
4. Instalasi dan verifikasi Flutter.
5. Pembuatan proyek Flutter pertama.
6. Struktur proyek Flutter.
7. Pembuatan aplikasi Hello Flutter.
8. Penggunaan `Center` dan `Column`.
9. Penggunaan `Icon`, `Text`, dan `SizedBox`.
10. Penggunaan state pada `StatefulWidget`.
11. Penggunaan `setState()`.
12. Penggunaan hot reload.
13. Pembuatan aplikasi counter.
14. Modifikasi counter melalui latihan mandiri.
15. Pembuatan aplikasi Kartu Perkenalan sebagai tugas.

---

# Catatan Praktikum

Project Flutter pada Pertemuan 1 digunakan untuk mempraktikkan materi dan latihan yang terdapat pada modul.

Struktur dokumentasi repository:

```text
pertemuan-1/
├── README.md
├── doc-tugas/
├── praktikum/
└── tugas/
```

`README.md` ini berfungsi sebagai catatan materi dan pembelajaran Pertemuan 1, sedangkan dokumentasi kode dan langkah praktikum disimpan pada folder `praktikum/`.