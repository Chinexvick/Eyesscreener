import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/kit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _page = PageController();
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();
  int _i = 0;

  static const _copy = [
    (
      'Spot opportunities\non BNB Chain',
      'Scan every pair in real time. Sort by gainers, new listings, liquidity and trending, with live prices.',
    ),
    (
      'AI explains the\nrisk for you',
      'Paste any token and get a plain-English safety report: honeypots, locked liquidity, taxes and whale wallets.',
    ),
    (
      'Get alerted and\nlearn as you go',
      'Set price, momentum and risk alerts, build a watchlist and level up with short crypto lessons.',
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    _float.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_i < 2) {
      _page.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.read<AppState>().finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final last = _i == 2;
    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                child: Row(
                  children: [
                    const Logo(size: 34),
                    const SizedBox(width: 10),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: const Wordmark(size: 17),
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: last ? 0 : 1,
                      child: Tap(
                        onTap: last
                            ? null
                            : () => context.read<AppState>().finishOnboarding(),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Skip',
                            style: inter(14.5, w: 600, color: p.dim),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _page,
                  onPageChanged: (v) => setState(() => _i = v),
                  children: [
                    _Visual(controller: _float, builder: _visualOne),
                    _Visual(controller: _float, builder: _visualTwo),
                    _Visual(controller: _float, builder: _visualThree),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 4, 26, 0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.12),
                        end: Offset.zero,
                      ).animate(a),
                      child: c,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(_i),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_copy[_i].$1, style: display(31, spacing: -0.8)),
                      const SizedBox(height: 12),
                      Text(
                        _copy[_i].$2,
                        style: inter(15.5, color: p.dim, height: 1.55),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
                child: Row(
                  children: [
                    Row(
                      children: [
                        for (var d = 0; d < 3; d++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 7),
                            width: d == _i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: d == _i ? Brand.yellowGradient : null,
                              color: d == _i ? null : p.line,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: last
                          ? (MediaQuery.of(context).size.width < 350
                                ? 'Start'
                                : 'Get started')
                          : 'Next',
                      icon: last
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      expand: false,
                      height: 56,
                      onTap: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- visuals -------------------------------------------------------------

  static Widget _visualOne(BuildContext context, double t) {
    final p = context.pal;
    Widget pill(String l, String v) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l, style: inter(11.5, color: p.faint)),
            const SizedBox(height: 3),
            Text(v, style: inter(15.5, w: 800)),
          ],
        ),
      ),
    );
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 390,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 330,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(color: p.line),
                        boxShadow: [
                          BoxShadow(
                            color: Brand.green.withValues(alpha: 0.22),
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/img/hero-owl.jpg',
                            fit: BoxFit.cover,
                            alignment: const Alignment(0.55, -0.35),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _floatCard(
                      t,
                      0,
                      left: 6,
                      top: 34,
                      child: _miniToken(
                        context,
                        'babydoge',
                        'BabyDoge',
                        '+72.36%',
                        Brand.green,
                      ),
                    ),
                    _floatCard(
                      t,
                      0.5,
                      right: 4,
                      bottom: 36,
                      child: _miniToken(
                        context,
                        'tst',
                        'TST',
                        '+56.72%',
                        Brand.green,
                      ),
                    ),
                    _floatCard(
                      t,
                      0.25,
                      left: 34,
                      bottom: 6,
                      child: _miniChip(
                        context,
                        Icons.bolt_rounded,
                        'Live data',
                        Brand.yellow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Row(
                  children: [
                    pill('Market cap', r'$72.4B'),
                    const SizedBox(width: 10),
                    pill('24h volume', r'$6.8B'),
                    const SizedBox(width: 10),
                    pill('Active pairs', '12,482'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _visualTwo(BuildContext context, double t) {
    final p = context.pal;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const RadialGradient(
              radius: 0.62,
              colors: [Colors.black, Colors.transparent],
              stops: [0.55, 1.0],
            ).createShader(r),
            child: Image.asset(
              'assets/img/promo-owl.jpg',
              width: 340,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.75],
                colors: [
                  p.bg.withValues(alpha: 0),
                  p.bg.withValues(alpha: 0.35),
                  p.bg,
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.55),
          child: Container(
            width: 300,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: p.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: p.isDark ? 0.5 : 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Row(
              children: [
                const ScoreGauge(
                  score: 82,
                  size: 112,
                  stroke: 11,
                  label: 'Safety',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _check(context, 'Honeypot check'),
                      _check(context, 'Liquidity locked'),
                      _check(context, 'Sell tax 2%'),
                      _check(context, 'Verified source'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _floatCard(
          t,
          0,
          right: 12,
          top: 30,
          child: _miniChip(
            context,
            Icons.shield_rounded,
            'Low risk',
            Brand.green,
          ),
        ),
        if (MediaQuery.of(context).size.height > 700)
          _floatCard(
            t,
            0.4,
            left: 16,
            top: 150,
            child: _miniChip(
              context,
              Icons.auto_awesome_rounded,
              'AI report',
              Brand.yellow,
            ),
          ),
      ],
    );
  }

  static Widget _visualThree(BuildContext context, double t) {
    final p = context.pal;
    Widget notif(IconData i, Color c, String title, String sub) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(i, size: 21, color: c),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: inter(14, w: 650)),
                const SizedBox(height: 2),
                Text(sub, style: inter(12.5, color: p.dim)),
              ],
            ),
          ),
        ],
      ),
    );
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 310,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(0, math.sin(t * math.pi * 2) * 4),
                    child: notif(
                      Icons.trending_up_rounded,
                      Brand.green,
                      'TST is up 56.7% in 24h',
                      'Signal alert · just now',
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, math.sin(t * math.pi * 2 + 1) * 4),
                    child: notif(
                      Icons.warning_amber_rounded,
                      Brand.red,
                      'Risk warning: SAFI',
                      'Liquidity is unlocked · 14m ago',
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, math.sin(t * math.pi * 2 + 2) * 4),
                    child: notif(
                      Icons.school_rounded,
                      Brand.yellow,
                      'Lesson: spotting rug pulls',
                      'Crypto Academy · 5 min',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: p.line),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Your progress', style: inter(13.5, w: 650)),
                            const Spacer(),
                            Text(
                              '7 of 12',
                              style: inter(13, w: 700, color: Brand.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 7 / 12,
                            minHeight: 9,
                            backgroundColor: p.line,
                            valueColor: const AlwaysStoppedAnimation(
                              Brand.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -16,
                right: -6,
                child: Transform.translate(
                  offset: Offset(0, math.sin(t * math.pi * 2) * 5),
                  child: const Logo(size: 54, glow: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _check(BuildContext context, String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.5),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 18, color: Brand.green),
        const SizedBox(width: 8),
        Flexible(
          child: Text(t, style: inter(13.5, w: 600, color: context.pal.text)),
        ),
      ],
    ),
  );

  static Widget _miniToken(
    BuildContext context,
    String icon,
    String name,
    String chg,
    Color c,
  ) {
    final p = context.pal;
    return Glass(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetCircle(icon, size: 32),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: inter(13, w: 700, color: p.text)),
              Text(chg, style: inter(12.5, w: 700, color: c)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _miniChip(BuildContext context, IconData i, String t, Color c) {
    return Glass(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 17, color: c),
          const SizedBox(width: 7),
          Text(t, style: inter(13, w: 700, color: context.pal.text)),
        ],
      ),
    );
  }

  static Widget _floatCard(
    double t,
    double phase, {
    double? left,
    double? right,
    double? top,
    double? bottom,
    required Widget child,
  }) {
    final dy = math.sin((t + phase) * math.pi * 2) * 7;
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.translate(offset: Offset(0, dy), child: child),
    );
  }
}

class _Visual extends StatelessWidget {
  const _Visual({required this.controller, required this.builder});
  final AnimationController controller;
  final Widget Function(BuildContext, double) builder;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (c, _) => Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: builder(c, controller.value),
    ),
  );
}
