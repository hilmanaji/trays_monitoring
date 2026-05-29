import 'package:hive_flutter/hive_flutter.dart';

import '../constants/api_constants.dart';

class HiveStorageService {
  HiveStorageService._();

  static final HiveStorageService instance = HiveStorageService._();

  Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(ApiConstants.pendingMovementsBox)) {
      await Hive.openBox<dynamic>(ApiConstants.pendingMovementsBox);
    }
  }

  Box<dynamic> get pendingMovementsBox =>
      Hive.box<dynamic>(ApiConstants.pendingMovementsBox);
}
