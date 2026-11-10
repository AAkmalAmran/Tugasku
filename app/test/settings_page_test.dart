import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasku/data/state/theme_controller.dart';
import 'package:tugasku/theme.dart';
import 'package:tugasku/ui/settings/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeController Unit Test', () {
    test('Menginisialisasi default ke ThemeMode.system dan membaca dari SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final controller = ThemeController();
      await controller.loadThemeMode();

      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
    });

    test('Mengubah tema ke light dan menyimpannya ke SharedPreferences', () async {
      final controller = ThemeController();
      await controller.loadThemeMode();

      int listenerNotificationCount = 0;
      controller.addListener(() {
        listenerNotificationCount++;
      });

      await controller.setThemeMode(ThemeMode.light);

      expect(controller.themeMode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);
      expect(listenerNotificationCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('Toggle dark mode switch mengubah antara dark dan light', () async {
      final controller = ThemeController();
      await controller.toggleDarkMode(true);
      expect(controller.themeMode, ThemeMode.dark);

      await controller.toggleDarkMode(false);
      expect(controller.themeMode, ThemeMode.light);
    });
  });

  group('SettingsPage Widget Tests', () {
    testWidgets('SettingsPage menampilkan komponen pengaturan tema dan info aplikasi', (WidgetTester tester) async {
      final controller = ThemeController(initialMode: ThemeMode.system);

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          home: SettingsPage(themeController: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Judul AppBar
      expect(find.text('Pengaturan'), findsOneWidget);

      // Section Tampilan
      expect(find.text('Tampilan Aplikasi'), findsOneWidget);
      expect(find.text('Mode Gelap'), findsNWidgets(2)); // Switch label & Radio tile label
      expect(find.text('Ikuti Sistem'), findsOneWidget);
      expect(find.text('Mode Terang'), findsOneWidget);

      // Section Informasi Aplikasi
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('Tugasku'), findsOneWidget);
      expect(find.text('1.0.0+1'), findsOneWidget);
      expect(find.text('Kelompok 03 (PAB)'), findsOneWidget);
    });

    testWidgets('Mengetuk opsi tema memperbarui controller dan tampilan secara real-time', (WidgetTester tester) async {
      final controller = ThemeController(initialMode: ThemeMode.light);

      await tester.pumpWidget(
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return MaterialApp(
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: controller.themeMode,
              home: SettingsPage(themeController: controller),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.themeMode, ThemeMode.light);

      // Ketuk opsi Mode Gelap pada RadioListTile
      final darkModeRadio = find.widgetWithText(RadioListTile<ThemeMode>, 'Mode Gelap');
      expect(darkModeRadio, findsOneWidget);
      await tester.tap(darkModeRadio);
      await tester.pumpAndSettle();

      // Controller sekarang menjadi dark mode
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);

      // Ketuk switch Mode Gelap untuk mematikan mode gelap
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(controller.themeMode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);

      // Ketuk opsi Ikuti Sistem
      final systemRadio = find.widgetWithText(RadioListTile<ThemeMode>, 'Ikuti Sistem');
      await tester.tap(systemRadio);
      await tester.pumpAndSettle();

      expect(controller.themeMode, ThemeMode.system);
    });
  });
}

