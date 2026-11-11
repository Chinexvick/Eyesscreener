import 'package:eyes_screener/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('splash leads to onboarding, then to the create account screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(EyesApp(prefs: prefs));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SEE EVERYTHING. INVEST WISELY.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Next'), findsOneWidget);
    expect(find.textContaining('Spot opportunities'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('AI explains'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Get alerted'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('onboarding and sign in fit a small phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarding': false});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(EyesApp(prefs: prefs));
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 800));
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Create your account'), findsOneWidget);
  });
}
