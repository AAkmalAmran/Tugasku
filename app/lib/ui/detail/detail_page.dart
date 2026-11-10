import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/tugas.dart';
import '../../data/services/api_service.dart';
import '../../data/state/task_store.dart';

/// Halaman Detail Tugas (Member 3)
///
/// Menampilkan informasi lengkap suatu tugas dan menyediakan tombol interaktif
/// untuk memperbarui status penyelesaian tugas.
class DetailPage extends StatefulWidget {
  final int taskId;
  final Tugas? task;
  final String? heroTag;
  final ApiService? apiService;
  final TasksStore? store;
  final void Function(Tugas updatedTask)? onTaskUpdated;

  const DetailPage({
    super.key,
    required this.taskId,
    this.task,
    this.heroTag,
    this.apiService,
    this.store,
    this.onTaskUpdated,
  });

  /// Constructor praktis jika sudah memegang objek [Tugas].
  DetailPage.fromTask({
    Key? key,
    required Tugas task,
    String? heroTag,
    ApiService? apiService,
    TasksStore? store,
    void Function(Tugas updatedTask)? onTaskUpdated,
  }) : this(
          key: key,
          taskId: task.id,
          task: task,
          heroTag: heroTag,
          apiService: apiService,
          store: store,
          onTaskUpdated: onTaskUpdated,
        );

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final ApiService _apiService;
  Tugas? _task;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _task = widget.task;

    if (_task == null) {
      _fetchDetail(showLoading: true);
    } else {
      _fetchDetail(showLoading: false);
    }
  }

  Future<void> _fetchDetail({required bool showLoading}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final fetched = await _apiService.fetchTask(widget.taskId);
      if (!mounted) return;
      setState(() {
        _task = fetched;
        _isLoading = false;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (_task == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      if (!mounted) return;
      if (_task == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Gagal memuat detail tugas. Periksa koneksi atau server lalu coba lagi.';
        });
      }
    }
  }

  void _toggleCompletion() {
    if (_task == null) return;
    final updated = _task!.copyWith(selesai: !_task!.selesai);
    setState(() {
      _task = updated;
    });

    widget.store?.setDone(updated.id, updated.selesai);
    widget.onTaskUpdated?.call(updated);

    final message =
        updated.selesai ? 'Ditandai selesai' : 'Ditandai belum selesai';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: _toggleCompletion,
        ),
      ),
    );
  }

  bool get _isOverdue {
    if (_task == null || _task!.selesai) return false;
    return DateTime.now().isAfter(_task!.tenggat);
  }

  bool get _isDueWithin24Hours {
    if (_task == null || _task!.selesai) return false;
    final now = DateTime.now();
    final diff = _task!.tenggat.difference(now);
    return diff >= Duration.zero && diff < const Duration(hours: 24);
  }

  String _formatDeadline(DateTime dateTime) {
    try {
      return DateFormat('EEEE, d MMM yyyy · HH.mm', 'id_ID').format(dateTime);
    } catch (_) {
      final local = dateTime.toLocal();
      const dayNames = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final day = dayNames[local.weekday - 1];
      final month = monthNames[local.month - 1];
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$day, ${local.day} $month ${local.year} · $hour.$minute';
    }
  }

  String _formatRelativeTime(DateTime deadline, bool isDone) {
    if (isDone) return 'Tugas sudah selesai';
    final now = DateTime.now();
    if (now.isAfter(deadline)) {
      final diff = now.difference(deadline);
      if (diff.inDays >= 1) {
        return 'Terlambat ${diff.inDays} hari';
      } else if (diff.inHours >= 1) {
        return 'Terlambat ${diff.inHours} jam';
      } else {
        return 'Terlambat ${diff.inMinutes.clamp(1, 60)} menit';
      }
    } else {
      final diff = deadline.difference(now);
      if (diff.inDays >= 1) {
        final hours = diff.inHours % 24;
        return hours > 0
            ? 'Sisa ${diff.inDays} hari $hours jam'
            : 'Sisa ${diff.inDays} hari';
      } else if (diff.inHours >= 1) {
        final minutes = diff.inMinutes % 60;
        return minutes > 0
            ? 'Sisa ${diff.inHours} jam $minutes menit'
            : 'Sisa ${diff.inHours} jam';
      } else {
        return 'Sisa ${diff.inMinutes.clamp(1, 60)} menit';
      }
    }
  }

  (Color bg, Color fg) _getPriorityColors(
      String priority, ColorScheme colors) {
    switch (priority) {
      case 'Tinggi':
        return (colors.primaryContainer, colors.onPrimaryContainer);
      case 'Sedang':
        return (colors.secondaryContainer, colors.onSecondaryContainer);
      case 'Rendah':
      default:
        return (colors.surfaceContainerHighest, colors.onSurfaceVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _task);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Tugas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Kembali',
            onPressed: () => Navigator.pop(context, _task),
          ),
          actions: [
            if (_isLoading && _task != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              )
            else if (_task != null)
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Muat ulang',
                onPressed: () => _fetchDetail(showLoading: false),
              ),
          ],
        ),
        body: _buildBody(context, colors, textTheme),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, ColorScheme colors, TextTheme textTheme) {
    if (_isLoading && _task == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _task == null) {
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
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () => _fetchDetail(showLoading: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_task == null) {
      return const SizedBox.shrink();
    }

    final priorityColors = _getPriorityColors(_task!.prioritas, colors);

    return RefreshIndicator(
      onRefresh: () => _fetchDetail(showLoading: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Tugas dengan Hero Animation & Strikethrough saat selesai
            Hero(
              tag: widget.heroTag ?? 'task-${_task!.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  _task!.judul,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration:
                        _task!.selesai ? TextDecoration.lineThrough : null,
                    color: _task!.selesai
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Chips: Prioritas, Status Selesai, dan Badge Urgensi (< 24 jam / Terlambat)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.flag_rounded,
                    size: 16,
                    color: priorityColors.$2,
                  ),
                  label: Text(_task!.prioritas),
                  labelStyle: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: priorityColors.$2,
                  ),
                  backgroundColor: priorityColors.$1,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _task!.selesai
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: _task!.selesai
                        ? colors.onSecondaryContainer
                        : colors.onSurfaceVariant,
                  ),
                  label: Text(_task!.selesai ? 'Selesai' : 'Belum selesai'),
                  labelStyle: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _task!.selesai
                        ? colors.onSecondaryContainer
                        : colors.onSurfaceVariant,
                  ),
                  backgroundColor: _task!.selesai
                      ? colors.secondaryContainer
                      : colors.surfaceContainerHighest,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                if (_isOverdue)
                  Chip(
                    avatar: Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colors.onPrimary,
                    ),
                    label: const Text('Terlambat'),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                    backgroundColor: colors.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                else if (_isDueWithin24Hours)
                  Chip(
                    avatar: Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: colors.onPrimary,
                    ),
                    label: const Text('< 24 jam'),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                    backgroundColor: colors.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Detail Atribut
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile(
                      icon: Icons.school_outlined,
                      label: 'Mata Kuliah',
                      value: _task!.mataKuliah,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const Divider(height: 24),
                    _buildDeadlineTile(colors, textTheme),
                    const Divider(height: 24),
                    _buildStatusTile(colors, textTheme),
                    const Divider(height: 24),
                    _buildNotesTile(colors, textTheme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi Material 3 (Tandai Selesai & Kembali)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, _task),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _toggleCompletion,
                    child: Text(
                      _task!.selesai
                          ? 'Tandai belum selesai'
                          : 'Tandai selesai',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineTile(ColorScheme colors, TextTheme textTheme) {
    final relativeText = _formatRelativeTime(_task!.tenggat, _task!.selesai);
    final relativeColor = _isOverdue
        ? colors.error
        : (_isDueWithin24Hours ? colors.primary : colors.onSurfaceVariant);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.calendar_today_rounded, size: 22, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tenggat',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDeadline(_task!.tenggat),
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: relativeColor),
                  const SizedBox(width: 4),
                  Text(
                    relativeText,
                    style: textTheme.bodySmall?.copyWith(
                      color: relativeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTile(ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          _task!.selesai
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 22,
          color: colors.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _task!.selesai ? 'Selesai' : 'Belum selesai',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Checkbox(
          value: _task!.selesai,
          onChanged: (_) => _toggleCompletion(),
          activeColor: colors.secondary,
        ),
      ],
    );
  }

  Widget _buildNotesTile(ColorScheme colors, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.notes_rounded, size: 22, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catatan',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _task!.catatan.trim().isEmpty
                    ? 'Tidak ada catatan.'
                    : _task!.catatan,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
