import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

const _headers = {
  'Content-Type': 'application/json; charset=utf-8',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};
const _priorities = ['Rendah', 'Sedang', 'Tinggi'];

// In-memory data, loaded from data/tugasku.json at startup.
// Restarting the server resets everything to the seed data.
late List<Map<String, dynamic>> _tasks;
// ignore: unused_element
late List<Map<String, dynamic>> _schedule;
// ignore: unused_element
late Map<String, dynamic> _profile;

Response _json(Object body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: _headers);

Response _error(int status, String message) =>
    _json({'message': message}, status: status);

Future<void> _loadSeed() async {
  final file = File.fromUri(Platform.script.resolve('../data/tugasku.json'));
  final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  _tasks = (data['tugas'] as List).cast<Map<String, dynamic>>().toList();
  _schedule = (data['jadwal'] as List).cast<Map<String, dynamic>>().toList();
  _profile = data['profil'] as Map<String, dynamic>;
}

// ---------------- Member 1 ----------------

/// POST /tugas -> 201 with the created task, 400 on invalid input.
Future<Response> _createTask(Request request) async {
  final Object? decoded;
  try {
    decoded = jsonDecode(await request.readAsString());
  } on FormatException {
    return _error(400, 'Body bukan JSON yang valid');
  }
  if (decoded is! Map<String, dynamic>) {
    return _error(400, 'Body harus berupa objek JSON');
  }

  for (final field in ['judul', 'mataKuliah', 'tenggat']) {
    final value = decoded[field];
    if (value is! String || value.trim().isEmpty) {
      return _error(400, 'Field $field wajib diisi');
    }
  }
  if (DateTime.tryParse(decoded['tenggat'] as String) == null) {
    return _error(400, 'Format tenggat tidak valid');
  }

  final prioritas = (decoded['prioritas'] as String?) ?? 'Sedang';
  if (!_priorities.contains(prioritas)) {
    return _error(400, 'Prioritas harus Rendah, Sedang, atau Tinggi');
  }

  // id = (max existing id) + 1
  final nextId = _tasks.fold<int>(0, (m, t) => max(m, t['id'] as int)) + 1;

  final task = <String, dynamic>{
    'id': nextId,
    'judul': (decoded['judul'] as String).trim(),
    'mataKuliah': (decoded['mataKuliah'] as String).trim(),
    'prioritas': prioritas,
    'tenggat': decoded['tenggat'],
    'selesai': decoded['selesai'] is bool ? decoded['selesai'] : false,
    'catatan': (decoded['catatan'] as String?) ?? '',
  };
  _tasks.add(task);
  return _json(task, status: 201);
}

// ---------------- Member 2 ----------------

/// GET /tugas -> 200 with all tasks as a JSON array.
Response _getTasks(Request request) => _json(_tasks);

// ---------------- Member 3 ----------------

/// GET /tugas/<id> -> 200, 404 if missing, 400 if id is not an integer.
Response _getTask(Request request, String id) {
  final parsedId = int.tryParse(id);
  if (parsedId == null) {
    return _error(400, 'ID tugas harus berupa angka');
  }

  final task = _tasks.cast<Map<String, dynamic>?>().firstWhere(
        (t) => t?['id'] == parsedId,
        orElse: () => null,
      );

  if (task == null) {
    return _error(404, 'Tugas tidak ditemukan');
  }

  return _json(task);
}

// ---------------- Member 4 ----------------

/// GET /jadwal
Response _getSchedule(Request request) =>
    _error(501, 'Belum diimplementasikan (Member 4)');

// ---------------- Member 5 ----------------

/// GET /profil
Response _getProfile(Request request) =>
    _error(501, 'Belum diimplementasikan (Member 5)');

Future<void> main() async {
  await _loadSeed();

  final router = Router()
    ..post('/tugas', _createTask)
    ..get('/tugas', _getTasks)
    ..get('/tugas/<id>', _getTask)
    ..get('/jadwal', _getSchedule)
    ..get('/profil', _getProfile);

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Tugasku server listening on port ${server.port}');
}