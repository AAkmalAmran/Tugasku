import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/tugas.dart';

/// Kartu tugas kustom sesuai standar Material 3 dan spesifikasi Design.md.
/// Menggabungkan Row, Column, Expanded, dan Stack.
class TaskCard extends StatefulWidget {
  final Tugas task;
  final String? heroTag;
  final ValueChanged<bool>? onToggleDone;
  final VoidCallback? onTap;
  final DateTime? now; // Opsional untuk pengujian deterministik

  const TaskCard({
    super.key,
    required this.task,
    this.heroTag,
    this.onToggleDone,
    this.onTap,
    this.now,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.selesai;
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.selesai != widget.task.selesai) {
      _isDone = widget.task.selesai;
    }
  }

  DateTime get _effectiveNow => widget.now ?? DateTime.now();

  bool get _isOverdue => !_isDone && widget.task.tenggat.isBefore(_effectiveNow);

  bool get _isDueWithin24Hours {
    if (_isDone || _isOverdue) return false;
    final diff = widget.task.tenggat.difference(_effectiveNow);
    return diff >= Duration.zero && diff < const Duration(hours: 24);
  }

  String _formatDeadline(DateTime dateTime) {
    try {
      return DateFormat('EEE, d MMM yyyy · HH.mm', 'id_ID').format(dateTime);
    } catch (_) {
      // Fallback jika lokal belum terinisialisasi
      return DateFormat('EEE, d MMM yyyy · HH.mm').format(dateTime);
    }
  }

  Widget _buildPriorityChip(ColorScheme colors, TextTheme textTheme) {
    final String priority = widget.task.prioritas;
    final Color bgColor;
    final Color textColor;

    switch (priority) {
      case 'Tinggi':
        bgColor = colors.primaryContainer;
        textColor = colors.onPrimaryContainer;
        break;
      case 'Rendah':
        bgColor = colors.surfaceContainerHighest;
        textColor = colors.onSurfaceVariant;
        break;
      case 'Sedang':
      default:
        bgColor = colors.secondaryContainer;
        textColor = colors.onSecondaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget? _buildUrgencyBadge(ColorScheme colors, TextTheme textTheme) {
    if (!_isOverdue && !_isDueWithin24Hours) return null;

    final isLate = _isOverdue;
    final text = isLate ? 'Terlambat' : '< 24 jam';
    final icon = isLate
        ? Icons.warning_amber_rounded
        : Icons.schedule_rounded;

    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.onPrimary),
            const SizedBox(width: 4),
            Text(
              text,
              style: textTheme.labelSmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
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

    final formattedDeadline = _formatDeadline(widget.task.tenggat);
    final semanticStatus = _isDone ? 'Selesai' : 'Belum selesai';
    final badgeWidget = _buildUrgencyBadge(colors, textTheme);
    final effectiveTag = widget.heroTag ?? 'task-list-${widget.task.id}';

    return Semantics(
      label:
          'Tugas ${widget.task.judul}, mata kuliah ${widget.task.mataKuliah}, '
          'tenggat $formattedDeadline, prioritas ${widget.task.prioritas}, $semanticStatus',
      button: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  12,
                  badgeWidget != null ? 88 : 12,
                  12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isDone,
                      activeColor: colors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (bool? value) {
                        if (value == null) return;
                        setState(() {
                          _isDone = value;
                        });
                        widget.onToggleDone?.call(value);
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: effectiveTag,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                widget.task.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: _isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: _isDone
                                      ? colors.onSurfaceVariant
                                      : colors.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.task.mataKuliah,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildPriorityChip(colors, textTheme),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDeadline,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ?badgeWidget,
            ],
          ),
        ),
      ),
    );
  }
}

