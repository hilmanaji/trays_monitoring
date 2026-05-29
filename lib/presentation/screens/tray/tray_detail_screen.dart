import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_formatter.dart';
import '../../providers/app_providers.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class TrayDetailScreen extends ConsumerWidget {
  const TrayDetailScreen({super.key, required this.trayId});

  final int trayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tray = ref.watch(trayDetailProvider(trayId));

    return ModulePage(
      title: 'Tray Detail',
      subtitle: 'Inspect tray identity, location, and lifecycle status.',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/trays'),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to Trays'),
        ),
      ],
      children: [
        tray.when(
          data: (item) => SectionPanel(
            title: item.epc,
            child: Column(
              children: [
                _DetailRow(label: 'Tray Type', value: item.trayTypeName),
                _DetailRow(
                  label: 'Current Location',
                  value: item.currentLocationName,
                ),
                _DetailRow(label: 'Status', value: item.status),
                _DetailRow(
                  label: 'Created Date',
                  value: DateTimeFormatter.formatDateTime(item.createdAt),
                ),
              ],
            ),
          ),
          loading: () => const SectionPanel(
            title: 'Tray Detail',
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, stackTrace) =>
              SectionPanel(title: 'Tray Detail', child: Text(error.toString())),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label)),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
