import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Brand colours that never change between themes.
class Brand {
  static const yellow = Color(0xFFF6C01B);
  static const yellow2 = Color(0xFFFFD84A);
  static const gold = Color(0xFFB98300);
  static const green = Color(0xFF22C55E);
  static const greenDeep = Color(0xFF16A34A);
  static const forest = Color(0xFF0B2A14);
  static const red = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);
  static const ink = Color(0xFF2A1F00);

  static const yellowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [yellow2, yellow],
  );
}

/// Theme-dependent surface colours.
class Pal extends ThemeExtension<Pal> {
  const Pal({
    required this.bg,
    required this.card,
    required this.card2,
    required this.line,
    required this.text,
    required this.dim,
    required this.faint,
    required this.isDark,
  });

  final Color bg, card, card2, line, text, dim, faint;
  final bool isDark;

  static const dark = Pal(
    bg: Color(0xFF070D09),
    card: Color(0xFF101813),
    card2: Color(0xFF16211A),
    line: Color(0xFF1F2D24),
    text: Color(0xFFF1F6F2),
    dim: Color(0xFFA6B3AA),
    faint: Color(0xFF6C7B71),
    isDark: true,
  );

  static const light = Pal(
    bg: Color(0xFFF4F6F5),
    card: Color(0xFFFFFFFF),
    card2: Color(0xFFF1F4F2),
    line: Color(0xFFE6EAE8),
    text: Color(0xFF111A14),
    dim: Color(0xFF4B5850),
    faint: Color(0xFF8A968E),
    isDark: false,
  );

  @override
  Pal copyWith() => this;

  @override
  Pal lerp(ThemeExtension<Pal>? other, double t) {
    if (other is! Pal) return this;
    return t < 0.5 ? this : other;
  }
}

extension PalX on BuildContext {
  Pal get pal => Theme.of(this).extension<Pal>()!;
}

/// Inter is a variable font, so weights are set through the `wght` axis.
TextStyle inter(
  double size, {
  double w = 400,
  Color? color,
  double? height,
  double? spacing,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: FontWeight.values[((w / 100).round().clamp(1, 9)) - 1],
    fontVariations: [FontVariation('wght', w)],
    color: color,
    height: height,
    letterSpacing: spacing,
  );
}

TextStyle display(
  double size, {
  Color? color,
  double w = 800,
  double? spacing,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: size,
    fontWeight: w >= 800
        ? FontWeight.w800
        : (w >= 700 ? FontWeight.w700 : FontWeight.w600),
    color: color,
    height: 1.1,
    letterSpacing: spacing ?? -0.4,
  );
}

ThemeData buildTheme(Pal p) {
  final base = p.isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: Brand.yellow,
      onPrimary: Brand.ink,
      secondary: Brand.green,
      surface: p.card,
      onSurface: p.text,
      error: Brand.red,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: p.text,
      displayColor: p.text,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: p.line,
    extensions: [p],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
