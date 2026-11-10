import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola state tema aplikasi (Sistem, Terang, Gelap)
/// dan menyimpannya secara persisten ke SharedPreferences.
class ThemeController extends ChangeNotifier {
  static const String themePreferenceKey = 'theme_mode';

  ThemeMode _themeMode;
  SharedPreferences? _prefs;

  ThemeController({
    SharedPreferences? prefs,
    ThemeMode initialMode = ThemeMode.system,
  })  : _prefs = prefs,
        _themeMode = initialMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Memuat preferensi tema yang tersimpan dari SharedPreferences.
  Future<void> loadThemeMode() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedMode = _prefs?.getString(themePreferenceKey);
    if (savedMode != null) {
      _themeMode = _parseThemeMode(savedMode);
      notifyListeners();
    }
  }

  /// Mengubah tema aplikasi dan menyimpannya secara persisten.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(themePreferenceKey, mode.name);
  }

  /// Mengubah tema antara Terang dan Gelap (toggle switch).
  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  static ThemeMode _parseThemeMode(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// InheritedNotifier untuk membagikan [ThemeController] ke seluruh widget tree.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope tidak ditemukan di BuildContext');
    return scope!.notifier!;
  }

  static ThemeController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    return scope?.notifier;
  }
}

