import '../entities/user.dart';

abstract class AuthRepository {
  Future<String> login({required String nik, required String password});
  Future<User> getCurrentUser();
  Future<void> logout();
  Future<void> clearSession();
}
