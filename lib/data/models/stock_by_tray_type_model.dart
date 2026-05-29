import '../../core/utils/json_utils.dart';
import '../../domain/entities/stock_by_tray_type.dart';

class StockByTrayTypeModel extends StockByTrayType {
  const StockByTrayTypeModel({
    required super.trayTypeId,
    required super.trayTypeName,
    required super.total,
  });

  factory StockByTrayTypeModel.fromJson(Map<String, dynamic> json) {
    final trayType = JsonUtils.asMap(json['tray_type']);
    final trayTypeName = JsonUtils.stringValue(
      trayType,
      const ['name', 'tray_type_name', 'model', 'material_description'],
      fallback: JsonUtils.stringValue(json, const [
        'tray_type',
        'tray_type_name',
        'name',
        'model',
        'material_description',
      ], fallback: 'Unknown Tray Type'),
    );

    return StockByTrayTypeModel(
      trayTypeId: JsonUtils.intValue(json, const ['tray_type_id', 'id']),
      trayTypeName: trayTypeName,
      total: JsonUtils.intValue(
        json,
        const ['total', 'count', 'qty'],
        fallback: _sumPivotTotals(json),
      ),
    );
  }

  static int _sumPivotTotals(Map<String, dynamic> json) {
    var total = 0;
    for (final entry in json.entries) {
      final key = entry.key;
      if (key == 'tray_type_id' ||
          key == 'id' ||
          key == 'tray_type' ||
          key == 'tray_type_name' ||
          key == 'name') {
        continue;
      }

      final value = entry.value;
      if (value is int) {
        total += value;
      } else if (value is num) {
        total += value.toInt();
      } else if (value is String) {
        total += int.tryParse(value.trim()) ?? 0;
      }
    }
    return total;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tray_type_id': trayTypeId,
      'tray_type_name': trayTypeName,
      'total': total,
    };
  }
}
