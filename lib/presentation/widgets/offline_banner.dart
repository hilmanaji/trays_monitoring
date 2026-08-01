import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: cs.statusWarningContainer,
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: cs.statusWarningOnContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — changes will sync when connected',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.statusWarningOnContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
