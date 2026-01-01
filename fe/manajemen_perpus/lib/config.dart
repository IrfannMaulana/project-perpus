// Sesuaikan dengan server backend kamu:
// - Emulator Android: http://10.0.2.2:3000
// - PC yang sama (web/desktop): http://localhost:3000
const String BASE_URL = "http://192.168.1.5:3000";

String? globalToken;

/// Header JSON standar, bisa sekalian kirim Authorization kalau sudah login
Map<String, String> jsonHeaders({bool withAuth = false}) {
  return {
    "Content-Type": "application/json",
    if (withAuth && globalToken != null) "Authorization": "Bearer $globalToken",
  };
}
