import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/market_data.dart';
import '../../core/models.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../state/auth_state.dart';
import '../../state/market_state.dart';
import '../../widgets/kit.dart';
import '../../widgets/token_row.dart';
import '../alerts_screen.dart';
import '../academy_screen.dart';
import '../eyes_screen.dart';
import '../risk_radar_screen.dart';
import '../shell.dart';
import '../token_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _tf = '24H';

  static String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final auth = context.watch<AuthState>();
    final market = context.watch<MarketState>();
    final app = context.watch<AppState>();
    final nav = context.read<NavState>();
    final first = auth.isGuest || auth.user == null
        ? null
        : auth.user!.name.split(' ').first;

    final gainers = [...market.tokens]
      ..sort((a, b) => b.change.compareTo(a.change));
    final trending = [...market.tokens]
      ..sort((a, b) => b.trend.compareTo(a.trend));
    final fired = app.alerts.where((a) {
      final t = market.byId(a.symbol);
      return a.on && t != null && a.triggeredBy(t);
    }).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 130),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                Tap(
                  onTap: () => nav.go(4),
                  child: _Avatar(auth: auth),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(), style: inter(13, color: p.dim)),
                      const SizedBox(height: 1),
                      Text(
                        first ?? 'Eyes Screener',
                        style: display(21, spacing: -0.3),
                      ),
                    ],
                  ),
                ),
                IconBtn(
                  icon: Icons.notifications_none_rounded,
                  badge: fired > 0,
                  onTap: () => openPage(context, const AlertsScreen()),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: AppCard(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              onTap: () => nav.go(1, focusSearch: true),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 22, color: p.faint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search token, symbol or contract',
                      style: inter(14.5, color: p.faint),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Brand.yellow.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 17,
                      color: Brand.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Market card
          Reveal(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _MarketCard(tf: _tf, onTf: (v) => setState(() => _tf = v)),
            ),
          ),
          // Quick actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                _Quick(
                  icon: Icons.radar_rounded,
                  label: 'Risk\nRadar',
                  onTap: () => openPage(context, const RiskRadarScreen()),
                ),
                _Quick(
                  icon: Icons.notifications_active_rounded,
                  label: 'Signal\nAlerts',
                  onTap: () => openPage(context, const AlertsScreen()),
                  badge: app.alerts.where((a) => a.on).length,
                ),
                _Quick(
                  icon: Icons.school_rounded,
                  label: 'Crypto\nAcademy',
                  onTap: () => openPage(context, const AcademyScreen()),
                ),
                _Quick(
                  icon: Icons.rocket_launch_rounded,
                  label:
                      r'$EYES'
                      '\nEcosystem',
                  onTap: () => openPage(context, const EyesScreen()),
                ),
              ],
            ),
          ),
          SectionTitle(
            'Top gainers',
            action: 'See all',
            onAction: () => nav.go(1, tab: 'gainers'),
          ),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _GainerCard(token: gainers[i]),
            ),
          ),
          SectionTitle(
            'Trending now',
            action: 'See all',
            onAction: () => nav.go(1, tab: 'trending'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    MiniTokenRow(token: trending[i], rank: i + 1),
                    if (i < 4) Divider(height: 1, color: p.line),
                  ],
                ],
              ),
            ),
          ),
          SectionTitle(
            'Recent new pairs',
            action: 'See all',
            onAction: () => nav.go(1, tab: 'new'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < MarketData.pairs.length; i++) ...[
                    _PairRow(pair: MarketData.pairs[i]),
                    if (i < MarketData.pairs.length - 1)
                      Divider(height: 1, color: p.line),
                  ],
                ],
              ),
            ),
          ),
          // Promo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Tap(
              onTap: () => openPage(context, const EyesScreen()),
              child: const _PromoBanner(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Text(
              'Data shown is demo data and not financial advice. Always do your own research.',
              textAlign: TextAlign.center,
              style: inter(12, color: p.faint, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.auth});
  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final u = auth.user;
    final guest = u == null || u.isGuest;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: guest ? null : Brand.yellowGradient,
        color: guest ? context.pal.card : null,
        border: Border.all(
          color: guest ? context.pal.line : Colors.transparent,
        ),
      ),
      alignment: Alignment.center,
      child: guest
          ? const Logo(size: 34)
          : Text(u.initials, style: display(16, color: Brand.ink)),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.tf, required this.onTf});
  final String tf;
  final ValueChanged<String> onTf;

  static const _cfg = {
    '1H': (60, 0.6, 11),
    '24H': (72, 1.0, 7),
    '7D': (84, 1.4, 3),
    '30D': (90, 2.0, 5),
  };

  @override
  Widget build(BuildContext context) {
    final c = _cfg[tf]!;
    final data = chartSeries('home-$tf-${c.$3}', n: c.$1, vol: c.$2);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14391C), Color(0xFF0B1F10)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Brand.green.withValues(alpha: 0.16),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3BA2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hexagon_rounded,
                  size: 18,
                  color: Color(0xFF1D1D1D),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'BNB Chain market',
                style: inter(14, w: 650, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Brand.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Live', style: inter(12, w: 700, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Total market cap', style: inter(12.5, color: Colors.white70)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r'$72.4B',
                style: display(34, color: Colors.white, spacing: -1),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '+6.3%',
                  style: inter(14.5, w: 700, color: Brand.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 104,
            child: Sparkline(data, color: const Color(0xFF7CE08E)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final t in ['1H', '24H', '7D', '30D'])
                Expanded(
                  child: Tap(
                    onTap: () => onTf(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: t == tf ? Brand.yellowGradient : null,
                        color: t == tf
                            ? null
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t,
                        style: inter(
                          12.5,
                          w: 700,
                          color: t == tf ? Brand.ink : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _mini('24h volume', r'$6.8B', '+18.7%'),
              const SizedBox(width: 12),
              _mini('Active pairs', '12,482', '+11.2%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String l, String v, String d) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: inter(11.5, color: Colors.white60)),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(v, style: inter(16, w: 700, color: Colors.white)),
              const SizedBox(width: 6),
              Text(d, style: inter(12, w: 700, color: Brand.green)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Quick extends StatelessWidget {
  const _Quick({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Expanded(
      child: Tap(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: p.line),
                  ),
                  child: Icon(icon, size: 28, color: Brand.yellow),
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Brand.green,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: p.bg, width: 2),
                      ),
                      child: Text(
                        '$badge',
                        style: inter(10.5, w: 800, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: inter(12, w: 600, color: p.dim, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _GainerCard extends StatelessWidget {
  const _GainerCard({required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tap(
      onTap: () => openPage(context, TokenDetailScreen(token: token)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TokenAvatar(token, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    token.symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: inter(13.5, w: 700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Sparkline(
                chartSeries(
                  'g-${token.id}',
                  n: 40,
                  vol: 1.2,
                  up: token.change >= 0,
                ),
                dot: false,
                stroke: 1.8,
                color: token.change >= 0 ? Brand.green : Brand.red,
              ),
            ),
            const SizedBox(height: 6),
            Text(Fmt.price(token.price), style: inter(13, w: 650)),
            Change(token.change, size: 13),
          ],
        ),
      ),
    );
  }
}

class _PairRow extends StatelessWidget {
  const _PairRow({required this.pair});
  final (String, String, String, int) pair;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          AssetCircle(pair.$3, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: pair.$1, style: inter(14.5, w: 700)),
                  TextSpan(
                    text: '  / ${pair.$2}',
                    style: inter(13, color: p.faint),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Brand.green.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text('NEW', style: inter(10.5, w: 800, color: Brand.green)),
          ),
          const SizedBox(width: 12),
          Text(Fmt.ago(pair.$4), style: inter(12.5, color: p.dim)),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Brand.yellow.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/img/promo-owl.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF07110A),
                  const Color(0xFF07110A).withValues(alpha: 0.88),
                  Colors.transparent,
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(r'$EYES', style: display(30, color: Brand.yellow2)),
                const SizedBox(height: 4),
                Text(
                  'POWERED BY NATURE',
                  style: inter(
                    10.5,
                    w: 800,
                    color: const Color(0xFFB9F04A),
                    spacing: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Smarter research.\nBetter decisions.',
                  style: inter(14.5, w: 650, color: Colors.white, height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore the ecosystem',
                      style: inter(13, w: 700, color: Brand.yellow),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Brand.yellow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
