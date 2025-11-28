import 'package:flutter/material.dart';
import 'pages/buku_tambah.dart';
import 'pages/buku_lihat.dart'; // <-- tambahkan ini

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Halaman awal aplikasi
      home: ListBukuPage(), // <-- fakta PENTING: halaman utama adalah list buku
      // Semua route
      routes: {
        '/tambah-buku': (context) => TambahBukuPage(),
        '/list-buku': (context) => ListBukuPage(), // <-- tambahkan ini
      },
    );
  }
}
