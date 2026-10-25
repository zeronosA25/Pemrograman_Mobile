import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model Data Belanja
class BarangBelanja {
  String nama;
  int jumlah;
  String kategori;
  bool dibeli;

  BarangBelanja({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.dibeli = false,
  });
}

// State Management menggunakan ChangeNotifier
class BelanjaModel extends ChangeNotifier {
  final List<BarangBelanja> _items = [];
  
  List<BarangBelanja> get items => List.unmodifiable(_items);
  
  // Menghitung jumlah barang yang belum dibeli untuk ditampilkan di AppBar
  int get jumlahBelumDibeli => _items.where((b) => !b.dibeli).length;

  void tambahBarang(String nama, int jumlah, String kategori) {
    _items.add(BarangBelanja(nama: nama, jumlah: jumlah, kategori: kategori));
    notifyListeners();
  }

  void toggleDibeli(int index) {
    _items[index].dibeli = !_items[index].dibeli;
    notifyListeners();
  }

  void hapusBarang(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Belanja',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const DaftarBelanjaPage(),
    );
  }
}

// Halaman Daftar Belanja
class DaftarBelanjaPage extends StatelessWidget {
  const DaftarBelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Belanja (Belum: ${model.jumlahBelumDibeli})'),
      ),
      body: model.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada daftar belanja',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final item = model.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.dibeli,
                      onChanged: (_) => context.read<BelanjaModel>().toggleDibeli(index),
                    ),
                    title: Text(
                      item.nama,
                      style: TextStyle(
                        decoration: item.dibeli ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Jumlah: ${item.jumlah} | Kategori: ${item.kategori}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => context.read<BelanjaModel>().hapusBarang(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahBelanjaPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Halaman Form Tambah Belanja dengan Validasi
class TambahBelanjaPage extends StatefulWidget {
  const TambahBelanjaPage({super.key});

  @override
  State<TambahBelanjaPage> createState() => _TambahBelanjaPageState();
}

class _TambahBelanjaPageState extends State<TambahBelanjaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String? _kategoriPilihan;

  final List<String> _kategoriList = ['Makanan', 'Minuman', 'Elektronik', 'Lainnya'];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final jumlah = int.parse(_jumlahController.text.trim());
      final kategori = _kategoriPilihan!;

      context.read<BelanjaModel>().tambahBarang(nama, jumlah, kategori);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil ditambahkan ke daftar belanja')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Belanjaan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Validasi Nama Barang
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Validasi Jumlah Barang (Angka > 0)
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  final angka = int.tryParse(v);
                  if (angka == null || angka <= 0) {
                    return 'Jumlah harus berupa angka lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Validasi Dropdown Kategori
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _kategoriPilihan = v;
                  });
                },
                validator: (v) => v == null ? 'Pilih kategori terlebih dahulu' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan Barang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}