// lib/services/peminjaman_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class PeminjamanService {
  static Future<List> fetchPeminjaman({
    String? status,
    int? idAnggota,
    int? idBuku,
    DateTime? start,
    DateTime? end,
  }) async {
    final query = <String, String>{};

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (idAnggota != null) {
      query['id_anggota'] = idAnggota.toString();
    }
    if (idBuku != null) {
      query['id_buku'] = idBuku.toString();
    }
    if (start != null && end != null) {
      String fmt(DateTime d) =>
          "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      query['start'] = fmt(start);
      query['end'] = fmt(end);
    }

    final uri = Uri.parse(
      "$BASE_URL/peminjaman",
    ).replace(queryParameters: query.isEmpty ? null : query);

    final response = await http
        .get(uri, headers: jsonHeaders(withAuth: true))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'];
      return decoded is List ? decoded : [decoded];
    } else {
      throw Exception('Gagal load peminjaman: ${response.statusCode}');
    }
  }

  static Future<Map> fetchPeminjamanById(int id) async {
    final url = Uri.parse("$BASE_URL/peminjaman/$id");
    final response = await http
        .get(url, headers: jsonHeaders(withAuth: true))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal load peminjaman: ${response.statusCode}');
    }
  }

  static Future<bool> createPeminjaman(Map payload) async {
    final url = Uri.parse("$BASE_URL/peminjaman");

    // Backend cuma butuh id_anggota, id_buku, tanggal_pinjam
    final body = {
      "id_anggota": payload["id_anggota"],
      "id_buku": payload["id_buku"],
      "tanggal_pinjam": payload["tanggal_pinjam"],
    };

    final response = await http
        .post(url, headers: jsonHeaders(withAuth: true), body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;
  }

  /// Di backend, "update" peminjaman sebenarnya = tandai pengembalian
  /// PUT /peminjaman/:id/return
  static Future<bool> updatePeminjaman(int id, Map payload) async {
    final url = Uri.parse("$BASE_URL/peminjaman/$id/return");

    final body = <String, dynamic>{};
    if (payload["tanggal_kembali"] != null) {
      body["tanggal_kembali"] = payload["tanggal_kembali"];
    }

    final response = await http
        .put(url, headers: jsonHeaders(withAuth: true), body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> editPeminjaman(int id, Map payload) async {
    final url = Uri.parse("$BASE_URL/peminjaman/$id");

    final response = await http.put(
      url,
      headers: jsonHeaders(withAuth: true),
      body: jsonEncode(payload),
    );

    return response.statusCode == 200;
  }

  /// "Delete" di frontend aku ubah jadi "mark as returned"
  /// supaya tidak memanggil endpoint yang tidak ada.
  static Future<bool> deletePeminjaman(int id) async {
    final url = Uri.parse("$BASE_URL/peminjaman/$id/return");
    final response = await http
        .put(
          url,
          headers: jsonHeaders(withAuth: true),
          body: jsonEncode({}), // tanggal_kembali diisi otomatis oleh backend
        )
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
