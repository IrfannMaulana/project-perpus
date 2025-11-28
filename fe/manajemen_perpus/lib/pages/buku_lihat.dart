import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buku_edit.dart';

class ListBukuPage extends StatefulWidget {
  @override
  _ListBukuPageState createState() => _ListBukuPageState();
}

class _ListBukuPageState extends State<ListBukuPage> {
  List bukuList = [];
  List filteredList = [];
  bool loading = true;

  TextEditingController searchController = TextEditingController();

  Future<void> getBuku() async {
    final url = Uri.parse("http://192.168.1.x:3000/buku"); // GANTI IP

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        bukuList = jsonDecode(response.body);
        filteredList = bukuList;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil data buku")));
    }
  }

  @override
  void initState() {
    super.initState();
    getBuku();
  }

  void searchBuku(String keyword) {
    setState(() {
      filteredList = bukuList
          .where(
            (b) => b['judul'].toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> deleteBuku(int id) async {
    final url = Uri.parse("http://192.168.1.x/buku/$id");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Buku berhasil dihapus")));
      getBuku(); // refresh setelah hapus
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
                Navigator.pop(context); // tutup dialog
                deleteBuku(buku['id_buku']); // eksekusi hapus
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
        title: Icon(Icons.book, size: 32, color: Colors.black),
        leading: Icon(Icons.menu, color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.logout, color: Colors.black),
          ),
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
                    Navigator.pushNamed(
                      context,
                      '/tambah-buku',
                    ).then((_) => getBuku());
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
                            title: Text(b['judul']),
                            subtitle: Text("Pengarang: ${b['pengarang']}"),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol edit
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditBukuPage(buku: b),
                                      ),
                                    );
                                  },
                                ),
                                // Tombol hapus
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
        currentIndex: 0, // halaman ini aktif
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/list-buku');
          }
          // index 1 & 2 bisa ditambah nanti
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
