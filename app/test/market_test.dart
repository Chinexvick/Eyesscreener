import 'package:eyes_screener/core/market_data.dart';
import 'package:eyes_screener/core/models.dart';
import 'package:eyes_screener/core/risk_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tokens = MarketData.build();

  test(
    'market data has the featured tokens first and 200+ tokens in total',
    () {
      expect(tokens.length, greaterThan(200));
      expect(tokens.first.symbol, 'BABYDOGE');
      expect(tokens[1].symbol, 'TST');
      expect(
        tokens.map((t) => t.symbol).toSet().length,
        tokens.length,
        reason: 'symbols are unique',
      );
      expect(
        tokens.every(
          (t) => t.address.length == 42 && t.address.startsWith('0x'),
        ),
        isTrue,
      );
    },
  );

  test('market data is deterministic', () {
    final again = MarketData.build();
    expect(again[50].symbol, tokens[50].symbol);
    expect(again[50].price, tokens[50].price);
  });

  test('risk analysis is stable and consistent with the risk level', () {
    for (final t in tokens.take(80)) {
      final a = RiskModel.analyse(t);
      expect(a.score, inInclusiveRange(0, 100));
      expect(identical(a, RiskModel.analyse(t)), isTrue);
      if (t.risk == Risk.low) expect(a.score, greaterThanOrEqualTo(70));
      if (t.risk == Risk.high) expect(a.score, lessThan(50));
    }
  });

  test('unlisted contract addresses still get a report', () {
    final t = MarketData.synthetic(
      '0x1234567890abcdef1234567890abcdef12345678',
    );
    expect(t.synthetic, isTrue);
    expect(RiskModel.analyse(t).flags.length, 7);
  });
}
