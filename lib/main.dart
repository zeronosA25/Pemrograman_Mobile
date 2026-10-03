import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tugas Praktikum 1',
      home: KartuPerkenalan(),
    );
  }
}

class KartuPerkenalan extends StatelessWidget {
  const KartuPerkenalan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Perkenalan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Icon(Icons.account_circle, size: 120, color: Colors.blueAccent),
            SizedBox(height: 24),
            
            Text(
              'Muhammad Aditya',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            Text(
              'NIM: 20240801234',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            
            Text(
              'Jurusan: Teknik Informatika',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            
            Text(
              'Hobi: Menulis Kode',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}