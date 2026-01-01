import 'package:flutter/material.dart';
import 'pages/login/login_page.dart';
import 'pages/buku/buku_tambah.dart';
import 'pages/buku/buku_lihat.dart';
import 'pages/peminjaman/peminjaman_page.dart';
import 'pages/peminjaman/peminjaman_tambah.dart';
import 'pages/anggota/anggota_page.dart';
import 'pages/peminjaman/peminjaman_laporan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perpus App',

      // Halaman awal aplikasi: LOGIN dulu
      home: const LoginPage(),

      // Semua route
      routes: {
        '/login': (context) => const LoginPage(),
        '/list-buku': (context) => ListBukuPage(),
        '/tambah-buku': (context) => TambahBukuPage(),
        '/peminjaman': (context) => PeminjamanPage(),
        '/tambah-peminjaman': (context) => TambahPeminjamanPage(),
        '/anggota': (context) => AnggotaPage(),
        '/laporan-peminjaman': (context) => const LaporanPeminjamanPage(),
      },
    );
  }
}
