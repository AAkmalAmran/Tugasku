import 'package:flutter/material.dart';

import '../../data/state/theme_controller.dart';

/// Halaman Pengaturan Aplikasi (Anggota 4)
///
/// Memungkinkan pengguna mengatur preferensi tema (Terang, Gelap, Sistem)
/// secara interaktif dan real-time, serta menampilkan informasi aplikasi.
class SettingsPage extends StatelessWidget {
  final ThemeController? themeController;

  const SettingsPage({super.key, this.themeController});

  @override
  Widget build(BuildContext context) {
    final controller = themeController ?? ThemeScope.maybeOf(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: false,
      ),
      body: controller == null
          ? const Center(child: Text('Pengaturan tema tidak tersedia'))
          : ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final currentMode = controller.themeMode;
                final isDark = currentMode == ThemeMode.dark;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // Section 1: Tema & Tampilan
                    Text(
                      'Tampilan Aplikasi',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // Switch interaktif Mode Gelap Cepat
                            SwitchListTile(
                              title: Text(
                                'Mode Gelap',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                isDark
                                    ? 'Mode gelap aktif'
                                    : (currentMode == ThemeMode.system
                                        ? 'Mengikuti pengaturan sistem'
                                        : 'Mode terang aktif'),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              secondary: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: colors.secondary,
                              ),
                              value: isDark,
                              onChanged: (val) {
                                controller.toggleDarkMode(val);
                              },
                            ),
                            const Divider(height: 16),

                            // Pilihan Mode Lengkap: RadioGroup (Sistem / Terang / Gelap)
                            RadioGroup<ThemeMode>(
                              groupValue: currentMode,
                              onChanged: (mode) {
                                if (mode != null) controller.setThemeMode(mode);
                              },
                              child: const Column(
                                children: [
                                  RadioListTile<ThemeMode>(
                                    title: Text('Ikuti Sistem'),
                                    subtitle: Text(
                                      'Otomatis mengikuti preferensi perangkat',
                                    ),
                                    secondary: Icon(Icons.brightness_auto_rounded),
                                    value: ThemeMode.system,
                                  ),
                                  RadioListTile<ThemeMode>(
                                    title: Text('Mode Terang'),
                                    subtitle: Text(
                                      'Tampilan cerah dengan tema merah & krem',
                                    ),
                                    secondary: Icon(Icons.light_mode_outlined),
                                    value: ThemeMode.light,
                                  ),
                                  RadioListTile<ThemeMode>(
                                    title: Text('Mode Gelap'),
                                    subtitle: Text(
                                      'Tampilan kontras gelap ramah mata',
                                    ),
                                    secondary: Icon(Icons.dark_mode_outlined),
                                    value: ThemeMode.dark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Informasi Aplikasi
                    Text(
                      'Tentang Aplikasi',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: colors.onPrimaryContainer,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tugasku',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Pengingat Jadwal Kuliah & Tugas',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const _InfoRow(
                              icon: Icons.info_outline_rounded,
                              label: 'Versi',
                              value: '1.0.0+1',
                            ),
                            const SizedBox(height: 12),
                            const _InfoRow(
                              icon: Icons.group_outlined,
                              label: 'Pengembang',
                              value: 'Kelompok 03 (PAB)',
                            ),
                            const SizedBox(height: 12),
                            const _InfoRow(
                              icon: Icons.code_rounded,
                              label: 'Teknologi',
                              value: 'Flutter & Dart Shelf REST API',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
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
