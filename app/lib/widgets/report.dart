import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/risk_model.dart';
import '../core/theme.dart';
import 'kit.dart';

void copyAddress(BuildContext context, Token t) {
  Clipboard.setData(ClipboardData(text: t.address));
  showToast(
    context,
    'Contract address copied',
    icon: Icons.copy_rounded,
    color: Brand.yellow,
  );
}

/// Score gauge, verdict and written summary.
class SafetyHeader extends StatelessWidget {
  const SafetyHeader({super.key, required this.token, this.showAddress = true});
  final Token token;
  final bool showAddress;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final a = RiskModel.analyse(token);
    final c = flagColor(a.level);
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              ScoreGauge(score: a.score, size: 128, stroke: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        a.verdict,
                        style: inter(12.5, w: 700, color: c),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _line(
                      context,
                      Icons.dangerous_outlined,
                      '${a.bad} critical',
                      a.bad > 0 ? Brand.red : p.faint,
                    ),
                    const SizedBox(height: 6),
                    _line(
                      context,
                      Icons.warning_amber_rounded,
                      '${a.warn} warnings',
                      a.warn > 0 ? Brand.amber : p.faint,
                    ),
                    const SizedBox(height: 6),
                    _line(
                      context,
                      Icons.check_circle_outline_rounded,
                      '${a.flags.length - a.bad - a.warn} passed',
                      Brand.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(a.summary, style: inter(14, color: p.dim, height: 1.55)),
          if (showAddress) ...[
            const SizedBox(height: 14),
            Tap(
              onTap: () => copyAddress(context, token),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: p.card2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 15, color: p.faint),
                    const SizedBox(width: 8),
                    Text(
                      Fmt.shortAddr(token.address),
                      style: inter(12.5, w: 600, color: p.dim),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(BuildContext context, IconData i, String t, Color c) => Row(
    children: [
      Icon(i, size: 18, color: c),
      const SizedBox(width: 8),
      Text(t, style: inter(13.5, w: 600, color: context.pal.text)),
    ],
  );
}

class SecurityChecks extends StatelessWidget {
  const SecurityChecks({super.key, required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    final a = RiskModel.analyse(token);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: Brand.green),
              const SizedBox(width: 10),
              Text(
                'Security checks',
                style: display(17, w: 700, spacing: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < a.flags.length; i++)
            FlagTile(a.flags[i], last: i == a.flags.length - 1),
        ],
      ),
    );
  }
}

class KeyNumbers extends StatelessWidget {
  const KeyNumbers({super.key, required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final a = RiskModel.analyse(token);
    final top = a.top10 <= 30
        ? Brand.green
        : (a.top10 <= 50 ? Brand.amber : Brand.red);
    Widget kv(String l, String v, {Color? c}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: inter(12, color: p.faint)),
          const SizedBox(height: 3),
          Text(v, style: inter(15.5, w: 700, color: c)),
        ],
      ),
    );
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, size: 20, color: Brand.green),
              const SizedBox(width: 10),
              Text('Key numbers', style: display(17, w: 700, spacing: -0.2)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              kv('Price', Fmt.price(token.price)),
              kv(
                '24h change',
                Fmt.pct(token.change),
                c: token.change >= 0 ? Brand.green : Brand.red,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              kv('Liquidity', Fmt.money(token.liq)),
              kv('24h volume', Fmt.money(token.vol)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              kv('Market cap', Fmt.money(token.mcap)),
              kv('Holders', Fmt.int_(a.holders)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              kv(
                'Pair age',
                a.ageDays > 60
                    ? '${(a.ageDays / 30).round()} months'
                    : '${a.ageDays} days',
              ),
              kv('AI signal', '${token.signal}/100'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('Top 10 holders', style: inter(12.5, color: p.faint)),
              const Spacer(),
              Text('${a.top10}%', style: inter(13, w: 700, color: top)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: a.top10 / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 9,
                backgroundColor: p.line,
                valueColor: AlwaysStoppedAnimation(top),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WatchOut extends StatelessWidget {
  const WatchOut({super.key, required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final a = RiskModel.analyse(token);
    final items = a.flags.where((f) => f.status != FlagStatus.good).toList()
      ..sort(
        (x, y) => (x.status == FlagStatus.bad ? 0 : 1).compareTo(
          y.status == FlagStatus.bad ? 0 : 1,
        ),
      );
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 20, color: Brand.green),
              const SizedBox(width: 10),
              Text('What to watch', style: display(17, w: 700, spacing: -0.2)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'Nothing alarming stood out. Keep position sizes sensible and re-check before large trades.',
              style: inter(14, color: p.dim, height: 1.5),
            )
          else
            for (final f in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: flagColor(f.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${f.label}: ',
                              style: inter(14, w: 650),
                            ),
                            TextSpan(
                              text: '${f.detail}.',
                              style: inter(14, color: p.dim),
                            ),
                          ],
                        ),
                        style: const TextStyle(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
