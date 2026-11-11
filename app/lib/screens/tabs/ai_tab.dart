import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/market_data.dart';
import '../../core/models.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../state/market_state.dart';
import '../../widgets/kit.dart';
import '../../widgets/report.dart';
import '../alerts_screen.dart';
import '../shell.dart';
import '../token_detail_screen.dart';

class AiTab extends StatefulWidget {
  const AiTab({super.key});

  @override
  State<AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<AiTab> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  Token? _token;
  String? _notFound;
  int _step = -1; // -1 idle, 0..n running
  Timer? _timer;
  int _seenNonce = 0;

  static const _steps = [
    'Reading contract and ownership',
    'Simulating buys and sells',
    'Checking liquidity lock',
    'Analysing holder distribution',
    'Writing report',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Token? _resolve(MarketState m, String q) {
    final s = q.trim();
    if (s.isEmpty) return null;
    final t = m.search(s);
    if (t != null) return t;
    if (RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(s)) {
      return MarketData.synthetic(s);
    }
    return null;
  }

  void _run(String q) {
    FocusScope.of(context).unfocus();
    final m = context.read<MarketState>();
    if (q.trim().isEmpty) {
      showToast(
        context,
        'Enter a token name, symbol or contract address',
        icon: Icons.info_outline_rounded,
        color: Brand.yellow,
      );
      return;
    }
    final t = _resolve(m, q);
    _timer?.cancel();
    if (t == null) {
      setState(() {
        _token = null;
        _notFound = q.trim();
        _step = -1;
      });
      return;
    }
    setState(() {
      _notFound = null;
      _token = null;
      _step = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 420), (tm) {
      if (!mounted) return tm.cancel();
      setState(() => _step++);
      if (_step > _steps.length) {
        tm.cancel();
        setState(() {
          _token = t;
          _step = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final nav = context.watch<NavState>();
    final market = context.watch<MarketState>();
    if (nav.aiNonce != _seenNonce) {
      _seenNonce = nav.aiNonce;
      final q = nav.aiQuery;
      if (q != null) {
        _input.text = q;
        WidgetsBinding.instance.addPostFrameCallback((_) => _run(q));
      }
    }
    final risky = market.tokens
        .where((t) => t.risk == Risk.high)
        .take(2)
        .map((t) => t.symbol);
    final suggestions = ['TST', 'BABYDOGE', 'FLOKI', ...risky];

    return SafeArea(
      bottom: false,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          const PageTitle(
            'AI Investigator',
            subtitle:
                'Paste a token name or contract. Get a plain-English safety report in seconds.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              radius: 24,
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: p.faint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      onSubmitted: _run,
                      textInputAction: TextInputAction.search,
                      style: inter(15, w: 500),
                      cursorColor: Brand.yellow,
                      decoration: InputDecoration(
                        hintText: 'Name, symbol or 0x… address',
                        hintStyle: inter(14.5, color: p.faint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  Tap(
                    onTap: () => _run(_input.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: Brand.yellowGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Brand.ink,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              itemCount: suggestions.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => i == 0
                  ? Center(
                      child: Text(
                        'Try',
                        style: inter(13, w: 600, color: p.faint),
                      ),
                    )
                  : SelectChip(
                      label: suggestions[i - 1],
                      selected: false,
                      onTap: () {
                        _input.text = suggestions[i - 1];
                        _run(suggestions[i - 1]);
                      },
                    ),
            ),
          ),
          if (_step >= 0)
            _Thinking(
              step: _step,
              steps: _steps,
              symbol: _input.text.trim().toUpperCase(),
            ),
          if (_notFound != null)
            EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No token found',
              text:
                  'We could not find “$_notFound”. Try a symbol like TST, or paste a full 42-character 0x contract address.',
            ),
          if (_token == null && _step < 0 && _notFound == null)
            const _IdleHint(),
          if (_token != null) _Report(token: _token!),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Text(
              'Reports use demo heuristics. They are not a guarantee of safety and not financial advice.',
              textAlign: TextAlign.center,
              style: inter(12, color: p.faint, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget row(IconData i, String t, String s) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Brand.yellow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(i, size: 21, color: Brand.yellow),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: inter(14.5, w: 650)),
                const SizedBox(height: 2),
                Text(s, style: inter(13, color: p.dim, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 6),
        child: Column(
          children: [
            row(
              Icons.bug_report_outlined,
              'Honeypot simulation',
              'Checks whether you can actually sell.',
            ),
            row(
              Icons.lock_outline_rounded,
              'Liquidity and ownership',
              'Is liquidity locked and ownership renounced?',
            ),
            row(
              Icons.groups_outlined,
              'Holders and taxes',
              'Whale concentration, mint rights and trading taxes.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking({
    required this.step,
    required this.steps,
    required this.symbol,
  });
  final int step;
  final List<String> steps;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Brand.yellow,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Investigating $symbol…',
                    style: inter(15.5, w: 650),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: i < step
                          ? const Icon(
                              Icons.check_circle_rounded,
                              key: ValueKey('d'),
                              size: 20,
                              color: Brand.green,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              key: const ValueKey('o'),
                              size: 20,
                              color: p.line,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      steps[i],
                      style: inter(
                        13.5,
                        w: 500,
                        color: i < step ? p.text : p.faint,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final watched = app.isWatched(token.id);
    return Reveal(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                TokenAvatar(token, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: display(20, spacing: -0.3),
                      ),
                      Text(
                        token.symbol,
                        style: inter(13, color: context.pal.faint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SafetyHeader(token: token),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: watched
                      ? GhostButton(
                          label: 'Saved',
                          icon: Icons.star_rounded,
                          height: 50,
                          onTap: () => app.toggleWatch(token.id),
                        )
                      : PrimaryButton(
                          label: 'Watch',
                          icon: Icons.star_outline_rounded,
                          height: 50,
                          onTap: () {
                            app.toggleWatch(token.id);
                            showToast(
                              context,
                              '${token.name} added to Watchlist',
                              icon: Icons.star_rounded,
                              color: Brand.yellow,
                            );
                          },
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GhostButton(
                    label: 'Alert',
                    icon: Icons.notifications_active_outlined,
                    height: 50,
                    onTap: () => openPage(
                      context,
                      AlertsScreen(prefillSymbol: token.symbol),
                    ),
                  ),
                ),
                if (!token.synthetic) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: GhostButton(
                      label: 'Details',
                      icon: Icons.arrow_outward_rounded,
                      height: 50,
                      onTap: () =>
                          openPage(context, TokenDetailScreen(token: token)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            SecurityChecks(token: token),
            const SizedBox(height: 14),
            KeyNumbers(token: token),
            const SizedBox(height: 14),
            WatchOut(token: token),
          ],
        ),
      ),
    );
  }
}
