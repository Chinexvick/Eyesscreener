import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isGuest = false,
  });

  final String id, name, email;
  final DateTime createdAt;
  final bool isGuest;

  static final guest = AppUser(
    id: 'guest',
    name: 'Guest',
    email: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    isGuest: true,
  );

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Swap this interface for a real backend (Supabase, Firebase, your own API).
abstract class AuthRepository {
  Future<AppUser?> restore();
  bool get hasAccounts;
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signInAsGuest();
  Future<void> signOut();
  Future<bool> emailExists(String email);
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });
  Future<AppUser> updateName(String name);
  Future<void> deleteAccount();
}

/// On-device accounts. Passwords are salted and hashed (iterated SHA-256) and never stored in plain text.
/// This is for the offline demo: accounts live only on this phone.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _usersKey = 'auth.users';
  static const _sessionKey = 'auth.session';
  static const _rounds = 12000;

  Map<String, dynamic> _users() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsers(Map<String, dynamic> u) =>
      _prefs.setString(_usersKey, jsonEncode(u));

  static String _norm(String email) => email.trim().toLowerCase();

  static String _hash(String password, String salt) {
    List<int> bytes = utf8.encode('$salt:$password');
    for (var i = 0; i < _rounds; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Url.encode(bytes);
  }

  static String _salt() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  AppUser _toUser(String email, Map u) => AppUser(
    id: email,
    name: u['name'] as String,
    email: email,
    createdAt: DateTime.fromMillisecondsSinceEpoch(u['created'] as int),
  );

  @override
  bool get hasAccounts => _users().isNotEmpty;

  @override
  Future<AppUser?> restore() async {
    final s = _prefs.getString(_sessionKey);
    if (s == null) return null;
    if (s == 'guest') return AppUser.guest;
    final u = _users()[s];
    if (u == null) return null;
    return _toUser(s, u as Map);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final key = _norm(email);
    final users = _users();
    if (users.containsKey(key)) {
      throw const AuthException(
        'An account with this email already exists. Try signing in.',
      );
    }
    final salt = _salt();
    users[key] = {
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(password, salt),
      'created': DateTime.now().millisecondsSinceEpoch,
    };
    await _saveUsers(users);
    await _prefs.setString(_sessionKey, key);
    return _toUser(key, users[key] as Map);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final key = _norm(email);
    final u = _users()[key] as Map?;
    if (u == null || _hash(password, u['salt'] as String) != u['hash']) {
      throw const AuthException('Incorrect email or password.');
    }
    await _prefs.setString(_sessionKey, key);
    return _toUser(key, u);
  }

  @override
  Future<void> signInAsGuest() => _prefs.setString(_sessionKey, 'guest');

  @override
  Future<void> signOut() => _prefs.remove(_sessionKey);

  @override
  Future<bool> emailExists(String email) async =>
      _users().containsKey(_norm(email));

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final key = _norm(email);
    final users = _users();
    final u = users[key] as Map?;
    if (u == null) {
      throw const AuthException('No account found for this email.');
    }
    final salt = _salt();
    u['salt'] = salt;
    u['hash'] = _hash(newPassword, salt);
    await _saveUsers(users);
  }

  @override
  Future<AppUser> updateName(String name) async {
    final key = _prefs.getString(_sessionKey);
    final users = _users();
    final u = key == null ? null : users[key] as Map?;
    if (key == null || u == null) {
      throw const AuthException('You are not signed in.');
    }
    u['name'] = name.trim();
    await _saveUsers(users);
    return _toUser(key, u);
  }

  @override
  Future<void> deleteAccount() async {
    final key = _prefs.getString(_sessionKey);
    final users = _users();
    if (key != null) users.remove(key);
    await _saveUsers(users);
    await _prefs.remove(_sessionKey);
    final prefix = '$key.';
    for (final k
        in _prefs.getKeys().where((k) => k.startsWith(prefix)).toList()) {
      await _prefs.remove(k);
    }
  }
}

class Validators {
  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 2) return 'Enter your name';
    return null;
  }

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(s)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
      return 'Include a letter and a number';
    }
    return null;
  }

  /// 0 (empty) … 4 (strong)
  static int strength(String s) {
    var n = 0;
    if (s.length >= 8) n++;
    if (RegExp(r'[A-Z]').hasMatch(s) && RegExp(r'[a-z]').hasMatch(s)) n++;
    if (RegExp(r'\d').hasMatch(s)) n++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(s) || s.length >= 12) n++;
    return s.isEmpty ? 0 : n.clamp(1, 4);
  }
}
