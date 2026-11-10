import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugasku/data/services/api_service.dart';
import 'package:tugasku/data/state/task_store.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/root_navigation.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  TasksStore createMockStore() {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/profil') {
        return http.Response(
          jsonEncode({
            'nama': 'Naruto Uzumaki',
            'nim': '1234567890',
            'programStudi': 'S1 Sistem Informasi',
            'semester': 7,
            'dosenWali': 'Kakashi Hatake',
            'sksSemesterIni': 20,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response(
        '[]',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    return TasksStore(api: ApiService(client: mockClient));
  }

  testWidgets(
    'RootNavigation menampilkan 4 tab dan berpindah halaman via NavigationBar',
    (WidgetTester tester) async {
      final store = createMockStore();
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: RootNavigation(tasksStore: store),
        ),
      );
      await tester.pumpAndSettle();

      // Pastikan 4 tab destinasi ada di NavigationBar
      expect(find.widgetWithText(NavigationDestination, 'Hari Ini'), findsOneWidget);
      expect(find.widgetWithText(NavigationDestination, 'Tugas'), findsOneWidget);
      expect(find.widgetWithText(NavigationDestination, 'Jadwal'), findsOneWidget);
      expect(find.widgetWithText(NavigationDestination, 'Profil'), findsOneWidget);

      // Default tab adalah index 0 (Hari Ini)
      expect(
        find.text('Tidak ada tugas mendesak'),
        findsOneWidget,
      );

      // Ketuk tab Profil (index 3)
      await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
      await tester.pumpAndSettle();

      // Halaman Profil aktif dan menampilkan identitas & ringkasan
      expect(find.text('Naruto Uzumaki'), findsOneWidget);
      expect(find.text('1234567890 · S1 Sistem Informasi'), findsOneWidget);
      expect(find.text('Ringkasan Tugas'), findsOneWidget);
      expect(find.text('Informasi Akademik'), findsOneWidget);

      // Ketuk tab Tugas (index 1)
      await tester.tap(find.widgetWithText(NavigationDestination, 'Tugas'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada tugas'), findsOneWidget);

      // Ketuk tab Jadwal (index 2)
      await tester.tap(find.widgetWithText(NavigationDestination, 'Jadwal'));
      await tester.pumpAndSettle();
      expect(find.text('Jadwal Kuliah'), findsOneWidget);
    },
  );
}
