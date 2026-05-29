import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/register_rfid_request.dart';
import '../../domain/usecases/tray_usecases.dart';
import '../../core/utils/feedback_service.dart';
import '../../services/rfid/rfid_service.dart';
import 'app_providers.dart';

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, SubmissionState>((ref) {
      return RegistrationController(
        registerRfidUseCase: ref.watch(registerRfidUseCaseProvider),
        getTraysUseCase: ref.watch(getTraysUseCaseProvider),
        operatorFeedbackService: ref.watch(operatorFeedbackServiceProvider),
        rfidService: ref.watch(rfidServiceProvider),
      );
    });

class SubmissionState {
  const SubmissionState({
    this.isScanning = false,
    this.isSubmitting = false,
    this.epcs = const <String>[],
    this.errorMessage,
    this.successMessage,
  });

  final bool isScanning;
  final bool isSubmitting;
  final List<String> epcs;
  final String? errorMessage;
  final String? successMessage;

  SubmissionState copyWith({
    bool? isScanning,
    bool? isSubmitting,
    List<String>? epcs,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SubmissionState(
      isScanning: isScanning ?? this.isScanning,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      epcs: epcs ?? this.epcs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class RegistrationController extends StateNotifier<SubmissionState> {
  RegistrationController({
    required this.registerRfidUseCase,
    required this.getTraysUseCase,
    required this.operatorFeedbackService,
    required this.rfidService,
  }) : super(const SubmissionState()) {
    _subscription = rfidService.scannedTags.listen(_handleTagScanned);
  }

  final RegisterRfidUseCase registerRfidUseCase;
  final GetTraysUseCase getTraysUseCase;
  final OperatorFeedbackService operatorFeedbackService;
  final RFIDService rfidService;
  late final StreamSubscription<String> _subscription;

  Future<void> startScan() async {
    await rfidService.startScan();
    state = state.copyWith(
      isScanning: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> stopScan() async {
    await rfidService.stopScan();
    state = state.copyWith(isScanning: false);
  }

  void addManualTags(String rawInput) {
    for (final epc in _parseTags(rawInput)) {
      _handleTagScanned(epc);
    }
  }

  void removeTag(String epc) {
    final updated = [...state.epcs]..remove(epc);
    state = state.copyWith(epcs: updated);
  }

  void clearTags() {
    state = state.copyWith(
      epcs: const <String>[],
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<bool> submit({
    required int? trayTypeId,
    required int? locationId,
  }) async {
    if (state.epcs.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Scan at least one RFID EPC before submitting.',
      );
      return false;
    }
    if (trayTypeId == null || locationId == null) {
      state = state.copyWith(
        errorMessage: 'Select tray type and initial location.',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final duplicates = <String>[];
      for (final epc in state.epcs) {
        final trays = await getTraysUseCase.call(search: epc);
        final exists = trays.any(
          (tray) => tray.epc.toString().toUpperCase() == epc,
        );
        if (exists) {
          duplicates.add(epc);
        }
      }

      if (duplicates.isNotEmpty) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage:
              'Duplicate EPC detected: ${duplicates.take(3).join(', ')}${duplicates.length > 3 ? ' and ${duplicates.length - 3} more' : ''}.',
        );
        return false;
      }

      final failed = <String, String>{};
      var successCount = 0;

      for (final epc in state.epcs) {
        try {
          await registerRfidUseCase.call(
            RegisterRfidRequest(
              epc: epc,
              trayTypeId: trayTypeId,
              locationId: locationId,
            ),
          );
          successCount += 1;
        } on AppException catch (error) {
          failed[epc] = error.displayMessage;
        }
      }

      if (successCount > 0) {
        await operatorFeedbackService.operationCompleted();
      }
      await stopScan();

      if (failed.isEmpty) {
        state = SubmissionState(
          successMessage: '$successCount RFID trays registered successfully.',
        );
        return true;
      }

      state = SubmissionState(
        epcs: failed.keys.toList(),
        errorMessage:
        '${successCount > 0 ? 'Registered $successCount trays. ' : ''}Failed ${failed.length} RFID tags. ${failed.entries.first.key}: ${failed.entries.first.value}. Remaining tags were kept in the list for retry.',
      );
      return false;
    } on AppException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.displayMessage,
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  void _handleTagScanned(String epc) {
    final normalized = epc.trim().toUpperCase();
    if (normalized.isEmpty || state.epcs.contains(normalized)) {
      return;
    }

    state = state.copyWith(
      epcs: [...state.epcs, normalized],
      clearError: true,
      clearSuccess: true,
    );
    unawaited(operatorFeedbackService.tagCaptured());
  }

  List<String> _parseTags(String rawInput) {
    return rawInput
        .split(RegExp(r'[\n,;]+'))
        .map((entry) => entry.trim().toUpperCase())
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
