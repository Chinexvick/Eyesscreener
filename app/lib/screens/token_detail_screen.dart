import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/kit.dart';
import '../widgets/report.dart';
import 'alerts_screen.dart';
import 'shell.dart';

class TokenDetailScreen extends StatefulWidget {
  const TokenDetailScreen({super.key, required this.token});
  final Token token;

  @override
  State<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends State<TokenDetailScreen> {
  String _tf = '24H';
  static const _tfs = {
    '1H': (60, 0.4),
    '24H': (72, 1.0),
    '7D': (84, 1.8),
    '30D': (90, 2.6),
  };

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final t = widget.token;
    final app = context.watch<AppState>();
    final watched = app.isWatched(t.id);
    final cfg = _tfs[_tf]!;
    final data = chartSeries(
      '${t.id}$_tf',
      n: cfg.$1,
      vol: cfg.$2,
      up: t.change >= 0,
    );
    final up = data.last >= data.first;
    final c = up ? Brand.green : Brand.red;

    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    IconBtn(
                      icon: Icons.copy_rounded,
                      onTap: () => copyAddress(context, t),
                    ),
                    const SizedBox(width: 10),
                    IconBtn(
                      icon: watched
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      onTap: () {
                        final on = app.toggleWatch(t.id);
                        showToast(
                          context,
                          on
                              ? '${t.name} added to Watchlist'
                              : '${t.name} removed from Watchlist',
                          icon: Icons.star_rounded,
                          color: Brand.yellow,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Reveal(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    children: [
                      TokenAvatar(t, size: 58),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: display(22, spacing: -0.4),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${t.symbol} / WBNB',
                                  style: inter(13, w: 500, color: p.faint),
                                ),
                                const SizedBox(width: 8),
                                RiskPill(t.risk, small: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Fmt.price(t.price), style: display(34, spacing: -1)),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Change(t.change, size: 15),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, left: 6),
                      child: Text('24h', style: inter(12.5, color: p.faint)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                  child: Sparkline(data, color: c, grid: true, stroke: 2.4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line),
                  ),
                  child: Row(
                    children: [
                      for (final k in _tfs.keys)
                        Expanded(
                          child: Tap(
                            onTap: () => setState(() => _tf = k),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: _tf == k
                                    ? Brand.yellowGradient
                                    : null,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                k,
                                style: inter(
                                  13,
                                  w: 700,
                                  color: _tf == k ? Brand.ink : p.dim,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.75,
                  children: [
                    StatTile(label: 'Liquidity', value: Fmt.money(t.liq)),
                    StatTile(label: '24h volume', value: Fmt.money(t.vol)),
                    StatTile(label: 'Market cap', value: Fmt.money(t.mcap)),
                    StatTile(
                      label: 'Transactions (24h)',
                      value: Fmt.count(t.txns),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: SafetyHeader(token: t),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: AppCard(
                  child: Row(
                    children: [
                      SignalRing(t.signal, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI signal', style: inter(15, w: 700)),
                            const SizedBox(height: 3),
                            Text(
                              'Momentum, liquidity and holder behaviour combine to ${t.signal}/100.',
                              style: inter(13, color: p.dim, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: SecurityChecks(token: t),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: WatchOut(token: t),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Full AI report',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                        context.read<NavState>().go(2, ai: t.symbol);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GhostButton(
                            label: 'Create alert',
                            icon: Icons.notifications_active_outlined,
                            height: 52,
                            onTap: () => openPage(
                              context,
                              AlertsScreen(prefillSymbol: t.symbol),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GhostButton(
                            label: 'BscScan',
                            icon: Icons.open_in_new_rounded,
                            height: 52,
                            onTap: () => launchUrl(
                              Uri.parse(
                                'https://bscscan.com/token/${t.address}',
                              ),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Demo data. Not financial advice.',
                  textAlign: TextAlign.center,
                  style: inter(12, color: p.faint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
