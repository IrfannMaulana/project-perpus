import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // bisa dihapus kalau tidak dipakai lagi
import 'dart:convert';
import '../../services/buku_service.dart';

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

  bool loading = false;

  @override
  void initState() {
    super.initState();

    judulController = TextEditingController(text: widget.buku['judul'] ?? '');
    pengarangController = TextEditingController(
      text: widget.buku['pengarang'] ?? '',
    );
    penerbitController = TextEditingController(
      text: widget.buku['penerbit'] ?? '',
    );
    kategoriController = TextEditingController(
      text: widget.buku['kategori'] ?? '',
    );
    // aman jika null
    tahunController = TextEditingController(
      text: widget.buku['tahun_terbit']?.toString() ?? '',
    );
  }

  Future<void> editBuku() async {
    setState(() => loading = true);

    try {
      final payload = {
        "judul": judulController.text,
        "pengarang": pengarangController.text,
        "penerbit": penerbitController.text,
        "tahun_terbit": int.tryParse(tahunController.text) ?? 0,
        "kategori": kategoriController.text,
      };

      debugPrint('REQUEST BODY: ${jsonEncode(payload)}');

      final ok = await BukuService.updateBuku(widget.buku['id_buku'], payload);

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data buku berhasil diperbarui")),
        );
        Navigator.pop(context, true); // supaya list refresh
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal memperbarui buku")));
      }
    } catch (e) {
      debugPrint('ERROR editBuku: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
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
                onPressed: loading ? null : editBuku,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
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
