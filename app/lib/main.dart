import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme.dart';
import 'ui/root_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const TugaskuApp());
}

class TugaskuApp extends StatelessWidget {
  const TugaskuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugasku',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const RootNavigation(),
    );
  }
}
