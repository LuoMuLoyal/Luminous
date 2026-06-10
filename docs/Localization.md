# Flutter Localization

Last updated: 2026-06-10

This file records the localization workflow and ownership rules. It is not a catalog of every current string.

## Files

- Config: `l10n.yaml`
- ARB: `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`
- Generated output: `lib/l10n/app_localizations*.dart`

## Supported Locales

- `system`
- `zh-CN`
- `en`

Persisted preference keys:

- Locale: `app.locale`
- Theme mode: `theme.mode`
- Theme palette: `theme.palette`

## Rules

- Do not hardcode user-visible text in pages or widgets.
- Add visible text to both ARB files.
- Reminder UI strings for date windows, local sound preference, SMS unavailable state, and delivery history are owned by the Medicine feature ARB entries.
- Keep normal app pages limited to necessary titles, labels, values, statuses, and actions.
- Avoid explanatory, onboarding, or marketing-style page copy unless a task explicitly requires it.
- Remove l10n keys when the active UI that owns them is deleted.
- Deferred strings may remain only when deferred code still references them and the code is annotated.
- When an action moves to another tab, remove the old tab's action strings instead of keeping inactive labels.

## Add Or Change Text

1. Edit both ARB files.
2. Run:

```bash
flutter gen-l10n
```

3. Read strings through:

```dart
AppLocalizations.of(context)
```

4. Run at least:

```bash
flutter analyze
flutter test
```

## Locale Ownership

- `LuminousApp` reads `appLocaleControllerProvider` and passes the resolved locale into `MaterialApp.router.locale`.
- Lucent network requests reuse the same preference for `Accept-Language`.
- Signed-in language changes currently sync to Lucent profile fields through `locale / timezone / unitSystem`.
- Choosing `system` clears the backend locale preference.
- After auth restore or sign-in, `LuminousApp` may backfill the local locale from Lucent `profile.locale` when the value maps to `zh-CN`, `en`, or `system`.
