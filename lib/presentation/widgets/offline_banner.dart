import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/neo_theme.dart';
import 'neo_box.dart';

final _connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Persistent slim banner shown at the top of content when the device is offline.
/// Slides in/out smoothly; zero height when online so it never displaces layout.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(_connectivityProvider);
    final isOffline = conn.maybeWhen(
      data: (r) => r.every((x) => x == ConnectivityResult.none),
      orElse: () => false,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: isOffline ? _Banner() : const SizedBox.shrink(),
    );
  }
}

class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final neo = context.neo;

    // Inset strip: the connection state is a groove in the ground rather than
    // a coloured bar, so it never competes with the accent CTA below it.
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
      child: NeoBox.inset(
        radius: AppSpacing.radiusNeoSm,
        elevation: 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, size: 16, color: cs.statusWarning),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Offline — changes will sync when connected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: neo.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
