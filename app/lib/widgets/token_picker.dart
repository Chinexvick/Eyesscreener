import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../state/market_state.dart';
import 'kit.dart';

/// Bottom sheet with search to pick a token.
Future<Token?> pickToken(
  BuildContext context, {
  String title = 'Choose a token',
}) {
  return showModalBottomSheet<Token>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _Picker(title: title),
  );
}

class _Picker extends StatefulWidget {
  const _Picker({required this.title});
  final String title;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final all = context.read<MarketState>().tokens;
    final q = _q.text.trim().toLowerCase();
    final list =
        (q.isEmpty
                ? all.take(40)
                : all.where(
                    (t) =>
                        t.name.toLowerCase().contains(q) ||
                        t.symbol.toLowerCase().contains(q),
                  ))
            .take(60)
            .toList();
    final h = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: h * 0.78,
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: p.line),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: p.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: display(21))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: TextField(
                  controller: _q,
                  autofocus: false,
                  onChanged: (_) => setState(() {}),
                  style: inter(15, w: 500),
                  cursorColor: Brand.yellow,
                  decoration: InputDecoration(
                    hintText: 'Search tokens',
                    hintStyle: inter(14.5, color: p.faint),
                    prefixIcon: Icon(Icons.search_rounded, color: p.faint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches',
                      text: 'Try another name or symbol.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final t = list[i];
                        return Tap(
                          onTap: () => Navigator.pop(context, t),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                TokenAvatar(t, size: 40),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: inter(14.5, w: 650),
                                      ),
                                      Text(
                                        t.symbol,
                                        style: inter(12.5, color: p.faint),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Fmt.price(t.price),
                                      style: inter(13.5, w: 650),
                                    ),
                                    Change(t.change, size: 12.5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
