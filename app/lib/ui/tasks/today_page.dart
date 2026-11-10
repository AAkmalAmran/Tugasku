import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/tugas.dart';
import '../../data/services/api_service.dart';
import '../../data/state/task_store.dart';
import '../detail/detail_page.dart';
import 'task_card.dart';

/// Tab Hari Ini (Member 2)
/// Menampilkan tugas-tugas mendesak (belum selesai) yang terlambat atau jatuh tempo < 24 jam.
class TodayPage extends StatefulWidget {
  final ApiService? apiService;
  final TasksStore? tasksStore;

  const TodayPage({
    super.key,
    this.apiService,
    this.tasksStore,
  });

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late ApiService _apiService;
  Future<List<Tugas>>? _tasksFuture;
  List<Tugas>? _localTasks;

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

  Future<void> _openDetail(Tugas task) async {
    final heroTag = 'task-today-${task.id}';
    final updatedTask = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          task: task,
          heroTag: heroTag,
          apiService: _apiService,
          onStatusChanged: (isDone) {
            _onToggleTaskDone(task, isDone);
          },
        ),
      ),
    );

    if (!mounted || updatedTask == null) return;
    if (updatedTask.selesai != task.selesai) {
      _onToggleTaskDone(task, updatedTask.selesai);
    }
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
              Icons.task_alt_rounded,
              size: 64,
              color: colors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada tugas mendesak',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua tugas dalam kontrol yang baik atau sudah selesai!',
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

  Widget _buildSectionHeader(String title, ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final now = DateTime.now();
    String formattedToday;
    try {
      formattedToday = DateFormat('EEE, d MMM', 'id_ID').format(now);
    } catch (_) {
      formattedToday = DateFormat('EEE, d MMM').format(now);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hari Ini'),
            Text(
              formattedToday,
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Tugas>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _localTasks == null) {
            return _buildLoadingState();
          }

          if (snapshot.hasError && _localTasks == null) {
            return _buildErrorState(snapshot.error, colors, textTheme);
          }

          if (snapshot.hasData && _localTasks == null) {
            _localTasks = List<Tugas>.from(snapshot.data!);
          } else if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done &&
              _localTasks != null) {
            _localTasks = List<Tugas>.from(snapshot.data!);
          }

          final tasks = _localTasks ?? [];

          // Filter unfinished tasks
          final unfinished = tasks.where((t) => !t.selesai).toList();

          // Section 1: Overdue tasks
          final overdue = unfinished
              .where((t) => t.tenggat.isBefore(now))
              .toList()
            ..sort((a, b) => a.tenggat.compareTo(b.tenggat));

          // Section 2: Due within 24 hours
          final dueWithin24Hours = unfinished.where((t) {
            final diff = t.tenggat.difference(now);
            return !t.tenggat.isBefore(now) &&
                diff >= Duration.zero &&
                diff < const Duration(hours: 24);
          }).toList()
            ..sort((a, b) => a.tenggat.compareTo(b.tenggat));

          final totalUrgent = overdue.length + dueWithin24Hours.length;

          if (totalUrgent == 0) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildEmptyState(colors, textTheme),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Urgent banner summary
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: colors.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$totalUrgent tugas mendesak perlu diselesaikan',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (overdue.isNotEmpty) ...[
                  _buildSectionHeader('Terlambat', colors, textTheme),
                  ...overdue.map(
                    (task) => TaskCard(
                      task: task,
                      heroTag: 'task-today-${task.id}',
                      onTap: () => _openDetail(task),
                      onToggleDone: (isDone) => _onToggleTaskDone(task, isDone),
                    ),
                  ),
                ],

                if (dueWithin24Hours.isNotEmpty) ...[
                  _buildSectionHeader('Kurang dari 24 jam', colors, textTheme),
                  ...dueWithin24Hours.map(
                    (task) => TaskCard(
                      task: task,
                      heroTag: 'task-today-${task.id}',
                      onTap: () => _openDetail(task),
                      onToggleDone: (isDone) => _onToggleTaskDone(task, isDone),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

