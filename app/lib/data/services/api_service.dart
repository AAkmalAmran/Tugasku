import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/jadwal.dart';
import '../models/profil.dart';
import '../models/tugas.dart';

/// Thrown when the server answers with an unexpected status code.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// The only class that talks to the network.
/// Pass a [http.Client] (e.g. MockClient) in tests.
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
  static const Duration timeout = Duration(seconds: 10);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  dynamic _decode(http.Response res) => jsonDecode(utf8.decode(res.bodyBytes));

  void _ensureStatus(http.Response res, int expected) {
    if (res.statusCode != expected) {
      String message = 'Unexpected status ${res.statusCode}';
      try {
        final data = _decode(res);
        if (data is Map && data['message'] is String) {
          message = data['message'] as String;
        }
      } catch (_) {}
      throw ApiException(res.statusCode, message);
    }
  }

  // ---------------- Member 1 ----------------

  /// POST /tugas.
  Future<Tugas> createTask(Tugas task) async {
    final body = task.toJson()..remove('id');
    final res = await _client
        .post(
          _uri('/tugas'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(body),
        )
        .timeout(timeout);
    _ensureStatus(res, 201);
    return Tugas.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // ---------------- Member 2 ----------------

  /// GET /tugas
  Future<List<Tugas>> fetchTasks() async {
    final res = await _client.get(_uri('/tugas')).timeout(timeout);
    _ensureStatus(res, 200);
    final list = _decode(res) as List<dynamic>;
    return list
        .map((item) => Tugas.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ---------------- Member 3 ----------------

  /// GET `/tugas/<id>`
  Future<Tugas> fetchTask(int id) {
    throw UnimplementedError('Member 3: GET /tugas/<id>');
  }

  // ---------------- Member 4 ----------------
    
  /// GET /jadwal
  Future<List<Jadwal>> fetchSchedule() {
    throw UnimplementedError('Member 4: GET /jadwal');
  }

  // ---------------- Member 5 ----------------

  /// GET /profil
  Future<Profil> fetchProfile() {
    throw UnimplementedError('Member 5: GET /profil');
  }
}