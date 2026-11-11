import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models.dart';

/// Deterministic seeded generator (matches the website's data).
class Seeded {
  Seeded(String str) {
    var h = 2166136261;
    for (final c in str.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    _h = h;
  }
  late int _h;

  double next() {
    var h = _h;
    h = (((h ^ (h >> 15)) * 2246822507) & 0xFFFFFFFF);
    h = (((h ^ (h >> 13)) * 3266489909) & 0xFFFFFFFF);
    h ^= h >> 16;
    _h = h;
    return (h & 0xFFFFFFFF) / 4294967296;
  }
}

class MarketData {
  static List<Token> build() {
    final featured = <Token>[
      Token(
        name: 'BabyDoge',
        symbol: 'BABYDOGE',
        icon: 'babydoge',
        price: 0.00000215,
        change: 72.36,
        liq: 12.4e6,
        vol: 18.7e6,
        mcap: 156.4e6,
        txns: 38.7e3,
        risk: Risk.low,
        signal: 82,
        cats: ['bsc', 'memes'],
        age: 900,
        trend: 95,
        address: _addr('BABYDOGE'),
      ),
      Token(
        name: 'TST',
        symbol: 'TST',
        icon: 'tst',
        price: 0.0214,
        change: 56.72,
        liq: 4.8e6,
        vol: 9.3e6,
        mcap: 78.6e6,
        txns: 22.1e3,
        risk: Risk.medium,
        signal: 76,
        cats: ['bsc', 'memes', 'social'],
        age: 3,
        trend: 99,
        address: _addr('TST'),
      ),
      Token(
        name: 'Neiro',
        symbol: 'NEIRO',
        icon: 'neiro',
        price: 0.0018,
        change: 48.2,
        liq: 7.6e6,
        vol: 12.4e6,
        mcap: 134.2e6,
        txns: 54.3e3,
        risk: Risk.low,
        signal: 71,
        cats: ['bsc', 'memes'],
        age: 420,
        trend: 90,
        address: _addr('NEIRO'),
      ),
      Token(
        name: 'Floki',
        symbol: 'FLOKI',
        icon: 'floki',
        price: 0.000184,
        change: 42.17,
        liq: 34.2e6,
        vol: 71.6e6,
        mcap: 412.6e6,
        txns: 91.6e3,
        risk: Risk.low,
        signal: 69,
        cats: ['bsc', 'memes', 'gaming'],
        age: 1400,
        trend: 88,
        address: _addr('FLOKI'),
      ),
      Token(
        name: 'Pepe Unchained',
        symbol: 'PEPU',
        icon: 'pepu',
        price: 0.0063,
        change: 38.56,
        liq: 11.8e6,
        vol: 27.5e6,
        mcap: 98.4e6,
        txns: 41.2e3,
        risk: Risk.low,
        signal: 66,
        cats: ['bsc', 'memes', 'defi'],
        age: 210,
        trend: 84,
        address: _addr('PEPU'),
      ),
      Token(
        name: 'WIF',
        symbol: 'WIF',
        icon: 'wif',
        price: 1.23,
        change: 34.28,
        liq: 28.4e6,
        vol: 52.7e6,
        mcap: 281.6e6,
        txns: 72.8e3,
        risk: Risk.medium,
        signal: 64,
        cats: ['bsc', 'memes'],
        age: 800,
        trend: 86,
        address: _addr('WIF'),
      ),
      Token(
        name: 'CAT IN A DOGS WORLD',
        symbol: 'MEW',
        icon: 'mew',
        price: 0.0039,
        change: 31.76,
        liq: 5.7e6,
        vol: 16.2e6,
        mcap: 92.3e6,
        txns: 33.4e3,
        risk: Risk.low,
        signal: 62,
        cats: ['bsc', 'memes', 'social'],
        age: 300,
        trend: 80,
        address: _addr('MEW'),
      ),
      Token(
        name: 'BOME',
        symbol: 'BOME',
        icon: 'bome',
        price: 0.0067,
        change: 28.34,
        liq: 8.9e6,
        vol: 21.8e6,
        mcap: 114.7e6,
        txns: 45.2e3,
        risk: Risk.medium,
        signal: 58,
        cats: ['bsc', 'memes', 'nft'],
        age: 500,
        trend: 77,
        address: _addr('BOME'),
      ),
      Token(
        name: 'PEPE',
        symbol: 'PEPE',
        icon: 'pepe',
        price: 0.0000128,
        change: 24.67,
        liq: 16.5e6,
        vol: 36.4e6,
        mcap: 206.7e6,
        txns: 68.1e3,
        risk: Risk.low,
        signal: 54,
        cats: ['bsc', 'memes'],
        age: 1200,
        trend: 82,
        address: _addr('PEPE'),
      ),
      Token(
        name: 'DOGE',
        symbol: 'DOGE',
        icon: 'doge',
        price: 0.0812,
        change: 21.45,
        liq: 42.7e6,
        vol: 98.3e6,
        mcap: 1.2e9,
        txns: 127.6e3,
        risk: Risk.medium,
        signal: 48,
        cats: ['bsc', 'memes'],
        age: 2000,
        trend: 79,
        address: _addr('DOGE'),
      ),
    ];

    var seed = 20261021;
    double rnd() {
      seed = (seed * 1664525 + 1013904223) % 4294967296;
      return seed / 4294967296;
    }

    T pick<T>(List<T> a) => a[(rnd() * a.length).floor()];

    const pre = [
      'Moon',
      'Baby',
      'Mega',
      'Safe',
      'Turbo',
      'Based',
      'Shiba',
      'Cake',
      'Bit',
      'Hyper',
      'Quantum',
      'Lucky',
      'Golden',
      'Rocket',
      'Neo',
      'Alpha',
      'Pixel',
      'Meta',
      'Astro',
      'Frog',
      'Cyber',
      'Degen',
      'Sun',
      'Lion',
    ];
    const suf = [
      'Cat',
      'Inu',
      'Doge',
      'Swap',
      'Fi',
      'Verse',
      'Bot',
      'Chain',
      'Pad',
      'Punk',
      'AI',
      'Coin',
      'Yield',
      'Bull',
      'Pepe',
      'Floki',
      'Land',
      'Labs',
      'Dao',
      'X',
    ];
    const catBySuf = {
      'Swap': 'defi',
      'Fi': 'defi',
      'Yield': 'defi',
      'Dao': 'defi',
      'Bot': 'ai',
      'AI': 'ai',
      'Verse': 'gaming',
      'Land': 'gaming',
      'Punk': 'nft',
      'Pad': 'other',
      'Chain': 'other',
      'Labs': 'other',
      'Coin': 'social',
      'X': 'social',
    };
    const colors = [
      Color(0xFFF5B700),
      Color(0xFF16A34A),
      Color(0xFF2563EB),
      Color(0xFFDB2777),
      Color(0xFF7C3AED),
      Color(0xFFEA580C),
      Color(0xFF0891B2),
      Color(0xFFDC2626),
      Color(0xFF65A30D),
      Color(0xFF475569),
    ];

    final used = <String>{for (final t in featured) t.symbol};
    final generated = <Token>[];
    var change = 21.0;
    while (generated.length < 204) {
      final a = pick(pre), b = pick(suf);
      final sym = (a.substring(0, 2) + b.substring(0, math.min(3, b.length)))
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z]'), '');
      if (used.contains(sym)) continue;
      used.add(sym);
      change -= rnd() * 0.45;
      final mcap = math.pow(10, 6 + rnd() * 2.6).toDouble();
      final liq = mcap * (0.04 + rnd() * 0.12);
      final vol = liq * (0.8 + rnd() * 2.4);
      final cat = catBySuf[b] ?? 'memes';
      final signal = math.max(12, math.min(95, (30 + rnd() * 50).round()));
      final color = pick(colors);
      final price = math.pow(10, -7 + rnd() * 7.5).toDouble();
      final tx = (vol / (180 + rnd() * 420)).roundToDouble();
      final r1 = rnd();
      final risk = r1 < 0.55
          ? Risk.low
          : (rnd() < 0.75 ? Risk.medium : Risk.high);
      generated.add(
        Token(
          name: a + b,
          symbol: sym,
          color: color,
          price: price,
          change: double.parse(change.toStringAsFixed(2)),
          liq: liq,
          vol: vol,
          mcap: mcap,
          txns: tx,
          risk: risk,
          signal: signal,
          cats: ['bsc', cat],
          age: (rnd() * 3000).round(),
          trend: (rnd() * 78).round(),
          address: _addr(sym),
        ),
      );
    }
    return [...featured, ...generated];
  }

  static String _addr(String sym) {
    final r = Seeded('addr:$sym');
    final b = StringBuffer('0x');
    for (var i = 0; i < 40; i++) {
      b.write('0123456789abcdef'[(r.next() * 16).floor()]);
    }
    return b.toString();
  }

  /// Chain-wide gainers and pairs shown on Home.
  static const gainers = [
    ('TST', 'tst', 128.45),
    ('BabyDoge', 'babydoge', 72.36),
    ('PONKE', 'ponke', 56.72),
    ('Neiro', 'neiro', 48.2),
    ('FLOKI', 'floki', 42.17),
  ];

  static const pairs = [
    ('TST', 'WBNB', 'tst', 3),
    ('DOGEAI', 'WBNB', 'dogeai', 12),
    ('PEPE2.0', 'WBNB', 'pepe2', 18),
    ('KONG', 'WBNB', 'kong', 26),
    ('SHIBI', 'WBNB', 'shibi', 34),
  ];

  static Token synthetic(String addr) {
    final r = Seeded(addr.toLowerCase());
    final x = r.next();
    final risk = x < 0.4 ? Risk.low : (x < 0.6 ? Risk.medium : Risk.high);
    final liq = math.pow(10, 4.5 + r.next() * 2.8).toDouble();
    final vol = liq * (0.4 + r.next() * 2);
    final sym = '0x${addr.substring(2, 6).toUpperCase()}';
    return Token(
      name: 'Unlisted token',
      symbol: sym,
      address: addr,
      price: math.pow(10, -8 + r.next() * 6).toDouble(),
      change: double.parse(((r.next() - 0.4) * 60).toStringAsFixed(2)),
      liq: liq,
      vol: vol,
      mcap: liq * (8 + r.next() * 20),
      txns: (vol / 300).roundToDouble(),
      risk: risk,
      signal: (25 + r.next() * 50).round(),
      age: (r.next() * 120).round(),
      trend: 0,
      cats: ['bsc'],
      synthetic: true,
    );
  }
}
