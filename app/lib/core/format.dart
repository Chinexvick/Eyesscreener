import 'dart:math' as math;

class Fmt {
  static String price(double p) {
    if (p >= 1000) return '\$${_group(p.round())}';
    if (p >= 1) return '\$${p.toStringAsFixed(2)}';
    final dec = (-(math.log(p) / math.ln10)).ceil() + 2;
    var s = p.toStringAsFixed(dec.clamp(2, 12));
    if (s.contains('.')) s = s.replaceFirst(RegExp(r'0+$'), '');
    return '\$$s';
  }

  static String money(double n) {
    if (n >= 1e9) return '\$${(n / 1e9).toStringAsFixed(1)}B';
    if (n >= 1e6) return '\$${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '\$${(n / 1e3).toStringAsFixed(1)}K';
    return '\$${n.toStringAsFixed(0)}';
  }

  static String count(num n) {
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.round().toString();
  }

  static String pct(double n) => '${n >= 0 ? '+' : ''}${n.toStringAsFixed(2)}%';

  static String ago(int mins) {
    if (mins < 60) return '${math.max(1, mins)}m ago';
    if (mins < 1440) return '${(mins / 60).round()}h ago';
    return '${(mins / 1440).round()}d ago';
  }

  static String shortAddr(String a) =>
      a.length < 12 ? a : '${a.substring(0, 6)}…${a.substring(a.length - 4)}';

  static String _group(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  static String int_(int n) => _group(n);
}
