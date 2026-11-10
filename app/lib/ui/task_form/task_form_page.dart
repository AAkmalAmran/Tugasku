import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/tugas.dart';
import '../../data/services/api_service.dart';

/// Halaman Form Tambah Tugas
class TaskFormPage extends StatefulWidget {
  final ApiService? apiService;

  const TaskFormPage({super.key, this.apiService});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _tenggatController = TextEditingController();

  DateTime? _selectedDeadline;
  String _selectedPriority = 'Sedang';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulController.addListener(_onFieldChanged);
    _mataKuliahController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _judulController.dispose();
    _mataKuliahController.dispose();
    _catatanController.dispose();
    _tenggatController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _judulController.text.trim().isNotEmpty &&
      _mataKuliahController.text.trim().isNotEmpty &&
      _selectedDeadline != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDeadline ?? now;
    final first = DateTime(now.year, now.month, now.day);
    final last = DateTime(now.year + 5);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      final deadlineWithTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        23,
        59,
      );
      setState(() {
        _selectedDeadline = deadlineWithTime;
        _tenggatController.text =
            DateFormat('EEE, d MMM yyyy', 'id_ID').format(deadlineWithTime);
      });
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    final taskToCreate = Tugas(
      id: 0,
      judul: _judulController.text.trim(),
      mataKuliah: _mataKuliahController.text.trim(),
      prioritas: _selectedPriority,
      tenggat: _selectedDeadline!,
      selesai: false,
      catatan: _catatanController.text.trim(),
    );

    try {
      final service = widget.apiService ?? ApiService();
      final createdTask = await service.createTask(taskToCreate);

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas ditambahkan'),
        ),
      );

      Navigator.maybePop(context, createdTask);
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan. Coba lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Batal',
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _judulController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Judul *',
                  hintText: 'Misal: Laporan Praktikum Basis Data',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mataKuliahController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Mata kuliah *',
                  hintText: 'Misal: Basis Data',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Prioritas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Rendah',
                    label: Text('Rendah'),
                  ),
                  ButtonSegment<String>(
                    value: 'Sedang',
                    label: Text('Sedang'),
                  ),
                  ButtonSegment<String>(
                    value: 'Tinggi',
                    label: Text('Tinggi'),
                  ),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: _isLoading
                    ? null
                    : (newSelection) {
                        setState(() {
                          _selectedPriority = newSelection.first;
                        });
                      },
                showSelectedIcon: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tenggatController,
                readOnly: true,
                onTap: _isLoading ? null : _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Tenggat *',
                  hintText: 'Pilih tanggal',
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _catatanController,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Detail tugas, instruksi pengerjaan, dsb.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isFormValid && !_isLoading ? _submit : null,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onPrimary,
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

