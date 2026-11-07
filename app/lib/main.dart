import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme.dart';

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
      // TODO(Member 5): replace with const RootNavigation()
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary home so the app runs before RootNavigation exists.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Text(
          'Tugasku',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: colors.primary),
        ),
      ),
    );
  }
}