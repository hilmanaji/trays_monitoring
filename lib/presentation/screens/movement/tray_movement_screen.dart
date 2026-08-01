import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/movement_form_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_theme.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/counter_display.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/tray_card.dart';

class TrayMovementScreen extends ConsumerStatefulWidget {
  const TrayMovementScreen({super.key});

  @override
  ConsumerState<TrayMovementScreen> createState() => _TrayMovementScreenState();
}

class _TrayMovementScreenState extends ConsumerState<TrayMovementScreen> {
  int? _fromLocationId;
  int? _toLocationId;
  int _prevCount = 0;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(movementFormControllerProvider);
    final locations = ref.watch(locationsProvider);
    final neo       = context.neo;
    final hasTags   = formState.rfids.isNotEmpty;

    // Trigger flash whenever tag count increases
    final currentCount = formState.rfids.length;
    if (currentCount > _prevCount) {
      _prevCount = currentCount;
    }

    return Scaffold(
      backgroundColor: neo.ground,
      body: Column(
        children: [
          // ── Scan header (counter + status) ─────────────────────────────────
          _ScanHeader(
            count: formState.rfids.length,
            isScanning: formState.isScanning,
            prevCount: _prevCount,
          ),

          // ── Location selectors ─────────────────────────────────────────────
          locations.when(
            data: (items) => _LocationBar(
              locations: items,
              fromId: _fromLocationId,
              toId: _toLocationId,
              onFromChanged: (v) => setState(() => _fromLocationId = v),
              onToChanged:   (v) => setState(() => _toLocationId = v),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => _LocationError(message: e.toString()),
          ),

          // ── Tag list ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const NeoKicker('Terbaca / tags read'),
                const SizedBox(width: 9),
                NeoCountBadge(count: formState.rfids.length),
                const Spacer(),
                if (hasTags)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _confirmClear(context),
                    child: Text(
                      'Kosongkan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: neo.accentEnd,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ScanFlashOverlay(
              triggerKey: formState.rfids.length,
              child: hasTags
                  ? _TagList(
                      rfids: formState.rfids,
                      onRemove: (epc) => ref
                          .read(movementFormControllerProvider.notifier)
                          .removeTag(epc),
                    )
                  : _EmptyScanState(isScanning: formState.isScanning),
            ),
          ),

          // ── Error / info message ───────────────────────────────────────────
          if (formState.errorMessage != null)
            _MessageBanner(
              message: formState.errorMessage!,
              isError: true,
              onDismiss: () => ref
                  .read(movementFormControllerProvider.notifier)
                  .clearMessages(),
            ),
          if (formState.infoMessage != null)
            _MessageBanner(
              message: formState.infoMessage!,
              isError: false,
              onDismiss: () => ref
                  .read(movementFormControllerProvider.notifier)
                  .clearMessages(),
            ),

          // ── Trigger + commit bar ───────────────────────────────────────────
          // Mirrors the hardware layout: latching trigger on the left, the one
          // accent-gradient commit action filling the rest.
          BottomActionBar(
            tertiary: NeoTriggerButton(
              scanning: formState.isScanning,
              onTap: () {
                final ctrl = ref.read(movementFormControllerProvider.notifier);
                if (formState.isScanning) {
                  ctrl.stopScan();
                } else {
                  ctrl.startScan();
                }
              },
            ),
            secondary: NeoSecondaryButton(
              label: 'Manual',
              icon: Icons.keyboard_rounded,
              onPressed: () => _showManualInput(context),
            ),
            primary: NeoButton(
              label: hasTags
                  ? 'Pindahkan ${formState.rfids.length} tray'
                  : 'Belum ada tag',
              icon: hasTags ? Icons.send_rounded : null,
              onPressed: hasTags ? () => _confirmSubmit(context) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all tags?'),
        content: Text(
          'This will remove all ${ref.read(movementFormControllerProvider).rfids.length} scanned tags.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(movementFormControllerProvider.notifier).clearTags();
    }
  }

  Future<void> _showManualInput(BuildContext context) async {
    final ctrl = TextEditingController();
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual RFID Input',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'One EPC per line, or separated by commas',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 5,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'E200...\nE200...',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.touchMin,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('Add Tags'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (value != null && value.isNotEmpty) {
      ref.read(movementFormControllerProvider.notifier).addManualTags(value);
    }
  }

  Future<void> _confirmSubmit(BuildContext context) async {
    // Capture context-dependent objects before any await.
    final messenger = ScaffoldMessenger.of(context);

    if (_fromLocationId == null || _toLocationId == null) {
      HapticFeedback.vibrate();
      messenger.showSnackBar(
        const SnackBar(content: Text('Select From and To locations first')),
      );
      return;
    }

    final count = ref.read(movementFormControllerProvider).rfids.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Movement'),
        content: Text(
          'Submit $count scanned tags as one tray movement transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final result = await ref
        .read(movementFormControllerProvider.notifier)
        .submit(
          fromLocationId: _fromLocationId,
          toLocationId: _toLocationId,
        );

    if (!mounted) return;

    final state = ref.read(movementFormControllerProvider);
    final msg   = state.infoMessage ?? state.errorMessage;
    if (msg != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(msg)),
      );
      ref.read(movementFormControllerProvider.notifier).clearMessages();
    }

    if (result != MovementSubmissionResult.invalid) {
      setState(() {
        _fromLocationId = null;
        _toLocationId   = null;
        _prevCount      = 0;
      });
      ref.invalidate(pendingMovementsProvider);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan header — the glanceable counter block
// ─────────────────────────────────────────────────────────────────────────────

class _ScanHeader extends StatelessWidget {
  const _ScanHeader({
    required this.count,
    required this.isScanning,
    required this.prevCount,
  });

  final int count;
  final bool isScanning;
  final int prevCount;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).extension<AppColorScheme>()!;
    final neo = context.neo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: NeoBox(
        radius: AppSpacing.radiusNeo + 2,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CounterDisplay(
                  count: count,
                  label: 'Tags scanned',
                  sublabel: 'EPC unik dalam sesi ini',
                  color: neo.ink,
                  size: CounterSize.large,
                  isActive: isScanning,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatPill(
                  icon: isScanning
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  label: isScanning ? 'Live' : 'Idle',
                  color: isScanning ? cs.statusActive : neo.inkMuted,
                ),
                const SizedBox(height: 8),
                _StatPill(
                  icon: Icons.podcasts_rounded,
                  label: '26 dBm',
                  color: neo.inkMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NeoBox.inset(
      radius: 12,
      elevation: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location selector bar
// ─────────────────────────────────────────────────────────────────────────────

class _LocationBar extends StatelessWidget {
  const _LocationBar({
    required this.locations,
    required this.fromId,
    required this.toId,
    required this.onFromChanged,
    required this.onToChanged,
  });

  final List<dynamic> locations;
  final int? fromId;
  final int? toId;
  final ValueChanged<int?> onFromChanged;
  final ValueChanged<int?> onToChanged;

  String _nameFor(int? id) {
    if (id == null) return 'Pilih…';
    for (final loc in locations) {
      if (loc.id == id) return loc.name as String;
    }
    return 'Pilih…';
  }

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    // FROM is a well (given), TO is the accent surface (the decision) — the
    // same asymmetry the design uses to point the operator at the next step.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: _LocationSlot(
              kicker: 'DARI / FROM',
              value: _nameFor(fromId),
              accent: false,
              onTap: () => _pick(context, fromId, onFromChanged, 'Ambil dari mana?'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward_rounded, size: 17, color: neo.accentEnd),
          ),
          Expanded(
            child: _LocationSlot(
              kicker: 'KE / TO',
              value: _nameFor(toId),
              accent: true,
              onTap: () => _pick(context, toId, onToChanged, 'Pindah ke mana?'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    int? current,
    ValueChanged<int?> onChanged,
    String title,
  ) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => _LocationSheet(
        title: title,
        locations: locations,
        selectedId: current,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _LocationSlot extends StatelessWidget {
  const _LocationSlot({
    required this.kicker,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final String kicker;
  final String value;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final fg  = accent ? neo.onAccent : neo.ink;

    return NeoBox(
      depth: accent ? NeoDepth.accent : NeoDepth.inset,
      radius: AppSpacing.radiusNeo,
      elevation: 0.8,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            accent ? '$kicker ▾' : kicker,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: accent ? fg.withValues(alpha: 0.8) : neo.inkFaint,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet location picker — the design's "Pindah ke mana?" dialog.
class _LocationSheet extends StatelessWidget {
  const _LocationSheet({
    required this.title,
    required this.locations,
    required this.selectedId,
  });

  final String title;
  final List<dynamic> locations;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: neo.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih lokasi dari master data.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: neo.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: locations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, i) {
                  final loc = locations[i];
                  final selected = loc.id == selectedId;
                  return NeoBox(
                    depth: selected ? NeoDepth.accent : NeoDepth.raised,
                    radius: AppSpacing.radiusNeoSm + 2,
                    elevation: 0.7,
                    height: 50,
                    onTap: () => Navigator.pop(context, loc.id as int),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.name as String,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? neo.onAccent : neo.ink,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_rounded, size: 18, color: neo.onAccent),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.red500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tag list
// ─────────────────────────────────────────────────────────────────────────────

class _TagList extends StatelessWidget {
  const _TagList({required this.rfids, required this.onRemove});
  final List<String> rfids;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: rfids.length,
      itemBuilder: (context, index) {
        final epc = rfids[rfids.length - 1 - index]; // newest first
        final originalIndex = rfids.length - 1 - index;
        return EpcTagTile(
          key: ValueKey(epc),
          epc: epc,
          index: originalIndex,
          onRemove: () => onRemove(epc),
          isNew: index == 0, // most recently added
        );
      },
    );
  }
}

class _EmptyScanState extends StatelessWidget {
  const _EmptyScanState({required this.isScanning});
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return ScanIdleState(scanning: isScanning);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message banner (error / info)
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).extension<AppColorScheme>()!;
    final neo = context.neo;
    final accent = isError ? cs.statusError : cs.statusOk;
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    // Floating toast, matching the design: ground-coloured card lifted off the
    // surface, with the status carried by the glyph alone.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: NeoBox(
        radius: AppSpacing.radiusNeo,
        elevation: 1.2,
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: neo.ink,
                ),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(Icons.close_rounded, size: 16, color: neo.inkGhost),
            ),
          ],
        ),
      ),
    );
  }
}
