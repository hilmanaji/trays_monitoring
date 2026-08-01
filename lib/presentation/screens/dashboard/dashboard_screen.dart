import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_formatter.dart';
import '../../../domain/entities/dashboard_snapshot.dart';
import '../../../domain/entities/stock_by_tray_type.dart';
import '../../../domain/entities/tray_movement.dart';
import '../../../domain/entities/tray_type.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_theme.dart';
import '../../utils/project_stock_summary.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/neo_box.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(dashboardSnapshotProvider);
    ref.invalidate(pendingMovementsProvider);
    await Future.wait<dynamic>([
      ref.read(dashboardSnapshotProvider.future),
      ref.read(pendingMovementsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard      = ref.watch(dashboardSnapshotProvider);
    final pendingAsync   = ref.watch(pendingMovementsProvider);
    final trayTypesAsync = ref.watch(trayTypesProvider);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      backgroundColor: context.neo.ground,
      color: context.neo.accentEnd,
      child: dashboard.when(
        data: (snapshot) {
          final pendingCount = pendingAsync.maybeWhen(
            data: (items) => items.length,
            orElse: () => 0,
          );
          return _DashboardContent(
            snapshot: snapshot,
            pendingCount: pendingCount,
            trayTypesAsync: trayTypesAsync,
          );
        },
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: e.toString(), onRetry: () => _refresh(ref)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.snapshot,
    required this.pendingCount,
    required this.trayTypesAsync,
  });

  final DashboardSnapshot snapshot;
  final int pendingCount;
  final AsyncValue<List<TrayType>> trayTypesAsync;

  static const _hPad = EdgeInsets.symmetric(horizontal: AppSpacing.md);

  @override
  Widget build(BuildContext context) {
    final w      = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 600;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Live stock kicker ────────────────────────────────────────────────
        SliverPadding(
          padding: _hPad.add(const EdgeInsets.only(top: 10, bottom: 12)),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const NeoKicker('Stok tray · live'),
                const Spacer(),
                if (pendingCount > 0)
                  _PendingSyncBadge(count: pendingCount)
                else
                  Text(
                    'sync ${DateTimeFormatter.formatTime(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: context.neo.inkGhost,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── KPI grid ─────────────────────────────────────────────────────────
        SliverPadding(
          padding: _hPad,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: twoCol ? 4 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: twoCol ? 1.05 : 1.28,
            ),
            delegate: SliverChildListDelegate([
              KpiCard(
                label: 'Total Tray',
                value: '${snapshot.totalTrays}',
                note: 'terdaftar aktif',
                icon: Icons.inbox_rounded,
                color: context.neo.accentEnd,
              ),
              KpiCard(
                label: 'Lokasi',
                value: '${snapshot.totalLocations}',
                note: 'zona & rak aktif',
                icon: Icons.place_rounded,
                color: context.neo.accentEnd,
              ),
              KpiCard(
                label: 'Stock Items',
                value: '${snapshot.totalStock}',
                note: 'tray di gudang',
                icon: Icons.inventory_rounded,
                color: context.neo.accentEnd,
              ),
              KpiCard(
                label: 'Recent Moves',
                value: '${snapshot.recentMovementsCount}',
                note: 'transaksi terakhir',
                icon: Icons.local_shipping_rounded,
                color: context.neo.accentEnd,
              ),
            ]),
          ),
        ),

        // ── Transactions ─────────────────────────────────────────────────────
        SliverPadding(
          padding: _hPad.add(const EdgeInsets.only(top: 24, bottom: 12)),
          sliver: const SliverToBoxAdapter(
            child: NeoKicker('Transaksi / transactions'),
          ),
        ),
        SliverPadding(
          padding: _hPad,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: twoCol ? 4 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: twoCol ? 1.15 : 1.5,
            ),
            delegate: SliverChildListDelegate(const [
              _TransactionTile(
                num: '01', label: 'Registrasi', en: 'NEW TRAY',
                icon: Icons.qr_code_scanner_rounded, route: '/register',
              ),
              _TransactionTile(
                num: '02', label: 'Movement', en: 'TRANSFER',
                icon: Icons.sensors_rounded, route: '/movement',
              ),
              _TransactionTile(
                num: '03', label: 'Scrap', en: 'DISPOSAL',
                icon: Icons.delete_sweep_rounded, route: '/scrap',
                muted: true,
              ),
              _TransactionTile(
                num: '04', label: 'Find', en: 'LOCATE',
                icon: Icons.location_searching_rounded, route: '/find',
              ),
            ]),
          ),
        ),

        // ── Latest movements ─────────────────────────────────────────────────
        SliverPadding(
          padding: _hPad.add(const EdgeInsets.only(top: 24, bottom: 10)),
          sliver: SliverToBoxAdapter(
            child: NeoKicker(
              'Aktivitas terakhir',
              trailing: 'Lihat semua',
              onTrailingTap: () => context.go('/history'),
            ),
          ),
        ),
        SliverPadding(
          padding: _hPad,
          sliver: SliverToBoxAdapter(
            child: _LatestMovements(movements: snapshot.latestMovements),
          ),
        ),

        // ── Stock by project ─────────────────────────────────────────────────
        SliverPadding(
          padding: _hPad.add(const EdgeInsets.only(top: 24, bottom: 10)),
          sliver: const SliverToBoxAdapter(
            child: NeoKicker('Stok per project'),
          ),
        ),
        SliverPadding(
          padding: _hPad.add(const EdgeInsets.only(bottom: AppSpacing.xl)),
          sliver: SliverToBoxAdapter(
            child: _ProjectStockPanel(
              stockItems: snapshot.stockByTrayType,
              trayTypesAsync: trayTypesAsync,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _PendingSyncBadge extends StatelessWidget {
  const _PendingSyncBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox(
      radius: 12,
      elevation: 0.55,
      onTap: () => context.go('/movement'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem_rounded, size: 13, color: neo.accentEnd),
          const SizedBox(width: 5),
          Text(
            '$count pending',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: neo.accentEnd,
            ),
          ),
        ],
      ),
    );
  }
}

/// Numbered action tile — the 01–04 transaction grid from the design.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.num,
    required this.label,
    required this.en,
    required this.icon,
    required this.route,
    this.muted = false,
  });

  final String num;
  final String label;
  final String en;
  final IconData icon;
  final String route;

  /// Scrap uses the neutral ramp so destructive flows don't read as primary.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return NeoBox(
      radius: AppSpacing.radiusNeo + 2,
      onTap: () => context.go(route),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: muted ? neo.mutedGradient : neo.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  num,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: neo.onAccent,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 17, color: neo.inkFaint),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: neo.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                en,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9,
                  color: neo.inkFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatestMovements extends StatelessWidget {
  const _LatestMovements({required this.movements});
  final List<TrayMovement> movements;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    if (movements.isEmpty) {
      return NeoBox.inset(
        radius: AppSpacing.radiusNeo,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined, size: 20, color: neo.inkFaint),
            const SizedBox(width: 12),
            Text(
              'Belum ada pergerakan tercatat',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: neo.inkMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < movements.take(5).length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _MovementRow(movement: movements[i]),
        ],
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});
  final TrayMovement movement;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return NeoBox(
      radius: AppSpacing.radiusNeo,
      elevation: 0.85,
      onTap: () => context.go('/history'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const NeoIconBadge(text: 'MOVE', size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movement.movementNumber,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: neo.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${movement.fromLocationName} → ${movement.toLocationName} · '
                  '${movement.totalRfid} tag',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: neo.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            // createdAt is nullable on TrayMovement; formatTime renders '-'.
            DateTimeFormatter.formatTime(movement.createdAt),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: neo.inkGhost,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectStockPanel extends StatelessWidget {
  const _ProjectStockPanel({
    required this.stockItems,
    required this.trayTypesAsync,
  });

  final List<StockByTrayType> stockItems;
  final AsyncValue<List<TrayType>> trayTypesAsync;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return trayTypesAsync.when(
      data: (types) {
        final summary = ProjectStockSummaryBuilder.build(stockItems.cast(), types);
        if (summary.isEmpty) {
          return NeoBox.inset(
            radius: AppSpacing.radiusNeo,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Belum ada data stok',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: neo.inkMuted,
              ),
            ),
          );
        }

        final max = summary
            .map((e) => e.total)
            .fold<int>(1, (a, b) => b > a ? b : a);

        return NeoBox(
          radius: AppSpacing.radiusNeo + 2,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Column(
            children: [
              for (final row in summary)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StockRow(
                    project: row.project,
                    total: row.total,
                    ratio: row.total / max,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.project,
    required this.total,
    required this.ratio,
  });

  final String project;
  final int total;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: neo.ink,
                ),
              ),
            ),
            Text(
              '$total',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: neo.accentEnd,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        NeoProgressBar(value: ratio, height: 10),
      ],
    );
  }
}

// ─── Loading / Error states ───────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        EmptyStateWidget(
          icon: Icons.cloud_off_rounded,
          iconColor: Theme.of(context).extension<AppColorScheme>()!.statusError,
          title: 'Dashboard tidak tersedia',
          subtitle: message,
          action: SizedBox(
            width: 190,
            child: NeoSecondaryButton(
              label: 'Coba lagi',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}
