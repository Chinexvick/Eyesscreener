import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import 'kit.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon, activeIcon;
  final String label;
}

/// Floating glass bar with a raised centre action (AI Investigator).
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const items = [
    NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItem(
      Icons.candlestick_chart_outlined,
      Icons.candlestick_chart_rounded,
      'Screener',
    ),
    NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'AI'),
    NavItem(Icons.star_outline_rounded, Icons.star_rounded, 'Watchlist'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottom > 0 ? bottom * 0.55 + 8 : 14,
      ),
      child: SizedBox(
        height: 84,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: p.isDark ? 0.55 : 0.14,
                    ),
                    blurRadius: 34,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Glass(
                radius: 34,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final slot = c.maxWidth / 5;
                    return Stack(
                      children: [
                        // Sliding spotlight behind the active tab
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          left: slot * index + slot * 0.1,
                          top: 9,
                          width: slot * 0.8,
                          height: 50,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: index == 2 ? 0 : 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Brand.yellow.withValues(
                                  alpha: p.isDark ? 0.14 : 0.2,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < 5; i++)
                              Expanded(
                                child: i == 2
                                    ? const SizedBox()
                                    : _Slot(
                                        item: items[i],
                                        selected: i == index,
                                        onTap: () => _tap(i),
                                      ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Centre action
            Positioned(
              top: 0,
              child: Tap(
                onTap: () => _tap(2),
                scale: 0.92,
                child: AnimatedScale(
                  scale: index == 2 ? 1.06 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE066),
                          Brand.yellow,
                          Color(0xFFE8A800),
                        ],
                      ),
                      border: Border.all(color: p.bg, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Brand.yellow.withValues(
                            alpha: index == 2 ? 0.6 : 0.38,
                          ),
                          blurRadius: index == 2 ? 30 : 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 28,
                      color: Brand.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tap(int i) {
    HapticFeedback.selectionClick();
    onTap(i);
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = selected
        ? (p.isDark ? Brand.yellow : const Color(0xFF8A6200))
        : p.faint;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: 24,
                color: c,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: inter(10.5, w: selected ? 700 : 500, color: c),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
