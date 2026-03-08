import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String baseUrl =
      'https://skincare-app-production-0237.up.railway.app/api';

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    return _handle(res);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(uri,
        headers: _headers, body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> _delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.delete(uri, headers: _headers);
    if (res.statusCode == 204) return null;
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    String message = 'Request failed';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } catch (_) {}
    throw ApiException(res.statusCode, message);
  }

  // ── Auth ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final data = await _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    return await _get('/auth/me') as Map<String, dynamic>;
  }

  // ── Products ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProducts({
    String? country,
    String? category,
    String? functionality,
    String? brand,
    double? maxPrice,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final q = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (country != null) 'country': country,
      if (category != null) 'category': category,
      if (functionality != null) 'functionality': functionality,
      if (brand != null) 'brand': brand,
      if (maxPrice != null) 'maxPrice': maxPrice.toStringAsFixed(0),
      if (search != null && search.isNotEmpty) 'search': search,
    };
    return await _get('/products', query: q) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProductDetail(String id) async {
    return await _get('/products/$id') as Map<String, dynamic>;
  }

  // ── Countries ─────────────────────────────────────────────────
  Future<List<dynamic>> getCountries() async {
    final data = await _get('/countries') as Map<String, dynamic>;
    return data['countries'] as List<dynamic>;
  }

  Future<List<dynamic>> getStores(String countryCode) async {
    final data =
        await _get('/countries/$countryCode/stores') as Map<String, dynamic>;
    return data['stores'] as List<dynamic>;
  }

  // ── Favorites ─────────────────────────────────────────────────
  Future<List<dynamic>> getFavorites() async {
    final data = await _get('/favorites') as Map<String, dynamic>;
    return data['favorites'] as List<dynamic>;
  }

  Future<void> addFavorite(String productId) async {
    await _post('/favorites/$productId', {});
  }

  Future<void> removeFavorite(String productId) async {
    await _delete('/favorites/$productId');
  }

  // ── Reviews ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getReviews(String productId) async {
    return await _get('/products/$productId/reviews')
        as Map<String, dynamic>;
  }

  Future<void> postReview(
      String productId, int rating, String comment) async {
    await _post('/products/$productId/reviews', {
      'rating': rating,
      'comment': comment,
    });
  }
}

// Singleton instance
final apiService = ApiService();
