import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth_repository.dart';
import '../../core/theme.dart';
import '../../state/auth_state.dart';
import '../../widgets/kit.dart';
import 'auth_gate.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSwitch});
  final VoidCallback onSwitch;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passFocus = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().signIn(
        email: _email.text,
        password: _pass.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AuthShell(
      title: 'Welcome back',
      subtitle: 'Sign in to pick up your watchlist, alerts and lessons.',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              if (_error != null) ErrorBanner(_error!),
              AppField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress,
                action: TextInputAction.next,
                autofill: const [AutofillHints.email],
                validator: Validators.email,
                onSubmitted: (_) => _passFocus.requestFocus(),
              ),
              const SizedBox(height: 18),
              AppField(
                label: 'Password',
                controller: _pass,
                focusNode: _passFocus,
                hint: 'Your password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                action: TextInputAction.done,
                autofill: const [AutofillHints.password],
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Enter your password' : null,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Tap(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ForgotPasswordScreen(initialEmail: _email.text),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Forgot password?',
                style: inter(13.5, w: 600, color: Brand.yellow),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        PrimaryButton(label: 'Sign in', loading: _loading, onTap: _submit),
        const OrDivider(),
        GhostButton(
          label: 'Continue as guest',
          icon: Icons.explore_outlined,
          onTap: _loading
              ? null
              : () => context.read<AuthState>().continueAsGuest(),
        ),
        const SizedBox(height: 26),
        Center(
          child: Tap(
            onTap: widget.onSwitch,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'New to Eyes Screener?  ',
                      style: inter(14.5, color: p.dim),
                    ),
                    TextSpan(
                      text: 'Create account',
                      style: inter(14.5, w: 700, color: Brand.yellow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
