import 'package:flutter/material.dart';

import '../data/services/api_service.dart';
import '../data/state/task_store.dart';
import 'tasks/today_page.dart';
import 'tasks/tasks_page.dart';

/// Root navigation shell with Material 3 NavigationBar and IndexedStack (Member 5).
/// Holds the shared TasksStore instance.
class RootNavigation extends StatefulWidget {
  final ApiService? apiService;

  const RootNavigation({super.key, this.apiService});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 1; // Default to Tugas tab
  late final ApiService _apiService;
  late final TasksStore _tasksStore;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _tasksStore = TasksStore(api: _apiService);
  }

  @override
  void dispose() {
    _tasksStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const _PlaceholderTab(title: 'Jadwal Kuliah', icon: Icons.calendar_month_outlined),
          const _PlaceholderTab(title: 'Profil Mahasiswa', icon: Icons.person_outline),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colors.outlineVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

