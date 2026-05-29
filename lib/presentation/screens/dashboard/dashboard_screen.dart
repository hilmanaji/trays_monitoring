import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_formatter.dart';
import '../../../domain/entities/tray_type.dart';
import '../../providers/app_providers.dart';
import '../../utils/project_stock_summary.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

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
    final dashboard = ref.watch(dashboardSnapshotProvider);
    final pendingMovements = ref.watch(pendingMovementsProvider);
    final trayTypes = ref.watch(trayTypesProvider);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: dashboard.when(
        data: (snapshot) {
          final pendingCount = pendingMovements.maybeWhen(
            data: (items) => items.length,
            orElse: () => 0,
          );
          final width = MediaQuery.sizeOf(context).width;
          final cardWidth = width >= 1180
              ? 250.0
              : width >= 760
              ? (width - 74) / 2
              : double.infinity;
          final quickActionWidth = width >= 1180
              ? 220.0
              : width >= 760
              ? (width - 88) / 2
              : double.infinity;

          return ModulePage(
            title: 'Dashboard',
            subtitle:
                'Warehouse overview, stock posture, and recent tray activity.',
            actions: [
              if (pendingCount > 0)
                FilledButton.icon(
                  onPressed: () => context.go('/movement'),
                  icon: const Icon(Icons.sync_problem_rounded),
                  label: Text('Pending Sync $pendingCount'),
                ),
            ],
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E3E86), Color(0xFF1A6AF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warehouse Pulse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track tray flow, monitor inventory, and jump into daily actions faster from one mobile-friendly dashboard.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  KpiCard(
                    label: 'Total Trays',
                    value: '${snapshot.totalTrays}',
                    icon: Icons.inbox_rounded,
                    color: const Color(0xFF1A6AF4),
                  ),
                  KpiCard(
                    label: 'Total Locations',
                    value: '${snapshot.totalLocations}',
                    icon: Icons.place_rounded,
                    color: const Color(0xFF1FA6FF),
                  ),
                  KpiCard(
                    label: 'Stock Summary',
                    value: '${snapshot.totalStock}',
                    icon: Icons.inventory_rounded,
                    color: const Color(0xFF113D8D),
                  ),
                  KpiCard(
                    label: 'Recent Movements',
                    value: '${snapshot.recentMovementsCount}',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF5D7CFF),
                  ),
                ].map((card) => SizedBox(width: cardWidth, child: card)).toList(),
              ),
              const SizedBox(height: 16),
              SectionPanel(
                title: 'Quick Actions',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                      label: 'Register RFID',
                      icon: Icons.qr_code_scanner_rounded,
                      route: '/register',
                    ),
                    _QuickAction(
                      label: 'Move Trays',
                      icon: Icons.compare_arrows_rounded,
                      route: '/movement',
                    ),
                    _QuickAction(
                      label: 'Stock View',
                      icon: Icons.inventory_2_rounded,
                      route: '/stock',
                    ),
                    _QuickAction(
                      label: 'Scrap Tray',
                      icon: Icons.delete_sweep_rounded,
                      route: '/scrap',
                    ),
                  ].map((action) => SizedBox(width: quickActionWidth, child: action)).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SectionPanel(
                title: 'Latest Tray Movements',
                child: Column(
                  children: snapshot.latestMovements.isEmpty
                      ? const [
                          ListTile(title: Text('No movement data available.')),
                        ]
                      : snapshot.latestMovements
                            .take(5)
                            .map(
                              (movement) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(movement.movementNumber),
                                subtitle: Text(
                                  '${movement.fromLocationName} -> ${movement.toLocationName}',
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${movement.totalRfid} RFID'),
                                    Text(
                                      DateTimeFormatter.formatDateTime(
                                        movement.createdAt,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                ),
              ),
              const SizedBox(height: 16),
              SectionPanel(
                title: 'Stock by Project',
                child: _ProjectStockList(
                  stockItems: snapshot.stockByTrayType,
                  trayTypes: trayTypes,
                ),
              ),
            ],
          );
        },
        loading: () => const ModulePage(
          title: 'Dashboard',
          subtitle: 'Loading operational overview...',
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => ModulePage(
          title: 'Dashboard',
          subtitle: 'Operational overview is temporarily unavailable.',
          children: [
            SectionPanel(
              title: 'Dashboard Error',
              child: Text(error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectStockList extends StatelessWidget {
  const _ProjectStockList({required this.stockItems, required this.trayTypes});

  final List<dynamic> stockItems;
  final AsyncValue<List<TrayType>> trayTypes;

  @override
  Widget build(BuildContext context) {
    return trayTypes.when(
      data: (items) {
        final summary = ProjectStockSummaryBuilder.build(
          stockItems.cast(),
          items,
        );
        if (summary.isEmpty) {
          return const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('No stock data available.'),
          );
        }

        return Column(
          children: summary
              .map(
                (stock) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(stock.project),
                  trailing: Text('${stock.total}'),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.go(route),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: theme.textTheme.titleMedium),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
