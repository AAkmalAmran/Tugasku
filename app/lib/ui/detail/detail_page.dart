import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/tugas.dart';
import '../../data/services/api_service.dart';

/// Halaman Detail Tugas (Member 3)
/// Menerima objek [Tugas] dan [heroTag] melalui konstruktor.
class DetailPage extends StatefulWidget {
  final Tugas task;
  final String heroTag;
  final ApiService? apiService;
  final ValueChanged<bool>? onStatusChanged;

  const DetailPage({
    super.key,
    required this.task,
    required this.heroTag,
    this.apiService,
    this.onStatusChanged,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Tugas _task;
  bool _isLoadingBackground = false;
  String? _backgroundError;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _refreshFromServer();
  }

  Future<void> _refreshFromServer() async {
    final service = widget.apiService;
    if (service == null) return;

    setState(() {
      _isLoadingBackground = true;
      _backgroundError = null;
    });

    try {
      final fresh = await service.fetchTask(_task.id);
      if (!mounted) return;
      setState(() {
        _task = fresh;
        _isLoadingBackground = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingBackground = false;
        _backgroundError = 'Tidak dapat memperbarui data dari server';
      });
    }
  }

  void _toggleStatus() {
    final newStatus = !_task.selesai;
    setState(() {
      _task = _task.copyWith(selesai: newStatus);
    });
    widget.onStatusChanged?.call(newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus ? 'Ditandai selesai' : 'Ditandai belum selesai',
        ),
      ),
    );
  }

  String _formatDeadline(DateTime dateTime) {
    try {
      return DateFormat('EEEE, d MMMM yyyy · HH.mm', 'id_ID').format(dateTime);
    } catch (_) {
      return DateFormat('EEEE, d MMMM yyyy · HH.mm').format(dateTime);
    }
  }

  String _formatRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    if (deadline.isBefore(now)) {
      final diff = now.difference(deadline);
      final days = diff.inDays;
      if (days > 0) return 'Terlambat $days hari';
      final hours = diff.inHours;
      return 'Terlambat $hours jam';
    } else {
      final diff = deadline.difference(now);
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      if (days > 0) {
        return 'Sisa $days hari $hours jam';
      }
      return 'Sisa $hours jam';
    }
  }

  Widget _buildPriorityBadge(ColorScheme colors, TextTheme textTheme) {
    final String priority = _task.prioritas;
    final Color bg;
    final Color fg;
    switch (priority) {
      case 'Tinggi':
        bg = colors.primaryContainer;
        fg = colors.onPrimaryContainer;
        break;
      case 'Rendah':
        bg = colors.surfaceContainerHighest;
        fg = colors.onSurfaceVariant;
        break;
      case 'Sedang':
      default:
        bg = colors.secondaryContainer;
        fg = colors.onSecondaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme colors, TextTheme textTheme) {
    final isDone = _task.selesai;
    final bg = isDone ? colors.secondaryContainer : colors.surfaceContainerHighest;
    final fg = isDone ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            isDone ? 'Selesai' : 'Belum selesai',
            style: textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
        title: const Text('Detail Tugas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context, _task),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoadingBackground)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              if (_backgroundError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: colors.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _backgroundError!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _refreshFromServer,
                        child: Text(
                          'Coba lagi',
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              Hero(
                tag: widget.heroTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    _task.judul,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: _task.selesai ? TextDecoration.lineThrough : null,
                      color: _task.selesai ? colors.onSurfaceVariant : colors.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPriorityBadge(colors, textTheme),
                  _buildStatusBadge(colors, textTheme),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _DetailItem(
                icon: Icons.school_rounded,
                label: 'Mata Kuliah',
                value: _task.mataKuliah,
              ),
              const SizedBox(height: 16),
              _DetailItem(
                icon: Icons.calendar_today_rounded,
                label: 'Tenggat Waktu',
                value: _formatDeadline(_task.tenggat),
                subtitle: _formatRemainingTime(_task.tenggat),
              ),
              const SizedBox(height: 16),
              _DetailItem(
                icon: Icons.notes_rounded,
                label: 'Catatan',
                value: _task.catatan.isEmpty ? '-' : _task.catatan,
              ),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: _toggleStatus,
                child: Text(
                  _task.selesai ? 'Tandai belum selesai' : 'Tandai selesai',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, _task),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.primary),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

