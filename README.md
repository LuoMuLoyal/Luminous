# Luminous

Flutter personal health copilot. Current mainline is the reset five-tab shell backed by Lucent.

## Baseline

- Tabs: `today / record / medicine / mine / more`
- Design tokens: color / type / spacing / radius / shadow / breakpoints
- API client: `packages/lucent_openapi`
- Network layer: `lib/core/network/`
- i18n: Flutter `gen-l10n`

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
