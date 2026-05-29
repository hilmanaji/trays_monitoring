import '../../core/utils/json_utils.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nik,
    required super.name,
    required super.email,
    required super.role,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final parsedRoles = JsonUtils.stringList(json['roles']);
    final fallbackRole = JsonUtils.stringValue(
      json,
      const ['role'],
      fallback: 'operator',
    );
    final roles = parsedRoles.isNotEmpty ? parsedRoles : <String>[fallbackRole];

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
      role: roles.first,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nik': nik,
      'name': name,
      'email': email,
      'role': role,
      'roles': roles,
    };
  }
}
