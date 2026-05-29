import '../../core/utils/json_utils.dart';
import '../../domain/entities/pending_movement.dart';

class PendingMovementModel extends PendingMovement {
  const PendingMovementModel({
    required super.localId,
    required super.fromLocationId,
    required super.toLocationId,
    required super.rfids,
    required super.createdAt,
  });

  factory PendingMovementModel.fromEntity(PendingMovement movement) {
    return PendingMovementModel(
      localId: movement.localId,
      fromLocationId: movement.fromLocationId,
      toLocationId: movement.toLocationId,
      rfids: movement.rfids,
      createdAt: movement.createdAt,
    );
  }

  factory PendingMovementModel.fromJson(Map<String, dynamic> json) {
    return PendingMovementModel(
      localId: JsonUtils.stringValue(json, const ['local_id'], fallback: ''),
      fromLocationId: JsonUtils.intValue(json, const ['from_location_id']),
      toLocationId: JsonUtils.intValue(json, const ['to_location_id']),
      rfids: JsonUtils.stringList(json['rfids']),
      createdAt:
          JsonUtils.dateTimeValue(json, const ['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'local_id': localId,
      'from_location_id': fromLocationId,
      'to_location_id': toLocationId,
      'rfids': rfids,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
