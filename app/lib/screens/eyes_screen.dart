import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/kit.dart';

class EyesScreen extends StatelessWidget {
  const EyesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget perk(IconData i, String t, String s) => AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Brand.yellow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(i, color: Brand.yellow),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: inter(15, w: 700)),
                const SizedBox(height: 3),
                Text(s, style: inter(13, color: p.dim, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );

    Widget step(String t, String s, int state) {
      final c = state == 2 ? Brand.green : (state == 1 ? Brand.yellow : p.line);
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: state == 0 ? Colors.transparent : c,
                shape: BoxShape.circle,
                border: Border.all(color: c, width: 2.4),
                boxShadow: state == 1
                    ? [
                        BoxShadow(
                          color: Brand.yellow.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: state == 2
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: inter(14.5, w: 700)),
                  const SizedBox(height: 3),
                  Text(s, style: inter(13, color: p.dim, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              const PageTitle(r'$EYES Ecosystem', back: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Brand.yellow.withValues(alpha: 0.14),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
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
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFF07110A),
                              const Color(0xFF07110A).withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'EYES',
                              style: display(44, color: Brand.yellow2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'POWERED BY NATURE',
                              style: inter(
                                11,
                                w: 800,
                                color: const Color(0xFFB9F04A),
                                spacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 190,
                              child: Text(
                                r'The community token behind Eyes Screener. Details are a preview and may change.',
                                style: inter(
                                  13.5,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SectionTitle(
                'Planned perks',
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: perk(
                  Icons.auto_awesome_rounded,
                  'More AI reports',
                  'Holders get more AI Investigator reports and deeper analysis.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: perk(
                  Icons.notifications_active_rounded,
                  'Priority alerts',
                  'Faster signal alerts and more alert slots for the community.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: perk(
                  Icons.how_to_vote_rounded,
                  'Community votes',
                  'Vote on new features and data sources.',
                ),
              ),
              SectionTitle(
                'Roadmap',
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 2),
                  child: Column(
                    children: [
                      step(
                        'Phase 1: Eyes Screener',
                        'Screener, token pages, watchlist and mobile layout.',
                        2,
                      ),
                      step(
                        'Phase 2: Research tools',
                        'AI Investigator, Risk Radar, Signal Alerts and Crypto Academy.',
                        2,
                      ),
                      step(
                        'Phase 3: Live data',
                        'Connect a real-time BNB Chain data provider and on-chain security checks.',
                        1,
                      ),
                      step(
                        'Phase 4: \$EYES utility',
                        'Token-gated perks, community voting and wallet-based portfolios.',
                        0,
                      ),
                    ],
                  ),
                ),
              ),
              SectionTitle(
                'Token details',
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Column(
                    children: [
                      for (final (k, v) in [
                        ('Network', 'BNB Chain'),
                        ('Contract', 'To be announced'),
                        ('Status', 'Preview'),
                        ('Tagline', 'The eye that sees beyond'),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            children: [
                              Text(k, style: inter(13.5, color: p.faint)),
                              const Spacer(),
                              Text(v, style: inter(14, w: 650)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Text(
                  'Always verify the official contract address from our official channels before interacting. Not financial advice.',
                  textAlign: TextAlign.center,
                  style: inter(12, color: p.faint, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
