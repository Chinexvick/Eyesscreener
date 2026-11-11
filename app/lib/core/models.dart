import 'package:flutter/material.dart';

enum Risk { low, medium, high }

extension RiskX on Risk {
  String get label => switch (this) {
    Risk.low => 'Low',
    Risk.medium => 'Medium',
    Risk.high => 'High',
  };
  int get n => index + 1;
}

class Token {
  Token({
    required this.name,
    required this.symbol,
    required this.address,
    required this.price,
    required this.change,
    required this.liq,
    required this.vol,
    required this.mcap,
    required this.txns,
    required this.risk,
    required this.signal,
    required this.age,
    required this.trend,
    required this.cats,
    this.icon,
    this.color = const Color(0xFF64748B),
    this.synthetic = false,
  });

  final String name, symbol, address;
  final String? icon; // asset file name in assets/img/tokens
  final Color color;
  final bool synthetic;
  double price, change, liq, vol, mcap, txns;
  final Risk risk;
  final int signal, age, trend;
  final List<String> cats;

  String get id => symbol;
  String? get asset => icon == null ? null : 'assets/img/tokens/$icon.png';
}

enum FlagStatus { good, warn, bad }

class RiskFlag {
  const RiskFlag(this.id, this.label, this.tag, this.status, this.detail);
  final String id, label, tag, detail;
  final FlagStatus status;
}

class Analysis {
  Analysis({
    required this.score,
    required this.verdict,
    required this.summary,
    required this.flags,
    required this.lpLocked,
    required this.lockDays,
    required this.renounced,
    required this.buyTax,
    required this.sellTax,
    required this.top10,
    required this.holders,
    required this.honeypot,
    required this.verified,
    required this.mintable,
    required this.ageDays,
  });

  final int score, lpLocked, lockDays, top10, holders, ageDays;
  final String verdict, summary;
  final List<RiskFlag> flags;
  final bool renounced, honeypot, verified, mintable;
  final double buyTax, sellTax;

  int get bad => flags.where((f) => f.status == FlagStatus.bad).length;
  int get warn => flags.where((f) => f.status == FlagStatus.warn).length;
  FlagStatus get level => score >= 75
      ? FlagStatus.good
      : (score >= 50 ? FlagStatus.warn : FlagStatus.bad);
}
