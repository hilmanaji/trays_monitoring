import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Settings state & provider
// ─────────────────────────────────────────────────────────────────────────────

class AppSettings {
  const AppSettings({
    this.rfidPowerLevel = 2,
    this.beepEnabled = true,
    this.hapticEnabled = true,
    this.gloveModeEnabled = false,
    this.darkMode = true,
    this.scanMode = ScanMode.toggle,
    this.rfidRegion = RfidRegion.id,
  });

  /// 0 = Near (low power), 1 = Normal, 2 = Far (high power)
  final int rfidPowerLevel;
  final bool beepEnabled;
  final bool hapticEnabled;
  final bool gloveModeEnabled;
  final bool darkMode;
  final ScanMode scanMode;
  final RfidRegion rfidRegion;

  AppSettings copyWith({
    int? rfidPowerLevel,
    bool? beepEnabled,
    bool? hapticEnabled,
    bool? gloveModeEnabled,
    bool? darkMode,
    ScanMode? scanMode,
    RfidRegion? rfidRegion,
  }) {
    return AppSettings(
      rfidPowerLevel: rfidPowerLevel ?? this.rfidPowerLevel,
      beepEnabled: beepEnabled ?? this.beepEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      gloveModeEnabled: gloveModeEnabled ?? this.gloveModeEnabled,
      darkMode: darkMode ?? this.darkMode,
      scanMode: scanMode ?? this.scanMode,
      rfidRegion: rfidRegion ?? this.rfidRegion,
    );
  }
}

enum ScanMode { toggle, holdToScan }
enum RfidRegion { id, eu, us, jp }

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(const AppSettings());

  void setRfidPower(int level) =>
      state = state.copyWith(rfidPowerLevel: level.clamp(0, 2));
  void setBeep(bool v) => state = state.copyWith(beepEnabled: v);
  void setHaptic(bool v) => state = state.copyWith(hapticEnabled: v);
  void setGloveMode(bool v) => state = state.copyWith(gloveModeEnabled: v);
  void setDarkMode(bool v) => state = state.copyWith(darkMode: v);
  void setScanMode(ScanMode m) => state = state.copyWith(scanMode: m);
  void setRegion(RfidRegion r) => state = state.copyWith(rfidRegion: r);
}

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
  (_) => SettingsController(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final ctrl     = ref.read(settingsProvider.notifier);
    final theme    = Theme.of(context);
    final cs       = theme.extension<AppColorScheme>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // ── RFID Reader ─────────────────────────────────────────────────────
        _Section(title: 'RFID Reader', icon: Icons.sensors_rounded, children: [
          _PowerSelector(
            value: settings.rfidPowerLevel,
            onChanged: ctrl.setRfidPower,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RegionSelector(
            value: settings.rfidRegion,
            onChanged: ctrl.setRegion,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScanModeSelector(
            value: settings.scanMode,
            onChanged: ctrl.setScanMode,
          ),
        ]),

        const SizedBox(height: AppSpacing.md),

        // ── Feedback ────────────────────────────────────────────────────────
        _Section(
          title: 'Feedback',
          icon: Icons.vibration_rounded,
          children: [
            _SettingsTile(
              icon: Icons.volume_up_rounded,
              title: 'Beep on scan',
              subtitle: 'Audio confirmation per new tag',
              value: settings.beepEnabled,
              onChanged: ctrl.setBeep,
            ),
            _SettingsTile(
              icon: Icons.vibration_rounded,
              title: 'Haptic on scan',
              subtitle: 'Vibration pulse per new tag',
              value: settings.hapticEnabled,
              onChanged: ctrl.setHaptic,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Display ─────────────────────────────────────────────────────────
        _Section(
          title: 'Display',
          icon: Icons.brightness_6_rounded,
          children: [
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark mode',
              subtitle: 'Recommended for warehouse environments',
              value: settings.darkMode,
              onChanged: ctrl.setDarkMode,
            ),
            _SettingsTile(
              icon: Icons.back_hand_rounded,
              title: 'Glove mode',
              subtitle: 'Larger touch targets & increased spacing',
              value: settings.gloveModeEnabled,
              onChanged: ctrl.setGloveMode,
              accentColor: cs.statusWarning,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ── About ────────────────────────────────────────────────────────────
        _Section(
          title: 'About',
          icon: Icons.info_outline_rounded,
          children: [
            _InfoTile(label: 'App', value: 'SIIX Tray Monitor'),
            _InfoTile(label: 'Device', value: 'UROVO DT50(P)'),
            _InfoTile(label: 'RFID Module', value: 'Impinj E710 / E510'),
            _InfoTile(label: 'SDK', value: 'Urv_RfidSerialPortSdk v2.0.6'),
          ],
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: theme.colorScheme.outline,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (value ? accent : theme.colorScheme.onSurface)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value
                    ? accent
                    : theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerSelector extends StatelessWidget {
  const _PowerSelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['Near', 'Normal', 'Far'];
  static const _icons = [
    Icons.signal_wifi_0_bar_rounded,
    Icons.network_wifi_2_bar_rounded,
    Icons.signal_wifi_4_bar_rounded,
  ];
  static const _colors = [
    AppColors.amber500,
    AppColors.primary500,
    AppColors.green500,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.power_settings_new_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('UHF Read Power', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final selected = value == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? _colors[i].withValues(alpha: 0.12)
                          : theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: selected
                            ? _colors[i]
                            : theme.colorScheme.outline,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _icons[i],
                          size: 24,
                          color: selected
                              ? _colors[i]
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? _colors[i]
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              value == 0
                  ? 'Short range, better precision in dense areas'
                  : value == 1
                      ? 'Standard warehouse operation range'
                      : 'Max range — useful for large open areas',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionSelector extends StatelessWidget {
  const _RegionSelector({required this.value, required this.onChanged});
  final RfidRegion value;
  final ValueChanged<RfidRegion> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.language_rounded, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Frequency Region', style: theme.textTheme.titleSmall),
                Text(
                  'Must match your country\'s RF regulations',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          DropdownButton<RfidRegion>(
            value: value,
            underline: const SizedBox.shrink(),
            items: RfidRegion.values
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (r) {
              if (r != null) onChanged(r);
            },
          ),
        ],
      ),
    );
  }
}

class _ScanModeSelector extends StatelessWidget {
  const _ScanModeSelector({required this.value, required this.onChanged});
  final ScanMode value;
  final ValueChanged<ScanMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trigger mode', style: theme.textTheme.titleSmall),
                Text(
                  value == ScanMode.toggle
                      ? 'Press once to start, once to stop'
                      : 'Hold trigger to scan, release to stop',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          DropdownButton<ScanMode>(
            value: value,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: ScanMode.toggle,     child: Text('Toggle')),
              DropdownMenuItem(value: ScanMode.holdToScan, child: Text('Hold')),
            ],
            onChanged: (m) {
              if (m != null) onChanged(m);
            },
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
