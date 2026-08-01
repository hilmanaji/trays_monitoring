import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/neo_theme.dart';
import 'neo_box.dart';
import 'status_chip.dart';

/// Large-touch tray list tile — designed for glove-mode operation.
///
/// Extruded card that presses into the ground on tap; the EPC keeps its
/// monospace treatment so long hex strings stay scannable.
class TrayCard extends StatelessWidget {
  const TrayCard({
    super.key,
    required this.trayCode,
    required this.epc,
    required this.locationName,
    required this.status,
    this.trayType,
    this.lastMovement,
    this.onTap,
    this.trailing,
  });

  final String trayCode;
  final String epc;
  final String locationName;
  final TrayStatus status;
  final String? trayType;
  final String? lastMovement;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return NeoBox(
      radius: AppSpacing.radiusNeo,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const NeoIconBadge(icon: Icons.inbox_rounded, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trayCode,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: neo.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (trailing != null) trailing! else StatusChip(status: status, compact: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            epc,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              height: 1.4,
              color: neo.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          _MetaRow(
            items: [locationName, ?trayType, ?lastMovement],
          ),
        ],
      ),
    );
  }
}

/// Dot-separated metadata line — the recurring "type · part · customer" row.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: neo.inkMuted,
    );

    return Wrap(
      spacing: 7,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Text('·', style: style),
          Text(items[i], style: style),
        ],
      ],
    );
  }
}

/// Compact EPC tag tile used inside the live scan list.
class EpcTagTile extends StatelessWidget {
  const EpcTagTile({
    super.key,
    required this.epc,
    required this.index,
    this.onRemove,
    this.isNew = false,
  });

  final String epc;
  final int index;
  final VoidCallback? onRemove;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final cs  = Theme.of(context).extension<AppColorScheme>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      child: NeoBox(
        radius: AppSpacing.radiusNeoSm + 3,
        elevation: 0.85,
        padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
        child: Row(
          children: [
            NeoIconBadge(
              text: '${index + 1}',
              size: 30,
              radius: 10,
              accent: isNew,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                epc,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: neo.ink,
                ),
              ),
            ),
            if (isNew)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: cs.statusOk,
                  ),
                ),
              ),
            if (onRemove != null)
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close_rounded, size: 18, color: neo.inkGhost),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
