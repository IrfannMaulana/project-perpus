// lib/pages/peminjaman_page.dart
import '../../config.dart';
import '../login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/peminjaman_service.dart';
import '../../services/anggota_service.dart';
import '../../services/peminjaman_service.dart';
import 'peminjaman_tambah.dart';

class PeminjamanPage extends StatefulWidget {
  @override
  _PeminjamanPageState createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List peminjamanList = [];
  List filteredList = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();

  void _logout() {
    // hapus token global
    globalToken = null;

    // kembali ke halaman login & bersihkan history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> getPeminjaman() async {
    setState(() => loading = true);
    try {
      final data = await PeminjamanService.fetchPeminjaman();
      if (!mounted) return;
      setState(() {
        peminjamanList = data
            .where(
              (p) => (p['status'] ?? '').toString().toLowerCase() != 'kembali',
            )
            .toList();
        filteredList = peminjamanList;
        loading = false;
      });
    } catch (e) {
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
    getPeminjaman();
  }

  void search(String q) {
    setState(() {
      filteredList = peminjamanList.where((p) {
        final judul =
            (p['buku'] != null ? p['buku']['judul'] ?? '' : (p['judul'] ?? ''))
                .toString()
                .toLowerCase();
        final nama =
            (p['anggota'] != null
                    ? p['anggota']['nama_anggota'] ?? ''
                    : (p['nama'] ?? ''))
                .toString()
                .toLowerCase();
        return judul.contains(q.toLowerCase()) ||
            nama.contains(q.toLowerCase());
      }).toList();
    });
  }

  void _showDeleteDialog(Map p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kembalikan Buku"),
        content: Text(
          "Tandai peminjaman untuk buku \"${p['buku']?['judul'] ?? '—'}\" "
          "sebagai SUDAH DIKEMBALIKAN?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await PeminjamanService.deletePeminjaman(
                p['id_peminjaman'],
              );
              if (ok) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Buku berhasil ditandai sudah dikembalikan"),
                  ),
                );
                getPeminjaman();
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Gagal menandai pengembalian buku, coba lagi nanti",
                    ),
                  ),
                );
              }
            },
            child: const Text(
              "Ya, kembalikan",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String? iso) {
    if (iso == null) return "-";
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (e) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        centerTitle: true,
        leading: const Icon(
          Icons.local_library,
          color: Colors.black,
        ), // ikon perpus
        title: const Text('Peminjaman', style: TextStyle(color: Colors.black)),
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
            Row(
              children: [
                // Tombol tambah (tetap sama)
                InkWell(
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TambahPeminjamanPage()),
                    );
                    if (res == true) getPeminjaman();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
                const SizedBox(width: 10),

                // SEARCH BAR (otomatis lebih pendek karena ada ikon printer di kanan)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: "Cari judul / anggota...",
                              border: InputBorder.none,
                            ),
                            onChanged: search,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // TOMBOL PRINTER → buka halaman laporan peminjaman
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/laporan-peminjaman');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.print, size: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                        "Tidak ada peminjaman",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final p = filteredList[index];
                        final judul = p['buku'] != null
                            ? p['buku']['judul']
                            : (p['judul'] ?? '');
                        final nama = p['anggota'] != null
                            ? p['anggota']['nama_anggota']
                            : (p['nama'] ?? '');
                        final status = p['status'] ?? '';

                        return Card(
                          child: ListTile(
                            title: Text(judul ?? ''),
                            subtitle: Text(
                              "Peminjam: $nama\n"
                              "Pinjam: ${formatDate(p['tanggal_pinjam'])} • Status: $status",
                            ),
                            isThreeLine: true,
                            // ⬇⬇⬇ ini tetap bagian dari ListTile, bukan berdiri sendiri
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Edit peminjaman',
                                  onPressed: p['status'] == 'dipinjam'
                                      ? () async {
                                          final res = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TambahPeminjamanPage(
                                                    editData: p,
                                                  ),
                                            ),
                                          );
                                          if (res == true) getPeminjaman();
                                        }
                                      : null, // disable kalau sudah kembali
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_return,
                                    color: Colors.green,
                                  ),
                                  tooltip: 'Kembalikan buku',
                                  onPressed: () => _showDeleteDialog(p),
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
        currentIndex: 1, // peminjaman tengah
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/list-buku');
          if (index == 2) Navigator.pushReplacementNamed(context, '/anggota');
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
