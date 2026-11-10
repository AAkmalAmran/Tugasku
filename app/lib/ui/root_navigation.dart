import 'package:flutter/material.dart';

import '../data/services/api_service.dart';
import '../data/state/task_store.dart';
import 'profile/profile_page.dart';
import 'tasks/today_page.dart';
import 'tasks/tasks_page.dart';

/// Root shell aplikasi Tugasku dengan NavigationBar (4 Tab) dan IndexedStack.
///
/// Tanggung jawab Anggota 5:
/// 1. Mengelola single instance [TasksStore]
/// 2. Menjaga state 4 tab dengan [IndexedStack]
/// 3. Menyediakan navigasi Material 3 [NavigationBar]
class RootNavigation extends StatefulWidget {
  final TasksStore? tasksStore;
  final ApiService? apiService;

  const RootNavigation({super.key, this.tasksStore, this.apiService});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;
  late final ApiService _apiService;
  late final TasksStore _tasksStore;
  late final bool _internalStore;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.tasksStore != null) {
      _tasksStore = widget.tasksStore!;
      _internalStore = false;
    } else {
      _tasksStore = TasksStore(api: _apiService);
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
          TodayPage(
            apiService: _apiService,
            tasksStore: _tasksStore,
          ),
          TasksPage(
            apiService: _apiService,
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
