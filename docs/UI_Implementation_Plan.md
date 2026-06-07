# Luminous UI Plan

Last updated: 2026-06-07

Current timeline: `MigrationLog.md`. Product stage: `../Lucent/docs/public/ROADMAP.md`.

## Baseline

- Five-tab shell: `today / record / medicine / mine / more`
- Responsive design tokens
- Lucent OpenAPI client
- Flutter `gen-l10n`
- Auth datasource / session / login / register providers
- Login / Register pages
- Persisted `system / light / dark` theme preference and `default / blue-pink / yellow-green` palette preference with a standard `/settings/theme` child page
- Mobile bottom nav + desktop rail
- Today mobile north-star dashboard UI with repository/provider boundary, backend-backed current-medicine / water / vital / mood / dose-log summaries where available, bounded mock sections for unsupported concepts, lightweight placeholders for complex graphics, reusable Today primitives, and shared state views
- Record mobile north-star dashboard UI with repository/provider boundary, search/filter header, selected-date pill, six quick-record actions, timeline, symptom/mood/period/diet/specialist placeholders, desktop calendar/filter + timeline + trends workspace, Lucent-backed daily-record timeline/detail, real selected-date navigation, occurredAt-based timeline time, and quick-create flow
- Mine concept-aligned mock dashboard UI with repository/provider boundary, mobile profile/plans/privacy surface, and desktop status/onboarding/settings side rail
- Mine signed-out state now stays on the same static dashboard structure with a login notice instead of page-level skeleton loading
- Standalone Settings page at `/settings` now owns theme/language/notification/account-entry settings, while Mine stays focused on dashboard content and entry actions
- Settings theme, language, notifications, and more entries now each open a standard child page with persisted local preferences or utility actions instead of placeholder callbacks
- Page-level surfaces should use `AppShadowTokens.level1`; reserve higher shadow levels for floating feedback, modal-like panels, or authentication surfaces that need stronger separation.
- Loading states should preserve static page chrome and known local/mock content; use shimmer only inside the specific sections that wait on backend-backed data, not as full-page replacement screens.
- Notification settings now also reflect real system notification permission state; supported Lucent profile preferences (`locale / timezone / unitSystem`) can sync through settings, and the app locale can now also backfill from Lucent on auth restore/sign-in, while theme and notification toggles still remain local/device-side until Lucent exposes dedicated preference-write endpoints for them
- Reminder/notification contract defined in `../Lucent/docs/public/reminder-contract.md`: local notification permission + preference toggles are device-local; backend-owned reminder schedules, notification preferences, and delivery log are planned but not implemented; no FCM/APNs push delivery in scope
- Environment snapshot contract defined in `../Lucent/docs/public/environment-contract.md`: pollen / UV / air quality / temperature API; static seasonal reference data as initial implementation, no external API keys required
- More concept-aligned mock utility workspace UI with repository/provider boundary, mobile emergency/family/tools stack, and desktop reminder/recent/quick-entry side rail
- Medicine mobile north-star dashboard UI with repository/provider boundary, mobile header/search, drugbox, next-dose reminder, safety engine placeholders, quick operations, medication records, reference notice, safety tips, Lucent-backed current-medicine/manual dose-log data where available, and bounded mock content for unsupported scan/OCR/report/safety concepts
- Standalone Search feature at `/medicine/search` with source-aware medicine mock data, mobile workflow, and desktop preview panel
- Lucent-backed health-context write flows for Mine profile, allergies, conditions, and current medicines, with domain write inputs keeping generated OpenAPI DTOs out of presentation code
- Search add-to-current-medicines now writes through Lucent for signed-in users and routes signed-out users to `/login`
- Medicine and Today now consume the safe current-medicine subset from health context
- Today now consumes Lucent daily-record water/vital/mood summaries while unsupported recommendation, trend, period, campus-guide, and quick-action sections remain mock/placeholder-backed
- Medicine now reads and writes manual dose-log status for current medicines, including taken/skipped/pending; this is not push reminder scheduling

Restored: Search now uses real Lucent medicine search/detail API; Mine health-context edit flows write to Lucent; Record daily-record timeline/create uses Lucent; Medicine reads current medicines plus manual taken/skipped dose-log status; Today reads safe current-medicine, daily-record water/vital summaries, and manual dose-log pending counts. Still pending: live reminders (contract defined in `../Lucent/docs/public/reminder-contract.md` but not implemented), Medicine real scan/OCR/report/safety-engine backend data, More real tools/device integrations, richer record analytics, and broader feature data.

## UI Priority

1. Keep the daily-record and manual dose-log flows under regression as they expand; current auth, ownership, selected-date reload, occurredAt timeline time, null clearing, skipped/taken status, and provider invalidation coverage exists.
2. Expand Record forms before starting deferred More wiring; only add fields when Lucent contracts exist for the specific record type.
3. Keep Today factual: daily-record and dose-log summaries may be real, but unsupported advice/static sections must stay clearly bounded and use placeholders instead of hand-drawn complex graphics.
4. Connect More mock repository to real emergency, device, tool, and environment data sources after their Lucent contracts exist.
5. Expand palette variants only after default / blue-pink / yellow-green prove stable across the main settings, mine, today, medicine, and record surfaces.

## Rules

- Use `lib/core/design/`, `lib/core/theme/`, `lib/core/constants/app_breakpoints.dart`.
- Keep mobile feature widgets free of user-visible hardcoded copy and raw visual constants; use ARB/l10n for visible text and existing design tokens before adding feature-local constants.
- Read app theme mode from `appThemeControllerProvider`; do not hardcode `ThemeMode.system` in app entrypoints.
- Use `Theme.of(context).colorScheme` and `AppThemeSurface` for theme-aware surfaces before adding palette variants.
- Put protocol logic in `lib/core/network/`, not `utils`.
- Put user-visible text in ARB files.
- Do not revive old `home / drug / scan / settings` pages wholesale.

## Verify

```bash
flutter analyze
flutter test
flutter test integration_test
```

For the current north-star UI work, mobile is the target surface; check mobile overflow and zh/en text fit first. Desktop/web visual behavior is not a current implementation target.
