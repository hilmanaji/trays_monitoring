import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/movement_form_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/counter_display.dart';
import '../../widgets/empty_state_widget.dart';
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
    final theme     = Theme.of(context);
    final cs        = theme.extension<AppColorScheme>()!;

    // Trigger flash whenever tag count increases
    final currentCount = formState.rfids.length;
    if (currentCount > _prevCount) {
      _prevCount = currentCount;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => _LocationError(message: e.toString()),
          ),

          Divider(height: 1, color: theme.colorScheme.outline),

          // ── Tag list ───────────────────────────────────────────────────────
          Expanded(
            child: ScanFlashOverlay(
              triggerKey: formState.rfids.length,
              child: formState.rfids.isEmpty
                  ? _EmptyScanState(isScanning: formState.isScanning)
                  : _TagList(
                      rfids: formState.rfids,
                      onRemove: (epc) => ref
                          .read(movementFormControllerProvider.notifier)
                          .removeTag(epc),
                    ),
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

          // ── Bottom action bar ──────────────────────────────────────────────
          BottomActionBar(
            tertiary: OutlinedButton.icon(
              onPressed: formState.rfids.isEmpty
                  ? null
                  : () => _confirmClear(context),
              icon: const Icon(Icons.clear_all_rounded, size: 20),
              label: const Text('Clear'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                padding: EdgeInsets.zero,
              ),
            ),
            secondary: OutlinedButton.icon(
              onPressed: () => _showManualInput(context),
              icon: const Icon(Icons.keyboard_rounded, size: 20),
              label: const Text('Manual'),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
            ),
            primary: formState.isScanning
                ? FilledButton.icon(
                    onPressed: () => ref
                        .read(movementFormControllerProvider.notifier)
                        .stopScan(),
                    icon: const Icon(Icons.stop_rounded, size: 22),
                    label: const Text('Stop'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.statusError,
                      padding: EdgeInsets.zero,
                    ),
                  )
                : FilledButton.icon(
                    onPressed: formState.rfids.isNotEmpty
                        ? () => _confirmSubmit(context)
                        : () => ref
                            .read(movementFormControllerProvider.notifier)
                            .startScan(),
                    icon: Icon(
                      formState.rfids.isNotEmpty
                          ? Icons.send_rounded
                          : Icons.sensors_rounded,
                      size: 22,
                    ),
                    label: Text(
                      formState.rfids.isNotEmpty ? 'Submit' : 'Start Scan',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: formState.rfids.isNotEmpty
                          ? cs.statusOk
                          : theme.colorScheme.primary,
                      padding: EdgeInsets.zero,
                    ),
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
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceCard,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CounterDisplay(
              count: count,
              label: 'TAGS SCANNED',
              sublabel: 'unique EPCs in session',
              color: isScanning ? cs.statusActive : theme.colorScheme.primary,
              size: CounterSize.large,
              isActive: isScanning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatPill(
                icon: Icons.fiber_new_rounded,
                label: '$count new',
                color: cs.statusOk,
              ),
              const SizedBox(height: 6),
              _StatPill(
                icon: isScanning
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                label: isScanning ? 'Live' : 'Stopped',
                color: isScanning ? cs.statusActive : cs.statusIdle,
              ),
            ],
          ),
        ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;

    return Container(
      color: cs.surfaceCard,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _LocationDropdown(
              label: 'FROM',
              value: fromId,
              locations: locations,
              icon: Icons.north_east_rounded,
              onChanged: onFromChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          Expanded(
            child: _LocationDropdown(
              label: 'TO',
              value: toId,
              locations: locations,
              icon: Icons.south_west_rounded,
              onChanged: onToChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({
    required this.label,
    required this.value,
    required this.locations,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final List<dynamic> locations;
  final IconData icon;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value != null;

    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.6)
                : theme.colorScheme.outline,
          ),
        ),
      ),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('Select…')),
        ...locations.map<DropdownMenuItem<int>>(
          (loc) => DropdownMenuItem<int>(
            value: loc.id as int,
            child: Text(
              loc.name as String,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
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
    if (isScanning) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Icon(
              Icons.sensors_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for tags…',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Point the scanner at RFID tags\nor press the physical trigger button',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return EmptyStateWidget(
      icon: Icons.sensors_outlined,
      title: 'No tags scanned',
      subtitle:
          'Press Start Scan or use the physical\ntrigger button to begin scanning',
    );
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
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final bg = isError ? cs.statusErrorContainer : cs.statusOkContainer;
    final fg = isError ? cs.statusErrorOnContainer : cs.statusOkOnContainer;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      color: bg,
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(Icons.close_rounded, size: 16, color: fg),
          ),
        ],
      ),
    );
  }
}
