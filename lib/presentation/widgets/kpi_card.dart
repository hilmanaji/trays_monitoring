import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/neo_theme.dart';
import 'neo_box.dart';

/// Glanceable KPI metric card for the Dashboard.
///
/// Soft-UI form: kicker → oversized number → note. The icon lives in a small
/// inset well so the card keeps a single extruded silhouette.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.note,
    this.trend,
    this.trendUp,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Accent used by the icon well. The number itself always stays ink-coloured
  /// — neomorphic contrast is too low for coloured display type.
  final Color color;

  /// Supporting line under the number, e.g. "WH-A + WH-B".
  final String? note;

  /// Optional trend indicator, e.g. "+3 today".
  final String? trend;

  /// true = upward (green), false = downward (red), null = neutral.
  final bool? trendUp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return NeoBox(
      radius: AppSpacing.radiusNeo + 2,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: neo.inkFaint,
                  ),
                ),
              ),
              if (trend != null)
                _TrendBadge(trend: trend!, up: trendUp)
              else
                Icon(icon, size: 15, color: color),
            ],
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.0,
                color: neo.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note ?? label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: neo.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend, required this.up});
  final String trend;
  final bool? up;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final neo = context.neo;

    final (fg, icon) = switch (up) {
      null => (neo.inkMuted, Icons.remove_rounded),
      true => (cs.statusOk, Icons.trending_up_rounded),
      false => (cs.statusError, Icons.trending_down_rounded),
    };

    return NeoBox.inset(
      radius: 10,
      elevation: 0.45,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            trend,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
