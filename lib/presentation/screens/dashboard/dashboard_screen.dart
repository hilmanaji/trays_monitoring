import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_formatter.dart';
import '../../../domain/entities/tray_type.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/project_stock_summary.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/kpi_card.dart';

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

  final dynamic snapshot;
  final int pendingCount;
  final AsyncValue<List<TrayType>> trayTypesAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;
    final w     = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 600;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Hero header ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.headerGradientStart, cs.headerGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warehouse Pulse',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Real-time tray tracking & inventory status',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 12),
                  _PendingSyncBadge(count: pendingCount),
                ],
              ],
            ),
          ),
        ),

        // ── KPI grid ─────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: twoCol ? 4 : 2,
              crossAxisSpacing: AppSpacing.itemGap,
              mainAxisSpacing: AppSpacing.itemGap,
              childAspectRatio: twoCol ? 1.0 : 1.15,
            ),
            delegate: SliverChildListDelegate([
              KpiCard(
                label: 'Total Trays',
                value: '${snapshot.totalTrays}',
                icon: Icons.inbox_rounded,
                color: AppColors.primary500,
              ),
              KpiCard(
                label: 'Locations',
                value: '${snapshot.totalLocations}',
                icon: Icons.place_rounded,
                color: AppColors.blue500,
              ),
              KpiCard(
                label: 'Stock Items',
                value: '${snapshot.totalStock}',
                icon: Icons.inventory_rounded,
                color: AppColors.green600,
              ),
              KpiCard(
                label: 'Recent Moves',
                value: '${snapshot.recentMovementsCount}',
                icon: Icons.local_shipping_rounded,
                color: AppColors.amber500,
              ),
            ]),
          ),
        ),

        // ── Quick actions ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
          ),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: 'Quick Actions'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
          ),
          sliver: SliverToBoxAdapter(
            child: _QuickActionStrip(),
          ),
        ),

        // ── Latest movements ─────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
          ),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: 'Latest Movements'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
          ),
          sliver: SliverToBoxAdapter(
            child: _LatestMovements(movements: snapshot.latestMovements),
          ),
        ),

        // ── Stock by project ─────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
          ),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: 'Stock by Project'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl,
          ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _PendingSyncBadge extends StatelessWidget {
  const _PendingSyncBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/movement'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync_problem_rounded,
                color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            Text(
              'pending',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;

    const actions = [
      (Icons.sensors_rounded,       'Scan',     '/movement', AppColors.primary500),
      (Icons.qr_code_scanner_rounded,'Register', '/register', AppColors.blue500),
      (Icons.location_searching_rounded, 'Find', '/find',     AppColors.green500),
      (Icons.delete_sweep_rounded,   'Scrap',    '/scrap',    AppColors.red500),
    ];

    return Row(
      children: [
        for (final (icon, label, route, color) in actions) ...[
          Expanded(
            child: _QuickActionTile(
              icon: icon,
              label: label,
              route: route,
              color: color,
              cardColor: cs.surfaceCard,
              outlineColor: theme.colorScheme.outline,
            ),
          ),
          if (route != actions.last.$3) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    required this.cardColor,
    required this.outlineColor,
  });

  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final Color cardColor;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: outlineColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestMovements extends StatelessWidget {
  const _LatestMovements({required this.movements});
  final List<dynamic> movements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;

    if (movements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.inbox_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Text(
              'No movements recorded yet',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < movements.take(5).length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color: theme.colorScheme.outline,
              ),
            _MovementRow(movement: movements[i]),
          ],
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});
  final dynamic movement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.compare_arrows_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.movementNumber as String? ?? '',
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${movement.fromLocationName} → ${movement.toLocationName}',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${movement.totalRfid} tags',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DateTimeFormatter.formatDateTime(movement.createdAt as DateTime),
                style: theme.textTheme.labelSmall,
              ),
            ],
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

  final List<dynamic> stockItems;
  final AsyncValue<List<TrayType>> trayTypesAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.extension<AppColorScheme>()!;

    return trayTypesAsync.when(
      data: (types) {
        final summary = ProjectStockSummaryBuilder.build(
          stockItems.cast(),
          types,
        );
        if (summary.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Text(
              'No stock data available',
              style: theme.textTheme.bodySmall,
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            children: [
              for (var i = 0; i < summary.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: theme.colorScheme.outline,
                  ),
                _StockRow(project: summary[i].project, total: summary[i].total),
              ],
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
      error: (e, _) => Text(e.toString()),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.project, required this.total});
  final String project;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(project, style: theme.textTheme.bodyMedium),
          ),
          Text(
            '$total',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
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
    return EmptyStateWidget(
      icon: Icons.cloud_off_rounded,
      title: 'Dashboard unavailable',
      subtitle: message,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
      ),
    );
  }
}
