import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

// Model Data Pengeluaran
class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nama': nama,
        'jumlah': jumlah,
        'kategori': kategori,
        'tanggal': tanggal,
      };

  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
        id: m['id'] as int?,
        nama: m['nama'] as String,
        jumlah: m['jumlah'] as int,
        kategori: m['kategori'] as String,
        tanggal: m['tanggal'] as String,
      );
}

// Database Helper (SQLite)
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'pengeluaran.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'nama TEXT NOT NULL, '
          'jumlah INTEGER NOT NULL, '
          'kategori TEXT NOT NULL, '
          'tanggal TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<int> tambah(Pengeluaran p) async {
    final db = await database;
    return db.insert('pengeluaran', p.toMap());
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;
    final rows = await db.query('pengeluaran', orderBy: 'id DESC');
    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(Pengeluaran p) async {
    final db = await database;
    return db.update('pengeluaran', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }

  // Menghitung total pengeluaran dengan query SQL SUM
  static Future<int> hitungTotal() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(jumlah) as total FROM pengeluaran');
    final total = result.first['total'];
    return total == null ? 0 : total as int;
  }
}

// Aplikasi Utama
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _gelap = false;

  @override
  void initState() {
    super.initState();
    _muatTema();
  }

  // Membaca pengaturan tema dari SharedPreferences
  Future<void> _muatTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gelap = prefs.getBool('gelap') ?? false;
    });
  }

  // Menyimpan pengaturan tema ke SharedPreferences
  Future<void> _ubahTema(bool nilai) async {
    setState(() => _gelap = nilai);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', nilai);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(
        brightness: _gelap ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: PengeluaranPage(
        gelap: _gelap,
        onUbahTema: _ubahTema,
      ),
    );
  }
}

// Format Angka Ribuan
String formatRibuan(int angka) {
  String str = angka.toString();
  String hasil = '';
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    hasil = str[i] + hasil;
    count++;
    if (count % 3 == 0 && i > 0) {
      hasil = '.$hasil';
    }
  }
  return hasil;
}

// Halaman Utama (Daftar & Ringkasan Total)
class PengeluaranPage extends StatefulWidget {
  final bool gelap;
  final ValueChanged<bool> onUbahTema;

  const PengeluaranPage({
    super.key,
    required this.gelap,
    required this.onUbahTema,
  });

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;
  int _totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() async {
    final total = await DbHelper.hitungTotal();
    setState(() {
      _totalPengeluaran = total;
      _future = DbHelper.semua();
    });
  }

  Future<void> _bukaForm([Pengeluaran? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormPengeluaranPage(item: item)),
    );
    if (!mounted) return;
    _muat();
  }

  Future<void> _konfirmasiHapus(int id) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (setuju == true) {
      await DbHelper.hapus(id);
      _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          IconButton(
            icon: Icon(widget.gelap ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Ubah Tema',
            onPressed: () => widget.onUbahTema(!widget.gelap),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ringkasan Total Pengeluaran
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pengeluaran:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Rp ${formatRibuan(_totalPengeluaran)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pengeluaran>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Galat: ${snapshot.error}'));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('Belum ada data pengeluaran'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final item = data[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            item.kategori == 'Makanan'
                                ? Icons.fastfood
                                : item.kategori == 'Transportasi'
                                    ? Icons.directions_car
                                    : item.kategori == 'Hiburan'
                                        ? Icons.movie
                                        : Icons.shopping_bag,
                          ),
                        ),
                        title: Text(item.nama),
                        subtitle: Text(
                          '${item.kategori} • ${item.tanggal}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp ${formatRibuan(item.jumlah)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _konfirmasiHapus(item.id!),
                            ),
                          ],
                        ),
                        onTap: () => _bukaForm(item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Halaman Form Tambah & Ubah Pengeluaran
class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? item;
  const FormPengeluaranPage({super.key, this.item});

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  String? _kategoriPilihan;

  final List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Kebutuhan',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.item?.nama ?? '');
    _jumlah = TextEditingController(
      text: widget.item != null ? widget.item!.jumlah.toString() : '',
    );
    _kategoriPilihan = widget.item?.kategori;
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final tanggalSekarang = DateTime.now().toString().substring(0, 10);

    final p = Pengeluaran(
      id: widget.item?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategoriPilihan!,
      tanggal: widget.item?.tanggal ?? tanggalSekarang,
    );

    if (widget.item == null) {
      await DbHelper.tambah(p);
    } else {
      await DbHelper.ubah(p);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.item == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Validasi Nama Wajib Isi
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama Pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Validasi Jumlah Angka > 0
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
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
            const SizedBox(height: 12),

            // Validasi Dropdown Kategori
            DropdownButtonFormField<String>(
              value: _kategoriPilihan,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _kategoriList.map((k) {
                return DropdownMenuItem(value: k, child: Text(k));
              }).toList(),
              onChanged: (v) => setState(() => _kategoriPilihan = v),
              validator: (v) =>
                  v == null ? 'Pilih kategori terlebih dahulu' : null,
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _simpan,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}