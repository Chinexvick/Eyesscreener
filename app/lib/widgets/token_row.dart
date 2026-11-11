import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../screens/token_detail_screen.dart';
import '../state/app_state.dart';
import 'kit.dart';

/// Full screener card: identity, price, stats, risk, signal and watch toggle.
class TokenCard extends StatelessWidget {
  const TokenCard({
    super.key,
    required this.token,
    this.rank,
    this.showStats = true,
  });

  final Token token;
  final int? rank;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final app = context.watch<AppState>();
    final watched = app.isWatched(token.id);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
      radius: 22,
      onTap: () => openPage(context, TokenDetailScreen(token: token)),
      child: Column(
        children: [
          Row(
            children: [
              if (rank != null)
                SizedBox(
                  width: 24,
                  child: Text(
                    '$rank',
                    style: inter(12.5, w: 700, color: p.faint),
                  ),
                ),
              TokenAvatar(token, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(15.5, w: 650),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      token.symbol,
                      style: inter(12.5, w: 500, color: p.faint),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Fmt.price(token.price), style: inter(15, w: 700)),
                  const SizedBox(height: 2),
                  Change(token.change, size: 13),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          if (showStats) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 11),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.line)),
              ),
              child: Row(
                children: [
                  _stat(context, 'Liquidity', Fmt.money(token.liq)),
                  _stat(context, '24h Vol', Fmt.money(token.vol)),
                  _stat(context, 'MCap', Fmt.money(token.mcap)),
                  const SizedBox(width: 6),
                  RiskPill(token.risk, small: true),
                  const SizedBox(width: 10),
                  SignalRing(token.signal, size: 32),
                  Tap(
                    onTap: () {
                      final on = app.toggleWatch(token.id);
                      showToast(
                        context,
                        on
                            ? '${token.name} added to Watchlist'
                            : '${token.name} removed from Watchlist',
                        icon: on
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Brand.yellow,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        watched
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 23,
                        color: watched ? Brand.yellow : p.faint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String l, String v) {
    final p = context.pal;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: inter(11, color: p.faint)),
          const SizedBox(height: 2),
          Text(v, style: inter(12.5, w: 650)),
        ],
      ),
    );
  }
}

/// Slim list row used on Home.
class MiniTokenRow extends StatelessWidget {
  const MiniTokenRow({
    super.key,
    required this.token,
    this.rank,
    this.trailing,
  });
  final Token token;
  final int? rank;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tap(
      onTap: () => openPage(context, TokenDetailScreen(token: token)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (rank != null)
              SizedBox(
                width: 22,
                child: Text(
                  '$rank',
                  style: inter(12.5, w: 700, color: p.faint),
                ),
              ),
            TokenAvatar(token, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    token.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: inter(14.5, w: 650),
                  ),
                  Text(token.symbol, style: inter(12, color: p.faint)),
                ],
              ),
            ),
            trailing ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Fmt.price(token.price), style: inter(14, w: 650)),
                    Change(token.change, size: 12.5),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
