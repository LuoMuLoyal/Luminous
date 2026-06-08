# Lumos Current State

Last updated: 2026-06-08

## Product Direction

- Competition north star: Luminous is an AI health management and medication safety companion for college students and young adults in China.
- Core loop: record -> understand -> remind -> self-intervene -> connect services.
- Primary differentiator: Chinese medication safety as the trust base, connected with common young-adult scenarios such as symptoms, mood, sleep, diet, hydration, period, and campus service guidance.
- Terminal strategy: mobile app is the MVP surface; web is optional for reports and competition display; desktop app is out of MVP scope.
- Product north star reference: `docs/Product_North_Star.md`.

## Runtime Split

- `Lucent` is the active NestJS backend.
- `Luminous` is the active Flutter client.
- `Luminous/backend` is legacy reference only.
- Workspace root `D:\25080\Documents\VSCodeProject\Lumos` is not a git repository; `Lucent` and `Luminous` are separate git repositories.

## Lucent

- Stack: NestJS 11, Prisma 7, PostgreSQL, Redis, JWT auth, AdminJS.
- API base: `/api/v1`.
- Envelope: `{ code, message, data }`.
- Generated API contract: `Lucent/docs/openapi.json`.
- Current OpenAPI export after Environment Snapshot: 36 paths / 100 schemas.
- Daily records support CRUD, detail by id, attachment metadata, and Tencent COS image upload signing.
- Environment snapshot static reference API is implemented at `GET /api/v1/environment/snapshot`.
- Object storage provider is intentionally only Tencent COS for now.
- CI/CD deploys the app image as `latest`; there is no automatic rollback to a `sha-<commit>` image tag.

## Luminous

- Flutter five-tab shell: `today / record / medicine / report / mine`.
- State/navigation: Riverpod + GoRouter.
- Generated Lucent client: `packages/lucent_openapi`.
- Current generated client includes `DailyRecordsApi.dailyRecordsControllerCreateImageUploadV1` and generated `EnvironmentApi`.
- Real Lucent-backed flows: auth/account, health-context edits, medicine search/detail, current medicines, manual dose logs, daily-record timeline/detail/create/edit/delete, selected-date timeline reload, occurredAt-based timeline time, daily-record single-image attachment upload/display, Record mobile quick actions for Lucent-supported daily-record kinds, and first-pass type-specific daily-record create/edit fields for water, vital, symptom, and note.
- Auth/session state is explicitly split into restoring, confirmed signed-out, and signed-in protected-data access. Protected providers do not call Lucent while auth is restoring or signed out; confirmed signed-out main tabs use local/mock static surfaces, while signed-in tabs and edit flows use protected repositories.
- Mobile north-star UI is active for Today, Record, Medicine, Report, and Mine. These five main tabs share partial skeleton loading: stable page chrome plus local/mock/static sections render immediately, while backend-backed fields render shimmer slots through the shared skeleton primitives. Today now uses compact priority cards and a UI-only Today todo list for system-created medication/hydration tasks plus user-created mood/custom tasks; the previous Today trend-card section is no longer active. Record keeps real daily-record timeline/detail data and now focuses on record-page jobs: quick record, AI input placeholder, health record timeline, filters, calendar/today overview, quick operations, and a guide row. Record mobile logic v1 wires supported quick actions to `/record/create` with selected kind/date, date chips to selected-date state, and filter chips to dashboard filtering; unsupported domains such as medication, sleep, and women-health remain placeholders or separate-domain boundaries until matching APIs exist. The old mobile-only symptom tracking, mood trend, period/diet, and specialist pack sections were removed from Record; period/women-health entry is shown only when health context marks `sexAtBirth == female`, while signed-out, male, or unknown profiles use non-period record actions. Medicine keeps real current-medicine and manual dose-log data where available while safety engine, scan/OCR, report, reference notice, and safety tips are bounded mock/placeholder sections. Report uses a feature-local mock repository for weekly score, trends, findings, exports, privacy controls, and pattern analysis until Lucent exposes report/insight APIs. Mine reads real auth/account plus health-context profile/allergy/condition/current-medicine data while campus services, privacy permissions, reminders, and secondary settings remain bounded mock entries.
- Medicine mobile UI now uses a lighter reference-aligned drugbox: the drugbox and next-dose reminder are merged into one section, alert/status colors are low-alpha, and safety-engine alerts plus medicine records avoid nested inner cards in favor of compact rows and dividers.
- Environment snapshot is backend-ready but frontend-deferred. Future frontend wiring should target contextual Today signals and/or Mine service-resource entries, not a standalone generic More tab.
- Still mock/static or planned: live reminders, Mine campus/privacy/reminder/settings contracts, Report insights/export data, Medicine OCR/barcode scanning and richer safety-engine data, smart devices, family profiles, push notifications, richer record analytics, and other low-frequency utilities that do not yet have a north-star tab home.

## UI Status

- Mobile is the current implementation target. Desktop/web visual behavior is not part of the current UI acceptance scope.
- Today, Record, Medicine, Report, and Mine are aligned to the approved mobile north-star references with feature-first structure and reusable primitives where the page patterns repeat.
- Complex charts, trend visuals, safety-engine graphics, scan/OCR/report graphics, and unsupported concept art should remain lightweight placeholders until the backend/data contract and visual requirements are stable.
- Page-level surfaces should use `AppShadowTokens.level1`; reserve higher shadow levels for floating feedback, modal-like panels, or authentication surfaces that need stronger separation.
- Loading states should preserve static page chrome and known local/mock content. Use skeleton shimmer only inside sections that wait on backend-backed data, through `AppSkeletonScope` and skeleton slots where possible.
- Auth-gated UI distinguishes session restoring, confirmed signed-out, and signed-in protected-data states. Restoring sessions keep skeleton/loading surfaces and must not redirect to login or call protected Lucent APIs; confirmed signed-out main tabs may show local/mock static surfaces; signed-in states may call protected repositories.
- UI review on 2026-06-07 found the mobile five-tab surface suitable to freeze for logic-layer work. Do not add a sixth tab or revive a generic utility hub; route low-frequency entries through Mine, contextual Today actions, or defer them.

## UI Rules

- Use `lib/core/design/`, `lib/core/theme/`, and `lib/core/constants/app_breakpoints.dart` before adding feature-local constants.
- Keep mobile feature widgets free of user-visible hardcoded copy and raw visual constants; use ARB/l10n for visible text and existing design tokens first.
- Read app theme mode from `appThemeControllerProvider`; do not hardcode `ThemeMode.system` in app entrypoints.
- Use `Theme.of(context).colorScheme` and `AppThemeSurface` for theme-aware surfaces before adding palette variants.
- Put protocol logic in `lib/core/network/`, not `utils`.
- Do not revive old `home / drug / scan / settings` pages wholesale.

## UI Priorities

1. Keep daily-record and manual dose-log flows under regression as they expand; current auth, ownership, selected-date reload, Record mobile quick-action create routing, filter chip reload, occurredAt timeline time, common type form mapping, null clearing, skipped/taken status, and provider invalidation coverage exists.
2. Refine Record forms further only when Lucent contracts exist for the specific record type; the current supported first pass is water, vital, symptom, and note.
3. Keep Today factual: daily-record and dose-log summaries may be real, but unsupported advice/static sections must stay clearly bounded and use placeholders instead of hand-drawn complex graphics.
4. Connect Report mock repository to real report/insight/export data sources after Lucent contracts exist; keep complex charts as placeholders until the data contract and chart requirements are stable.
5. Connect Mine campus service, privacy permission, reminder, and settings extras to real Lucent data sources after those contracts exist; keep bounded mock entries explicit until then.
6. Keep low-frequency utilities out of the bottom navigation; wire environment or service resources contextually through Today/Mine only after the relevant contracts and user jobs are stable.
7. Expand palette variants only after default / blue-pink / yellow-green prove stable across the main settings, mine, today, medicine, report, and record surfaces.

## Verification Baseline

- Lucent: `pnpm lint:check`, `pnpm build`, `pnpm test:ci`, relevant e2e, `pnpm export:openapi`.
- Luminous: `flutter analyze`, `flutter test`, and local device/emulator E2E with `flutter test integration_test` or a single module file under `integration_test/`.
- OpenAPI sync: run `dart run tool/regenerate_lucent_openapi.dart` from `Luminous`.
