import 'package:flutter/material.dart';

import '../data/models/tugas.dart';
import '../data/services/api_service.dart';
import '../data/state/task_store.dart';
import 'profile/profile_page.dart';
import 'task_form/task_form_page.dart';

/// Root shell aplikasi Tugasku dengan NavigationBar (4 Tab) dan IndexedStack.
///
/// Tanggung jawab Anggota 5:
/// 1. Mengelola single instance [TasksStore]
/// 2. Menjaga state 4 tab dengan [IndexedStack]
/// 3. Menyediakan navigasi Material 3 [NavigationBar]
class RootNavigation extends StatefulWidget {
  final TasksStore? tasksStore;

  const RootNavigation({super.key, this.tasksStore});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;
  late final TasksStore _tasksStore;
  late final bool _internalStore;

  @override
  void initState() {
    super.initState();
    if (widget.tasksStore != null) {
      _tasksStore = widget.tasksStore!;
      _internalStore = false;
    } else {
      _tasksStore = TasksStore(api: ApiService());
      _internalStore = true;
    }
  }

  @override
  void dispose() {
    if (_internalStore) {
      _tasksStore.dispose();
    }
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _TabPlaceholder(
            title: 'Hari Ini',
            subtitle: 'Tugas mendesak (< 24 jam) & terlambat',
            icon: Icons.today_rounded,
            tasksStore: _tasksStore,
          ),
          _TasksTabPlaceholder(
            tasksStore: _tasksStore,
          ),
          _TabPlaceholder(
            title: 'Jadwal Kuliah',
            subtitle: 'Jadwal mingguan dikelompokkan per hari',
            icon: Icons.calendar_month_rounded,
            tasksStore: _tasksStore,
          ),
          ProfilePage(
            tasksStore: _tasksStore,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: colors.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Placeholder view untuk tab tugas lengkap dengan FAB tambah tugas.
class _TasksTabPlaceholder extends StatelessWidget {
  final TasksStore tasksStore;

  const _TasksTabPlaceholder({required this.tasksStore});

  Future<void> _openAddTask(BuildContext context) async {
    final newTask = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormPage()),
    );
    if (newTask != null) {
      tasksStore.addTask(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tab Tugas (Member 2)',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Daftar tugas dengan filter, checkbox selesai, dan penanda < 24 jam.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _openAddTask(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Tugas Baru'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(context),
        tooltip: 'Tambah tugas',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Generic placeholder view untuk tab lain sebelum diintegrasikan oleh anggota lain.
class _TabPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final TasksStore tasksStore;

  const _TabPlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tasksStore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: colors.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
