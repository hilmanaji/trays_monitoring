import '../../core/utils/json_utils.dart';
import '../../domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required super.id,
    required super.code,
    required super.name,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: JsonUtils.intValue(json, const ['id']),
      code: JsonUtils.stringValue(json, const [
        'code',
        'location_code',
      ], fallback: '-'),
      name: JsonUtils.stringValue(json, const [
        'name',
        'location_name',
      ], fallback: 'Unknown Location'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'code': code, 'name': name};
  }
}
