import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/auth_state.dart';
import '../state/market_state.dart';
import 'auth/auth_gate.dart';
import 'onboarding_screen.dart';
import 'shell.dart';
import 'splash_screen.dart';

/// Decides what to show: splash → onboarding → sign in / create account → app.
class AppFlow extends StatefulWidget {
  const AppFlow({super.key});

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  bool _splashDone = false;
  String? _lastScope;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final market = context.read<MarketState>();

    // Keep saved data in step with the signed-in account.
    if (auth.ready && _lastScope != auth.scope) {
      _lastScope = auth.scope;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => app.loadScope(auth.scope),
      );
    }
    app.live ? market.startLive() : market.stopLive();

    final Widget screen;
    if (!_splashDone || !auth.ready) {
      screen = SplashScreen(
        ready: auth.ready,
        onDone: () => setState(() => _splashDone = true),
      );
    } else if (!app.onboardingDone) {
      screen = const OnboardingScreen(key: ValueKey('onboarding'));
    } else if (!auth.signedIn) {
      screen = const AuthGate(key: ValueKey('auth'));
    } else {
      screen = MainShell(key: ValueKey('shell-${auth.scope}'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.985, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: screen,
    );
  }
}
