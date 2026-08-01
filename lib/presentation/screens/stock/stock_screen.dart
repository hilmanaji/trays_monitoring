import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/tray_type.dart';
import '../../providers/app_providers.dart';
import '../../theme/neo_theme.dart';
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
                child: _ScrollableTable(
                  columns: const ['Location', 'Total'],
                  rows: filtered
                      .map((item) => [item.locationName, '${item.total}'])
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
      child: _ScrollableTable(
        columns: const ['Project', 'Total'],
        rows: filtered
            .map((item) => [item.project, '${item.total}'])
            .toList(),
      ),
    );
  }
}

/// A DataTable sizes itself to its content, so on a 375px handheld the default
/// column spacing pushes it past the panel and Flutter reports a right-edge
/// overflow. Tighter metrics make it fit in the common case, and the horizontal
/// scroll view keeps long location names reachable instead of clipped.
class _ScrollableTable extends StatelessWidget {
  const _ScrollableTable({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    if (rows.isEmpty) {
      return Text(
        'No data for the current filter.',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: neo.inkMuted,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 100,
        ),
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 0,
          headingRowHeight: 38,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 48,
          dividerThickness: 1,
          headingTextStyle: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: neo.inkFaint,
          ),
          dataTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: neo.ink,
          ),
          columns: [
            for (final c in columns) DataColumn(label: Text(c.toUpperCase())),
          ],
          rows: [
            for (final r in rows)
              DataRow(cells: [for (final cell in r) DataCell(Text(cell))]),
          ],
        ),
      ),
    );
  }
}
