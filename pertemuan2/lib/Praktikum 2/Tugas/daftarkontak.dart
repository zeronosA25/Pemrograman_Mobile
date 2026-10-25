import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// 1. Model data Kontak
class Kontak {
  final String nama;
  final String telepon;
  final String email;
  const Kontak(this.nama, this.telepon, this.email);
}

// 1. List berisi minimal 6 objek kelas kontak
final List<Kontak> daftarKontak = const [
  Kontak('Aditya', '081234567890', 'aditya@student.ac.id'),
  Kontak('Depun', '081298765432', 'depun@email.com'),
  Kontak('Septiara', '085612345678', 'septiara@email.com'),
  Kontak('Oca', '081122334455', 'oca@email.com'),
  Kontak('Mitha', '089988776655', 'mitha@email.com'),
  Kontak('Alif', '087766554433', 'alif@email.com'),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Praktikum 2',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HalamanKontak(),
    );
  }
}

// 2. Halaman utama menampilkan daftar kontak
class HalamanKontak extends StatelessWidget {
  const HalamanKontak({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              // 3. Avatar berisi huruf pertama nama
              leading: CircleAvatar(
                child: Text(kontak.nama[0]),
              ),
              title: Text(kontak.nama),
              subtitle: Text(kontak.telepon),
              // 4. Mengetuk kontak membuka halaman detail
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailKontak(kontak: kontak)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// 4. Halaman detail yang menampilkan seluruh data kontak dan tombol kembali
class DetailKontak extends StatelessWidget {
  final Kontak kontak;
  const DetailKontak({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kontak.nama)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(kontak.nama[0], style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 24),
              Text('Nama: ${kontak.nama}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Telepon: ${kontak.telepon}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text('Email: ${kontak.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 32),
              ElevatedButton(
                // Tombol kembali
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}