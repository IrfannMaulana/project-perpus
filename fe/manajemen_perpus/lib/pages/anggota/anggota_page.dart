// lib/pages/anggota_page.dart
import '../login/login_page.dart';
import '../../config.dart';

import 'package:flutter/material.dart';
import '../../services/anggota_service.dart';

class AnggotaPage extends StatefulWidget {
  @override
  _AnggotaPageState createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  List anggotaList = [];
  List filteredList = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();

  void _logout() {
    globalToken = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> getAnggota() async {
    setState(() => loading = true);
    try {
      final data = await AnggotaService.fetchAnggota();
      if (!mounted) return;
      setState(() {
        anggotaList = data;
        filteredList = data;
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
    getAnggota();
  }

  void search(String q) {
    setState(() {
      filteredList = anggotaList.where((a) {
        final nama = (a['nama_anggota'] ?? '').toString().toLowerCase();
        final nis = (a['nis'] ?? '').toString().toLowerCase();
        return nama.contains(q.toLowerCase()) || nis.contains(q.toLowerCase());
      }).toList();
    });
  }

  void _confirmDelete(Map a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Hapus Anggota"),
        content: Text(
          "Yakin ingin menghapus ${a['nama_anggota']}?\n\n"
          "Anggota yang pernah meminjam tidak bisa dihapus.",
        ),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);

              final error = await AnggotaService.deleteAnggota(a['id_anggota']);

              if (error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Anggota berhasil dihapus")),
                );
                getAnggota();
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map a) {
    final namaCtrl = TextEditingController(text: a['nama_anggota']);
    final alamatCtrl = TextEditingController(text: a['alamat']);
    final hpCtrl = TextEditingController(text: a['no_hp']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Anggota"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: alamatCtrl,
                decoration: InputDecoration(labelText: "Alamat"),
              ),
              TextField(
                controller: hpCtrl,
                decoration: InputDecoration(labelText: "No HP"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await AnggotaService.updateAnggota(a['id_anggota'], {
                "nama_anggota": namaCtrl.text,
                "alamat": alamatCtrl.text,
                "no_hp": hpCtrl.text,
              });
              if (ok) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Anggota diperbarui")));
                getAnggota();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal memperbarui anggota")),
                );
              }
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final namaCtrl = TextEditingController();
    final nisCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    final hpCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Anggota"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: nisCtrl,
                decoration: InputDecoration(labelText: "NIS"),
              ),
              TextField(
                controller: alamatCtrl,
                decoration: InputDecoration(labelText: "Alamat"),
              ),
              TextField(
                controller: hpCtrl,
                decoration: InputDecoration(labelText: "No HP"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await AnggotaService.createAnggota({
                "nama_anggota": namaCtrl.text,
                "nis": nisCtrl.text,
                "alamat": alamatCtrl.text,
                "no_hp": hpCtrl.text,
              });
              if (ok) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Anggota ditambahkan")));
                getAnggota();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menambahkan anggota")),
                );
              }
            },
            child: Text("Tambah"),
          ),
        ],
      ),
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
        title: const Text('Anggota', style: TextStyle(color: Colors.black)),
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
                InkWell(
                  onTap: _showAddDialog,
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
                              hintText: "Cari nama / NIS...",
                              border: InputBorder.none,
                            ),
                            onChanged: search,
                          ),
                        ),
                      ],
                    ),
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
                        "Tidak ada anggota",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final a = filteredList[index];
                        return Card(
                          child: ListTile(
                            title: Text(a['nama_anggota'] ?? ''),
                            subtitle: Text(
                              "NIS: ${a['nis'] ?? '-'} • ${a['no_hp'] ?? ''}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(a),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(a),
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/list-buku');
          if (index == 1)
            Navigator.pushReplacementNamed(context, '/peminjaman');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Buku"),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Peminjman",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Anggota"),
        ],
      ),
    );
  }
}
