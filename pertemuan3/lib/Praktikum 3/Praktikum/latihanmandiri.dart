import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model Data Tugas
class Tugas {
  String judul;
  bool selesai;
  Tugas(this.judul, {this.selesai = false});
}

// State Management menggunakan ChangeNotifier
class TugasModel extends ChangeNotifier {
  final List<Tugas> _items = [];
  List<Tugas> get items => List.unmodifiable(_items);
  int get jumlahSelesai => _items.where((t) => t.selesai).length;

  void tambah(String judul) {
    _items.add(Tugas(judul));
    notifyListeners();
  }

  void toggle(int index) {
    _items[index].selesai = !_items[index].selesai;
    notifyListeners();
  }

  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // Latihan Mandiri No. 2: Method hapusSelesai
  void hapusSelesai() {
    _items.removeWhere((t) => t.selesai);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TugasModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Tugas',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const TugasPage(),
    );
  }
}

// Halaman Daftar Tugas
class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas (${model.jumlahSelesai}/${model.items.length})'),
        actions: [
          // Latihan Mandiri No. 2: Tombol hapus tugas yang sudah selesai di AppBar
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Tugas Selesai',
            onPressed: model.jumlahSelesai > 0
                ? () => context.read<TugasModel>().hapusSelesai()
                : null,
          ),
        ],
      ),
      // Latihan Mandiri No. 4: Jika daftar kosong, tampilkan teks di tengah layar
      body: model.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada tugas',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final t = model.items[index];
                return ListTile(
                  leading: Checkbox(
                    value: t.selesai,
                    onChanged: (_) => context.read<TugasModel>().toggle(index),
                  ),
                  title: Text(
                    t.judul,
                    style: TextStyle(
                      decoration: t.selesai ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => context.read<TugasModel>().hapus(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Halaman Tambah Tugas dengan Form dan Validasi (Latihan Mandiri No. 1 & 3)
class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final judul = _controller.text.trim();
      context.read<TugasModel>().tambah(judul);
      
      // Latihan Mandiri No. 3: Tampilkan SnackBar setelah tugas disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas ditambahkan')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  border: OutlineInputBorder(),
                ),
                // Latihan Mandiri No. 1: Validasi minimal 3 karakter
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Judul tugas wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _simpan(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}