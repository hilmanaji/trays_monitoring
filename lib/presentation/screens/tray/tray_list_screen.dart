import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_formatter.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/module_page.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/section_panel.dart';

class TrayListScreen extends ConsumerStatefulWidget {
  const TrayListScreen({super.key});

  @override
  ConsumerState<TrayListScreen> createState() => _TrayListScreenState();
}

class _TrayListScreenState extends ConsumerState<TrayListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trays = ref.watch(
      trayListProvider(TraySearchQuery(search: _searchController.text)),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          trayListProvider(TraySearchQuery(search: _searchController.text)),
        );
        await ref.read(
          trayListProvider(
            TraySearchQuery(search: _searchController.text),
          ).future,
        );
      },
      child: ModulePage(
        title: 'Tray Detail Module',
        subtitle:
            'Search trays and drill into RFID EPC, type, location, and status.',
        children: [
          SectionPanel(
            title: 'Search Tray',
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by RFID EPC or tray identifier',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          trays.when(
            data: (items) => SectionPanel(
              title: 'Tray List',
              child: Column(
                children: items.isEmpty
                    ? const [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('No trays found.'),
                        ),
                      ]
                    : items
                          .map(
                            // Rows are wells inside the panel: raised-on-raised
                            // reads as noise in soft UI.
                            (tray) => NeoBox.inset(
                              margin: const EdgeInsets.only(bottom: 12),
                              radius: AppSpacing.radiusNeoSm,
                              elevation: 0.7,
                              child: ListTile(
                                title: Text(tray.epc),
                                subtitle: Text(
                                  '${tray.trayTypeName} • ${tray.currentLocationName}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(tray.status),
                                    Text(
                                      DateTimeFormatter.formatDate(
                                        tray.createdAt,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    context.go('/trays/detail/${tray.id}'),
                              ),
                            ),
                          )
                          .toList(),
              ),
            ),
            loading: () => const SectionPanel(
              title: 'Tray List',
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stackTrace) =>
                SectionPanel(title: 'Tray List', child: Text(error.toString())),
          ),
        ],
      ),
    );
  }
}
