import '../../core/utils/json_utils.dart';
import '../../domain/entities/tray.dart';

class TrayModel extends Tray {
  const TrayModel({
    required super.id,
    required super.epc,
    required super.trayTypeName,
    required super.currentLocationName,
    required super.status,
    super.createdAt,
  });

  factory TrayModel.fromJson(Map<String, dynamic> json) {
    final trayType = JsonUtils.asMap(json['tray_type']);
    final currentLocation = JsonUtils.asMap(json['current_location']);
    final location = JsonUtils.asMap(json['location']);

    return TrayModel(
      id: JsonUtils.intValue(json, const ['id']),
      epc: JsonUtils.stringValue(json, const [
        'epc',
        'rfid_epc',
      ], fallback: '-'),
      trayTypeName: JsonUtils.stringValue(
        trayType,
        const ['name', 'tray_type_name', 'model', 'material_description'],
        fallback: JsonUtils.stringValue(json, const [
          'tray_type_name',
          'tray_type_model',
          'tray_type_description',
        ], fallback: 'Unknown Tray Type'),
      ),
      currentLocationName: JsonUtils.stringValue(
        currentLocation,
        const ['name'],
        fallback: JsonUtils.stringValue(
          location,
          const ['name'],
          fallback: JsonUtils.stringValue(json, const [
            'current_location_name',
            'location_name',
          ], fallback: 'Unknown Location'),
        ),
      ),
      status: JsonUtils.stringValue(json, const ['status'], fallback: 'ACTIVE'),
      createdAt: JsonUtils.dateTimeValue(json, const ['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'epc': epc,
      'tray_type_name': trayTypeName,
      'current_location_name': currentLocationName,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
