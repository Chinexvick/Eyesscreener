import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_state.dart';
import '../widgets/kit.dart';
import '../widgets/nav_bar.dart';
import 'tabs/ai_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/screener_tab.dart';
import 'tabs/watchlist_tab.dart';

/// Lets any screen switch tabs (and pass a search or a token to investigate).
class NavState extends ChangeNotifier {
  int index = 0;
  String? screenerQuery;
  String? screenerTab;
  String? aiQuery;
  int aiNonce = 0;
  int searchFocusNonce = 0;
  int screenerNonce = 0;

  void go(
    int i, {
    String? query,
    String? tab,
    String? ai,
    bool focusSearch = false,
  }) {
    index = i;
    if (query != null || tab != null) {
      screenerQuery = query;
      screenerTab = tab;
      screenerNonce++;
    }
    if (ai != null) {
      aiQuery = ai;
      aiNonce++;
    }
    if (focusSearch) searchFocusNonce++;
    notifyListeners();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _nav = NavState();
  final _visited = <int>{0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthState>();
      if (auth.welcome != null && mounted) {
        showToast(
          context,
          auth.welcome!,
          icon: Icons.waving_hand_rounded,
          color: Colors.amber,
        );
        auth.welcome = null;
      }
    });
  }

  @override
  void dispose() {
    _nav.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _nav,
      child: Consumer<NavState>(
        builder: (context, nav, _) {
          _visited.add(nav.index);
          Widget tab(int i, Widget Function() build) =>
              _visited.contains(i) ? build() : const SizedBox.shrink();
          return Scaffold(
            extendBody: true,
            body: EyesBackground(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IndexedStack(
                      index: nav.index,
                      children: [
                        tab(0, () => const HomeTab()),
                        tab(1, () => const ScreenerTab()),
                        tab(2, () => const AiTab()),
                        tab(3, () => const WatchlistTab()),
                        tab(4, () => const ProfileTab()),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GlassNavBar(
                      index: nav.index,
                      onTap: (i) => nav.go(i),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
