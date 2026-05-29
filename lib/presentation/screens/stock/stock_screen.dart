import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/tray_type.dart';
import '../../providers/app_providers.dart';
import '../../utils/project_stock_summary.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockSummary = ref.watch(stockSummaryProvider);
    final stockByType = ref.watch(stockByTrayTypeProvider);
    final trayTypes = ref.watch(trayTypesProvider);
    final query = _searchController.text.trim().toLowerCase();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stockSummaryProvider);
        ref.invalidate(stockByTrayTypeProvider);
        await Future.wait<dynamic>([
          ref.read(stockSummaryProvider.future),
          ref.read(stockByTrayTypeProvider.future),
        ]);
      },
      child: ModulePage(
        title: 'Stock Module',
        subtitle:
            'Location and project-level stock visibility with warehouse-friendly tables.',
        children: [
          SectionPanel(
            title: 'Search',
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search location or project',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          stockSummary.when(
            data: (items) {
              final filtered = items
                  .where(
                    (item) => item.locationName.toLowerCase().contains(query),
                  )
                  .toList();
              return SectionPanel(
                title: 'Stock by Location',
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: filtered
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(Text(item.locationName)),
                            DataCell(Text('${item.total}')),
                          ],
                        ),
                      )
                      .toList(),
                ),
              );
            },
            loading: () => const SectionPanel(
              title: 'Stock by Location',
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stackTrace) => SectionPanel(
              title: 'Stock by Location',
              child: Text(error.toString()),
            ),
          ),
          const SizedBox(height: 12),
          _ProjectStockTable(
            stockByType: stockByType,
            trayTypes: trayTypes,
            query: query,
          ),
        ],
      ),
    );
  }
}

class _ProjectStockTable extends StatelessWidget {
  const _ProjectStockTable({
    required this.stockByType,
    required this.trayTypes,
    required this.query,
  });

  final AsyncValue<List<dynamic>> stockByType;
  final AsyncValue<List<TrayType>> trayTypes;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (stockByType.isLoading || trayTypes.isLoading) {
      return const SectionPanel(
        title: 'Stock by Project',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (stockByType.hasError) {
      return SectionPanel(
        title: 'Stock by Project',
        child: Text(stockByType.error.toString()),
      );
    }

    if (trayTypes.hasError) {
      return SectionPanel(
        title: 'Stock by Project',
        child: Text(trayTypes.error.toString()),
      );
    }

    final summary = ProjectStockSummaryBuilder.build(
      stockByType.valueOrNull?.cast() ?? const [],
      trayTypes.valueOrNull ?? const <TrayType>[],
    );
    final filtered = summary
        .where((item) => item.project.toLowerCase().contains(query))
        .toList();

    return SectionPanel(
      title: 'Stock by Project',
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Project')),
          DataColumn(label: Text('Total')),
        ],
        rows: filtered
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.project)),
                  DataCell(Text('${item.total}')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
