# Flutter i18n

Last updated: 2026-05-31-15:05

## Files

- Config: `l10n.yaml`
- ARB: `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

## Current Scope

- App title, tabs, Today dashboard/image placeholders, Record dashboard, Medicine workspace/search, Mine dashboard, More dashboard, placeholders
- Login / Register / Forgot Password / Change Email / AuthShell
- Account Settings
- Standalone Settings page
- Auth empty-field toast prompts
- Mine signed-out notice / guest state copy
- Network `Accept-Language`

## UI Copy Rules

- Normal app pages should keep only necessary titles, labels, values, statuses, and actions.
- Avoid explanatory, narrative, onboarding, or marketing-style copy unless a task explicitly needs it.

## Add Text

1. Add keys to both ARB files.
2. Run `flutter gen-l10n`.
3. Read via `AppLocalizations.of(context)`.

Do not hardcode user-visible text in pages.
