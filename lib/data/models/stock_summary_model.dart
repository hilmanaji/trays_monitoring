import '../../core/utils/json_utils.dart';
import '../../domain/entities/stock_summary.dart';

class StockSummaryModel extends StockSummary {
  const StockSummaryModel({
    required super.locationId,
    required super.locationName,
    required super.total,
  });

  factory StockSummaryModel.fromJson(Map<String, dynamic> json) {
    final location = JsonUtils.asMap(json['location']);
    return StockSummaryModel(
      locationId: JsonUtils.intValue(json, const ['location_id', 'id']),
      locationName: JsonUtils.stringValue(
        location,
        const ['name'],
        fallback: JsonUtils.stringValue(json, const [
          'location_name',
          'name',
        ], fallback: 'Unknown Location'),
      ),
      total: JsonUtils.intValue(json, const ['total', 'count', 'qty']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'location_id': locationId,
      'location_name': locationName,
      'total': total,
    };
  }
}
