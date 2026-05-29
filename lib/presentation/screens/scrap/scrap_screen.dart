import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/scrap_controller.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class ScrapScreen extends ConsumerStatefulWidget {
  const ScrapScreen({super.key});

  @override
  ConsumerState<ScrapScreen> createState() => _ScrapScreenState();
}

class _ScrapScreenState extends ConsumerState<ScrapScreen> {
  final _epcController = TextEditingController();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _epcController.dispose();
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _scanRfid() async {
    final controller = TextEditingController();
    final epc = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulated RFID Scan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'RFID EPC'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Use EPC'),
          ),
        ],
      ),
    );
    if (epc != null && epc.trim().isNotEmpty) {
      _epcController.text = epc.trim().toUpperCase();
      await ref.read(operatorFeedbackServiceProvider).tagCaptured();
    }
  }

  Future<void> _submit() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Scrap'),
            content: const Text(
              'Submit this tray as scrap? This action should be reviewed carefully.',
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

    final ok = await ref
        .read(scrapControllerProvider.notifier)
        .submit(
          epc: _epcController.text,
          reason: _reasonController.text,
          remarks: _remarksController.text,
        );
    final state = ref.read(scrapControllerProvider);
    if (!mounted) {
      return;
    }

    if (state.successMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
      ref.read(scrapControllerProvider.notifier).clearMessages();
      if (ok) {
        _epcController.clear();
        _reasonController.clear();
        _remarksController.clear();
      }
    }
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      ref.read(scrapControllerProvider.notifier).clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(scrapControllerProvider);

    return ModulePage(
      title: 'Scrap Module',
      subtitle:
          'Scan a tray, record the reason, and submit scrap transactions.',
      children: [
        SectionPanel(
          title: 'Scrap Form',
          child: Column(
            children: [
              TextField(
                controller: _epcController,
                decoration: const InputDecoration(
                  labelText: 'RFID EPC',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Scrap Reason',
                  prefixIcon: Icon(Icons.report_problem_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _remarksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  prefixIcon: Icon(Icons.notes_rounded),
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
                  onPressed: _scanRfid,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Scan RFID'),
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
                      : const Icon(Icons.delete_forever_rounded),
                  label: const Text('Submit Scrap'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
