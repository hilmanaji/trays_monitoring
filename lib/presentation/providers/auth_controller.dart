import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../core/utils/session_coordinator.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'app_providers.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      loginUseCase: ref.watch(loginUseCaseProvider),
      logoutUseCase: ref.watch(logoutUseCaseProvider),
      authRepository: ref.watch(authRepositoryProvider),
      tokenStorage: ref.watch(secureTokenStorageProvider),
      sessionCoordinator: ref.watch(sessionCoordinatorProvider),
    );
  },
);

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isRefreshingUser = false,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isRefreshingUser;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
    bool? isRefreshingUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefreshingUser: isRefreshingUser ?? this.isRefreshingUser,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.authRepository,
    required this.tokenStorage,
    required this.sessionCoordinator,
  }) : super(const AuthState(status: AuthStatus.unknown)) {
    _sessionListener = () => unawaited(_handleUnauthorized());
    sessionCoordinator.addListener(_sessionListener);
    unawaited(bootstrap());
  }

  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  final SecureTokenStorage tokenStorage;
  final SessionCoordinator sessionCoordinator;
  late final void Function() _sessionListener;

  Future<void> bootstrap() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final token = await tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await authRepository.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await authRepository.clearSession();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String nik, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await loginUseCase.call(nik: nik, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on AppException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error.displayMessage,
      );
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    await logoutUseCase.call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshCurrentUser() async {
    if (!state.isAuthenticated || state.isRefreshingUser) {
      return;
    }

    state = state.copyWith(isRefreshingUser: true, clearError: true);
    try {
      final user = await authRepository.getCurrentUser();
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isRefreshingUser: false,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isRefreshingUser: false,
        errorMessage: error.displayMessage,
      );
    } catch (error) {
      state = state.copyWith(
        isRefreshingUser: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _handleUnauthorized() async {
    await authRepository.clearSession();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Your session expired. Please sign in again.',
    );
  }

  @override
  void dispose() {
    sessionCoordinator.removeListener(_sessionListener);
    super.dispose();
  }
}
