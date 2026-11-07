import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugasku/data/services/api_service.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/task_form/task_form_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  Widget createWidgetUnderTest({ApiService? apiService}) {
    return MaterialApp(
      theme: lightTheme,
      home: TaskFormPage(apiService: apiService),
    );
  }

  testWidgets(
    'Tombol Simpan dinonaktifkan saat field wajib kosong dan aktif setelah terisi',
    (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'id': 101,
            'judul': 'Laporan Praktikum',
            'mataKuliah': 'Pemrograman Mobile',
            'prioritas': 'Sedang',
            'tenggat': DateTime.now().toUtc().toIso8601String(),
            'selesai': false,
            'catatan': '',
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(createWidgetUnderTest(apiService: apiService));
      await tester.pumpAndSettle();

      // Tombol Simpan pertama kali harus disabled (onPressed == null)
      final simpanFinder = find.widgetWithText(FilledButton, 'Simpan');
      expect(simpanFinder, findsOneWidget);
      expect(tester.widget<FilledButton>(simpanFinder).onPressed, isNull);

      // Isi Judul
      final judulField = find.widgetWithText(TextField, 'Judul *');
      await tester.enterText(judulField, 'Laporan Praktikum');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(simpanFinder).onPressed, isNull);

      // Isi Mata Kuliah
      final matkulField = find.widgetWithText(TextField, 'Mata kuliah *');
      await tester.enterText(matkulField, 'Pemrograman Mobile');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(simpanFinder).onPressed, isNull);

      // Pilih Tanggal Tenggat via DatePicker
      final tenggatField = find.widgetWithText(TextField, 'Tenggat *');
      await tester.tap(tenggatField);
      await tester.pumpAndSettle();

      // Konfirmasi pilihan tanggal pada DatePicker dialog
      final okButton = find.text('OK');
      expect(okButton, findsOneWidget);
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      // Sekarang semua field wajib terisi -> Tombol Simpan harus aktif
      expect(tester.widget<FilledButton>(simpanFinder).onPressed, isNotNull);

      // Submit form
      await tester.tap(simpanFinder);
      await tester.pumpAndSettle();

      // Muncul konfirmasi SnackBar
      expect(find.text('Tugas ditambahkan'), findsOneWidget);
    },
  );
}

