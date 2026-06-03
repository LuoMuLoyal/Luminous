# Luminous UI Plan

Last updated: 2026-06-03

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
- Mine signed-out state now stays on the same static dashboard structure with a login notice instead of page-level skeleton loading
- Standalone Settings page at `/settings` now owns theme/language/notification/account-entry settings, while Mine stays focused on dashboard content and entry actions
- Settings language, notifications, and more entries now each open a standard child page with persisted local preferences or utility actions instead of placeholder callbacks
- Notification settings now also reflect real system notification permission state; supported Lucent profile preferences (`locale / timezone / unitSystem`) can sync through settings, and the app locale can now also backfill from Lucent on auth restore/sign-in, while theme and notification toggles still remain local/device-side until Lucent exposes dedicated preference-write endpoints for them
- More concept-aligned mock utility workspace UI with repository/provider boundary, mobile emergency/family/tools stack, and desktop reminder/recent/quick-entry side rail
- Medicine mobile-first mock workspace UI with repository/provider boundary
- Standalone Search feature at `/medicine/search` with source-aware medicine mock data, mobile workflow, and desktop preview panel
- Lucent-backed health-context write flows for Mine profile, allergies, conditions, and current medicines, with domain write inputs keeping generated OpenAPI DTOs out of presentation code
- Search add-to-current-medicines now writes through Lucent for signed-in users and routes signed-out users to `/login`
- Medicine and Today now consume the safe current-medicine subset from health context

Restored: Search now uses real Lucent medicine search/detail API; Mine health-context edit flows write to Lucent; Medicine and Today read the safe current-medicine subset. Still pending: real daily records, manual medicine adherence logs, live reminders, real scan/upload, More real tools/device integrations, and broader feature data.

## UI Priority

1. Harden Mine health-context edit flows with edit-prefill, validation, and route tests.
2. Add Lucent-backed daily records and connect the Record tab timeline/edit flows.
3. Connect Today to factual daily-record summaries while keeping unsupported advice/static sections clear.
4. Add manual medicine adherence logs and connect Medicine/Today status actions.
5. Connect More mock repository to real emergency, device, tool, and environment data sources after the Record/Medicine loop is stable.
6. Add palette variants after the fixed-token surfaces have been reduced.

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
