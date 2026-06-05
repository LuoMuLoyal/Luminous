# Flutter i18n

Last updated: 2026-06-05

## Files

- Config: `l10n.yaml`
- ARB: `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

## Current Scope

- App title, tabs, Today dashboard/image placeholders, Record dashboard, Medicine workspace/search, Mine dashboard, More dashboard, placeholders
- Login / Register / Forgot Password / Change Email / AuthShell
- WeChat Web OAuth login action, callback input, and OAuth feedback toasts
- Account Settings
- Standalone Settings page
- Settings child pages and persisted app locale selection
- Signed-in settings locale sync to Lucent profile preferences
- Settings notification permission status labels
- Auth empty-field toast prompts
- Mine signed-out notice / guest state copy
- Mine signed-in account detail labels and account management action
- Record quick-create form labels and save failure toast
- Medicine manual dose-log actions, saved/failed toasts, and taken/skipped/pending status labels
- Network `Accept-Language`
- Flutter UI locale driven by persisted app locale preference

## UI Copy Rules

- Normal app pages should keep only necessary titles, labels, values, statuses, and actions.
- Avoid explanatory, narrative, onboarding, or marketing-style copy unless a task explicitly needs it.

## Add Text

1. Add keys to both ARB files.
2. Run `flutter gen-l10n`.
3. Read via `AppLocalizations.of(context)`.

## Locale Source

- Persisted locale preference key: `app.locale`
- Supported in settings flow: `system`, `zh-CN`, `en`
- `LuminousApp` reads `appLocaleControllerProvider` and passes the resolved locale into `MaterialApp.router.locale`.
- Lucent network requests reuse the same preference for `Accept-Language`.
- When signed in, settings preference sync currently writes the supported Lucent profile fields `locale / timezone / unitSystem`; language changes use that same path, and choosing `system` clears the backend locale preference.
- After auth restore or sign-in, `LuminousApp` best-effort backfills the local app locale from Lucent `profile.locale` when the backend value maps cleanly to the supported `zh-CN / en / system` set.

Do not hardcode user-visible text in pages.
