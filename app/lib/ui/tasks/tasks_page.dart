import 'package:flutter/material.dart';

import '../../data/models/tugas.dart';
import '../../data/services/api_service.dart';
import '../../data/state/task_store.dart';
import '../detail/detail_page.dart';
import '../task_form/task_form_page.dart';
import 'task_card.dart';

/// Tab Daftar Tugas (Member 2)
/// Menampilkan daftar tugas dengan FutureBuilder (3 state eksplisit: Loading, Error, Success),
/// FilterChip/ChoiceChip, RefreshIndicator, FAB tambah tugas, dan navigasi Hero ke DetailPage.
class TasksPage extends StatefulWidget {
  final ApiService? apiService;
  final TasksStore? tasksStore;

  const TasksPage({
    super.key,
    this.apiService,
    this.tasksStore,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late ApiService _apiService;
  Future<List<Tugas>>? _tasksFuture;
  List<Tugas>? _localTasks;

  // Filter state
  String _statusFilter = 'Semua'; // 'Semua', 'Belum selesai', 'Selesai'
  bool _filterOnlyHighPriority = false;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _loadTasks();

    if (widget.tasksStore != null) {
      widget.tasksStore!.addListener(_onStoreChanged);
    }
  }

  @override
  void dispose() {
    widget.tasksStore?.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {
        _tasksFuture = widget.tasksStore!.tasks;
      });
    }
  }

  void _loadTasks() {
    setState(() {
      if (widget.tasksStore != null) {
        _tasksFuture = widget.tasksStore!.tasks;
      } else {
        _tasksFuture = _apiService.fetchTasks();
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (widget.tasksStore != null) {
      widget.tasksStore!.load();
    } else {
      final future = _apiService.fetchTasks();
      setState(() {
        _tasksFuture = future;
      });
      await future;
    }
  }

  void _onToggleTaskDone(Tugas task, bool isDone) {
    if (widget.tasksStore != null) {
      widget.tasksStore!.setDone(task.id, isDone);
    } else if (_localTasks != null) {
      setState(() {
        final index = _localTasks!.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _localTasks![index] = _localTasks![index].copyWith(selesai: isDone);
        }
      });
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDone ? 'Ditandai selesai' : 'Ditandai belum selesai',
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAddTaskForm() async {
    final newTask = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(apiService: _apiService),
      ),
    );

    if (!mounted) return;

    if (newTask != null) {
      if (widget.tasksStore != null) {
        widget.tasksStore!.addTask(newTask);
      } else {
        setState(() {
          if (_localTasks != null) {
            _localTasks!.add(newTask);
          } else {
            _localTasks = [newTask];
          }
        });
      }
    }
  }

  Future<void> _openDetail(Tugas task) async {
    final heroTag = 'task-list-${task.id}';
    final updatedTask = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          taskId: task.id,
          task: task,
          heroTag: heroTag,
          apiService: _apiService,
        ),
      ),
    );

    if (!mounted || updatedTask == null) return;
    if (updatedTask.selesai != task.selesai) {
      _onToggleTaskDone(task, updatedTask.selesai);
    }
  }

  List<Tugas> _applyFilters(List<Tugas> allTasks) {
    return allTasks.where((task) {
      // Filter status
      if (_statusFilter == 'Belum selesai' && task.selesai) return false;
      if (_statusFilter == 'Selesai' && !task.selesai) return false;

      // Filter prioritas tinggi
      if (_filterOnlyHighPriority && task.prioritas != 'Tinggi') return false;

      return true;
    }).toList()
      ..sort((a, b) {
        // Unfinished first, then sorted by deadline
        if (a.selesai != b.selesai) {
          return a.selesai ? 1 : -1;
        }
        return a.tenggat.compareTo(b.tenggat);
      });
  }

  Widget _buildFilterChips(ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Semua'),
            selected: _statusFilter == 'Semua',
            onSelected: (selected) {
              if (selected) setState(() => _statusFilter = 'Semua');
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Belum selesai'),
            selected: _statusFilter == 'Belum selesai',
            onSelected: (selected) {
              if (selected) setState(() => _statusFilter = 'Belum selesai');
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Selesai'),
            selected: _statusFilter == 'Selesai',
            onSelected: (selected) {
              if (selected) setState(() => _statusFilter = 'Selesai');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Tinggi'),
            selected: _filterOnlyHighPriority,
            onSelected: (selected) {
              setState(() => _filterOnlyHighPriority = selected);
            },
            selectedColor: colors.secondaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object? error, ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi atau server lalu coba lagi.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: _loadTasks,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 64,
              color: colors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tugas',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk tombol + untuk menambah tugas baru.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
      ),
      body: FutureBuilder<List<Tugas>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting &&
              _localTasks == null) {
            return _buildLoadingState();
          }

          // State 2: Error
          if (snapshot.hasError && _localTasks == null) {
            return _buildErrorState(snapshot.error, colors, textTheme);
          }

          // Update local tasks saat snapshot data berhasil diterima
          if (snapshot.hasData && _localTasks == null) {
            _localTasks = List<Tugas>.from(snapshot.data!);
          } else if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done &&
              _localTasks != null) {
            // Sinkronisasi data baru saat refresh
            _localTasks = List<Tugas>.from(snapshot.data!);
          }

          final tasksToDisplay = _localTasks ?? [];
          final filtered = _applyFilters(tasksToDisplay);

          // State 3: Success
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilterChips(colors),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState(colors, textTheme)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            return TaskCard(
                              task: task,
                              heroTag: 'task-list-${task.id}',
                              onTap: () => _openDetail(task),
                              onToggleDone: (isDone) {
                                _onToggleTaskDone(task, isDone);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskForm,
        tooltip: 'Tambah tugas',
        child: const Icon(Icons.add),
      ),
    );
  }
}

