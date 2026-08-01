import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/signal_strength_meter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class FindState {
  const FindState({
    this.targetEpc,
    this.rssi = 0.0,
    this.isScanning = false,
    this.lastSeenAt,
    this.detectedEpcs = const {},
  });

  final String? targetEpc;

  /// Normalised signal strength for the target EPC: 0.0 – 1.0.
  /// Without real RSSI from the SDK this is approximated by detection frequency.
  final double rssi;
  final bool isScanning;
  final DateTime? lastSeenAt;
  final Set<String> detectedEpcs;

  FindState copyWith({
    String? targetEpc,
    bool clearTarget = false,
    double? rssi,
    bool? isScanning,
    DateTime? lastSeenAt,
    Set<String>? detectedEpcs,
  }) {
    return FindState(
      targetEpc: clearTarget ? null : (targetEpc ?? this.targetEpc),
      rssi: rssi ?? this.rssi,
      isScanning: isScanning ?? this.isScanning,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      detectedEpcs: detectedEpcs ?? this.detectedEpcs,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class FindController extends StateNotifier<FindState> {
  FindController({required this.rfidService}) : super(const FindState());

  final dynamic rfidService;
  StreamSubscription<String>? _sub;

  /// Rolling detection window for proximity approximation.
  final List<DateTime> _recentHits = [];
  Timer? _decayTimer;

  Future<void> startScan() async {
    await rfidService.startScan();
    _sub = (rfidService.scannedTags as Stream<String>).listen(_onTag);
    _decayTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _decayRssi(),
    );
    state = state.copyWith(isScanning: true, rssi: 0);
  }

  Future<void> stopScan() async {
    _sub?.cancel();
    _decayTimer?.cancel();
    await rfidService.stopScan();
    state = state.copyWith(isScanning: false, rssi: 0);
  }

  void setTarget(String epc) {
    state = state.copyWith(
      targetEpc: epc.trim().toUpperCase(),
      rssi: 0,
    );
  }

  void clearTarget() {
    state = state.copyWith(clearTarget: true, rssi: 0);
  }

  void _onTag(String epc) {
    final normalized = epc.trim().toUpperCase();
    final updated = {...state.detectedEpcs, normalized};
    state = state.copyWith(detectedEpcs: updated);

    if (state.targetEpc == null || normalized == state.targetEpc) {
      _recentHits.add(DateTime.now());
      _computeRssi();
      if (state.targetEpc != null) {
        _triggerHaptic(state.rssi);
      }
    }
  }

  void _decayRssi() {
    final cutoff = DateTime.now().subtract(const Duration(seconds: 2));
    _recentHits.removeWhere((t) => t.isBefore(cutoff));
    _computeRssi();
  }

  void _computeRssi() {
    // Approximation: hits-per-second over last 2s window → normalised 0..1
    final hitsPerSec = _recentHits.length / 2.0;
    final rssi = (hitsPerSec / 8.0).clamp(0.0, 1.0);
    state = state.copyWith(rssi: rssi, lastSeenAt: _recentHits.isNotEmpty ? _recentHits.last : null);
  }

  Future<void> _triggerHaptic(double rssi) async {
    if (!await Vibration.hasVibrator()) return;
    if (rssi > 0.75) {
      Vibration.vibrate(duration: 80);
    } else if (rssi > 0.5) {
      Vibration.vibrate(duration: 50);
    } else if (rssi > 0.25) {
      Vibration.vibrate(duration: 30);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _decayTimer?.cancel();
    super.dispose();
  }
}

final findControllerProvider =
    StateNotifierProvider.autoDispose<FindController, FindState>((ref) {
  return FindController(rfidService: ref.watch(rfidServiceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class FindScreen extends ConsumerStatefulWidget {
  const FindScreen({super.key});

  @override
  ConsumerState<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends ConsumerState<FindScreen> {
  final _epcCtrl = TextEditingController();

  @override
  void dispose() {
    _epcCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(findControllerProvider);
    final theme  = Theme.of(context);
    final cs     = theme.extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Target EPC input ─────────────────────────────────────────────
          _TargetBar(
            controller: _epcCtrl,
            targetEpc: state.targetEpc,
            onSet: (epc) =>
                ref.read(findControllerProvider.notifier).setTarget(epc),
            onClear: () =>
                ref.read(findControllerProvider.notifier).clearTarget(),
          ),
          Divider(height: 1, color: theme.colorScheme.outline),

          // ── Geiger meter ─────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GeigerMeter(
                    rssi: state.rssi,
                    targetEpc: state.targetEpc,
                    isActive: state.isScanning,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SignalStrengthMeter(
                    rssi: state.rssi,
                    height: 20,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.lastSeenAt != null)
                    Text(
                      'Last seen: ${_elapsed(state.lastSeenAt!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  if (state.isScanning && state.targetEpc == null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(
                        'All tags: ${state.detectedEpcs.length} detected',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Nearby tags ───────────────────────────────────────────────────
          if (state.detectedEpcs.isNotEmpty && state.targetEpc == null)
            _NearbyList(
              epcs: state.detectedEpcs,
              onSelect: (epc) {
                _epcCtrl.text = epc;
                ref.read(findControllerProvider.notifier).setTarget(epc);
              },
            ),

          // ── Bottom actions ────────────────────────────────────────────────
          BottomActionBar(
            secondary: state.targetEpc != null
                ? OutlinedButton.icon(
                    onPressed: () {
                      _epcCtrl.clear();
                      ref.read(findControllerProvider.notifier).clearTarget();
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: const Text('Clear Target'),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  )
                : null,
            primary: state.isScanning
                ? FilledButton.icon(
                    onPressed: () =>
                        ref.read(findControllerProvider.notifier).stopScan(),
                    icon: const Icon(Icons.stop_rounded, size: 22),
                    label: const Text('Stop'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.statusError,
                      padding: EdgeInsets.zero,
                    ),
                  )
                : FilledButton.icon(
                    onPressed: () =>
                        ref.read(findControllerProvider.notifier).startScan(),
                    icon: const Icon(Icons.location_searching_rounded, size: 22),
                    label: const Text('Start Scan'),
                    style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                  ),
          ),
        ],
      ),
    );
  }

  String _elapsed(DateTime dt) {
    final secs = DateTime.now().difference(dt).inSeconds;
    if (secs < 5) return 'just now';
    if (secs < 60) return '${secs}s ago';
    return '${(secs / 60).floor()}m ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Target bar
// ─────────────────────────────────────────────────────────────────────────────

class _TargetBar extends StatelessWidget {
  const _TargetBar({
    required this.controller,
    required this.targetEpc,
    required this.onSet,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? targetEpc;
  final ValueChanged<String> onSet;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;
    final hasTarget = targetEpc != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: cs.surfaceCard,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'Enter target EPC or scan a tag…',
                prefixIcon: Icon(
                  Icons.location_searching_rounded,
                  size: 20,
                  color: hasTarget
                      ? cs.statusOk
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                suffixIcon: hasTarget
                    ? Icon(Icons.gps_fixed_rounded,
                        size: 18, color: cs.statusOk)
                    : null,
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) onSet(v.trim());
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSpacing.touchMin,
            height: AppSpacing.touchMin,
            child: FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSet(controller.text.trim());
                  FocusScope.of(context).unfocus();
                }
              },
              style: FilledButton.styleFrom(padding: EdgeInsets.zero),
              child: const Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby tags list (when no specific target is set)
// ─────────────────────────────────────────────────────────────────────────────

class _NearbyList extends StatelessWidget {
  const _NearbyList({required this.epcs, required this.onSelect});
  final Set<String> epcs;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;
    final list  = epcs.toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: cs.surfaceCard,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs,
            ),
            child: Text(
              'DETECTED TAGS — tap to target',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              itemCount: list.length,
              itemBuilder: (context, i) => InkWell(
                onTap: () => onSelect(list[i]),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm - 2,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        size: 14,
                        color: cs.statusActive,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          list[i],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.my_location_rounded,
                        size: 14,
                        color: AppColors.primary400,
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
  }
}
