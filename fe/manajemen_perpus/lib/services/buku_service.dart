// lib/services/buku_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class BukuService {
  static Future<List> fetchBuku() async {
    final url = Uri.parse("$BASE_URL/buku");
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'];

      // fallback: cari list pertama di dalam map
      final firstList = decoded is Map
          ? decoded.values.firstWhere((v) => v is List, orElse: () => null)
          : null;
      if (firstList != null) return firstList as List;
      return decoded is List ? decoded : [decoded];
    } else {
      throw Exception(
        'Gagal load buku: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map> fetchBukuById(int id) async {
    final url = Uri.parse("$BASE_URL/buku/$id");
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal load buku: ${response.statusCode}');
    }
  }

  static Future<bool> createBuku(Map payload) async {
    final url = Uri.parse("$BASE_URL/buku");
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

  static Future<bool> updateBuku(int id, Map payload) async {
    final url = Uri.parse("$BASE_URL/buku/$id");
    final response = await http
        .put(
          url,
          headers: jsonHeaders(withAuth: true),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> deleteBuku(int id) async {
    final url = Uri.parse("$BASE_URL/buku/$id");
    final response = await http
        .delete(url, headers: jsonHeaders(withAuth: true))
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
