import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugasku/data/services/api_service.dart';
import 'package:tugasku/data/state/task_store.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/profile/profile_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  final profileJson = jsonEncode({
    'nama': 'Naruto Uzumaki',
    'nim': '1234567890',
    'programStudi': 'S1 Sistem Informasi',
    'semester': 7,
    'dosenWali': 'Kakashi Hatake',
    'sksSemesterIni': 20,
  });

  final tasksJson = jsonEncode([
    {
      'id': 1,
      'judul': 'Tugas 1',
      'mataKuliah': 'Basis Data',
      'prioritas': 'Tinggi',
      'tenggat': '2026-11-12T23:59:00+07:00',
      'selesai': false,
      'catatan': '',
    },
    {
      'id': 2,
      'judul': 'Tugas 2',
      'mataKuliah': 'Pemrograman Mobile',
      'prioritas': 'Sedang',
      'tenggat': '2026-11-13T23:59:00+07:00',
      'selesai': false,
      'catatan': '',
    },
    {
      'id': 3,
      'judul': 'Tugas 3 Selesai',
      'mataKuliah': 'Jaringan Komputer',
      'prioritas': 'Rendah',
      'tenggat': '2026-11-14T23:59:00+07:00',
      'selesai': true,
      'catatan': '',
    },
  ]);

  testWidgets(
    'ProfilePage menampilkan identitas, ringkasan tugas, dan info akademik',
    (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/profil') {
          return http.Response(
            profileJson,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.url.path == '/tugas') {
          return http.Response(
            tasksJson,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final api = ApiService(client: mockClient);
      final store = TasksStore(api: api);

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: ProfilePage(tasksStore: store, apiService: api),
        ),
      );

      // Loading state awal
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Identitas mahasiswa
      expect(find.text('Naruto Uzumaki'), findsOneWidget);
      expect(find.text('1234567890 · S1 Sistem Informasi'), findsOneWidget);

      // Ringkasan tugas (Total: 3, Belum: 2, Selesai: 1)
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Belum'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Informasi akademik
      expect(find.text('Semester 7'), findsOneWidget);
      expect(find.text('Kakashi Hatake'), findsOneWidget);
      expect(find.text('20 SKS'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfilePage menampilkan state error dan tombol Coba lagi saat gagal memuat',
    (WidgetTester tester) async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/profil') {
          requestCount++;
          if (requestCount == 1) {
            return http.Response('Server error', 500);
          }
          return http.Response(
            profileJson,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      });

      final api = ApiService(client: mockClient);
      final store = TasksStore(api: api);

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: ProfilePage(tasksStore: store, apiService: api),
        ),
      );

      await tester.pumpAndSettle();

      // Menampilkan pesan error dan tombol Coba lagi
      expect(find.text('Gagal memuat profil'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);

      // Ketuk Coba lagi
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      // Berhasil memuat data setelah retry
      expect(find.text('Naruto Uzumaki'), findsOneWidget);
    },
  );
}
