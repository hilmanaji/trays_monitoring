import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TrayStatus {
  scanned,
  missing,
  unexpected,
  pending,
  active,
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.label,
    this.compact = false,
  });

  final TrayStatus status;
  final String? label;

  /// Smaller variant for use inside dense list tiles.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;

    final (bg, fg, icon, defaultLabel) = switch (status) {
      TrayStatus.scanned    => (
          cs.statusOkContainer,
          cs.statusOkOnContainer,
          Icons.check_circle_rounded,
          'Scanned',
        ),
      TrayStatus.missing    => (
          cs.statusErrorContainer,
          cs.statusErrorOnContainer,
          Icons.error_rounded,
          'Missing',
        ),
      TrayStatus.unexpected => (
          cs.statusWarningContainer,
          cs.statusWarningOnContainer,
          Icons.warning_rounded,
          'Unexpected',
        ),
      TrayStatus.pending    => (
          cs.statusIdleContainer,
          cs.statusIdleOnContainer,
          Icons.schedule_rounded,
          'Pending',
        ),
      TrayStatus.active     => (
          cs.statusActiveContainer,
          cs.statusActiveOnContainer,
          Icons.sensors_rounded,
          'Scanning',
        ),
    };

    final hPad = compact ? 8.0 : 10.0;
    final vPad = compact ? 4.0 : 6.0;
    final iconSize = compact ? 12.0 : 14.0;
    final fontSize = compact ? 11.0 : 13.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          SizedBox(width: compact ? 4 : 5),
          Text(
            label ?? defaultLabel,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
