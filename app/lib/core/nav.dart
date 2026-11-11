import 'package:flutter/material.dart';

/// Push a page with a soft fade + rise.
Future<T?> openPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, a, _, child) {
        final curved = CurvedAnimation(
          parent: a,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
