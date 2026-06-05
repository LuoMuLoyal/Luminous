# Luminous

Flutter personal health copilot. Current mainline is the reset five-tab shell backed by Lucent.

## Baseline

- Tabs: `today / record / medicine / mine / more`
- Design tokens: color / type / spacing / radius / shadow / breakpoints
- API client: `packages/lucent_openapi`
- Network layer: `lib/core/network/`
- i18n: Flutter `gen-l10n`
- WeChat OAuth: Android/iOS uses the WeChat SDK through `fluwx` to obtain an auth code and then calls Lucent's mobile callback endpoint. Desktop login starts a loopback callback listener, asks Lucent for an authorize URL with that callback URI, opens the system browser, verifies the returned `state`, and completes login automatically when Lucent redirects back with `code` and `state`. Web login passes `/login/oauth/wechat` as the callback path. Manual callback paste remains as a fallback.

Mobile WeChat SDK builds need:

- Dart define `WECHAT_MOBILE_APP_ID=<wx app id>`
- iOS Dart define `WECHAT_IOS_UNIVERSAL_LINK=<universal link>` when applicable
- iOS native URL Scheme build setting: copy `ios/Flutter/Wechat.example.xcconfig` to `ios/Flutter/Wechat.xcconfig` and set the same `WECHAT_MOBILE_APP_ID`
- Matching Android signature/package and iOS URL Scheme/Universal Link setup in the WeChat Open Platform console and native projects. iOS Universal Link still requires real Associated Domains configuration in the Apple developer account and release signing setup.

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
dart run tool/regenerate_lucent_openapi.dart
```

## CI

- GitHub Actions workflow: `.github/workflows/flutter-ci.yml`
- Current CI scope: `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`
- Current CI is validation-only. It does not build or publish Android, iOS, desktop, or web artifacts.

## Docs

Start with [docs/README.md](docs/README.md).

Key shared docs live in `../Lucent/docs/public/`:

- [ROADMAP](../Lucent/docs/public/ROADMAP.md)
- [api-contract](../Lucent/docs/public/api-contract.md)
- [design-system](../Lucent/docs/public/design-system.md)

Key frontend docs:

- [docs/MigrationLog.md](docs/MigrationLog.md)
- [docs/OpenApi_Client.md](docs/OpenApi_Client.md)
- [docs/Localization.md](docs/Localization.md)
- [docs/UI_Implementation_Plan.md](docs/UI_Implementation_Plan.md)
