import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../state/market_state.dart';
import '../widgets/kit.dart';
import '../widgets/token_picker.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.prefillSymbol});
  final String? prefillSymbol;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.prefillSymbol != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final t = context.read<MarketState>().find(widget.prefillSymbol!);
        if (t != null) _openForm(t);
      });
    }
  }

  Future<void> _openForm([Token? initial]) async {
    final app = context.read<AppState>();
    final rule = await showModalBottomSheet<AlertRule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertForm(initial: initial),
    );
    if (rule != null && mounted) {
      app.addAlert(rule);
      showToast(
        context,
        'Alert added for ${rule.symbol}',
        icon: Icons.notifications_active_rounded,
        color: Brand.yellow,
      );
    }
  }

  String _describe(AlertRule r) => switch (r.cond) {
    AlertCond.priceAbove => 'price goes above ${Fmt.price(r.value)}',
    AlertCond.priceBelow => 'price falls below ${Fmt.price(r.value)}',
    AlertCond.changeAbove =>
      '24h change is above ${r.value.toStringAsFixed(r.value == r.value.roundToDouble() ? 0 : 2)}%',
    AlertCond.signalAbove => 'AI signal is above ${r.value.round()}',
    AlertCond.liqBelow => 'liquidity falls below ${Fmt.money(r.value)}',
    AlertCond.riskHigh => 'risk becomes High',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final app = context.watch<AppState>();
    final market = context.watch<MarketState>();
    final up = ([...market.tokens]
      ..sort((a, b) => b.change.compareTo(a.change)));
    final bySig = ([...market.tokens]
      ..sort((a, b) => b.signal.compareTo(a.signal)));
    final high = market.tokens.where((t) => t.risk == Risk.high).toList();
    final feed = <(IconData, Color, String, String, int)>[
      (
        Icons.trending_up_rounded,
        Brand.green,
        '${up.first.symbol} is up ${up.first.change.toStringAsFixed(2)}% in 24h',
        'Strongest mover on ${Fmt.money(up.first.vol)} of volume.',
        3,
      ),
      (
        Icons.auto_awesome_rounded,
        Brand.green,
        'AI signal ${bySig.first.signal} on ${bySig.first.symbol}',
        'Highest AI score across tracked BNB Chain pairs.',
        9,
      ),
      if (high.isNotEmpty)
        (
          Icons.warning_amber_rounded,
          Brand.red,
          'Risk warning: ${high.first.symbol}',
          'Liquidity is mostly unlocked and taxes are high. Be careful.',
          14,
        ),
      (
        Icons.fiber_new_rounded,
        Brand.amber,
        'DOGEAI/WBNB new pair',
        'Listed 12 minutes ago. Early liquidity is thin.',
        18,
      ),
      (
        Icons.water_drop_rounded,
        Brand.green,
        'Liquidity added to ${up[2].symbol}',
        'Pool depth is now ${Fmt.money(up[2].liq)}.',
        31,
      ),
      if (high.length > 1)
        (
          Icons.lock_open_rounded,
          Brand.red,
          '${high[1].symbol} liquidity unlocked',
          'Deployer can withdraw liquidity at any time.',
          52,
        ),
    ];

    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              PageTitle(
                'Signal Alerts',
                subtitle:
                    'Tell Eyes what to watch for. Alerts are checked against live data.',
                back: true,
                trailing: IconBtn(icon: Icons.add_rounded, onTap: _openForm),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: PrimaryButton(
                  label: 'New alert',
                  icon: Icons.add_alert_rounded,
                  onTap: _openForm,
                ),
              ),
              SectionTitle(
                'Your alerts',
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
              ),
              if (app.alerts.isEmpty)
                const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No alerts yet',
                  text:
                      'Create your first alert and we will flag it when the condition is met.',
                )
              else
                for (final r in app.alerts)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Builder(
                      builder: (context) {
                        final t = market.byId(r.symbol);
                        final hit = t != null && r.on && r.triggeredBy(t);
                        return Dismissible(
                          key: ValueKey('a-${r.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: Brand.red,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            app.removeAlert(r.id);
                            showToast(
                              context,
                              'Alert deleted',
                              icon: Icons.delete_outline_rounded,
                              color: Brand.red,
                            );
                          },
                          child: AppCard(
                            padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                            child: Row(
                              children: [
                                if (t != null)
                                  TokenAvatar(t, size: 40)
                                else
                                  const SizedBox(width: 40),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: r.symbol,
                                              style: inter(14.5, w: 700),
                                            ),
                                            TextSpan(
                                              text: '  ${_describe(r)}',
                                              style: inter(14, color: p.dim),
                                            ),
                                          ],
                                        ),
                                        style: const TextStyle(height: 1.35),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (hit) ...[
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: Brand.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Triggered now · ',
                                              style: inter(
                                                12,
                                                w: 700,
                                                color: Brand.green,
                                              ),
                                            ),
                                          ],
                                          Text(
                                            t == null
                                                ? 'Token not found'
                                                : 'Now ${Fmt.price(t.price)} · ${Fmt.pct(t.change)}',
                                            style: inter(12, color: p.faint),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: r.on,
                                  onChanged: (_) => app.toggleAlert(r.id),
                                  activeThumbColor: Brand.ink,
                                  activeTrackColor: Brand.yellow,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              SectionTitle(
                'Signal feed',
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < feed.length; i++)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: i == feed.length - 1
                                ? null
                                : Border(bottom: BorderSide(color: p.line)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: feed[i].$2.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  feed[i].$1,
                                  size: 20,
                                  color: feed[i].$2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(feed[i].$3, style: inter(14, w: 650)),
                                    const SizedBox(height: 3),
                                    Text(
                                      feed[i].$4,
                                      style: inter(
                                        13,
                                        color: p.dim,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Fmt.ago(feed[i].$5),
                                style: inter(12, color: p.faint),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertForm extends StatefulWidget {
  const _AlertForm({this.initial});
  final Token? initial;

  @override
  State<_AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends State<_AlertForm> {
  Token? _token;
  AlertCond _cond = AlertCond.priceAbove;
  final _value = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _token = widget.initial;
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _save() {
    if (_token == null) return setState(() => _error = 'Choose a token');
    double v = 0;
    if (_cond.needsValue) {
      final parsed = double.tryParse(_value.text.trim().replaceAll(',', ''));
      if (parsed == null) return setState(() => _error = 'Enter a number');
      v = parsed;
    }
    Navigator.pop(
      context,
      AlertRule(
        id: DateTime.now().millisecondsSinceEpoch,
        symbol: _token!.symbol,
        cond: _cond,
        value: v,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          22,
          14,
          22,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: p.line),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('New alert', style: display(22)),
              const SizedBox(height: 18),
              Text('Token', style: inter(13, w: 600, color: p.dim)),
              const SizedBox(height: 8),
              Tap(
                onTap: () async {
                  final t = await pickToken(context);
                  if (t != null) {
                    setState(() {
                      _token = t;
                      _error = null;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.line),
                  ),
                  child: Row(
                    children: [
                      if (_token != null) ...[
                        TokenAvatar(_token!, size: 32),
                        const SizedBox(width: 12),
                        Text(_token!.name, style: inter(15, w: 650)),
                        const SizedBox(width: 8),
                        Text(_token!.symbol, style: inter(13, color: p.faint)),
                      ] else ...[
                        Icon(Icons.search_rounded, color: p.faint),
                        const SizedBox(width: 12),
                        Text(
                          'Choose a token',
                          style: inter(15, color: p.faint),
                        ),
                      ],
                      const Spacer(),
                      Icon(Icons.keyboard_arrow_down_rounded, color: p.faint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('When', style: inter(13, w: 600, color: p.dim)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in AlertCond.values)
                    SelectChip(
                      label: c.title,
                      selected: _cond == c,
                      onTap: () => setState(() => _cond = c),
                    ),
                ],
              ),
              if (_cond.needsValue) ...[
                const SizedBox(height: 18),
                AppField(
                  label: 'Value',
                  controller: _value,
                  hint: '0',
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  icon: Icons.tag_rounded,
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: inter(13, w: 600, color: Brand.red),
                  ),
                ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Add alert',
                icon: Icons.notifications_active_rounded,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
