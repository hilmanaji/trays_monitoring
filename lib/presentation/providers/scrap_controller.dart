import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/feedback_service.dart';
import '../../domain/entities/scrap_request.dart';
import '../../domain/usecases/tray_usecases.dart';
import 'app_providers.dart';
import 'registration_controller.dart';

final scrapControllerProvider =
    StateNotifierProvider<ScrapController, SubmissionState>((ref) {
      return ScrapController(
        scrapTrayUseCase: ref.watch(scrapTrayUseCaseProvider),
        operatorFeedbackService: ref.watch(operatorFeedbackServiceProvider),
      );
    });

class ScrapController extends StateNotifier<SubmissionState> {
  ScrapController({
    required this.scrapTrayUseCase,
    required this.operatorFeedbackService,
  }) : super(const SubmissionState());

  final ScrapTrayUseCase scrapTrayUseCase;
  final OperatorFeedbackService operatorFeedbackService;

  Future<bool> submit({
    required String epc,
    required String reason,
    required String remarks,
  }) async {
    final normalized = epc.trim().toUpperCase();
    if (normalized.isEmpty) {
      state = state.copyWith(errorMessage: 'RFID EPC cannot be empty.');
      return false;
    }
    if (reason.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Scrap reason is required.');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await scrapTrayUseCase.call(
        ScrapRequest(
          epc: normalized,
          reason: reason.trim(),
          remarks: remarks.trim(),
        ),
      );
      await operatorFeedbackService.operationCompleted();
      state = const SubmissionState(
        successMessage: 'Tray scrap submitted successfully.',
      );
      return true;
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
}
