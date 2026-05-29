import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
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
            'Location and tray-type stock visibility with warehouse-friendly tables.',
        children: [
          SectionPanel(
            title: 'Search',
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search location or tray type',
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
          stockByType.when(
            data: (items) {
              final filtered = items
                  .where(
                    (item) => item.trayTypeName.toLowerCase().contains(query),
                  )
                  .toList();
              return SectionPanel(
                title: 'Stock by Tray Type',
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Tray Type')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: filtered
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(Text(item.trayTypeName)),
                            DataCell(Text('${item.total}')),
                          ],
                        ),
                      )
                      .toList(),
                ),
              );
            },
            loading: () => const SectionPanel(
              title: 'Stock by Tray Type',
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stackTrace) => SectionPanel(
              title: 'Stock by Tray Type',
              child: Text(error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
