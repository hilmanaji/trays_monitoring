import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/neo_theme.dart';
import 'neo_box.dart';

/// Generic empty-state placeholder with icon, title, and optional action.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeoBox.inset(
          radius: AppSpacing.radiusNeoLg,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoBox(
                width: 68,
                height: 68,
                radius: 34,
                elevation: 0.8,
                alignment: Alignment.center,
                child: Icon(icon, size: 30, color: iconColor ?? neo.inkFaint),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: neo.ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: neo.inkMuted,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 22),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Idle scan state — the pulsing accent disc from the design's "TERBACA" panel.
class ScanIdleState extends StatelessWidget {
  const ScanIdleState({
    super.key,
    this.title = 'Tekan trigger untuk\nmembaca tag',
    this.subtitle = 'Bulk read · UHF 865–868 MHz · 26 dBm',
    this.scanning = false,
  });

  final String title;
  final String subtitle;

  /// While live, the copy switches to "waiting for tags".
  final bool scanning;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: NeoBox.inset(
          radius: AppSpacing.radiusNeoLg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NeoPulse(),
              const SizedBox(height: 16),
              Text(
                scanning ? 'Menunggu tag…\nWaiting for tags' : title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: neo.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: neo.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state with retry button.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;

    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      iconColor: cs.statusError,
      title: 'Something went wrong',
      subtitle: message,
      action: onRetry == null
          ? null
          : SizedBox(
              width: 180,
              child: NeoSecondaryButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                height: AppSpacing.touchMin,
              ),
            ),
    );
  }
}
