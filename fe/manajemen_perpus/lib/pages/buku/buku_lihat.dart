// lib/pages/buku/list_buku_page.dart
import '../login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';
import '../../services/buku_service.dart';
import 'buku_edit.dart';
import 'buku_tambah.dart';

class ListBukuPage extends StatefulWidget {
  @override
  _ListBukuPageState createState() => _ListBukuPageState();
}

class _ListBukuPageState extends State<ListBukuPage> {
  List bukuList = [];
  List filteredList = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

  void _logout() {
    globalToken = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> getBuku() async {
    setState(() => loading = true);
    try {
      final data = await BukuService.fetchBuku();
      if (!mounted) return;
      setState(() {
        bukuList = data;
        filteredList = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('getBuku ERROR: $e');
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    getBuku();
  }

  void searchBuku(String keyword) {
    setState(() {
      filteredList = bukuList.where((b) {
        final judul = (b['judul'] ?? '').toString().toLowerCase();
        final pengarang = (b['pengarang'] ?? '').toString().toLowerCase();
        return judul.contains(keyword.toLowerCase()) ||
            pengarang.contains(keyword.toLowerCase());
      }).toList();
    });
  }

  Future<void> deleteBuku(int id) async {
    final ok = await BukuService.deleteBuku(id);
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Buku berhasil dihapus")));
      getBuku();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menghapus buku")));
    }
  }

  void _showDeleteDialog(Map buku) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Buku"),
          content: Text(
            "Apakah Anda yakin ingin menghapus buku \"${buku['judul']}\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteBuku(buku['id_buku']);
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.local_library, color: Colors.black),
        title: const Text('Buku', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Row: tombol tambah + search bar
            Row(
              children: [
                // Tombol tambah
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TambahBukuPage()),
                    ).then((value) {
                      if (value == true) getBuku();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, size: 28),
                  ),
                ),

                SizedBox(width: 10),

                // Search bar
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Cari judul...",
                              border: InputBorder.none,
                            ),
                            onChanged: searchBuku,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Card besar (tabel buku)
            Container(
              padding: EdgeInsets.all(20),
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),

              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada buku",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final b = filteredList[index];
                        return Card(
                          child: ListTile(
                            title: Text(b['judul'] ?? ''),
                            subtitle: Text(
                              "Pengarang: ${b['pengarang'] ?? ''}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditBukuPage(buku: b),
                                      ),
                                    ).then((result) {
                                      if (result == true) getBuku();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteDialog(b);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[300],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/list-buku');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/peminjaman');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/anggota');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Buku"),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Peminjaman",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Anggota"),
        ],
      ),
    );
  }
}
