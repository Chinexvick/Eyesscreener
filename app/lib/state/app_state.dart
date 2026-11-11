import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models.dart';

enum AlertCond {
  priceAbove,
  priceBelow,
  changeAbove,
  signalAbove,
  liqBelow,
  riskHigh,
}

extension AlertCondX on AlertCond {
  String get title => switch (this) {
    AlertCond.priceAbove => 'Price goes above (\$)',
    AlertCond.priceBelow => 'Price falls below (\$)',
    AlertCond.changeAbove => '24h change above (%)',
    AlertCond.signalAbove => 'AI signal above (0–100)',
    AlertCond.liqBelow => 'Liquidity falls below (\$)',
    AlertCond.riskHigh => 'Risk becomes High',
  };

  bool get needsValue => this != AlertCond.riskHigh;
}

class AlertRule {
  AlertRule({
    required this.id,
    required this.symbol,
    required this.cond,
    required this.value,
    this.on = true,
  });

  final int id;
  final String symbol;
  final AlertCond cond;
  final double value;
  bool on;

  bool triggeredBy(Token t) => switch (cond) {
    AlertCond.priceAbove => t.price > value,
    AlertCond.priceBelow => t.price < value,
    AlertCond.changeAbove => t.change > value,
    AlertCond.signalAbove => t.signal > value,
    AlertCond.liqBelow => t.liq < value,
    AlertCond.riskHigh => t.risk == Risk.high,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'cond': cond.name,
    'value': value,
    'on': on,
  };

  static AlertRule fromJson(Map<String, dynamic> j) => AlertRule(
    id: j['id'] as int,
    symbol: j['symbol'] as String,
    cond: AlertCond.values.firstWhere(
      (c) => c.name == j['cond'],
      orElse: () => AlertCond.priceAbove,
    ),
    value: (j['value'] as num).toDouble(),
    on: j['on'] as bool? ?? true,
  );
}

/// Settings and per-account saved data (watchlist, alerts, lesson progress).
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == _prefs.getString('theme'),
      orElse: () => ThemeMode.dark,
    );
    _live = _prefs.getBool('live') ?? true;
    onboardingDone = _prefs.getBool('onboarding') ?? false;
    loadScope('guest');
  }

  final SharedPreferences _prefs;
  late ThemeMode _themeMode;
  late bool _live;
  bool onboardingDone = false;

  String _scope = 'guest';
  List<String> _watchlist = [];
  List<AlertRule> _alerts = [];
  Set<String> _lessons = {};

  ThemeMode get themeMode => _themeMode;
  bool get live => _live;
  List<String> get watchlist => List.unmodifiable(_watchlist);
  List<AlertRule> get alerts => List.unmodifiable(_alerts);
  Set<String> get lessonsDone => Set.unmodifiable(_lessons);

  String _k(String k) => '$_scope.$k';

  void loadScope(String scope) {
    _scope = scope;
    final w = _prefs.getStringList(_k('watchlist'));
    _watchlist =
        w ??
        (scope == 'guest' || !_prefs.containsKey(_k('watchlist'))
            ? ['BABYDOGE', 'TST']
            : []);
    final a = _prefs.getString(_k('alerts'));
    if (a != null) {
      try {
        _alerts = (jsonDecode(a) as List)
            .map((e) => AlertRule.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        _alerts = [];
      }
    } else {
      _alerts = [
        AlertRule(
          id: 1,
          symbol: 'TST',
          cond: AlertCond.changeAbove,
          value: 100,
        ),
        AlertRule(
          id: 2,
          symbol: 'FLOKI',
          cond: AlertCond.priceBelow,
          value: 0.00015,
        ),
      ];
    }
    _lessons = (_prefs.getStringList(_k('lessons')) ?? []).toSet();
    notifyListeners();
  }

  // ---- settings ----
  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    await _prefs.setString('theme', m.name);
    notifyListeners();
  }

  Future<void> setLive(bool v) async {
    _live = v;
    await _prefs.setBool('live', v);
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    onboardingDone = true;
    await _prefs.setBool('onboarding', true);
    notifyListeners();
  }

  // ---- watchlist ----
  bool isWatched(String id) => _watchlist.contains(id);

  bool toggleWatch(String id) {
    final on = !_watchlist.contains(id);
    on ? _watchlist.add(id) : _watchlist.remove(id);
    _prefs.setStringList(_k('watchlist'), _watchlist);
    notifyListeners();
    return on;
  }

  // ---- alerts ----
  void _saveAlerts() => _prefs.setString(
    _k('alerts'),
    jsonEncode(_alerts.map((a) => a.toJson()).toList()),
  );

  void addAlert(AlertRule r) {
    _alerts.insert(0, r);
    _saveAlerts();
    notifyListeners();
  }

  void toggleAlert(int id) {
    final r = _alerts.firstWhere((a) => a.id == id);
    r.on = !r.on;
    _saveAlerts();
    notifyListeners();
  }

  void removeAlert(int id) {
    _alerts.removeWhere((a) => a.id == id);
    _saveAlerts();
    notifyListeners();
  }

  // ---- academy ----
  bool lessonDone(String key) => _lessons.contains(key);

  void toggleLesson(String key) {
    _lessons.contains(key) ? _lessons.remove(key) : _lessons.add(key);
    _prefs.setStringList(_k('lessons'), _lessons.toList());
    notifyListeners();
  }

  // ---- data ----
  Future<void> clearSavedData() async {
    for (final k in ['watchlist', 'alerts', 'lessons']) {
      await _prefs.remove(_k(k));
    }
    _watchlist = [];
    _alerts = [];
    _lessons = {};
    notifyListeners();
  }
}
