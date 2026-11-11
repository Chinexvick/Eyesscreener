import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth_repository.dart';
import '../../core/theme.dart';
import '../../state/auth_state.dart';
import '../../widgets/kit.dart';
import 'auth_gate.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.onSwitch});
  final VoidCallback onSwitch;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _emailF = FocusNode(), _passF = FocusNode(), _confirmF = FocusNode();
  bool _terms = false, _loading = false, _termsError = false;
  String? _error;
  int _strength = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _pass, _confirm]) {
      c.dispose();
    }
    for (final f in [_emailF, _passF, _confirmF]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok = _form.currentState!.validate();
    setState(() => _termsError = !_terms);
    if (!ok || !_terms) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().signUp(
        name: _name.text,
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
      title: 'Create your account',
      subtitle:
          'Save your watchlist and alerts, and unlock the full AI toolkit.',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              if (_error != null) ErrorBanner(_error!),
              AppField(
                label: 'Full name',
                controller: _name,
                hint: 'Alex Morgan',
                icon: Icons.person_outline_rounded,
                keyboard: TextInputType.name,
                action: TextInputAction.next,
                autofill: const [AutofillHints.name],
                validator: Validators.name,
                onSubmitted: (_) => _emailF.requestFocus(),
              ),
              const SizedBox(height: 18),
              AppField(
                label: 'Email',
                controller: _email,
                focusNode: _emailF,
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress,
                action: TextInputAction.next,
                autofill: const [AutofillHints.email],
                validator: Validators.email,
                onSubmitted: (_) => _passF.requestFocus(),
              ),
              const SizedBox(height: 18),
              AppField(
                label: 'Password',
                controller: _pass,
                focusNode: _passF,
                hint: 'At least 8 characters',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                action: TextInputAction.next,
                autofill: const [AutofillHints.newPassword],
                validator: Validators.password,
                onChanged: (v) =>
                    setState(() => _strength = Validators.strength(v)),
                onSubmitted: (_) => _confirmF.requestFocus(),
              ),
              const SizedBox(height: 12),
              _StrengthMeter(_strength),
              const SizedBox(height: 18),
              AppField(
                label: 'Confirm password',
                controller: _confirm,
                focusNode: _confirmF,
                hint: 'Repeat your password',
                icon: Icons.verified_user_outlined,
                obscure: true,
                action: TextInputAction.done,
                validator: (v) =>
                    v != _pass.text ? 'Passwords do not match' : null,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Tap(
          onTap: () => setState(() {
            _terms = !_terms;
            _termsError = false;
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  gradient: _terms ? Brand.yellowGradient : null,
                  color: _terms ? null : p.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _termsError
                        ? Brand.red
                        : (_terms ? Colors.transparent : p.line),
                    width: 1.4,
                  ),
                ),
                child: _terms
                    ? const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: Brand.ink,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: inter(13.5, color: p.dim, height: 1.45),
                      ),
                      TextSpan(
                        text: 'Terms of Use',
                        style: inter(13.5, w: 650, color: p.text),
                      ),
                      TextSpan(
                        text:
                            ' and understand that nothing in this app is financial advice.',
                        style: inter(13.5, color: p.dim, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 36),
            child: Text(
              'Please accept to continue',
              style: inter(12.5, w: 500, color: Brand.red),
            ),
          ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Create account',
          loading: _loading,
          onTap: _submit,
        ),
        const SizedBox(height: 18),
        Center(
          child: Tap(
            onTap: widget.onSwitch,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: inter(14.5, color: p.dim),
                    ),
                    TextSpan(
                      text: 'Sign in',
                      style: inter(14.5, w: 700, color: Brand.yellow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Tap(
            onTap: _loading
                ? null
                : () => context.read<AuthState>().continueAsGuest(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Skip for now',
                style: inter(13.5, w: 600, color: p.faint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter(this.level);
  final int level;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final colors = [Brand.red, Brand.amber, Brand.yellow2, Brand.green];
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final c = level == 0 ? p.line : colors[level - 1];
    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 5,
              margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
              decoration: BoxDecoration(
                color: i < level ? c : p.line,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        SizedBox(
          width: 54,
          child: Text(
            labels[level],
            textAlign: TextAlign.right,
            style: inter(12.5, w: 700, color: c),
          ),
        ),
      ],
    );
  }
}
