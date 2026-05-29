import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class OperatorFeedbackService {
  Future<void> tagCaptured() async {
    await SystemSound.play(SystemSoundType.click);
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      await Vibration.vibrate(duration: 60);
    }
  }

  Future<void> operationCompleted() async {
    await SystemSound.play(SystemSoundType.alert);
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      await Vibration.vibrate(duration: 120);
    }
  }
}
