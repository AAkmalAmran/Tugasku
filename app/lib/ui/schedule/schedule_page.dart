import 'package:flutter/material.dart';

import '../../data/models/jadwal.dart';
import '../../data/services/api_service.dart';

/// Tab Jadwal Kuliah (Anggota 4 - Signature Feature)
///
/// Menampilkan jadwal kuliah mingguan yang dikelompokkan berdasarkan hari
/// (Senin s/d Sabtu) dengan FutureBuilder (Loading, Error, Success).
class SchedulePage extends StatefulWidget {
  final ApiService? apiService;

  const SchedulePage({super.key, this.apiService});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final ApiService _apiService;
  late Future<List<Jadwal>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _loadSchedule();
  }

  void _loadSchedule() {
    setState(() {
      _scheduleFuture = _apiService.fetchSchedule();
    });
  }

  Future<void> _handleRefresh() async {
    _loadSchedule();
    await _scheduleFuture;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<Jadwal>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
                      'Gagal memuat jadwal',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
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
                      onPressed: _loadSchedule,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allSchedules = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: Jadwal.days.length,
              itemBuilder: (context, index) {
                final day = Jadwal.days[index];
                final daySchedules = allSchedules
                    .where((item) => item.hari.toLowerCase() == day.toLowerCase())
                    .toList()
                  ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Hari (warna secondary / teal)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Text(
                          day.toUpperCase(),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: colors.secondary,
                          ),
                        ),
                      ),
                      if (daySchedules.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  size: 20,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Tidak ada kuliah',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...daySchedules.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.mataKuliah,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: colors.secondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${item.jamMulai} – ${item.jamSelesai}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.meeting_room_outlined,
                                          size: 18,
                                          color: colors.secondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Ruang: ${item.ruangan}',
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
