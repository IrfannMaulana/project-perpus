import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  /// Login ke backend /petugas/login
  /// Berhasil → set globalToken dan kembalikan data petugas
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$BASE_URL/petugas/login");

    final response = await http
        .post(
          url,
          headers: jsonHeaders(), // tanpa auth
          body: jsonEncode({"username": username, "password": password}),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final token = body['token'] as String?;
      final data = body['data'] as Map<String, dynamic>?;

      if (token == null || data == null) {
        throw Exception("Token atau data login tidak ditemukan");
      }

      // simpan token global
      globalToken = token;

      return data;
    } else {
      final message = body['message'] ?? 'Login gagal';
      throw Exception(message);
    }
  }
}
