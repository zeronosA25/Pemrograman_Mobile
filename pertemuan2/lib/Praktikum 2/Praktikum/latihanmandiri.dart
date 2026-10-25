import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// 4. Fungsi buatan sendiri untuk memformat harga menjadi ribuan
String formatRibuan(int angka) {
  String strAngka = angka.toString();
  String hasil = '';
  int hitung = 0;
  for (int i = strAngka.length - 1; i >= 0; i--) {
    hasil = strAngka[i] + hasil;
    hitung++;
    if (hitung % 3 == 0 && i > 0) {
      hasil = '.$hasil';
    }
  }
  return hasil;
}

// 2. Modifikasi Model dengan menambahkan properti deskripsi
class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;
  const Makanan(this.nama, this.harga, this.deskripsi);
}

// 1. Penambahan 3 menu baru sehingga daftar tetap bisa digulir
final List<Makanan> daftarMenu = const [
  Makanan('Nasi Goreng', 15000, 'Nasi goreng spesial dengan telur dan ayam suwir.'),
  Makanan('Mie Ayam', 12000, 'Mie ayam pangsit dengan kuah kaldu asli.'),
  Makanan('Es Teh', 4000, 'Es teh manis segar penghilang dahaga.'),
  Makanan('Ayam Bakar', 20000, 'Ayam bakar madu lengkap dengan sambal trasi.'),
  Makanan('Sate Madura', 18000, 'Sate ayam dengan siraman bumbu kacang kental.'), // Menu baru
  Makanan('Gado-Gado', 15000, 'Sayuran rebus segar dengan saus kacang.'),       // Menu baru
  Makanan('Es Jeruk', 5000, 'Perasan jeruk murni yang menyegarkan.'),           // Menu baru
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];
          // 3. Mengganti Card dengan Container berlatar warna dan sudut membulat
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(item.nama),
              // Memanggil fungsi formatRibuan buatan sendiri
              subtitle: Text('Rp ${formatRibuan(item.harga)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPage(makanan: item)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Makanan makanan;
  const DetailPage({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(makanan.nama)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              Text(makanan.nama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // 2. Menampilkan deskripsi pada DetailPage
              Text(
                makanan.deskripsi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Memanggil fungsi formatRibuan buatan sendiri
              Text(
                'Rp ${formatRibuan(makanan.harga)}',
                style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
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