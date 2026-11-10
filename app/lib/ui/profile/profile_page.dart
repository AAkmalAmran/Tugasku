import 'package:flutter/material.dart';

import '../../data/models/profil.dart';
import '../../data/models/tugas.dart';
import '../../data/services/api_service.dart';
import '../../data/state/task_store.dart';
import '../../data/state/theme_controller.dart';
import '../settings/settings_page.dart';

/// Halaman Profil Mahasiswa (Anggota 5)
///
/// Menampilkan identitas mahasiswa dari server (GET /profil),
/// aset avatar lokal, ringkasan jumlah tugas (dihitung di client),
/// dan informasi akademik.
class ProfilePage extends StatefulWidget {
  final TasksStore tasksStore;
  final ApiService? apiService;
  final ThemeController? themeController;

  const ProfilePage({
    super.key,
    required this.tasksStore,
    this.apiService,
    this.themeController,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profil> _profileFuture;
  late final ApiService _api;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? widget.tasksStore.api;
    _profileFuture = _api.fetchProfile();
  }

  void _retry() {
    setState(() {
      _profileFuture = _api.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    themeController: widget.themeController,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Profil>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                      'Gagal memuat profil',
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Periksa koneksi atau server lalu coba lagi.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: _retry,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profil = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _retry();
              widget.tasksStore.load();
              await _profileFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar & Identitas Utama
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: colors.primaryContainer,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profil.nama,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profil.nim} · ${profil.programStudi}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Ringkasan Tugas (Komputasi Client dari TasksStore)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ringkasan Tugas',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: widget.tasksStore,
                    builder: (context, _) {
                      return FutureBuilder<List<Tugas>>(
                        future: widget.tasksStore.tasks,
                        builder: (context, taskSnapshot) {
                          final tasks = taskSnapshot.data ?? [];
                          final total = tasks.length;
                          final uncompleted =
                              tasks.where((t) => !t.selesai).length;
                          final completed =
                              tasks.where((t) => t.selesai).length;

                          return Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  label: 'Total',
                                  value: taskSnapshot.hasData
                                      ? total.toString()
                                      : '-',
                                  valueColor: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MetricCard(
                                  label: 'Belum',
                                  value: taskSnapshot.hasData
                                      ? uncompleted.toString()
                                      : '-',
                                  valueColor: colors.error,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MetricCard(
                                  label: 'Selesai',
                                  value: taskSnapshot.hasData
                                      ? completed.toString()
                                      : '-',
                                  valueColor: colors.secondary,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Informasi Akademik
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Informasi Akademik',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          _AcademicRow(
                            icon: Icons.school_outlined,
                            title: 'Semester',
                            value: 'Semester ${profil.semester}',
                          ),
                          const Divider(height: 20),
                          _AcademicRow(
                            icon: Icons.badge_outlined,
                            title: 'Dosen Wali',
                            value: profil.dosenWali,
                          ),
                          const Divider(height: 20),
                          _AcademicRow(
                            icon: Icons.auto_stories_outlined,
                            title: 'SKS Semester Ini',
                            value: '${profil.sksSemesterIni} SKS',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Pengaturan & Preferensi
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferensi',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.palette_outlined, color: colors.secondary),
                      title: const Text('Pengaturan Tampilan & Tema'),
                      subtitle: const Text('Mode Terang, Gelap, atau Sistem'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsPage(
                              themeController: widget.themeController,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AcademicRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 22, color: colors.secondary),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
