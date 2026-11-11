import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../state/market_state.dart';
import '../../widgets/kit.dart';
import '../../widgets/token_picker.dart';
import '../../widgets/token_row.dart';
import '../shell.dart';

class WatchlistTab extends StatelessWidget {
  const WatchlistTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final app = context.watch<AppState>();
    final market = context.watch<MarketState>();
    final tokens = [
      for (final id in app.watchlist)
        if (market.byId(id) != null) market.byId(id)!,
    ];
    final avg = tokens.isEmpty
        ? 0.0
        : tokens.fold<double>(0, (s, t) => s + t.change) / tokens.length;
    final best = tokens.isEmpty
        ? null
        : (([...tokens]..sort((a, b) => b.change.compareTo(a.change))).first);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          PageTitle(
            'Watchlist',
            subtitle: tokens.isEmpty
                ? 'Tokens you star show up here.'
                : '${tokens.length} token${tokens.length == 1 ? '' : 's'} tracked · swipe a card to remove',
            trailing: IconBtn(
              icon: Icons.add_rounded,
              onTap: () async {
                final t = await pickToken(context, title: 'Add to watchlist');
                if (t == null || !context.mounted) return;
                if (app.isWatched(t.id)) {
                  showToast(
                    context,
                    '${t.symbol} is already in your watchlist',
                    icon: Icons.info_outline_rounded,
                    color: Brand.yellow,
                  );
                } else {
                  app.toggleWatch(t.id);
                  showToast(
                    context,
                    '${t.name} added to Watchlist',
                    icon: Icons.star_rounded,
                    color: Brand.yellow,
                  );
                }
              },
            ),
          ),
          if (tokens.isEmpty)
            EmptyState(
              icon: Icons.star_outline_rounded,
              title: 'Your watchlist is empty',
              text:
                  'Star tokens in the screener, or add one here, to track them with live prices.',
              action: 'Browse the screener',
              onAction: () => context.read<NavState>().go(1),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _Mini(label: 'Tracked', value: '${tokens.length}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Mini(
                      label: 'Avg 24h',
                      value: Fmt.pct(avg),
                      color: avg >= 0 ? Brand.green : Brand.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Mini(
                      label: 'Best',
                      value: best!.symbol,
                      sub: Fmt.pct(best.change),
                      color: Brand.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            for (final t in tokens)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                child: Dismissible(
                  key: ValueKey('w-${t.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Brand.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  onDismissed: (_) {
                    app.toggleWatch(t.id);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    showToast(
                      context,
                      '${t.name} removed',
                      icon: Icons.delete_outline_rounded,
                      color: Brand.red,
                    );
                  },
                  child: TokenCard(token: t),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.line),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Brand.yellow,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: open a token and tap “Create alert” to get notified of price moves and risk changes.',
                        style: inter(13, color: p.dim, height: 1.45),
                      ),
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
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value, this.sub, this.color});
  final String label, value;
  final String? sub;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: inter(12, color: p.faint)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: inter(17, w: 800, color: color)),
          ),
          if (sub != null) Text(sub!, style: inter(12, w: 700, color: color)),
        ],
      ),
    );
  }
}
