import '../../core/utils/json_utils.dart';
import '../../domain/entities/tray_movement.dart';

class TrayMovementModel extends TrayMovement {
  const TrayMovementModel({
    required super.id,
    required super.movementNumber,
    required super.fromLocationName,
    required super.toLocationName,
    required super.rfids,
    required super.totalRfid,
    super.createdAt,
  });

  factory TrayMovementModel.fromJson(Map<String, dynamic> json) {
    final fromLocation = JsonUtils.asMap(json['from_location']);
    final toLocation = JsonUtils.asMap(json['to_location']);

    final rfids = JsonUtils.stringList(json['rfids']);

    return TrayMovementModel(
      id: JsonUtils.intValue(json, const ['id']),
      movementNumber: JsonUtils.stringValue(json, const [
        'movement_number',
        'number',
        'reference_no',
      ], fallback: 'MV-${JsonUtils.intValue(json, const ['id'])}'),
      fromLocationName: JsonUtils.stringValue(
        fromLocation,
        const ['name'],
        fallback: JsonUtils.stringValue(json, const [
          'from_location_name',
        ], fallback: '-'),
      ),
      toLocationName: JsonUtils.stringValue(
        toLocation,
        const ['name'],
        fallback: JsonUtils.stringValue(json, const [
          'to_location_name',
        ], fallback: '-'),
      ),
      rfids: rfids,
      totalRfid: JsonUtils.intValue(json, const [
        'total_rfid',
        'rfids_count',
      ], fallback: rfids.length),
      createdAt: JsonUtils.dateTimeValue(json, const ['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'movement_number': movementNumber,
      'from_location_name': fromLocationName,
      'to_location_name': toLocationName,
      'rfids': rfids,
      'total_rfid': totalRfid,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
