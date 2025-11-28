import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahBukuPage extends StatefulWidget {
  @override
  _TambahBukuPageState createState() => _TambahBukuPageState();
}

class _TambahBukuPageState extends State<TambahBukuPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController pengarangController = TextEditingController();
  final TextEditingController penerbitController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();

  Future<void> tambahBuku() async {
    final url = Uri.parse("http://192.168.1.x:3000/buku");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "judul": judulController.text,
        "pengarang": pengarangController.text,
        "penerbit": penerbitController.text,
        "tahun_terbit": int.tryParse(tahunController.text) ?? 0,
        "kategori": kategoriController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Buku berhasil ditambahkan")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menambahkan buku")));
    }
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
        padding: EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: judulController,
                  decoration: inputStyle("Judul Buku"),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: pengarangController,
                  decoration: inputStyle("Pengarang"),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: penerbitController,
                  decoration: inputStyle("Penerbit"),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: kategoriController,
                  decoration: inputStyle("Kategori"),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: tahunController,
                  decoration: inputStyle("Tahun Terbit"),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tambahBuku,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Tambah",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar (seperti desain kamu)
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
