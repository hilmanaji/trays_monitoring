import '../../core/utils/json_utils.dart';
import '../../domain/entities/movement_page.dart';
import 'tray_movement_model.dart';

class MovementPageModel extends MovementPage {
  const MovementPageModel({
    required super.items,
    required super.currentPage,
    required super.lastPage,
    required super.total,
  });

  factory MovementPageModel.fromJson(dynamic payload) {
    final map = JsonUtils.asMap(payload);
    final metaSource = map['data'] is Map ? JsonUtils.asMap(map['data']) : map;
    final items = JsonUtils.unwrapList(payload)
        .map((entry) => TrayMovementModel.fromJson(JsonUtils.asMap(entry)))
        .toList();

    return MovementPageModel(
      items: items,
      currentPage: JsonUtils.intValue(metaSource, const [
        'current_page',
      ], fallback: 1),
      lastPage: JsonUtils.intValue(metaSource, const [
        'last_page',
      ], fallback: items.isEmpty ? 1 : 1),
      total: JsonUtils.intValue(metaSource, const [
        'total',
      ], fallback: items.length),
    );
  }
}
