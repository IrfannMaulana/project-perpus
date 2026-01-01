// lib/services/anggota_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AnggotaService {
  static Future<List> fetchAnggota() async {
    final url = Uri.parse("$BASE_URL/anggota");
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'];
      return decoded is List ? decoded : [decoded];
    } else {
      throw Exception('Gagal load anggota: ${response.statusCode}');
    }
  }

  static Future<Map> fetchAnggotaById(int id) async {
    final url = Uri.parse("$BASE_URL/anggota/$id");
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal load anggota: ${response.statusCode}');
    }
  }

  static Future<bool> createAnggota(Map payload) async {
    final url = Uri.parse("$BASE_URL/anggota");
    final response = await http
        .post(
          url,
          headers: jsonHeaders(withAuth: true),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;
  }

  static Future<bool> updateAnggota(int id, Map payload) async {
    final url = Uri.parse("$BASE_URL/anggota/$id");
    final response = await http
        .put(
          url,
          headers: jsonHeaders(withAuth: true),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<String?> deleteAnggota(int id) async {
    final url = Uri.parse("$BASE_URL/anggota/$id");

    final response = await http.delete(
      url,
      headers: jsonHeaders(withAuth: true),
    );

    if (response.statusCode == 200) {
      return null; // sukses
    }

    try {
      final decoded = jsonDecode(response.body);
      return decoded['message'] ?? "Gagal menghapus";
    } catch (_) {
      return "Gagal menghapus";
    }
  }
}
