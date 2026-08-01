import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neo_box.dart';

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

    // Soft UI carries state in the glyph + ink colour; the pill itself is a
    // well pressed into the ground, never a coloured block.
    final (fg, icon, defaultLabel) = switch (status) {
      TrayStatus.scanned    => (cs.statusOk,      Icons.check_circle_rounded, 'Scanned'),
      TrayStatus.missing    => (cs.statusError,   Icons.error_rounded,        'Missing'),
      TrayStatus.unexpected => (cs.statusWarning, Icons.warning_rounded,      'Unexpected'),
      TrayStatus.pending    => (cs.statusIdle,    Icons.schedule_rounded,     'Pending'),
      TrayStatus.active     => (cs.statusActive,  Icons.sensors_rounded,      'Scanning'),
    };

    final hPad = compact ? 9.0 : 11.0;
    final vPad = compact ? 5.0 : 6.0;
    final iconSize = compact ? 12.0 : 14.0;
    final fontSize = compact ? 10.0 : 12.0;

    return NeoBox.inset(
      radius: compact ? 11 : 13,
      elevation: compact ? 0.45 : 0.6,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          SizedBox(width: compact ? 4 : 5),
          Text(
            (label ?? defaultLabel).toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
