import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../core/market_data.dart';
import '../core/models.dart';
import '../core/theme.dart';

// ---------------------------------------------------------------------------
// Interaction
// ---------------------------------------------------------------------------

/// Press feedback: gentle scale + optional haptic tick.
class Tap extends StatefulWidget {
  const Tap({
    super.key,
    required this.child,
    this.onTap,
    this.haptic = true,
    this.scale = 0.97,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool haptic;
  final double scale;
  final HitTestBehavior behavior;

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Fade + slide-up entrance.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.delay = 0, this.dy = 18});

  final Widget child;
  final int delay; // ms
  final double dy;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + delay),
      curve: Interval(delay / (520 + delay), 1, curve: Curves.easeOutCubic),
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: c),
      ),
      child: child,
    );
  }
}

void showToast(
  BuildContext context,
  String msg, {
  IconData icon = Icons.check_circle_rounded,
  Color? color,
}) {
  final p = context.pal;
  final m = ScaffoldMessenger.of(context);
  m.clearSnackBars();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 104),
      duration: const Duration(milliseconds: 2400),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: p.isDark ? const Color(0xFF1B2A20) : const Color(0xFF111A14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Brand.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: inter(13.5, w: 500, color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Surfaces
// ---------------------------------------------------------------------------

class EyesBackground extends StatelessWidget {
  const EyesBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: p.bg)),
        Positioned(
          top: -140,
          right: -120,
          child: _Glow(
            size: 380,
            color: Brand.green.withValues(alpha: p.isDark ? 0.16 : 0.10),
          ),
        ),
        Positioned(
          top: 260,
          left: -180,
          child: _Glow(
            size: 360,
            color: Brand.yellow.withValues(alpha: p.isDark ? 0.07 : 0.10),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 22,
    this.gradient,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? p.card : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.line),
        boxShadow: p.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
    return onTap == null ? box : Tap(onTap: onTap, child: box);
  }
}

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 28,
    this.padding,
    this.blur = 24,
  });
  final Widget child;
  final double radius, blur;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: p.isDark
                ? const Color(0xFF111B15).withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: p.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons & inputs
// ---------------------------------------------------------------------------

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.height = 54,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading, expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Tap(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: expand ? 0 : 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: Brand.yellowGradient,
            borderRadius: BorderRadius.circular(height / 2.6),
            boxShadow: [
              BoxShadow(
                color: Brand.yellow.withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Brand.ink,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: Brand.ink),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: inter(15.5, w: 700, color: Brand.ink)),
                  ],
                ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.height = 54,
    this.expand = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  final bool expand, danger;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = danger ? Brand.red : p.text;
    return Tap(
      onTap: onTap,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: expand ? 0 : 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(height / 2.6),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19, color: c),
              const SizedBox(width: 8),
            ],
            Text(label, style: inter(14.5, w: 600, color: c)),
          ],
        ),
      ),
    );
  }
}

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboard,
    this.validator,
    this.onChanged,
    this.action,
    this.onSubmitted,
    this.autofill,
    this.focusNode,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscure, enabled;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextInputAction? action;
  final Iterable<String>? autofill;
  final FocusNode? focusNode;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late bool _hide = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label, style: inter(13, w: 600, color: p.dim)),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _hide,
          keyboardType: widget.keyboard,
          textInputAction: widget.action,
          autofillHints: widget.autofill,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: inter(15.5, w: 500, color: p.text),
          cursorColor: Brand.yellow,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: inter(15, color: p.faint),
            filled: true,
            fillColor: p.card,
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 21, color: p.faint),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _hide = !_hide),
                    icon: Icon(
                      _hide
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 21,
                      color: p.faint,
                    ),
                  )
                : null,
            errorStyle: inter(12.5, w: 500, color: Brand.red),
            enabledBorder: border(p.line),
            disabledBorder: border(p.line),
            focusedBorder: border(Brand.yellow, 1.6),
            errorBorder: border(Brand.red.withValues(alpha: 0.7)),
            focusedErrorBorder: border(Brand.red, 1.6),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Token bits
// ---------------------------------------------------------------------------

class TokenAvatar extends StatelessWidget {
  const TokenAvatar(this.token, {super.key, this.size = 42});
  final Token token;
  final double size;

  @override
  Widget build(BuildContext context) {
    final a = token.asset;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: token.color,
        border: Border.all(color: context.pal.line),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: a != null
          ? Image.asset(
              a,
              width: size,
              height: size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            )
          : Text(
              token.symbol.substring(0, math.min(2, token.symbol.length)),
              style: inter(size * 0.34, w: 700, color: Colors.white),
            ),
    );
  }
}

class AssetCircle extends StatelessWidget {
  const AssetCircle(this.file, {super.key, this.size = 36});
  final String file;
  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/img/tokens/$file.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    ),
  );
}

class RiskPill extends StatelessWidget {
  const RiskPill(this.risk, {super.key, this.small = false});
  final Risk risk;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (risk) {
      Risk.low => (Brand.green.withValues(alpha: 0.16), Brand.green),
      Risk.medium => (Brand.yellow.withValues(alpha: 0.16), Brand.yellow),
      Risk.high => (Brand.red.withValues(alpha: 0.16), Brand.red),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(risk.label, style: inter(small ? 11 : 12, w: 700, color: fg)),
    );
  }
}

class Change extends StatelessWidget {
  const Change(this.value, {super.key, this.size = 13.5, this.bold = true});
  final double value, size;
  final bool bold;

  @override
  Widget build(BuildContext context) => Text(
    Fmt.pct(value),
    style: inter(
      size,
      w: bold ? 700 : 600,
      color: value >= 0 ? Brand.green : Brand.red,
    ),
  );
}

Color flagColor(FlagStatus s) => switch (s) {
  FlagStatus.good => Brand.green,
  FlagStatus.warn => Brand.amber,
  FlagStatus.bad => Brand.red,
};

class SignalRing extends StatelessWidget {
  const SignalRing(this.value, {super.key, this.size = 36});
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = ((value - 45) / 40).clamp(0.0, 1.0);
    final c = HSLColor.fromAHSL(1, 45 + t * 97, 0.78, 0.5).toColor();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value / 100, c, context.pal.line),
        child: Center(child: Text('$value', style: inter(size * 0.34, w: 800))),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.p, this.color, this.track);
  final double p;
  final Color color, track;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width * 0.11;
    final r = Rect.fromLTWH(w / 2, w / 2, s.width - w, s.height - w);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = track;
    canvas.drawArc(r, 0, math.pi * 2, false, base);
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * p,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.p != p || o.color != color || o.track != track;
}

/// 270° gauge used for safety scores.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.score,
    this.size = 150,
    this.label = 'Safety score',
    this.stroke = 13,
  });
  final int score;
  final double size, stroke;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = flagColor(
      score >= 75
          ? FlagStatus.good
          : (score >= 50 ? FlagStatus.warn : FlagStatus.bad),
    );
    final p = context.pal;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => CustomPaint(
          painter: _GaugePainter(v, c, p.line, stroke),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(v * 100).round()}', style: display(size * 0.26)),
                if (label != null)
                  Text(
                    label!,
                    style: inter(size * 0.085, w: 500, color: p.dim),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.p, this.color, this.track, this.stroke);
  final double p, stroke;
  final Color color, track;

  @override
  void paint(Canvas canvas, Size s) {
    final r = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      s.width - stroke,
      s.height - stroke,
    );
    const start = math.pi * 0.75, sweep = math.pi * 1.5;
    canvas.drawArc(
      r,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = track,
    );
    final shader = SweepGradient(
      startAngle: start,
      endAngle: start + sweep,
      colors: [color.withValues(alpha: 0.55), color],
      transform: const GradientRotation(0),
    ).createShader(r);
    canvas.drawArc(
      r,
      start,
      sweep * p,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter o) =>
      o.p != p || o.color != color || o.track != track;
}

// ---------------------------------------------------------------------------
// Charts
// ---------------------------------------------------------------------------

List<double> chartSeries(
  String key, {
  int n = 72,
  double vol = 1,
  bool up = true,
}) {
  final r = Seeded(key);
  var v = 50.0;
  final out = <double>[];
  for (var i = 0; i < n; i++) {
    v += (r.next() - (up ? 0.43 : 0.57)) * 6 * vol + math.sin(i / 3) * 1.5;
    out.add(v);
  }
  return out;
}

class Sparkline extends StatelessWidget {
  const Sparkline(
    this.data, {
    super.key,
    this.color = Brand.green,
    this.fill = true,
    this.stroke = 2,
    this.dot = true,
    this.grid = false,
  });
  final List<double> data;
  final Color color;
  final bool fill, dot, grid;
  final double stroke;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SparkPainter(
      data,
      color,
      fill,
      stroke,
      dot,
      grid,
      context.pal.line,
    ),
    size: Size.infinite,
  );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(
    this.d,
    this.color,
    this.fill,
    this.stroke,
    this.dot,
    this.grid,
    this.gridColor,
  );
  final List<double> d;
  final Color color, gridColor;
  final bool fill, dot, grid;
  final double stroke;

  @override
  void paint(Canvas canvas, Size s) {
    if (d.length < 2) return;
    final mn = d.reduce(math.min), mx = d.reduce(math.max);
    const padT = 8.0, padB = 6.0;
    Offset pt(int i) => Offset(
      i / (d.length - 1) * (s.width - 8) + 2,
      s.height -
          padB -
          (d[i] - mn) /
              ((mx - mn) == 0 ? 1 : (mx - mn)) *
              (s.height - padT - padB),
    );
    if (grid) {
      for (final g in [0.25, 0.5, 0.75]) {
        canvas.drawLine(
          Offset(0, s.height * g),
          Offset(s.width, s.height * g),
          Paint()
            ..color = gridColor
            ..strokeWidth = 1,
        );
      }
    }
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < d.length; i++) {
      final a = pt(i - 1), b = pt(i);
      final mid = (a.dx + b.dx) / 2;
      path.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }
    if (fill) {
      final area = Path.from(path)
        ..lineTo(pt(d.length - 1).dx, s.height)
        ..lineTo(pt(0).dx, s.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & s),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    if (dot) {
      final l = pt(d.length - 1);
      canvas.drawCircle(l, 7, Paint()..color = color.withValues(alpha: 0.22));
      canvas.drawCircle(l, 3.6, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter o) => o.d != d || o.color != color;
}

// ---------------------------------------------------------------------------
// Misc layout bits
// ---------------------------------------------------------------------------

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 26, 20, 12),
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: display(19, w: 700, spacing: -0.2)),
          ),
          if (action != null)
            Tap(
              onTap: onAction,
              child: Row(
                children: [
                  Text(action!, style: inter(13, w: 600, color: Brand.green)),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: Brand.green,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(
    this.title, {
    super.key,
    this.subtitle,
    this.trailing,
    this.back = false,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool back;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: EdgeInsets.fromLTRB(back ? 12 : 20, 12, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (back)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: back ? 6 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: display(28)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: inter(14, color: p.dim, height: 1.45),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.badge = false,
    this.size = 44,
    this.filled = true,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge, filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tap(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? p.card : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? Border.all(color: p.line) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21, color: p.text),
            if (badge)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Brand.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.card, width: 1.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? Brand.yellowGradient : null,
          color: selected ? null : p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Colors.transparent : p.line),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Brand.yellow.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Brand.ink : p.dim),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: inter(
                13.5,
                w: selected ? 700 : 600,
                color: selected ? Brand.ink : p.dim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.subColor,
    this.icon,
  });
  final String label, value;
  final String? sub;
  final Color? subColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Brand.yellow.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: Brand.yellow),
            ),
          Text(label, style: inter(12.5, color: p.dim)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: display(22, spacing: -0.5)),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub!, style: inter(12.5, w: 600, color: subColor ?? p.faint)),
          ],
        ],
      ),
    );
  }
}

class FlagTile extends StatelessWidget {
  const FlagTile(this.flag, {super.key, this.last = false});
  final RiskFlag flag;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = flagColor(flag.status);
    final icon = switch (flag.status) {
      FlagStatus.good => Icons.check_rounded,
      FlagStatus.warn => Icons.priority_high_rounded,
      FlagStatus.bad => Icons.close_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: c),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flag.label, style: inter(14.5, w: 650)),
                const SizedBox(height: 2),
                Text(flag.detail, style: inter(13, color: p.dim, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title, text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Brand.yellow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, size: 32, color: Brand.yellow),
          ),
          const SizedBox(height: 18),
          Text(title, style: display(19, w: 700), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            text,
            style: inter(14, color: p.dim, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 22),
            PrimaryButton(label: action!, onTap: onAction, expand: false),
          ],
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 44, this.glow = false});
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: Brand.yellow.withValues(alpha: 0.35),
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      child: Image.asset(
        'assets/img/logo.png',
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'EYES',
            style: display(size, color: Brand.green),
          ),
          TextSpan(
            text: '-SCREENER',
            style: display(size, color: p.text),
          ),
        ],
      ),
    );
  }
}
