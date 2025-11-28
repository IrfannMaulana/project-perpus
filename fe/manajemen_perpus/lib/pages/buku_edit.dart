import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditBukuPage extends StatefulWidget {
  final Map buku;

  EditBukuPage({required this.buku});

  @override
  _EditBukuPageState createState() => _EditBukuPageState();
}

class _EditBukuPageState extends State<EditBukuPage> {
  late TextEditingController judulController;
  late TextEditingController pengarangController;
  late TextEditingController penerbitController;
  late TextEditingController kategoriController;
  late TextEditingController tahunController;

  @override
  void initState() {
    super.initState();

    judulController = TextEditingController(text: widget.buku['judul']);
    pengarangController = TextEditingController(text: widget.buku['pengarang']);
    penerbitController = TextEditingController(text: widget.buku['penerbit']);
    kategoriController = TextEditingController(text: widget.buku['kategori']);
    tahunController = TextEditingController(
      text: widget.buku['tahun_terbit'].toString(),
    );
  }

  Future<void> editBuku() async {
    final url = Uri.parse("http://192.168.1.x/buku/${widget.buku['id_buku']}");

    final response = await http.put(
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
      ).showSnackBar(SnackBar(content: Text("Data buku berhasil diperbarui")));

      Navigator.pushReplacementNamed(context, '/list-buku');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memperbarui buku")));
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
        title: Text("Edit Buku", style: TextStyle(color: Colors.black)),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
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
                onPressed: editBuku,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
