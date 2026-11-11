import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Animated splash that continues from the native splash (same background and logo).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.ready, required this.onDone});

  final bool ready;
  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  bool _minTime = false;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      _minTime = true;
      _maybeFinish();
    });
  }

  @override
  void didUpdateWidget(SplashScreen old) {
    super.didUpdateWidget(old);
    _maybeFinish();
  }

  void _maybeFinish() {
    if (_fired || !_minTime || !widget.ready || !mounted) return;
    _fired = true;
    // Never call back into the parent while it is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF070D09);
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Soft glows
          Positioned(
            top: -120,
            right: -100,
            child: _glow(360, Brand.green.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _glow(420, Brand.yellow.withValues(alpha: 0.10)),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_in, _loop]),
              builder: (context, _) {
                final t = Curves.easeOutBack.transform(
                  Interval(0, 0.55, curve: Curves.easeOut).transform(_in.value),
                );
                final text = Curves.easeOutCubic.transform(
                  const Interval(0.45, 0.85).transform(_in.value),
                );
                final bar = Curves.easeInOut.transform(
                  const Interval(0.3, 1.0).transform(_in.value),
                );
                final pulse = math.sin(_loop.value * math.pi * 2) * 0.5 + 0.5;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < 3; i++) _ring(i, _loop.value),
                          Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.6 + 0.4 * t,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Brand.yellow.withValues(
                                        alpha: 0.25 + pulse * 0.2,
                                      ),
                                      blurRadius: 50 + pulse * 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/img/logo.png',
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: text,
                      child: Transform.translate(
                        offset: Offset(0, (1 - text) * 14),
                        child: Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'EYES',
                                    style: display(34, color: Brand.green),
                                  ),
                                  TextSpan(
                                    text: '-SCREENER',
                                    style: display(34, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'SEE EVERYTHING. INVEST WISELY.',
                              style: inter(
                                11.5,
                                w: 700,
                                color: const Color(0xFFA6B3AA),
                                spacing: 3.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Opacity(
                      opacity: text,
                      child: Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: bar,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: Brand.yellowGradient,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(int i, double v) {
    final p = (v + i / 3) % 1.0;
    return Opacity(
      opacity: (1 - p) * 0.35,
      child: Container(
        width: 128 + p * 100,
        height: 128 + p * 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Brand.yellow, width: 1.4),
        ),
      ),
    );
  }

  Widget _glow(double size, Color c) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)]),
    ),
  );
}
