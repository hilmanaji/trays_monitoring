import '../../core/utils/json_utils.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nik,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: JsonUtils.intValue(json, const ['id']),
      nik: JsonUtils.stringValue(json, const [
        'nik',
        'employee_id',
      ], fallback: '-'),
      name: JsonUtils.stringValue(json, const [
        'name',
      ], fallback: 'Warehouse User'),
      email: JsonUtils.stringValue(json, const ['email'], fallback: '-'),
      role: JsonUtils.stringValue(json, const ['role'], fallback: 'operator'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nik': nik,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
