import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/feedback_service.dart';
import '../../domain/entities/movement_request.dart';
import '../../domain/entities/pending_movement.dart';
import '../../domain/usecases/movement_usecases.dart';
import '../../services/rfid/rfid_service.dart';
import 'app_providers.dart';

final movementFormControllerProvider =
    StateNotifierProvider<MovementFormController, MovementFormState>((ref) {
      return MovementFormController(
        rfidService: ref.watch(rfidServiceProvider),
        operatorFeedbackService: ref.watch(operatorFeedbackServiceProvider),
        createTrayMovementUseCase: ref.watch(createTrayMovementUseCaseProvider),
        savePendingMovementUseCase: ref.watch(
          savePendingMovementUseCaseProvider,
        ),
      );
    });

enum MovementSubmissionResult { submitted, queuedOffline, invalid }

class MovementFormState {
  const MovementFormState({
    this.isScanning = false,
    this.isSubmitting = false,
    this.rfids = const <String>[],
    this.errorMessage,
    this.infoMessage,
  });

  final bool isScanning;
  final bool isSubmitting;
  final List<String> rfids;
  final String? errorMessage;
  final String? infoMessage;

  MovementFormState copyWith({
    bool? isScanning,
    bool? isSubmitting,
    List<String>? rfids,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return MovementFormState(
      isScanning: isScanning ?? this.isScanning,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      rfids: rfids ?? this.rfids,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}

class MovementFormController extends StateNotifier<MovementFormState> {
  MovementFormController({
    required this.rfidService,
    required this.operatorFeedbackService,
    required this.createTrayMovementUseCase,
    required this.savePendingMovementUseCase,
  }) : super(const MovementFormState()) {
    _subscription = rfidService.scannedTags.listen(_handleTagScanned);
  }

  final RFIDService rfidService;
  final OperatorFeedbackService operatorFeedbackService;
  final CreateTrayMovementUseCase createTrayMovementUseCase;
  final SavePendingMovementUseCase savePendingMovementUseCase;
  late final StreamSubscription<String> _subscription;

  Future<void> startScan() async {
    await rfidService.startScan();
    state = state.copyWith(isScanning: true, clearError: true, clearInfo: true);
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
    final updated = [...state.rfids]..remove(epc);
    state = state.copyWith(rfids: updated);
  }

  void clearTags() {
    state = state.copyWith(
      rfids: const <String>[],
      clearError: true,
      clearInfo: true,
    );
  }

  Future<MovementSubmissionResult> submit({
    required int? fromLocationId,
    required int? toLocationId,
  }) async {
    if (fromLocationId == null || toLocationId == null) {
      state = state.copyWith(
        errorMessage: 'Select both origin and destination locations.',
      );
      return MovementSubmissionResult.invalid;
    }
    if (fromLocationId == toLocationId) {
      state = state.copyWith(
        errorMessage: 'Origin and destination must be different.',
      );
      return MovementSubmissionResult.invalid;
    }
    if (state.rfids.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Scan at least one RFID tag before submitting.',
      );
      return MovementSubmissionResult.invalid;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearInfo: true,
    );
    final request = MovementRequest(
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      rfids: state.rfids,
    );

    try {
      await createTrayMovementUseCase.call(request);
      await operatorFeedbackService.operationCompleted();
      await stopScan();
      state = const MovementFormState(
        infoMessage: 'Tray movement submitted successfully.',
      );
      return MovementSubmissionResult.submitted;
    } on AppException catch (error) {
      if (error.type == AppExceptionType.network ||
          error.type == AppExceptionType.timeout) {
        await savePendingMovementUseCase.call(
          PendingMovement(
            localId: DateTime.now().millisecondsSinceEpoch.toString(),
            fromLocationId: fromLocationId,
            toLocationId: toLocationId,
            rfids: state.rfids,
            createdAt: DateTime.now(),
          ),
        );
        await stopScan();
        state = const MovementFormState(
          infoMessage:
              'Network unavailable. Movement saved locally for later sync.',
        );
        return MovementSubmissionResult.queuedOffline;
      }

      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.displayMessage,
      );
      return MovementSubmissionResult.invalid;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }

  void _handleTagScanned(String epc) {
    final normalized = epc.trim().toUpperCase();
    if (normalized.isEmpty || state.rfids.contains(normalized)) {
      return;
    }

    state = state.copyWith(
      rfids: [...state.rfids, normalized],
      clearError: true,
      clearInfo: true,
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
