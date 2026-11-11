import 'package:flutter/foundation.dart';

import '../core/auth_repository.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._repo);

  final AuthRepository _repo;
  AppUser? _user;
  bool _ready = false;

  /// Set after a fresh sign in / sign up so the app can greet the user once.
  String? welcome;

  AppUser? get user => _user;
  bool get ready => _ready;
  bool get signedIn => _user != null;
  bool get isGuest => _user?.isGuest ?? false;
  bool get hasAccounts => _repo.hasAccounts;

  /// Scope used to keep each account's saved data separate.
  String get scope => _user == null || _user!.isGuest ? 'guest' : _user!.id;

  Future<void> restore() async {
    _user = await _repo.restore();
    _ready = true;
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _user = await _repo.signUp(name: name, email: email, password: password);
    welcome = 'Welcome to Eyes Screener, ${name.trim().split(' ').first}!';
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _user = await _repo.signIn(email: email, password: password);
    welcome = 'Welcome back, ${_user!.name.split(' ').first}!';
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    await _repo.signInAsGuest();
    _user = AppUser.guest;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> emailExists(String email) => _repo.emailExists(email);

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) => _repo.resetPassword(email: email, newPassword: newPassword);

  Future<void> updateName(String name) async {
    _user = await _repo.updateName(name);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _repo.deleteAccount();
    _user = null;
    notifyListeners();
  }
}
