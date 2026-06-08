# Flutter i18n

Last updated: 2026-06-08

## Files

- Config: `l10n.yaml`
- ARB: `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

## Current Scope

- App title, five-tab labels, Today mobile dashboard/priority/recommendation/todo/quick-record copy and preview medication names, Record mobile date/quick-action/AI-input/timeline/filter/calendar/today-overview/quick-operation/guide copy, Record dashboard, Medicine mobile drugbox/next-dose/safety-engine/quick-operation/record/tip copy, Report mobile score/metric/trend/finding/export/privacy/pattern copy, Mine mobile account/archive/campus/notice copy, Settings privacy/reminder/export/help/about copy, Medicine workspace/search empty states, and bounded placeholders
- Login / Register / Forgot Password / Change Email / AuthShell
- WeChat Web OAuth login action, callback input, and OAuth feedback toasts
- Account Settings, account status, linked identity management labels, and WeChat identity binding feedback
- Standalone Settings page
- Settings child pages, persisted theme mode / palette selection, and persisted app locale selection
- Signed-in settings locale sync to Lucent profile preferences
- Settings notification permission status labels
- Auth empty-field toast prompts and the shared auth-required dialog prompt
- Mine signed-out notice / guest state copy
- Mine signed-in account detail labels and account management action
- Record quick-create/detail form labels, common type form labels for water/vital/symptom/note, detail page labels, and save/delete failure toast
- Medicine manual dose-log actions, saved/failed toasts, taken/skipped/pending status labels, missing dose/schedule/inventory placeholders, no-pending-dose labels, and mobile safety placeholder action toasts
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
- Persisted theme mode preference key: `theme.mode`
- Persisted theme palette preference key: `theme.palette`
- Supported in settings flow: `system`, `zh-CN`, `en`
- `LuminousApp` reads `appLocaleControllerProvider` and passes the resolved locale into `MaterialApp.router.locale`.
- Lucent network requests reuse the same preference for `Accept-Language`.
- When signed in, settings preference sync currently writes the supported Lucent profile fields `locale / timezone / unitSystem`; language changes use that same path, and choosing `system` clears the backend locale preference.
- After auth restore or sign-in, `LuminousApp` best-effort backfills the local app locale from Lucent `profile.locale` when the backend value maps cleanly to the supported `zh-CN / en / system` set.

Do not hardcode user-visible text in pages.
