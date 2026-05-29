import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/registration_controller.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class RfidRegistrationScreen extends ConsumerStatefulWidget {
  const RfidRegistrationScreen({super.key});

  @override
  ConsumerState<RfidRegistrationScreen> createState() =>
      _RfidRegistrationScreenState();
}

class _RfidRegistrationScreenState
    extends ConsumerState<RfidRegistrationScreen> {
  int? _trayTypeId;
  int? _locationId;

  Widget _dropdownLabel(String value) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  Future<void> _scanRfid() async {
    final controller = TextEditingController();
    final epcs = await showDialog<String>(
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
    if (epcs != null && epcs.trim().isNotEmpty) {
      ref.read(registrationControllerProvider.notifier).addManualTags(epcs);
    }
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(registrationControllerProvider.notifier)
        .submit(
          trayTypeId: _trayTypeId,
          locationId: _locationId,
        );
    final state = ref.read(registrationControllerProvider);
    if (!mounted) {
      return;
    }

    if (state.successMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
      ref.read(registrationControllerProvider.notifier).clearMessages();
      if (ok) {
        setState(() {
          _trayTypeId = null;
          _locationId = null;
        });
      }
    }
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      ref.read(registrationControllerProvider.notifier).clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trayTypes = ref.watch(trayTypesProvider);
    final locations = ref.watch(locationsProvider);
    final submissionState = ref.watch(registrationControllerProvider);

    return ModulePage(
      title: 'RFID Registration',
      subtitle: 'Register new tray tags with tray type and starting location.',
      children: [
        SectionPanel(
          title: 'Registration Form',
          child: Column(
            children: [
              trayTypes.when(
                data: (items) => DropdownButtonFormField<int>(
                  initialValue: _trayTypeId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tray Type'),
                  items: items
                      .map(
                        (trayType) => DropdownMenuItem<int>(
                          value: trayType.id,
                          child: _dropdownLabel(trayType.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _trayTypeId = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(error.toString()),
              ),
              const SizedBox(height: 16),
              locations.when(
                data: (items) => DropdownButtonFormField<int>(
                  initialValue: _locationId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Initial Location',
                  ),
                  items: items
                      .map(
                        (location) => DropdownMenuItem<int>(
                          value: location.id,
                          child: _dropdownLabel(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _locationId = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(error.toString()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionPanel(
          title: 'Scanned RFID List',
          trailing: Text('Total ${submissionState.epcs.length}'),
          child: Column(
            children: [
              if (submissionState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      submissionState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              if (submissionState.epcs.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No RFID tags scanned yet.'),
                ),
              ...submissionState.epcs.map(
                (epc) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      epc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      onPressed: () => ref
                          .read(registrationControllerProvider.notifier)
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
                  onPressed: submissionState.isScanning
                      ? () => ref
                            .read(registrationControllerProvider.notifier)
                            .stopScan()
                      : () => ref
                            .read(registrationControllerProvider.notifier)
                            .startScan(),
                  icon: Icon(
                    submissionState.isScanning
                        ? Icons.stop_circle_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    submissionState.isScanning ? 'Stop Scan' : 'Start Scan',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  onPressed: _scanRfid,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: const Text('Manual RFID Input'),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  onPressed: submissionState.epcs.isEmpty
                      ? null
                      : () => ref
                            .read(registrationControllerProvider.notifier)
                            .clearTags(),
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text('Clear List'),
                ),
              ),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: submissionState.isSubmitting ? null : _submit,
                  icon: submissionState.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Submit Registration'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
