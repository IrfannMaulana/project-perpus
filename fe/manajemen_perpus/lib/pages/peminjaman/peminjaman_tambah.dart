// lib/pages/peminjaman_tambah.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../services/peminjaman_service.dart';
import '../../services/anggota_service.dart';
import '../../services/peminjaman_service.dart';
import '../../services/anggota_service.dart';
import '../../services/peminjaman_service.dart';
import '../../services/buku_service.dart';

class TambahPeminjamanPage extends StatefulWidget {
  final Map? editData;
  TambahPeminjamanPage({this.editData});

  @override
  _TambahPeminjamanPageState createState() => _TambahPeminjamanPageState();
}

class _TambahPeminjamanPageState extends State<TambahPeminjamanPage> {
  List anggotaList = [];
  List bukuList = []; // kalau perlu ambil dari endpoint /buku
  int? selectedAnggota;
  int? selectedBuku;
  DateTime tanggalPinjam = DateTime.now();
  bool loading = false;

  Future<void> loadAnggota() async {
    try {
      final a = await AnggotaService.fetchAnggota();
      if (!mounted) return;
      setState(() => anggotaList = a);
    } catch (e) {
      // ignore
    }
  }

  Future<void> loadBuku() async {
    try {
      final data = await BukuService.fetchBuku();
      if (!mounted) return;
      setState(() => bukuList = data);
    } catch (e) {
      // kalau mau, bisa tampilkan snackbar error
    }
  }

  @override
  void initState() {
    super.initState();
    loadAnggota();
    loadBuku();
    if (widget.editData != null) {
      final d = widget.editData!;
      selectedAnggota = d['id_anggota'];
      selectedBuku = d['id_buku'];
      if (d['tanggal_pinjam'] != null) {
        try {
          tanggalPinjam = DateTime.parse(d['tanggal_pinjam']);
        } catch (e) {}
      }
    }
  }

  Future<void> submit() async {
    if (selectedAnggota == null || selectedBuku == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pilih anggota dan buku terlebih dahulu")),
      );
      return;
    }
    setState(() => loading = true);
    final payload = {
      "id_anggota": selectedAnggota,
      "id_buku": selectedBuku,
      "id_petugas": 1, // ganti sesuai session
      "tanggal_pinjam": tanggalPinjam.toUtc().toIso8601String(),
    };
    try {
      bool ok;
      if (widget.editData != null) {
        ok = await PeminjamanService.editPeminjaman(
          widget.editData!['id_peminjaman'],
          {
            "id_anggota": selectedAnggota,
            "id_buku": selectedBuku,
            "tanggal_pinjam": tanggalPinjam.toUtc().toIso8601String(),
          },
        );
      } else {
        ok = await PeminjamanService.createPeminjaman(payload);
      }

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editData != null
                  ? "Peminjaman diperbarui"
                  : "Peminjaman ditambahkan",
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan peminjaman")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: tanggalPinjam,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => tanggalPinjam = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.editData != null ? "Edit Peminjaman" : "Tambah Peminjaman",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedAnggota,
              items: anggotaList.map<DropdownMenuItem<int>>((a) {
                return DropdownMenuItem<int>(
                  value: a['id_anggota'],
                  child: Text("${a['nama_anggota']} — ${a['no_hp'] ?? ''}"),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedAnggota = v),
              decoration: InputDecoration(
                labelText: "Pilih Anggota",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedBuku,
              items: bukuList.map<DropdownMenuItem<int>>((b) {
                return DropdownMenuItem<int>(
                  value: b['id_buku'],
                  child: Text("${b['judul']}"),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedBuku = v),
              decoration: InputDecoration(
                labelText: "Pilih Buku",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Tanggal Pinjam",
                  filled: true,
                  fillColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('yyyy-MM-dd').format(tanggalPinjam)),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text(
                        widget.editData != null ? "Simpan" : "Tambah",
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
