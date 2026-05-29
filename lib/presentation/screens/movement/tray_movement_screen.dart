import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/movement_form_controller.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class TrayMovementScreen extends ConsumerStatefulWidget {
  const TrayMovementScreen({super.key});

  @override
  ConsumerState<TrayMovementScreen> createState() => _TrayMovementScreenState();
}

class _TrayMovementScreenState extends ConsumerState<TrayMovementScreen> {
  int? _fromLocationId;
  int? _toLocationId;

  Future<void> _manualScan() async {
    final controller = TextEditingController();
    final scannedValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual RFID Input'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'RFID EPC list',
            hintText: 'One EPC per line or separated by commas',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add Tags'),
          ),
        ],
      ),
    );

    if (scannedValue != null && scannedValue.trim().isNotEmpty) {
      ref.read(movementFormControllerProvider.notifier).addManualTags(
        scannedValue,
      );
    }
  }

  Future<void> _submit() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Movement'),
            content: Text(
              'Submit ${ref.read(movementFormControllerProvider).rfids.length} scanned RFID tags as one tray movement transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Submit'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }

    final result = await ref
        .read(movementFormControllerProvider.notifier)
        .submit(fromLocationId: _fromLocationId, toLocationId: _toLocationId);
    if (!mounted) {
      return;
    }

    final state = ref.read(movementFormControllerProvider);
    if (state.infoMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.infoMessage!)));
      ref.read(movementFormControllerProvider.notifier).clearMessages();
      if (result != MovementSubmissionResult.invalid) {
        setState(() {
          _fromLocationId = null;
          _toLocationId = null;
        });
        ref.invalidate(pendingMovementsProvider);
      }
    }
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      ref.read(movementFormControllerProvider.notifier).clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationsProvider);
    final formState = ref.watch(movementFormControllerProvider);

    return ModulePage(
      title: 'Tray Movement',
      subtitle:
          'Scan multiple RFID tags and submit warehouse movement transactions.',
      children: [
        SectionPanel(
          title: 'Movement Configuration',
          child: locations.when(
            data: (items) => Column(
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _fromLocationId,
                  decoration: const InputDecoration(labelText: 'From Location'),
                  items: items
                      .map(
                        (location) => DropdownMenuItem<int>(
                          value: location.id,
                          child: Text(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _fromLocationId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _toLocationId,
                  decoration: const InputDecoration(labelText: 'To Location'),
                  items: items
                      .map(
                        (location) => DropdownMenuItem<int>(
                          value: location.id,
                          child: Text(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _toLocationId = value),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(error.toString()),
          ),
        ),
        const SizedBox(height: 12),
        SectionPanel(
          title: 'Scanned RFID List',
          trailing: Text('Total ${formState.rfids.length}'),
          child: Column(
            children: [
              if (formState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              if (formState.rfids.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No RFID tags scanned yet.'),
                ),
              ...formState.rfids.map(
                (epc) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(epc),
                    trailing: IconButton(
                      onPressed: () => ref
                          .read(movementFormControllerProvider.notifier)
                          .removeTag(epc),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionPanel(
          title: 'Operator Actions',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: formState.isScanning
                      ? () => ref
                            .read(movementFormControllerProvider.notifier)
                            .stopScan()
                      : () => ref
                            .read(movementFormControllerProvider.notifier)
                            .startScan(),
                  icon: Icon(
                    formState.isScanning
                        ? Icons.stop_circle_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    formState.isScanning ? 'Stop Scan' : 'Start Scan',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  onPressed: _manualScan,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: const Text('Manual RFID Input'),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  onPressed: formState.rfids.isEmpty
                      ? null
                      : () => ref
                            .read(movementFormControllerProvider.notifier)
                            .clearTags(),
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text('Clear List'),
                ),
              ),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: formState.isSubmitting ? null : _submit,
                  icon: formState.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('Submit Movement'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
