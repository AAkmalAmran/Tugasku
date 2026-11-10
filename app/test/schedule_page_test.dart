import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tugasku/data/services/api_service.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/schedule/schedule_page.dart';

void main() {
  final scheduleJson = jsonEncode([
    {
      'id': 1,
      'hari': 'Senin',
      'mataKuliah': 'Basis Data',
      'jamMulai': '07.30',
      'jamSelesai': '09.10',
      'ruangan': 'TULT-0605',
    },
    {
      'id': 2,
      'hari': 'Selasa',
      'mataKuliah': 'Pemrograman Mobile',
      'jamMulai': '10.00',
      'jamSelesai': '11.40',
      'ruangan': 'GKU-2.01',
    },
  ]);

  group('Member 4: fetchSchedule Service Unit Test', () {
    test('Berhasil mengambil dan mem-parse daftar Jadwal (status 200)', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/jadwal');
        return http.Response(
          scheduleJson,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(client: mockClient);
      final schedules = await api.fetchSchedule();

      expect(schedules.length, 2);
      expect(schedules[0].hari, 'Senin');
      expect(schedules[0].mataKuliah, 'Basis Data');
      expect(schedules[0].jamMulai, '07.30');
      expect(schedules[0].jamSelesai, '09.10');
      expect(schedules[0].ruangan, 'TULT-0605');

      expect(schedules[1].hari, 'Selasa');
      expect(schedules[1].mataKuliah, 'Pemrograman Mobile');
    });

    test('Melempar ApiException jika respon bukan 200 (error case)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Server error'}),
          500,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(client: mockClient);
      expect(() => api.fetchSchedule(), throwsA(isA<ApiException>()));
    });
  });

  group('Member 4: SchedulePage Widget Tests', () {
    testWidgets('Menampilkan jadwal kuliah yang dikelompokkan per hari dan teks Tidak ada kuliah',
        (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          scheduleJson,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: SchedulePage(apiService: api),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Judul AppBar
      expect(find.text('Jadwal Kuliah'), findsOneWidget);

      // Header hari
      expect(find.text('SENIN'), findsOneWidget);
      expect(find.text('SELASA'), findsOneWidget);
      expect(find.text('RABU'), findsOneWidget);

      // Data jadwal Senin & Selasa
      expect(find.text('Basis Data'), findsOneWidget);
      expect(find.text('07.30 – 09.10'), findsOneWidget);
      expect(find.text('Ruang: TULT-0605'), findsOneWidget);

      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.text('10.00 – 11.40'), findsOneWidget);
      expect(find.text('Ruang: GKU-2.01'), findsOneWidget);

      // Hari tanpa jadwal (Rabu, Kamis, Jumat, Sabtu)
      expect(find.text('Tidak ada kuliah'), findsWidgets);
    });

    testWidgets('Menampilkan state error dan tombol Coba lagi saat gagal memuat',
        (WidgetTester tester) async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response('Server error', 500);
        }
        return http.Response(
          scheduleJson,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: SchedulePage(apiService: api),
        ),
      );

      await tester.pumpAndSettle();

      // Error state muncul
      expect(find.text('Gagal memuat jadwal'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);

      // Ketuk Coba lagi
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      // Data jadwal berhasil tampil setelah retry
      expect(find.text('Basis Data'), findsOneWidget);
    });
  });
}
