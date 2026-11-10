import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugasku/data/models/tugas.dart';
import 'package:tugasku/data/services/api_service.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/detail/detail_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  final dummyTask = Tugas(
    id: 1,
    judul: 'Laporan Praktikum Basis Data',
    mataKuliah: 'Basis Data',
    prioritas: 'Tinggi',
    tenggat: DateTime.now().add(const Duration(hours: 12)),
    selesai: false,
    catatan: 'Kerjakan modul 1 sampai 3 dan kumpulkan di LMS.',
  );

  Widget createWidgetUnderTest({
    Tugas? task,
    int? taskId,
    ApiService? apiService,
  }) {
    return MaterialApp(
      theme: lightTheme,
      home: DetailPage(
        task: task,
        taskId: taskId ?? task!.id,
        apiService: apiService,
      ),
    );
  }

  testWidgets(
    'DetailPage menampilkan seluruh data tugas dengan benar beserta badge < 24 jam',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(task: dummyTask));
      await tester.pumpAndSettle();

      // Memastikan judul, mata kuliah, prioritas, dan catatan tampil
      expect(find.text('Laporan Praktikum Basis Data'), findsOneWidget);
      expect(find.text('Basis Data'), findsOneWidget);
      expect(find.text('Tinggi'), findsOneWidget);
      expect(
        find.text('Kerjakan modul 1 sampai 3 dan kumpulkan di LMS.'),
        findsOneWidget,
      );

      // Status awal belum selesai
      expect(find.text('Belum selesai'), findsAtLeastNWidgets(1));

      // Badge indikator < 24 jam tampil
      expect(find.text('< 24 jam'), findsOneWidget);

      // Tombol aksi Material 3 tampil
      expect(find.text('Tandai selesai'), findsOneWidget);
      expect(find.text('Kembali'), findsOneWidget);
    },
  );

  testWidgets(
    'Interaksi toggle status selesai mengubah tampilan dan memicu SnackBar',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(task: dummyTask));
      await tester.pumpAndSettle();

      // Tekan tombol "Tandai selesai"
      final toggleButton = find.text('Tandai selesai');
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Label tombol berubah menjadi "Tandai belum selesai"
      expect(find.text('Tandai belum selesai'), findsOneWidget);

      // Chip status berubah menjadi "Selesai"
      expect(find.text('Selesai'), findsAtLeastNWidgets(1));

      // Memunculkan SnackBar konfirmasi
      expect(find.text('Ditandai selesai'), findsOneWidget);
    },
  );

  testWidgets(
    'DetailPage dapat mengambil data via fetchTask(id) jika task tidak disuplai di constructor',
    (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/tugas/99') {
          return http.Response(
            jsonEncode({
              'id': 99,
              'judul': 'Tugas Jaringan Komputer',
              'mataKuliah': 'Jaringan Komputer',
              'prioritas': 'Sedang',
              'tenggat': DateTime.now()
                  .add(const Duration(days: 3))
                  .toUtc()
                  .toIso8601String(),
              'selesai': false,
              'catatan': 'Konfigurasi router Cisco',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"message": "Not found"}', 404);
      });

      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        createWidgetUnderTest(taskId: 99, apiService: apiService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tugas Jaringan Komputer'), findsOneWidget);
      expect(find.text('Jaringan Komputer'), findsOneWidget);
      expect(find.text('Sedang'), findsOneWidget);
      expect(find.text('Konfigurasi router Cisco'), findsOneWidget);
    },
  );
}
