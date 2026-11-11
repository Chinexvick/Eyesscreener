import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../state/market_state.dart';
import '../../widgets/kit.dart';
import '../../widgets/token_row.dart';
import '../shell.dart';

class ScreenerTab extends StatefulWidget {
  const ScreenerTab({super.key});

  @override
  State<ScreenerTab> createState() => _ScreenerTabState();
}

enum _Sort { auto, price, change, liq, vol, mcap, signal }

class _Filters {
  double minLiq = 0, minVol = 0, minMcap = 0;
  Risk? risk;
  bool positiveOnly = false;

  int get active => [
    minLiq > 0,
    minVol > 0,
    minMcap > 0,
    risk != null,
    positiveOnly,
  ].where((e) => e).length;
}

class _ScreenerTabState extends State<ScreenerTab> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  String _tab = 'gainers';
  String _cat = 'all';
  _Sort _sort = _Sort.auto;
  bool _asc = false;
  final _f = _Filters();
  int _seenNonce = 0, _seenFocus = 0;

  static const _tabs = [
    ('gainers', 'Top Gainers', Icons.trending_up_rounded),
    ('new', 'New Pairs', Icons.auto_awesome_rounded),
    ('trending', 'Trending', Icons.local_fire_department_rounded),
    ('liquidity', 'Liquidity', Icons.water_drop_rounded),
    ('ai', 'AI Picks', Icons.psychology_rounded),
  ];
  static const _cats = [
    ('all', 'All'),
    ('bsc', 'BSC'),
    ('memes', 'Memes'),
    ('defi', 'DeFi'),
    ('ai', 'AI'),
    ('gaming', 'Gaming'),
    ('nft', 'NFT'),
    ('social', 'Social'),
    ('other', 'Other'),
  ];

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<Token> _visible(List<Token> all) {
    final q = _search.text.trim().toLowerCase();
    final list = all.where((t) {
      if (_cat != 'all' && !t.cats.contains(_cat)) return false;
      if (t.liq < _f.minLiq || t.vol < _f.minVol || t.mcap < _f.minMcap) {
        return false;
      }
      if (_f.risk != null && t.risk != _f.risk) return false;
      if (_f.positiveOnly && t.change < 0) return false;
      if (q.isNotEmpty &&
          !t.name.toLowerCase().contains(q) &&
          !t.symbol.toLowerCase().contains(q) &&
          !t.address.contains(q)) {
        return false;
      }
      return true;
    }).toList();

    num key(Token t, String k) => switch (k) {
      'change' => t.change,
      'age' => t.age,
      'trend' => t.trend,
      'liq' => t.liq,
      'signal' => t.signal,
      'price' => t.price,
      'vol' => t.vol,
      'mcap' => t.mcap,
      _ => 0,
    };
    String k;
    bool asc;
    if (_sort == _Sort.auto) {
      (k, asc) = switch (_tab) {
        'new' => ('age', true),
        'trending' => ('trend', false),
        'liquidity' => ('liq', false),
        'ai' => ('signal', false),
        _ => ('change', false),
      };
    } else {
      k = _sort.name;
      asc = _asc;
    }
    list.sort(
      (a, b) =>
          asc ? key(a, k).compareTo(key(b, k)) : key(b, k).compareTo(key(a, k)),
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketState>();
    final nav = context.watch<NavState>();

    // Apply requests from other screens (search from Home, "See all" links).
    if (nav.screenerNonce != _seenNonce) {
      _seenNonce = nav.screenerNonce;
      if (nav.screenerTab != null) {
        _tab = nav.screenerTab!;
        _sort = _Sort.auto;
      }
      if (nav.screenerQuery != null) _search.text = nav.screenerQuery!;
    }
    if (nav.searchFocusNonce != _seenFocus) {
      _seenFocus = nav.searchFocusNonce;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focus.requestFocus(),
      );
    }

    final list = _visible(market.tokens);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: PageTitle(
              'Screener',
              subtitle: 'Discover the best opportunities on BNB Chain.',
              trailing: _LiveBadge(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: p.line),
                      ),
                      child: TextField(
                        controller: _search,
                        focusNode: _focus,
                        onChanged: (_) => setState(() {}),
                        style: inter(15, w: 500),
                        cursorColor: Brand.yellow,
                        decoration: InputDecoration(
                          hintText: 'Search name, symbol or address',
                          hintStyle: inter(14.5, color: p.faint),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: p.faint,
                          ),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: p.faint,
                                  ),
                                  onPressed: () => setState(_search.clear),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tap(
                    onTap: _openFilters,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _f.active > 0 ? Brand.yellow : p.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _f.active > 0
                                  ? Colors.transparent
                                  : p.line,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: _f.active > 0 ? Brand.ink : p.text,
                          ),
                        ),
                        if (_f.active > 0)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Brand.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: p.bg, width: 2),
                              ),
                              child: Text(
                                '${_f.active}',
                                style: inter(10.5, w: 800, color: Colors.black),
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
          SliverToBoxAdapter(
            child: SizedBox(
              height: 62,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SelectChip(
                  label: _tabs[i].$2,
                  icon: _tabs[i].$3,
                  selected: _tab == _tabs[i].$1,
                  onTap: () => setState(() {
                    _tab = _tabs[i].$1;
                    _sort = _Sort.auto;
                  }),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _cats.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final sel = _cat == _cats[i].$1;
                  return Tap(
                    onTap: () => setState(() => _cat = _cats[i].$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: sel
                            ? Brand.yellow.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? Brand.yellow.withValues(alpha: 0.7)
                              : p.line,
                        ),
                      ),
                      child: Text(
                        _cats[i].$2,
                        style: inter(
                          13,
                          w: sel ? 700 : 500,
                          color: sel ? Brand.yellow : p.dim,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 14, 8),
              child: Row(
                children: [
                  Text(
                    '${list.length} tokens',
                    style: inter(13, w: 600, color: p.dim),
                  ),
                  const Spacer(),
                  PopupMenuButton<_Sort>(
                    tooltip: 'Sort',
                    color: p.card2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: p.line),
                    ),
                    onSelected: (s) => setState(() {
                      if (_sort == s) {
                        _asc = !_asc;
                      } else {
                        _sort = s;
                        _asc = false;
                      }
                    }),
                    itemBuilder: (_) => [
                      for (final s in _Sort.values)
                        PopupMenuItem(
                          value: s,
                          child: Text(
                            switch (s) {
                              _Sort.auto => 'Default',
                              _Sort.price => 'Price',
                              _Sort.change => '24h change',
                              _Sort.liq => 'Liquidity',
                              _Sort.vol => 'Volume',
                              _Sort.mcap => 'Market cap',
                              _Sort.signal => 'AI signal',
                            },
                            style: inter(
                              14,
                              w: _sort == s ? 700 : 500,
                              color: _sort == s ? Brand.yellow : p.text,
                            ),
                          ),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _sort != _Sort.auto && _asc
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 16,
                            color: Brand.yellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _sort == _Sort.auto
                                ? 'Sort'
                                : _sort.name == 'liq'
                                ? 'Liquidity'
                                : _sort.name[0].toUpperCase() +
                                      _sort.name.substring(1),
                            style: inter(13, w: 650, color: Brand.yellow),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No tokens match',
                text: 'Try a different search or clear some filters.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => TokenCard(
                  key: ValueKey(list[i].id),
                  token: list[i],
                  rank: i + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openFilters() {
    final p = context.pal;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void upd(VoidCallback f) {
            setState(f);
            setSheet(() {});
          }

          Widget group(String title, List<(String, bool, VoidCallback)> opts) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: inter(13.5, w: 650, color: p.dim)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in opts)
                          SelectChip(label: o.$1, selected: o.$2, onTap: o.$3),
                      ],
                    ),
                  ],
                ),
              );

          return Container(
            padding: EdgeInsets.fromLTRB(
              22,
              14,
              22,
              22 + MediaQuery.of(ctx).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: p.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(color: p.line),
            ),
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
                Row(
                  children: [
                    Text('Filters', style: display(22)),
                    const Spacer(),
                    Tap(
                      onTap: () => upd(() {
                        _f.minLiq = 0;
                        _f.minVol = 0;
                        _f.minMcap = 0;
                        _f.risk = null;
                        _f.positiveOnly = false;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'Reset',
                          style: inter(14, w: 650, color: Brand.yellow),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                group('Min liquidity', [
                  for (final (l, v) in [
                    ('Any', 0.0),
                    (r'$1M+', 1e6),
                    (r'$5M+', 5e6),
                    (r'$10M+', 1e7),
                    (r'$25M+', 25e6),
                  ])
                    (l, _f.minLiq == v, () => upd(() => _f.minLiq = v)),
                ]),
                group('24h volume', [
                  for (final (l, v) in [
                    ('Any', 0.0),
                    (r'$1M+', 1e6),
                    (r'$10M+', 1e7),
                    (r'$50M+', 5e7),
                  ])
                    (l, _f.minVol == v, () => upd(() => _f.minVol = v)),
                ]),
                group('Market cap', [
                  for (final (l, v) in [
                    ('Any', 0.0),
                    (r'$10M+', 1e7),
                    (r'$100M+', 1e8),
                    (r'$500M+', 5e8),
                  ])
                    (l, _f.minMcap == v, () => upd(() => _f.minMcap = v)),
                ]),
                group('Risk', [
                  ('Any', _f.risk == null, () => upd(() => _f.risk = null)),
                  for (final r in Risk.values)
                    (r.label, _f.risk == r, () => upd(() => _f.risk = r)),
                ]),
                group('Price change', [
                  (
                    'Any',
                    !_f.positiveOnly,
                    () => upd(() => _f.positiveOnly = false),
                  ),
                  (
                    'Positive only',
                    _f.positiveOnly,
                    () => upd(() => _f.positiveOnly = true),
                  ),
                ]),
                PrimaryButton(
                  label: 'Show results',
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Brand.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text('Live', style: inter(12.5, w: 700)),
        ],
      ),
    );
  }
}
