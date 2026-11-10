import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/state/theme_controller.dart';
import 'theme.dart';
import 'ui/root_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final themeController = ThemeController();
  await themeController.loadThemeMode();
  runApp(TugaskuApp(themeController: themeController));
}

class TugaskuApp extends StatefulWidget {
  final ThemeController? themeController;

  const TugaskuApp({super.key, this.themeController});

  @override
  State<TugaskuApp> createState() => _TugaskuAppState();
}

class _TugaskuAppState extends State<TugaskuApp> {
  late final ThemeController _themeController;
  late final bool _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.themeController != null) {
      _themeController = widget.themeController!;
      _internalController = false;
    } else {
      _themeController = ThemeController();
      _internalController = true;
      _themeController.loadThemeMode();
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _themeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tugasku',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeController.themeMode,
          debugShowCheckedModeBanner: false,
          home: ThemeScope(
            controller: _themeController,
            child: RootNavigation(themeController: _themeController),
          ),
        );
      },
    );
  }
}
