import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/neo_theme.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/siix_logo.dart';

typedef LoginCallback =
    Future<void> Function({required String nik, required String password});

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onLogin});

  final LoginCallback? onLogin;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.onLogin != null) {
      await widget.onLogin!(
        nik: _nikController.text.trim(),
        password: _passwordController.text,
      );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          nik: _nikController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = widget.onLogin == null
        ? ref.watch(authControllerProvider)
        : const AuthState(status: AuthStatus.unauthenticated);
    final isLoading = authState.status == AuthStatus.loading;
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    final neo = context.neo;

    return Scaffold(
      // Soft UI has no hero gradient: the sign-in card is simply the first
      // extruded object on the same ground the rest of the app uses.
      backgroundColor: neo.ground,
      body: Container(
        color: neo.ground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: NeoBox(
                  radius: AppSpacing.radiusNeoLg,
                  elevation: 1.3,
                  padding: EdgeInsets.all(isCompact ? 20 : 28),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(child: SiixLogo(width: 132)),
                          const SizedBox(height: 20),
                          Text(
                            'Tray Monitoring',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'RFID TRAY CONTROL · UROVO DT40',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: neo.inkFaint,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nikController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'NIK',
                              prefixIcon: Icon(Icons.badge_rounded),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter NIK'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_rounded),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                ? 'Enter password'
                                : null,
                          ),
                          if (authState.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                authState.errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (isLoading)
                            const SizedBox(
                              height: AppSpacing.touchMin,
                              child: Center(
                                child: SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              ),
                            )
                          else
                            NeoButton(
                              label: 'Masuk / Sign in',
                              icon: Icons.login_rounded,
                              onPressed: _submit,
                            ),
                        ],
                      ),
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
