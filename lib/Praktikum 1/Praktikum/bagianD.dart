// Praktikum 1 - Bagian D 

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello Flutter')),
        body: const Center(
          child: Text(
            'Halo, nama saya Muhammad Aditya ',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}