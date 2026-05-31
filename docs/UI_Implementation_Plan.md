# Luminous UI Plan

Last updated: 2026-05-31

Current timeline: `MigrationLog.md`. Product stage: `../Lucent/docs/public/ROADMAP.md`.

## Baseline

- Five-tab shell: `today / record / medicine / mine / more`
- Responsive design tokens
- Lucent OpenAPI client
- Flutter `gen-l10n`
- Auth datasource / session / login / register providers
- Login / Register pages
- Persisted `system / light / dark` theme preference foundation
- Mobile bottom nav + desktop rail
- Today concept-aligned mock dashboard UI with repository/provider boundary, mobile feed, desktop wide dashboard, plainer medicine-style surfaces, localized image placeholders, reusable Today primitives, and shared state views
- Record concept-aligned mock dashboard UI with repository/provider boundary, mobile feed, desktop calendar/filter + timeline + trends workspace, shared image placeholders, and toast-only mock actions
- Mine concept-aligned mock dashboard UI with repository/provider boundary, mobile profile/plans/privacy surface, and desktop status/onboarding/settings side rail
- Medicine mobile-first mock workspace UI with repository/provider boundary
- Standalone Search feature at `/medicine/search` with source-aware medicine mock data, mobile workflow, and desktop preview panel

Not restored yet: real medicine loop, live reminders, real scan/upload, real medicine API wiring, Mine write/edit flows, theme selection persistence UI, real feature data.

## UI Priority

1. Connect Today mock data to API-ready datasource/repository implementations.
2. Upgrade `more` from placeholder to usable skeleton.
3. Replace medicine mock data with Lucent-backed search, recognition, detail, add-to-drugbox, and reminder flows.
4. Connect Mine mock repository to Lucent account/profile/health-context reads and add a Mine/settings theme selector for `system / light / dark`.
5. Add palette variants after the fixed-token surfaces have been reduced.

## Rules

- Use `lib/core/design/`, `lib/core/theme/`, `lib/core/constants/app_breakpoints.dart`.
- Read app theme mode from `appThemeControllerProvider`; do not hardcode `ThemeMode.system` in app entrypoints.
- Use `Theme.of(context).colorScheme` and `AppThemeSurface` for theme-aware surfaces before adding palette variants.
- Put protocol logic in `lib/core/network/`, not `utils`.
- Put user-visible text in ARB files.
- Do not revive old `home / drug / scan / settings` pages wholesale.

## Verify

```bash
flutter analyze
flutter test
```

For responsive UI, also check mobile overflow, desktop spacing, and zh/en text fit.
