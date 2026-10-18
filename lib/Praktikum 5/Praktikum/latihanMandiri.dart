import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Praktikum 5 - Latihan Mandiri',
      home: CatatanPage(),
    );
  }
}

// 3. Model Data dengan kolom 'dibuat'
class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String? dibuat;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    this.dibuat,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'judul': judul,
        'isi': isi,
        'dibuat': dibuat,
      };

  factory Catatan.fromMap(Map<String, Object?> m) => Catatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        isi: m['isi'] as String,
        dibuat: m['dibuat'] as String?,
      );
}

// Helper Database
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'catatan.db');
    _db = await openDatabase(
      path,
      version: 2, // 3. Version dinaikkan ke 2
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'judul TEXT NOT NULL, '
          'isi TEXT NOT NULL, '
          'dibuat TEXT)',
        );
      },
      // 3. Implementasi onUpgrade untuk ALTER TABLE
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE catatan ADD COLUMN dibuat TEXT');
        }
      },
    );
    return _db!;
  }

  static Future<int> tambah(Catatan c) async {
    final db = await database;
    return db.insert('catatan', c.toMap());
  }

  // 2 & 4. Filter pencarian (LIKE) dan urutan dinamis (orderBy)
  static Future<List<Catatan>> semua({String? kataKunci, bool terbaru = true}) async {
    final db = await database;
    final urutan = terbaru ? 'id DESC' : 'id ASC';

    List<Map<String, Object?>> rows;
    if (kataKunci != null && kataKunci.trim().isNotEmpty) {
      rows = await db.query(
        'catatan',
        where: 'judul LIKE ?',
        whereArgs: ['%$kataKunci%'],
        orderBy: urutan,
      );
    } else {
      rows = await db.query('catatan', orderBy: urutan);
    }

    return rows.map(Catatan.fromMap).toList();
  }

  static Future<int> ubah(Catatan c) async {
    final db = await database;
    return db.update('catatan', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}

// Halaman Daftar Catatan
class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  late Future<List<Catatan>> _future;
  final _searchController = TextEditingController();
  bool _terbaru = true;

  @override
  void initState() {
    super.initState();
    _muatPengaturanUrutan();
  }

  // 4. Membaca pilihan urutan dari SharedPreferences
  Future<void> _muatPengaturanUrutan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _terbaru = prefs.getBool('terbaru') ?? true;
      _muat();
    });
  }

  // 4. Menyimpan pilihan urutan ke SharedPreferences
  Future<void> _ubahUrutan(bool terbaru) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terbaru', terbaru);
    setState(() {
      _terbaru = terbaru;
      _muat();
    });
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua(
        kataKunci: _searchController.text.trim(),
        terbaru: _terbaru,
      );
    });
  }

  Future<void> _buka([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormCatatanPage(catatan: catatan)),
    );
    if (!mounted) return;
    _muat();
  }

  // 1. AlertDialog Konfirmasi Hapus
  Future<void> _konfirmasiHapus(int id) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus catatan ini?'),
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
        title: const Text('Catatan Saya'),
        actions: [
          // 4. Tombol ubah urutan
          IconButton(
            icon: Icon(_terbaru ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _terbaru ? 'Urutkan Terlama' : 'Urutkan Terbaru',
            onPressed: () => _ubahUrutan(!_terbaru),
          ),
        ],
      ),
      body: Column(
        children: [
          // 2. Input pencarian
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari judul catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _muat();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _muat(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Catatan>>(
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
                  return const Center(child: Text('Tidak ada catatan'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final c = data[i];
                    return ListTile(
                      title: Text(c.judul),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.isi, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (c.dibuat != null)
                            Text(
                              'Dibuat: ${c.dibuat}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                        ],
                      ),
                      onTap: () => _buka(c),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _konfirmasiHapus(c.id!),
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
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Form Tambah/Ubah Catatan
class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;
  const FormCatatanPage({super.key, this.catatan});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _isi;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.catatan?.judul ?? '');
    _isi = TextEditingController(text: widget.catatan?.isi ?? '');
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    // 3. Menyimpan waktu dibuat saat catatan baru
    final waktuSekarang = DateTime.now().toString().substring(0, 16);

    final c = Catatan(
      id: widget.catatan?.id,
      judul: _judul.text.trim(),
      isi: _isi.text.trim(),
      dibuat: widget.catatan?.dibuat ?? waktuSekarang,
    );

    if (widget.catatan == null) {
      await DbHelper.tambah(c);
    } else {
      await DbHelper.ubah(c);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.catatan == null;
    return Scaffold(
      appBar: AppBar(title: Text(baru ? 'Catatan Baru' : 'Ubah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isi,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
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