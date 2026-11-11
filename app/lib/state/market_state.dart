import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/market_data.dart';
import '../core/models.dart';

class MarketState extends ChangeNotifier {
  MarketState() : tokens = MarketData.build();

  final List<Token> tokens;
  Timer? _timer;
  final _rng = Random();
  int version = 0;

  void startLive() {
    _timer ??= Timer.periodic(
      const Duration(milliseconds: 3500),
      (_) => _tick(),
    );
  }

  void stopLive() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    for (final t in tokens.take(60)) {
      if (_rng.nextDouble() > 0.3) continue;
      final drift = (_rng.nextDouble() - 0.48) * 0.012;
      t.price *= 1 + drift;
      t.change = double.parse((t.change + drift * 100).toStringAsFixed(2));
      t.vol *= 1 + drift.abs() * 0.5;
      t.txns += _rng.nextInt(40);
    }
    version++;
    notifyListeners();
  }

  Token? find(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return null;
    for (final t in tokens) {
      if (t.symbol.toLowerCase() == s ||
          t.address.toLowerCase() == s ||
          t.name.toLowerCase() == s) {
        return t;
      }
    }
    return null;
  }

  Token? search(String q) {
    final exact = find(q);
    if (exact != null) return exact;
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return null;
    for (final t in tokens) {
      if (t.name.toLowerCase().contains(s) ||
          t.symbol.toLowerCase().contains(s)) {
        return t;
      }
    }
    return null;
  }

  Token? byId(String id) {
    for (final t in tokens) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  void dispose() {
    stopLive();
    super.dispose();
  }
}
