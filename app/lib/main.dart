import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/models/tugas.dart';
import 'theme.dart';
import 'ui/task_form/task_form_page.dart';

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
/// The FAB lets Member 1 try the Add Task form (remove once Tugas tab exists).
class _PlaceholderHome extends StatefulWidget {
  const _PlaceholderHome();

  @override
  State<_PlaceholderHome> createState() => _PlaceholderHomeState();
}

class _PlaceholderHomeState extends State<_PlaceholderHome> {
  Tugas? _lastCreated;

  Future<void> _openForm() async {
    final newTask = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormPage()),
    );
    if (!mounted) return;
    if (newTask != null) setState(() => _lastCreated = newTask);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tugasku',
              style: textTheme.headlineSmall?.copyWith(color: colors.primary),
            ),
            if (_lastCreated != null) ...[
              const SizedBox(height: 16),
              Text(
                'Tersimpan: #${_lastCreated!.id} ${_lastCreated!.judul}',
                style: textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'Tambah tugas',
        child: const Icon(Icons.add),
      ),
    );
  }
}