import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_time_formatter.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/module_page.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/section_panel.dart';

class MovementHistoryScreen extends ConsumerStatefulWidget {
  const MovementHistoryScreen({super.key});

  @override
  ConsumerState<MovementHistoryScreen> createState() =>
      _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends ConsumerState<MovementHistoryScreen> {
  final _searchController = TextEditingController();
  int _page = 1;
  int? _locationId;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
        _page = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = MovementHistoryQuery(
      page: _page,
      search: _searchController.text,
      locationId: _locationId,
      date: _selectedDate,
    );
    final history = ref.watch(movementHistoryProvider(query));
    final locations = ref.watch(locationsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(movementHistoryProvider(query));
        await ref.read(movementHistoryProvider(query).future);
      },
      child: ModulePage(
        title: 'Movement History',
        subtitle:
            'Search and audit tray movement transactions with operational filters.',
        children: [
          SectionPanel(
            title: 'Filters',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search movement number or RFID',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onSubmitted: (_) => setState(() => _page = 1),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: locations.when(
                    data: (items) => DropdownButtonFormField<int?>(
                      initialValue: _locationId,
                      decoration: const InputDecoration(labelText: 'Location'),
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Locations'),
                        ),
                        ...items.map(
                          (location) => DropdownMenuItem<int?>(
                            value: location.id,
                            child: Text(location.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _locationId = value;
                        _page = 1;
                      }),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stackTrace) => Text(error.toString()),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(
                    _selectedDate == null
                        ? 'Filter Date'
                        : DateTimeFormatter.formatDate(_selectedDate),
                  ),
                ),
                if (_selectedDate != null)
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _selectedDate = null;
                      _page = 1;
                    }),
                    child: const Text('Clear Date'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          history.when(
            data: (pageData) => SectionPanel(
              title: 'Movements',
              trailing: Text(
                'Page ${pageData.currentPage}/${pageData.lastPage}',
              ),
              child: Column(
                children: [
                  if (pageData.items.isEmpty)
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'No movements found for the selected filters.',
                      ),
                    ),
                  ...pageData.items.map(
                    (movement) => NeoBox.inset(
                      margin: const EdgeInsets.only(bottom: 12),
                      radius: AppSpacing.radiusNeoSm,
                      elevation: 0.7,
                      child: ListTile(
                        title: Text(movement.movementNumber),
                        subtitle: Text(
                          '${movement.fromLocationName} -> ${movement.toLocationName}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: pageData.hasPrevious
                            ? () => setState(() => _page -= 1)
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: pageData.hasNext
                            ? () => setState(() => _page += 1)
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const SectionPanel(
              title: 'Movements',
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stackTrace) =>
                SectionPanel(title: 'Movements', child: Text(error.toString())),
          ),
        ],
      ),
    );
  }
}
