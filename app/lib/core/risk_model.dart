import 'format.dart';
import 'market_data.dart';
import 'models.dart';

/// Demo risk model: deterministic per token so reports are stable between visits.
class RiskModel {
  static final _cache = <String, Analysis>{};

  static Analysis analyse(Token t) {
    return _cache.putIfAbsent(t.id, () => _build(t));
  }

  static double _between(Seeded r, double a, double b) =>
      a + (b - a) * r.next();

  static Analysis _build(Token t) {
    final r = Seeded('${t.id}:risk');
    final lvl = t.risk;
    final lpLocked =
        (lvl == Risk.low
                ? _between(r, 86, 100)
                : lvl == Risk.medium
                ? _between(r, 40, 80)
                : _between(r, 0, 35))
            .round();
    final lockDays =
        (lvl == Risk.low
                ? _between(r, 180, 720)
                : lvl == Risk.medium
                ? _between(r, 30, 150)
                : _between(r, 0, 20))
            .round();
    final renounced = lvl == Risk.low
        ? true
        : (lvl == Risk.medium ? r.next() > 0.5 : false);
    final buyTax = double.parse(
      (lvl == Risk.low
              ? _between(r, 0, 3)
              : lvl == Risk.medium
              ? _between(r, 3, 8)
              : _between(r, 8, 20))
          .toStringAsFixed(1),
    );
    final sellTax = double.parse(
      (lvl == Risk.low
              ? _between(r, 0, 3)
              : lvl == Risk.medium
              ? _between(r, 3, 9)
              : _between(r, 10, 28))
          .toStringAsFixed(1),
    );
    final top10 =
        (lvl == Risk.low
                ? _between(r, 14, 30)
                : lvl == Risk.medium
                ? _between(r, 30, 48)
                : _between(r, 50, 82))
            .round();
    final holders = (t.txns * _between(r, 0.5, 2.2)).round().clamp(
      300,
      100000000,
    );
    final honeypot = lvl == Risk.high && r.next() > 0.6;
    final verified = lvl == Risk.high ? r.next() > 0.55 : true;
    final mintable = lvl == Risk.high
        ? r.next() > 0.4
        : (lvl == Risk.medium ? r.next() > 0.8 : false);
    var score = lvl == Risk.low
        ? _between(r, 78, 95)
        : lvl == Risk.medium
        ? _between(r, 52, 72)
        : _between(r, 14, 44);
    if (honeypot && score > 18) score = 18;

    final flags = <RiskFlag>[
      RiskFlag(
        'honeypot',
        'Honeypot check',
        'Honeypot',
        honeypot ? FlagStatus.bad : FlagStatus.good,
        honeypot
            ? 'Sells are blocked or heavily restricted in simulation'
            : 'Buy and sell simulation passed',
      ),
      RiskFlag(
        'lp',
        'Liquidity locked',
        'Unlocked LP',
        lpLocked >= 80
            ? FlagStatus.good
            : (lpLocked >= 40 ? FlagStatus.warn : FlagStatus.bad),
        '$lpLocked% of LP locked${lockDays > 0 ? ' for $lockDays more days' : ' — can be removed any time'}',
      ),
      RiskFlag(
        'owner',
        'Ownership',
        'Owner not renounced',
        renounced ? FlagStatus.good : FlagStatus.warn,
        renounced
            ? 'Contract ownership renounced'
            : 'Owner can still change contract settings',
      ),
      RiskFlag(
        'tax',
        'Buy / sell tax',
        'High tax',
        sellTax <= 5
            ? FlagStatus.good
            : (sellTax <= 10 ? FlagStatus.warn : FlagStatus.bad),
        'Buy $buyTax% · Sell $sellTax%',
      ),
      RiskFlag(
        'holders',
        'Holder concentration',
        'Whale heavy',
        top10 <= 30
            ? FlagStatus.good
            : (top10 <= 50 ? FlagStatus.warn : FlagStatus.bad),
        'Top 10 wallets hold $top10% of supply',
      ),
      RiskFlag(
        'mint',
        'Mint function',
        'Mintable',
        mintable ? FlagStatus.bad : FlagStatus.good,
        mintable ? 'Owner can mint new tokens' : 'No mint function found',
      ),
      RiskFlag(
        'verified',
        'Source code',
        'Unverified',
        verified ? FlagStatus.good : FlagStatus.warn,
        verified ? 'Verified on BscScan' : 'Contract source is not verified',
      ),
    ];

    final s = score.round();
    final verdict = s >= 75
        ? 'Looks relatively safe'
        : (s >= 50 ? 'Proceed with caution' : 'High risk');
    final bad = flags.where((f) => f.status == FlagStatus.bad).length;
    final warn = flags.where((f) => f.status == FlagStatus.warn).length;
    final issues = bad > 0
        ? '$bad critical issue${bad > 1 ? 's' : ''} found${warn > 0 ? ' and $warn warning${warn > 1 ? 's' : ''}' : ''}. '
        : (warn > 0
              ? 'No critical issues, but $warn warning${warn > 1 ? 's' : ''} to review. '
              : 'No critical issues were found. ');
    final summary =
        '${t.name} (${t.symbol}) scores $s/100 for safety — ${verdict.toLowerCase()}. $issues'
        'It is trading ${Fmt.pct(t.change)} over 24h on ${Fmt.money(t.vol)} of volume, with ${Fmt.money(t.liq)} of liquidity.';

    return Analysis(
      score: s,
      verdict: verdict,
      summary: summary,
      flags: flags,
      lpLocked: lpLocked,
      lockDays: lockDays,
      renounced: renounced,
      buyTax: buyTax,
      sellTax: sellTax,
      top10: top10,
      holders: holders,
      honeypot: honeypot,
      verified: verified,
      mintable: mintable,
      ageDays: t.age < 1 ? 1 : t.age,
    );
  }
}
