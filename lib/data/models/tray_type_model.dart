import '../../core/utils/json_utils.dart';
import '../../domain/entities/tray_type.dart';

class TrayTypeModel extends TrayType {
  const TrayTypeModel({
    required super.id,
    required super.code,
    required super.name,
    required super.description,
    required super.project,
  });

  factory TrayTypeModel.fromJson(Map<String, dynamic> json) {
    return TrayTypeModel(
      id: JsonUtils.intValue(json, const ['id']),
      code: JsonUtils.stringValue(json, const [
        'code',
        'tray_code',
        'tray_type_code',
        'oracle_code',
        'sap_code',
      ], fallback: '-'),
      name: JsonUtils.stringValue(json, const [
        'name',
        'tray_type_name',
        'model',
        'material_description',
      ], fallback: 'Unknown Tray Type'),
      description: JsonUtils.stringValue(json, const [
        'description',
        'material_description',
        'project',
        'category',
      ], fallback: 'Tray type configuration'),
      project: JsonUtils.stringValue(json, const [
        'project',
        'category',
      ], fallback: 'Unassigned'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'project': project,
    };
  }
}
