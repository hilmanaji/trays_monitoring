import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../providers/auth_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
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

  /// Host the reader will talk to — the design's "Reader connected" footer.
  String get _apiHost {
    final uri = Uri.tryParse(ApiConstants.serverUrl);
    final host = uri?.host ?? '';
    return host.isEmpty ? ApiConstants.serverUrl : host;
  }

  @override
  Widget build(BuildContext context) {
    final authState = widget.onLogin == null
        ? ref.watch(authControllerProvider)
        : const AuthState(status: AuthStatus.unauthenticated);
    final isLoading = authState.status == AuthStatus.loading;
    final neo = context.neo;
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return Scaffold(
      // No hero gradient and no card: soft UI puts the sign-in straight onto
      // the same ground the rest of the app uses, and lets the brand tile and
      // the field wells carry all the depth.
      backgroundColor: neo.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 22 : 28,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Brand ────────────────────────────────────────────────
                    NeoBox(
                      radius: 24,
                      elevation: 1.1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: const SiixLogo(width: 96, showTagline: false),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Tray Monitoring',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        height: 1.05,
                        color: neo.ink,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'RFID TRAY CONTROL · UROVO DT40',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: neo.inkFaint,
                      ),
                    ),

                    // ── Credentials ──────────────────────────────────────────
                    const SizedBox(height: 30),
                    _NeoTextField(
                      label: 'NIK',
                      controller: _nikController,
                      icon: Icons.badge_rounded,
                      textInputAction: TextInputAction.next,
                      hintText: 'Nomor induk karyawan',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Masukkan NIK'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _NeoTextField(
                      label: 'PASSWORD',
                      controller: _passwordController,
                      icon: Icons.lock_rounded,
                      obscureText: true,
                      hintText: '••••••••',
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan password'
                          : null,
                    ),

                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _LoginError(message: authState.errorMessage!),
                    ],

                    // ── Action ───────────────────────────────────────────────
                    const SizedBox(height: 26),
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
                      SizedBox(
                        width: double.infinity,
                        child: NeoButton(
                          label: 'Masuk / Sign in',
                          icon: Icons.login_rounded,
                          onPressed: _submit,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Reader ready · $_apiHost',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: neo.inkGhost,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text field shaped like the design's credential blocks: a well pressed into
/// the ground, kicker label on top, no visible input border of its own.
class _NeoTextField extends StatelessWidget {
  const _NeoTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hintText,
    this.obscureText = false,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hintText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return NeoBox.inset(
      radius: AppSpacing.radiusNeo,
      padding: const EdgeInsets.fromLTRB(16, 11, 14, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, right: 12),
            child: Icon(icon, size: 18, color: neo.inkFaint),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: neo.inkFaint,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  textInputAction: textInputAction,
                  validator: validator,
                  onFieldSubmitted: onFieldSubmitted,
                  cursorColor: neo.accentEnd,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: neo.ink,
                  ),
                  decoration: InputDecoration(
                    // The well *is* the field; strip Material's own chrome.
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: neo.inkGhost,
                    ),
                    errorStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginError extends StatelessWidget {
  const _LoginError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final neo = context.neo;

    return NeoBox(
      radius: AppSpacing.radiusNeoSm + 3,
      elevation: 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: cs.statusError),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: neo.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
