import 'package:flutter/material.dart';

import '../data/services/api_service.dart';
import '../data/state/task_store.dart';
import '../data/state/theme_controller.dart';
import 'profile/profile_page.dart';
import 'schedule/schedule_page.dart';
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
  final ThemeController? themeController;

  const RootNavigation({
    super.key,
    this.tasksStore,
    this.apiService,
    this.themeController,
  });

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
    _apiService = widget.apiService ?? widget.tasksStore?.api ?? ApiService();
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
          SchedulePage(
            apiService: _apiService,
          ),
          ProfilePage(
            tasksStore: _tasksStore,
            themeController: widget.themeController,
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

