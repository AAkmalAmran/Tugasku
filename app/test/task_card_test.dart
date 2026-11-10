import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugasku/data/models/tugas.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/tasks/task_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  Widget createWidgetUnderTest({
    required Tugas task,
    ValueChanged<bool>? onToggleDone,
    DateTime? now,
  }) {
    return MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: TaskCard(
          task: task,
          onToggleDone: onToggleDone,
          now: now,
        ),
      ),
    );
  }

  testWidgets(
    'TaskCard merender informasi tugas, interaksi checkbox, dan marker < 24 jam',
    (WidgetTester tester) async {
      final baseNow = DateTime(2026, 11, 10, 10, 0); // 10 Nov 2026 10:00
      // Tenggat 5 jam dari sekarang (< 24 jam)
      final deadlineSoon = baseNow.add(const Duration(hours: 5));

      final task = Tugas(
        id: 1,
        judul: 'Laporan Praktikum Basis Data',
        mataKuliah: 'Basis Data',
        prioritas: 'Tinggi',
        tenggat: deadlineSoon,
        selesai: false,
        catatan: 'Kerjakan bab 1-3',
      );

      bool? toggledValue;

      await tester.pumpWidget(
        createWidgetUnderTest(
          task: task,
          now: baseNow,
          onToggleDone: (val) {
            toggledValue = val;
          },
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifikasi rendering elemen kartu tugas
      expect(find.text('Laporan Praktikum Basis Data'), findsOneWidget);
      expect(find.text('Basis Data'), findsOneWidget);
      expect(find.text('Tinggi'), findsOneWidget);

      // Verifikasi Checkbox awal bernilai false (belum selesai)
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);

      // Verifikasi judul awal tidak tercoret
      final titleFinder = find.text('Laporan Praktikum Basis Data');
      final Text initialTitleWidget = tester.widget<Text>(titleFinder);
      expect(initialTitleWidget.style?.decoration, isNot(TextDecoration.lineThrough));

      // 2. Verifikasi kemunculan marker < 24 jam
      expect(find.text('< 24 jam'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);

      // 3. Uji interaksi Checkbox
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Callback terpanggil dengan nilai true
      expect(toggledValue, isTrue);

      // Checkbox sekarang bernilai true
      expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

      // Judul tugas sekarang tercoret otomatis (lineThrough)
      final Text updatedTitleWidget = tester.widget<Text>(titleFinder);
      expect(updatedTitleWidget.style?.decoration, TextDecoration.lineThrough);

      // Marker < 24 jam menghilang karena tugas sudah selesai
      expect(find.text('< 24 jam'), findsNothing);
    },
  );
}

