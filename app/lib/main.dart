import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/auth_repository.dart';
import 'core/theme.dart';
import 'screens/app_flow.dart';
import 'state/app_state.dart';
import 'state/auth_state.dart';
import 'state/market_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  runApp(EyesApp(prefs: prefs));
}

class EyesApp extends StatelessWidget {
  const EyesApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(prefs)),
        ChangeNotifierProvider(
          create: (_) => AuthState(LocalAuthRepository(prefs))..restore(),
        ),
        ChangeNotifierProvider(create: (_) => MarketState()),
      ],
      child: Consumer<AppState>(
        builder: (context, app, _) => MaterialApp(
          title: 'Eyes Screener',
          debugShowCheckedModeBanner: false,
          themeMode: app.themeMode,
          theme: buildTheme(Pal.light),
          darkTheme: buildTheme(Pal.dark),
          builder: (context, child) {
            final dark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: dark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: dark ? Brightness.dark : Brightness.light,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: dark
                    ? Brightness.light
                    : Brightness.dark,
              ),
              child: child!,
            );
          },
          home: const AppFlow(),
        ),
      ),
    );
  }
}
