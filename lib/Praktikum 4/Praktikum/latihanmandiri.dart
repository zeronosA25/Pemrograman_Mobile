import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 4',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PenggunaPage(),
    );
  }
}

// 1. Modifikasi Model Data
class Pengguna {
  final int id;
  final String name;
  final String username; // Kolom baru
  final String email;
  final String phone;
  final String website;
  final String city; // Kolom baru

  const Pengguna({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.city,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
      // Membaca data bersarang (nested JSON)
      city: json['address']['city'] as String, 
    );
  }
}

Future<List<Pengguna>> ambilPengguna() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/users');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));
  
  if (response.statusCode != 200) {
    throw Exception('Gagal memuat data (kode ${response.statusCode})');
  }
  
  final List<dynamic> data = jsonDecode(response.body);
  return data
      .map((e) => Pengguna.fromJson(e as Map<String, dynamic>))
      .toList();
}

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  late Future<List<Pengguna>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPengguna();
  }

  void _muatUlang() {
    setState(() {
      _future = ambilPengguna();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold dipindah ke dalam FutureBuilder agar AppBar bisa membaca jumlah data
    return FutureBuilder<List<Pengguna>>(
      future: _future,
      builder: (context, snapshot) {
        // 4. Menentukan judul AppBar berdasarkan status data
        String appBarTitle = 'Daftar Pengguna';
        if (snapshot.hasData && snapshot.data != null) {
          appBarTitle = 'Daftar Pengguna (${snapshot.data!.length})';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Terjadi kesalahan:\n${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
                      ],
                    ),
                  ),
                );
              }
              
              final data = snapshot.data!;
              
              // 3. Menangani kondisi daftar kosong
              if (data.isEmpty) {
                return const Center(child: Text("Tidak ada data", style: TextStyle(fontSize: 18)));
              }

              // 2. Membungkus ListView dengan RefreshIndicator
              return RefreshIndicator(
                onRefresh: () async {
                  _muatUlang();
                  await _future; // Menunggu data baru selesai diunduh
                },
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final p = data[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(p.name[0])),
                      title: Text(p.name),
                      subtitle: Text(p.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPenggunaPage(pengguna: p),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
          ),
        );
      },
    );
  }
}

class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;
  const DetailPenggunaPage({super.key, required this.pengguna});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pengguna.name)),
      body: ListView(
        children: [
          // Menampilkan Username
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(pengguna.username),
            subtitle: const Text('Username'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(pengguna.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(pengguna.phone),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(pengguna.website),
          ),
          // Menampilkan Kota
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(pengguna.city),
            subtitle: const Text('City'),
          ),
        ],
      ),
    );
  }
}