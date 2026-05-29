import '../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDatasource, this._tokenStorage);

  final AuthRemoteDatasource _remoteDatasource;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<void> clearSession() {
    return _tokenStorage.clearToken();
  }

  @override
  Future<User> getCurrentUser() {
    return _remoteDatasource.currentUser();
  }

  @override
  Future<String> login({required String nik, required String password}) async {
    final token = await _remoteDatasource.login(nik: nik, password: password);
    await _tokenStorage.saveToken(token);
    return token;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDatasource.logout();
    } finally {
      await _tokenStorage.clearToken();
    }
  }
}
