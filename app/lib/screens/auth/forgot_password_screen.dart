import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth_repository.dart';
import '../../core/theme.dart';
import '../../state/auth_state.dart';
import '../../widgets/kit.dart';
import 'auth_gate.dart';

/// Reset flow. Accounts live on this device, so the reset happens right here.
/// With a real backend, step 1 would send an email link instead.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _verified = false, _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthState>();
    try {
      if (!_verified) {
        final ok = await auth.emailExists(_email.text);
        if (!mounted) return;
        if (!ok) {
          setState(() => _error = 'No account found for this email.');
        } else {
          setState(() => _verified = true);
        }
      } else {
        await auth.resetPassword(email: _email.text, newPassword: _pass.text);
        if (!mounted) return;
        Navigator.of(context).pop();
        showToast(context, 'Password updated. You can sign in now.');
      }
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
      back: true,
      title: _verified ? 'Set a new password' : 'Reset password',
      subtitle: _verified
          ? 'Choose a new password for ${_email.text.trim()}.'
          : 'Enter the email you signed up with.',
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
                enabled: !_verified,
                validator: Validators.email,
                action: TextInputAction.done,
                onSubmitted: (_) => _verified ? null : _submit(),
              ),
              if (_verified) ...[
                const SizedBox(height: 18),
                AppField(
                  label: 'New password',
                  controller: _pass,
                  hint: 'At least 8 characters',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: Validators.password,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 18),
                AppField(
                  label: 'Confirm new password',
                  controller: _confirm,
                  hint: 'Repeat the password',
                  icon: Icons.verified_user_outlined,
                  obscure: true,
                  validator: (v) =>
                      v != _pass.text ? 'Passwords do not match' : null,
                  action: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: _verified ? 'Update password' : 'Continue',
          loading: _loading,
          onTap: _submit,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 19, color: p.faint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Accounts are stored on this device in this version, so the reset happens here. With an online account system this step would email you a link.',
                  style: inter(12.5, color: p.dim, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
