import 'package:flutter_test/flutter_test.dart';
import 'package:trays_monitoring/core/utils/json_utils.dart';
import 'package:trays_monitoring/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('unwraps wrapped backend data payload before parsing user fields', () {
      final payload = {
        'success': true,
        'message': 'Success',
        'data': {
          'id': 803,
          'nik': '25096205',
          'name': 'Hilmanudin Aji',
          'email': 'hilmanudin.aji@siix-global.com',
          'roles': ['SUPERADMIN'],
        },
      };

      final user = UserModel.fromJson(JsonUtils.unwrapMap(payload));

      expect(user.id, 803);
      expect(user.nik, '25096205');
      expect(user.name, 'Hilmanudin Aji');
      expect(user.email, 'hilmanudin.aji@siix-global.com');
      expect(user.roles, ['SUPERADMIN']);
    });

    test('reads roles from backend roles array', () {
      final user = UserModel.fromJson(const {
        'id': 803,
        'nik': '25096205',
        'name': 'Hilmanudin Aji',
        'email': 'hilmanudin.aji@siix-global.com',
        'roles': ['SUPERADMIN', 'WAREHOUSE'],
      });

      expect(user.role, 'SUPERADMIN');
      expect(user.roles, ['SUPERADMIN', 'WAREHOUSE']);
      expect(user.rolesLabel, 'SUPERADMIN, WAREHOUSE');
    });

    test('falls back to single role field when roles array is absent', () {
      final user = UserModel.fromJson(const {
        'id': 1,
        'nik': '1001',
        'name': 'Operator',
        'email': 'operator@example.com',
        'role': 'operator',
      });

      expect(user.role, 'operator');
      expect(user.roles, ['operator']);
      expect(user.primaryRole, 'operator');
    });
  });
}