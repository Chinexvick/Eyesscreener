import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../state/auth_state.dart';
import '../../widgets/kit.dart';
import '../academy_screen.dart';
import '../alerts_screen.dart';
import '../eyes_screen.dart';
import '../risk_radar_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final auth = context.watch<AuthState>();
    final app = context.watch<AppState>();
    final user = auth.user;
    final guest = user == null || user.isGuest;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          const PageTitle('Profile'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF14391C), Color(0xFF0B1F10)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: guest ? null : Brand.yellowGradient,
                          color: guest ? Colors.white10 : null,
                        ),
                        child: guest
                            ? const Logo(size: 46)
                            : Text(
                                user.initials,
                                style: display(24, color: Brand.ink),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guest ? 'Guest' : user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: display(21, color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              guest
                                  ? 'Create an account to keep your data safe'
                                  : user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: inter(13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (guest)
                    PrimaryButton(
                      label: 'Create free account',
                      icon: Icons.person_add_alt_1_rounded,
                      height: 50,
                      onTap: () => context.read<AuthState>().signOut(),
                    )
                  else
                    Row(
                      children: [
                        _num('${app.watchlist.length}', 'Watching'),
                        _num(
                          '${app.alerts.where((a) => a.on).length}',
                          'Alerts',
                        ),
                        _num('${app.lessonsDone.length}', 'Lessons'),
                      ],
                    ),
                ],
              ),
            ),
          ),
          _group(context, 'Tools', [
            _Row(
              Icons.radar_rounded,
              'Risk Radar',
              'Scan tokens for red flags',
              () => openPage(context, const RiskRadarScreen()),
            ),
            _Row(
              Icons.notifications_active_rounded,
              'Signal Alerts',
              '${app.alerts.where((a) => a.on).length} active',
              () => openPage(context, const AlertsScreen()),
            ),
            _Row(
              Icons.school_rounded,
              'Crypto Academy',
              '${app.lessonsDone.length} of 12 lessons done',
              () => openPage(context, const AcademyScreen()),
            ),
            _Row(
              Icons.rocket_launch_rounded,
              r'$EYES Ecosystem',
              'Perks and roadmap',
              () => openPage(context, const EyesScreen()),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'Preferences',
                    style: inter(13, w: 700, color: p.faint, spacing: 0.4),
                  ),
                ),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _iconBox(Icons.dark_mode_rounded),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text('Appearance', style: inter(15, w: 650)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: p.card2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            for (final (m, l) in [
                              (ThemeMode.system, 'System'),
                              (ThemeMode.light, 'Light'),
                              (ThemeMode.dark, 'Dark'),
                            ])
                              Expanded(
                                child: Tap(
                                  onTap: () => app.setThemeMode(m),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: app.themeMode == m
                                          ? Brand.yellowGradient
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      l,
                                      style: inter(
                                        13.5,
                                        w: 700,
                                        color: app.themeMode == m
                                            ? Brand.ink
                                            : p.dim,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: p.line),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _iconBox(Icons.bolt_rounded),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live price updates',
                                  style: inter(15, w: 650),
                                ),
                                Text(
                                  'Animate prices every few seconds',
                                  style: inter(12.5, color: p.faint),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: app.live,
                            onChanged: app.setLive,
                            activeThumbColor: Brand.ink,
                            activeTrackColor: Brand.yellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _group(context, 'Account', [
            if (!guest)
              _Row(
                Icons.edit_rounded,
                'Edit name',
                user.name,
                () => _editName(context),
              ),
            if (!guest)
              _Row(
                Icons.logout_rounded,
                'Sign out',
                user.email,
                () => _confirmSignOut(context),
              ),
            if (guest)
              _Row(
                Icons.login_rounded,
                'Sign in or create account',
                'Keep your data across devices',
                () => context.read<AuthState>().signOut(),
              ),
            _Row(
              Icons.cleaning_services_rounded,
              'Clear saved data',
              'Watchlist, alerts and lesson progress',
              () => _confirmClear(context),
            ),
            if (!guest)
              _Row(
                Icons.delete_forever_rounded,
                'Delete account',
                'Removes your account from this device',
                () => _confirmDelete(context),
                danger: true,
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
            child: Column(
              children: [
                const Logo(size: 40),
                const SizedBox(height: 10),
                const Wordmark(size: 16),
                const SizedBox(height: 6),
                Text('Version 1.0.0', style: inter(12, color: p.faint)),
                const SizedBox(height: 12),
                Text(
                  'Eyes Screener shows demo data and is not financial advice. Crypto is volatile and many new tokens are scams. Always do your own research.',
                  textAlign: TextAlign.center,
                  style: inter(12, color: p.faint, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _num(String v, String l) => Expanded(
    child: Column(
      children: [
        Text(v, style: display(22, color: Colors.white)),
        const SizedBox(height: 3),
        Text(l, style: inter(12, color: Colors.white70)),
      ],
    ),
  );

  static Widget _iconBox(IconData i) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: Brand.yellow.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(i, size: 21, color: Brand.yellow),
  );

  Widget _group(BuildContext context, String title, List<_Row> rows) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: inter(13, w: 700, color: p.faint, spacing: 0.4),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i < rows.length - 1) Divider(height: 1, color: p.line),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final auth = context.read<AuthState>();
    final ctrl = TextEditingController(text: auth.user?.name);
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final p = ctx.pal;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
            decoration: BoxDecoration(
              color: p.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(color: p.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Edit name', style: display(22)),
                const SizedBox(height: 18),
                AppField(
                  label: 'Full name',
                  controller: ctrl,
                  icon: Icons.person_outline_rounded,
                  action: TextInputAction.done,
                  onSubmitted: (v) => Navigator.pop(ctx, v),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Save',
                  onTap: () => Navigator.pop(ctx, ctrl.text),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (name != null && name.trim().length >= 2 && context.mounted) {
      await auth.updateName(name);
      if (context.mounted) showToast(context, 'Name updated');
    }
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String text,
    String action, {
    bool danger = false,
  }) async {
    final p = context.pal;
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: p.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: display(20)),
              const SizedBox(height: 10),
              Text(text, style: inter(14.5, color: p.dim, height: 1.5)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GhostButton(
                      label: 'Cancel',
                      height: 48,
                      onTap: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: danger
                        ? _DangerButton(
                            label: action,
                            onTap: () => Navigator.pop(ctx, true),
                          )
                        : PrimaryButton(
                            label: action,
                            height: 48,
                            onTap: () => Navigator.pop(ctx, true),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return r ?? false;
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    if (await _confirm(
          context,
          'Sign out?',
          'You can sign back in any time. Your saved data stays on this device.',
          'Sign out',
        ) &&
        context.mounted) {
      await context.read<AuthState>().signOut();
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    if (await _confirm(
          context,
          'Clear saved data?',
          'This removes your watchlist, alerts and lesson progress.',
          'Clear',
          danger: true,
        ) &&
        context.mounted) {
      await context.read<AppState>().clearSavedData();
      if (context.mounted) showToast(context, 'Saved data cleared');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (await _confirm(
          context,
          'Delete account?',
          'Your account and everything saved with it will be removed from this device. This cannot be undone.',
          'Delete',
          danger: true,
        ) &&
        context.mounted) {
      await context.read<AuthState>().deleteAccount();
    }
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tap(
    onTap: onTap,
    child: Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Brand.red,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: inter(15, w: 700, color: Colors.white)),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(
    this.icon,
    this.title,
    this.sub,
    this.onTap, {
    this.danger = false,
  });
  final IconData icon;
  final String title, sub;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = danger ? Brand.red : Brand.yellow;
    return Tap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 21, color: c),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: inter(
                      15,
                      w: 650,
                      color: danger ? Brand.red : p.text,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: inter(12.5, color: p.faint),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.faint),
          ],
        ),
      ),
    );
  }
}
