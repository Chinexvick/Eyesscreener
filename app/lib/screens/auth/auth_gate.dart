import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../state/auth_state.dart';
import '../../widgets/kit.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Switches between sign in and create account.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _signup = !context.read<AuthState>().hasAccounts;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (c, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(
            begin: Offset(_signup ? 0.06 : -0.06, 0),
            end: Offset.zero,
          ).animate(a),
          child: c,
        ),
      ),
      child: _signup
          ? SignupScreen(
              key: const ValueKey('signup'),
              onSwitch: () => setState(() => _signup = false),
            )
          : LoginScreen(
              key: const ValueKey('login'),
              onSwitch: () => setState(() => _signup = true),
            ),
    );
  }
}

/// Shared layout for the account screens.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.back = false,
  });

  final String title, subtitle;
  final List<Widget> children;
  final bool back;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: EyesBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (back) ...[
                        IconBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Logo(size: 38),
                      const SizedBox(width: 10),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: const Wordmark(size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Reveal(child: Text(title, style: display(32, spacing: -0.9))),
                  const SizedBox(height: 10),
                  Reveal(
                    delay: 60,
                    child: Text(
                      subtitle,
                      style: inter(15.5, color: p.dim, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Brand.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Brand.red.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 20, color: Brand.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: inter(13.5, w: 500, color: context.pal.text, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: p.line, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('or', style: inter(13, color: p.faint)),
          ),
          Expanded(child: Divider(color: p.line, height: 1)),
        ],
      ),
    );
  }
}
