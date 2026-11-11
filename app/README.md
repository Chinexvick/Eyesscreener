# Eyes Screener (Flutter app)

Native Android and iOS app for **Eyes Screener**: a BNB Chain token screener with AI-style risk
reports, alerts and a crypto academy. The app icon is the owl logo; the app name is "Eyes Screener".

## Flow

Native splash → animated splash → 3 onboarding screens → **Create account / Sign in** → app.
Guests can skip sign-up ("Continue as guest").

## Screens

- **Home**: market card, quick actions, top gainers, trending, new pairs
- **Screener**: search, 5 tabs, categories, filters, sorting, live prices
- **AI Investigator** (centre button): safety report for any name or `0x…` address
- **Watchlist**: swipe to remove, add by search
- **Profile**: theme, live updates, edit name, sign out, clear data, delete account
- **Token detail**, **Risk Radar**, **Signal Alerts**, **Crypto Academy**, **$EYES ecosystem**
- Sign in, create account (password strength), forgot password

## Run

```sh
cd app
flutter pub get
flutter run                # a connected device or emulator
flutter test               # unit and widget tests
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

CI builds an installable APK on every push to `app/**` (see `.github/workflows/flutter-android.yml`):
open the workflow run on GitHub and download the **eyes-screener-apk** artifact.

## Important notes

- **Market data and risk scores are demo data** (`lib/core/market_data.dart`, `lib/core/risk_model.dart`).
  To go live, replace `MarketData.build()` and `RiskModel.analyse()` with a real provider.
- **Accounts are stored on the device** (`LocalAuthRepository`): passwords are salted and hashed with
  iterated SHA-256 and are never saved in plain text. There is no server, so accounts do not sync
  between devices and password reset happens on the device. To use a real backend (Supabase, Firebase,
  your own API) implement `AuthRepository` in `lib/core/auth_repository.dart`.
- The APK from CI is signed with the Flutter debug key. For the Play Store, create a release keystore
  and configure signing in `android/app/build.gradle.kts`.
- Bundle id: `com.eyesscreener.eyes_screener`. Fonts (Inter, Poppins) are bundled under the SIL OFL.

## Regenerating the icon and splash

Source art is in `assets/icon/`. After changing it:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
