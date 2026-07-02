# Flutter Localization

Last updated: 2026-07-02

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

## Rules

- Do not hardcode user-visible text in pages or widgets.
- Add visible text to both ARB files.
- Assistant strings use `assistant*` ARB keys directly. Do not reintroduce compatibility alias layers for assistant l10n.
- Report AI summary state copy such as generate/loading/error/disabled hints is owned by the Report ARB entries, not by repository/domain fallback strings.
- Record natural-language intake strings such as bottom-sheet title, parse/save actions, candidate counts, selection hints, partial-save toasts, candidate failure hints, and per-kind candidate editor labels are owned by the Record ARB entries.
- Record fast-entry quick-choice labels plus date/time field labels are owned by the Record ARB entries.
- Record voice/OCR intake copy such as sheet titles, action labels, microphone-permission wording, and OCR failure toasts is owned by the Record ARB entries.
- Record meal-analysis strings such as status/coverage labels, summary section titles, estimate disclaimer, dish-editor helper text, and confirm-result action are owned by the Record ARB entries.
- Reminder UI strings for date windows, local sound preference, SMS unavailable state, delivery history, and on-device notification title/body/channel labels are owned by the Medicine feature ARB entries.
- Medicine add-before-save risk precheck strings such as confirmation sheet title, warning description, confirm action, and failure toast are owned by the Medicine/Search ARB entries.
- Sleep structured-record strings such as bedtime/wake-time labels, duration, quality, and sleep-stage labels are owned by the Record feature ARB entries.
- Mine no longer owns any campus-service strings; support-resource copy is limited to settings help/about surfaces plus backend-provided titles when present.
- Theme settings are mode-only right now. Do not add palette-specific ARB keys unless the product explicitly reintroduces multi-palette theming.
- Assistant tool inventory strings are owned by the Assistant ARB entries, including medicine retrieval tools such as leaflet search, DrugBank entity resolution, DrugBank passage search, and medical-QA search.
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
