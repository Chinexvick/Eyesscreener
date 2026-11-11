import 'package:eyes_screener/core/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalAuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = LocalAuthRepository(await SharedPreferences.getInstance());
  });

  test('sign up creates a session and normalises the email', () async {
    final u = await repo.signUp(
      name: 'Alex Morgan',
      email: ' Alex@Example.com ',
      password: 'Secret123',
    );
    expect(u.email, 'alex@example.com');
    expect(u.initials, 'AM');
    expect((await repo.restore())?.email, 'alex@example.com');
    expect(repo.hasAccounts, isTrue);
  });

  test('duplicate email is rejected', () async {
    await repo.signUp(name: 'Alex', email: 'a@b.co', password: 'Secret123');
    expect(
      () => repo.signUp(name: 'Other', email: 'A@B.co', password: 'Another123'),
      throwsA(isA<AuthException>()),
    );
  });

  test(
    'sign in checks the password and the password is not stored in plain text',
    () async {
      await repo.signUp(name: 'Alex', email: 'a@b.co', password: 'Secret123');
      await repo.signOut();
      expect(await repo.restore(), isNull);
      expect(
        () => repo.signIn(email: 'a@b.co', password: 'nope'),
        throwsA(isA<AuthException>()),
      );
      final u = await repo.signIn(email: 'A@B.CO', password: 'Secret123');
      expect(u.name, 'Alex');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth.users'), isNot(contains('Secret123')));
    },
  );

  test('reset password replaces the old one', () async {
    await repo.signUp(name: 'Alex', email: 'a@b.co', password: 'Secret123');
    await repo.signOut();
    expect(await repo.emailExists('a@b.co'), isTrue);
    expect(await repo.emailExists('x@y.co'), isFalse);
    await repo.resetPassword(email: 'a@b.co', newPassword: 'Brandnew456');
    expect(
      () => repo.signIn(email: 'a@b.co', password: 'Secret123'),
      throwsA(isA<AuthException>()),
    );
    expect(
      (await repo.signIn(email: 'a@b.co', password: 'Brandnew456')).email,
      'a@b.co',
    );
  });

  test('guest session, rename and delete account', () async {
    await repo.signInAsGuest();
    expect((await repo.restore())?.isGuest, isTrue);
    await repo.signUp(name: 'Alex', email: 'a@b.co', password: 'Secret123');
    expect((await repo.updateName('Alexander')).name, 'Alexander');
    await repo.deleteAccount();
    expect(await repo.restore(), isNull);
    expect(repo.hasAccounts, isFalse);
  });

  test('validators', () {
    expect(Validators.email('nope'), isNotNull);
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.password('short1'), isNotNull);
    expect(Validators.password('onlyletters'), isNotNull);
    expect(Validators.password('Secret123'), isNull);
    expect(Validators.name('A'), isNotNull);
    expect(Validators.strength(''), 0);
    expect(
      Validators.strength('abc12345'),
      lessThan(Validators.strength('Abc12345!xyz')),
    );
  });
}
