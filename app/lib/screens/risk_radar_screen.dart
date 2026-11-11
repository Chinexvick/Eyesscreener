import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/market_data.dart';
import '../core/models.dart';
import '../core/nav.dart';
import '../core/risk_model.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../state/market_state.dart';
import '../widgets/kit.dart';
import 'token_detail_screen.dart';

class RiskRadarScreen extends StatefulWidget {
  const RiskRadarScreen({super.key});

  @override
  State<RiskRadarScreen> createState() => _RiskRadarScreenState();
}

class _RiskRadarScreenState extends State<RiskRadarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
  Risk? _level;
  final _flags = <String>{};
  int _shown = 12;
  String? _hl;

  static const _flagDefs = [
    ('honeypot', 'Honeypot'),
    ('lp', 'Unlocked liquidity'),
    ('tax', 'High tax'),
    ('mint', 'Mintable'),
    ('holders', 'Whale heavy'),
  ];

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketState>();
    final rows = [for (final t in market.tokens) (t, RiskModel.analyse(t))];
    int count(Risk r) => rows.where((e) => e.$1.risk == r).length;

    var list = rows.where((e) {
      if (_level != null && e.$1.risk != _level) return false;
      return _flags.every((f) {
        final fl = e.$2.flags.firstWhere((x) => x.id == f);
        return fl.status != FlagStatus.good;
      });
    }).toList()..sort((a, b) => a.$2.score.compareTo(b.$2.score));
    if (_hl != null) {
      final i = list.indexWhere((e) => e.$1.id == _hl);
      if (i > 0) list.insert(0, list.removeAt(i));
    }
    final shown = list.take(_shown).toList();

    final blips = ([
      ...rows,
    ]..sort((a, b) => b.$1.mcap.compareTo(a.$1.mcap))).take(36).toList();

    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              const PageTitle(
                'Risk Radar',
                subtitle:
                    'Every tracked token, scored for safety. The further out a dot, the riskier.',
                back: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final s = c.maxWidth;
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: _sweep,
                                    builder: (_, _) => CustomPaint(
                                      painter: _RadarPainter(
                                        _sweep.value,
                                        p.line,
                                      ),
                                    ),
                                  ),
                                ),
                                for (final e in blips) _blip(e.$1, e.$2, s),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final (c, l) in [
                            (Brand.green, 'Low'),
                            (Brand.amber, 'Medium'),
                            (Brand.red, 'High'),
                          ]) ...[
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(l, style: inter(12.5, color: p.dim)),
                            const SizedBox(width: 18),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _Count('Low risk', count(Risk.low), Brand.green),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Count('Medium', count(Risk.medium), Brand.amber),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Count('High risk', count(Risk.high), Brand.red),
                    ),
                  ],
                ),
              ),
              SectionTitle(
                'Filters',
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    SelectChip(
                      label: 'All',
                      selected: _level == null,
                      onTap: () => setState(() {
                        _level = null;
                        _shown = 12;
                        _hl = null;
                      }),
                    ),
                    for (final r in Risk.values.reversed) ...[
                      const SizedBox(width: 8),
                      SelectChip(
                        label: r.label,
                        selected: _level == r,
                        onTap: () => setState(() {
                          _level = r;
                          _shown = 12;
                          _hl = null;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                height: 54,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  children: [
                    for (final f in _flagDefs) ...[
                      Tap(
                        onTap: () => setState(() {
                          _flags.contains(f.$1)
                              ? _flags.remove(f.$1)
                              : _flags.add(f.$1);
                          _shown = 12;
                          _hl = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: _flags.contains(f.$1)
                                ? Brand.red.withValues(alpha: 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _flags.contains(f.$1)
                                  ? Brand.red.withValues(alpha: 0.7)
                                  : p.line,
                            ),
                          ),
                          child: Text(
                            f.$2,
                            style: inter(
                              13,
                              w: _flags.contains(f.$1) ? 700 : 500,
                              color: _flags.contains(f.$1) ? Brand.red : p.dim,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'Flagged tokens',
                      style: display(19, w: 700, spacing: -0.2),
                    ),
                    const Spacer(),
                    Text(
                      '${list.length} match${list.length == 1 ? '' : 'es'}',
                      style: inter(13, color: p.faint),
                    ),
                  ],
                ),
              ),
              if (shown.isEmpty)
                const EmptyState(
                  icon: Icons.verified_user_outlined,
                  title: 'No tokens match',
                  text: 'Try removing a filter.',
                ),
              for (final e in shown)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: _RiskRow(
                    token: e.$1,
                    a: e.$2,
                    highlight: _hl == e.$1.id,
                  ),
                ),
              if (list.length > _shown)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: GhostButton(
                    label: 'Show more',
                    height: 50,
                    onTap: () => setState(() => _shown += 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blip(Token t, Analysis a, double size) {
    final r = Seeded('${t.id}:pos');
    final ang = r.next() * math.pi * 2;
    final rad = (0.14 + (100 - a.score) / 100 * 0.78) * 0.5;
    final c = flagColor(a.level);
    const d = 14.0;
    return Positioned(
      left: size * (0.5 + math.cos(ang) * rad) - d / 2,
      top: size * (0.5 + math.sin(ang) * rad) - d / 2,
      child: GestureDetector(
        onTap: () => setState(() {
          _hl = t.id;
          _level = null;
          _flags.clear();
        }),
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: c.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
            border: _hl == t.id
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.t, this.line);
  final double t;
  final Color line;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2 - 1;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Brand.green.withValues(alpha: 0.28);
    for (final f in [1.0, 0.75, 0.5, 0.25]) {
      canvas.drawCircle(c, r * f, ring);
    }
    final cross = Paint()
      ..color = line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), cross);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), cross);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t * math.pi * 2);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Brand.green.withValues(alpha: 0),
            Brand.green.withValues(alpha: 0.38),
          ],
          stops: const [0.72, 1.0],
          transform: const GradientRotation(0),
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RadarPainter o) => o.t != t;
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.n, this.color);
  final String label;
  final int n;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    radius: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: inter(12, color: context.pal.faint)),
        const SizedBox(height: 4),
        Text('$n', style: display(26, color: color)),
      ],
    ),
  );
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({
    required this.token,
    required this.a,
    required this.highlight,
  });
  final Token token;
  final Analysis a;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final app = context.watch<AppState>();
    final tags = a.flags.where((f) => f.status != FlagStatus.good).toList();
    final watched = app.isWatched(token.id);
    return AppCard(
      onTap: () => openPage(context, TokenDetailScreen(token: token)),
      padding: const EdgeInsets.all(14),
      gradient: highlight
          ? LinearGradient(
              colors: [
                Brand.yellow.withValues(alpha: 0.14),
                Brand.yellow.withValues(alpha: 0.04),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TokenAvatar(token, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(15, w: 650),
                    ),
                    Text(
                      '${token.symbol} · ${_money(token.liq)} liquidity',
                      style: inter(12, color: p.faint),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 52,
                height: 52,
                child: ScoreGauge(
                  score: a.score,
                  size: 52,
                  stroke: 6,
                  label: null,
                ),
              ),
              Tap(
                onTap: () => app.toggleWatch(token.id),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    watched ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: watched ? Brand.yellow : p.faint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (tags.isEmpty) _tag('No issues found', Brand.green),
              for (final f in tags) _tag(f.tag, flagColor(f.status)),
            ],
          ),
        ],
      ),
    );
  }

  static String _money(double n) => n >= 1e6
      ? '\$${(n / 1e6).toStringAsFixed(1)}M'
      : '\$${(n / 1e3).toStringAsFixed(0)}K';

  Widget _tag(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(t, style: inter(11.5, w: 700, color: c)),
  );
}
