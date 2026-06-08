# Lumos Current State

Last updated: 2026-06-08

## Product Direction

- Competition vision: Luminous is a proactive daily health self-management assistant for college students, using medication safety as the trust entry point and daily records as context.
- Core loop: record -> understand -> summarize -> proactively remind -> explain risk -> connect services -> report.
- Primary differentiator: active AI summaries and reminders over passive search, with medication safety, symptoms, hydration, diet, sleep, and campus service guidance in the MVP scope.
- Terminal strategy: mobile app is the MVP surface; web is for reports, export preview, printing, and competition display. Desktop, hardware, watch/speaker, and complex multi-endpoint expansion are out of MVP scope.
- Product vision reference: `docs/Product_Vision.md`. `docs/Product_North_Star.md` is a legacy draft kept temporarily for historical reference.

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
- Current OpenAPI export after Medicine Reminders: 38 paths / 106 schemas.
- Daily records support CRUD, detail by id, attachment metadata, and Tencent COS image upload signing.
- Environment snapshot static reference API is implemented at `GET /api/v1/environment/snapshot`.
- Object storage provider is intentionally only Tencent COS for now.
- CI/CD deploys the app image as `latest`; there is no automatic rollback to a `sha-<commit>` image tag.

## Luminous

- Flutter five-tab shell: `today / record / medicine / report / mine`.
- State/navigation: Riverpod + GoRouter.
- Generated Lucent client: `packages/lucent_openapi`.
- Current generated client includes `DailyRecordsApi.dailyRecordsControllerCreateImageUploadV1`, generated `EnvironmentApi`, and generated `MedicineRemindersApi`.
- Real Lucent-backed flows: auth/account, health-context edits, medicine search/detail, current medicines, manual dose logs, daily-record timeline/detail/create/edit/delete, selected-date timeline reload, occurredAt-based timeline time, daily-record single-image attachment upload/display, Record mobile quick actions for Lucent-supported daily-record kinds, and first-pass type-specific daily-record create/edit fields for water, vital, symptom, and note.
- Auth/session state is explicitly split into restoring, confirmed signed-out, and signed-in protected-data access. Protected providers do not call Lucent while auth is restoring or signed out; confirmed signed-out main tabs use local/mock static surfaces, while signed-in tabs and edit flows use protected repositories. Protected entry taps are intercepted on the current page with a modal `尚未登录 / 是否去登录` prompt; cancel stays on the current page, and login returns to that original page after success. Destination-page auth gates remain only as direct/deep-link fallback.
- Mobile MVP UI is active for Today, Record, Medicine, Report, and Mine. These five main tabs share partial skeleton loading: stable page chrome plus local/mock/static sections render immediately, while backend-backed fields render shimmer slots through the shared skeleton primitives. Today now uses compact medication/water/campus priority cards plus a UI-only Today todo list for system-created medication/hydration tasks and user-created custom tasks; Today trend, period, mood-check-in, and environment surfaces are not active. Record keeps real daily-record timeline/detail data and now focuses on MVP record-page jobs: symptoms, hydration, diet/meal, medication boundary entry, natural-language placeholder, timeline, filters, calendar/today overview, quick operations, and a guide row. Record mobile quick actions route Lucent-supported daily-record kinds to `/record/create` with selected kind/date; sleep and lightweight mood record shapes are kept in code with `Deferred by Product_Vision MVP` comments but hidden until matching product/API work is ready. Women-health, period management, sport/activity recovery, and specialist health pack entries are removed from the active Record surface. Medicine derives the drugbox from active Lucent current medicines, derives today's pending/taken/skipped state from dose logs, updates an existing same-day dose log before creating a new one, and refreshes Medicine plus Today after marking. Medicine keeps safety explanation and pregnancy/lactation/special-group medication safety conditions active; scan/OCR/photo/barcode/prescription quick actions are hidden and annotated as deferred code. Report uses a feature-local mock repository for daily/weekly-style score, medication/sleep/water trends, findings, exports, privacy export controls, and patterns until Lucent exposes report/insight APIs; period/cycle and counselor-led report content are removed. Mine reads real auth/account plus health-context profile/allergy/condition/current-medicine data and now keeps account, health archive, campus services, and privacy notice only; Settings owns privacy permissions, reminder preferences, data export, help, about, account, theme, language, and the Advanced settings page. The old More tab and `features/more` code were deleted; `/settings/more` remains only as a backward-compatible route to Advanced settings.
- Medicine mobile UI now uses a lighter reference-aligned drugbox: the drugbox and next-dose reminder are merged into one section, alert/status colors are low-alpha, and safety-engine alerts plus medicine records avoid nested inner cards in favor of compact rows and dividers. Lucent now exposes schedule-only medicine reminder CRUD at `/api/v1/me/medicine-reminders`; Medicine and Today read active reminders for next-dose times and show `提醒未设置` when a current medicine has no reminder. Medication inventory/refill tracking is intentionally removed from the current product scope.
- Environment snapshot is backend-ready but frontend-deferred. Future frontend wiring should target contextual Today signals and/or Mine service-resource entries, not a standalone generic More tab.
- Still mock/static or deferred: reminder edit UI, on-device scheduled notification delivery from Lucent reminder schedules, Mine campus-service contracts, Settings privacy/reminder/export/help/about contracts, Report insights/export data, richer safety-engine data, sleep contract/UI wiring, lightweight mood record wiring, environment contextual wiring, and Medicine scan/OCR/photo/barcode/prescription recognition. Explicitly out of MVP and not active: standalone More tab, women-health/period management, sport recovery, smart devices, family profiles, skin recognition, report photo import, specialist health packs, and desktop-first workflows.

## UI Status

- Mobile is the current implementation target. Desktop/web visual behavior is not part of the current UI acceptance scope.
- Today, Record, Medicine, Report, and Mine are aligned to `docs/Product_Vision.md` with feature-first structure and reusable primitives where the page patterns repeat.
- Complex charts, trend visuals, safety-engine graphics, scan/OCR/report graphics, and unsupported concept art should remain lightweight placeholders until the backend/data contract and visual requirements are stable.
- Page-level surfaces should use `AppShadowTokens.level1`; reserve higher shadow levels for floating feedback, modal-like panels, or authentication surfaces that need stronger separation.
- Loading states should preserve static page chrome and known local/mock content. Use skeleton shimmer only inside sections that wait on backend-backed data, through `AppSkeletonScope` and skeleton slots where possible.
- Auth-gated UI distinguishes session restoring, confirmed signed-out, and signed-in protected-data states. Restoring sessions keep skeleton/loading surfaces and must not redirect to login or call protected Lucent APIs; confirmed signed-out main tabs may show local/mock static surfaces; protected entry taps show a modal login prompt over the current page; protected edit/detail pages keep the same prompt only as direct/deep-link fallback; signed-in states may call protected repositories.
- UI review on 2026-06-08 converged the mobile five-tab surface to `docs/Product_Vision.md`. Do not add a sixth tab, revive a generic utility hub, or re-surface removed broad-health modules; route low-frequency entries through Mine, contextual Today actions, or defer them with an explicit `Deferred by Product_Vision MVP` code comment.

## UI Rules

- Use `lib/core/design/`, `lib/core/theme/`, and `lib/core/constants/app_breakpoints.dart` before adding feature-local constants.
- Keep mobile feature widgets free of user-visible hardcoded copy and raw visual constants; use ARB/l10n for visible text and existing design tokens first.
- Read app theme mode from `appThemeControllerProvider`; do not hardcode `ThemeMode.system` in app entrypoints.
- Use `Theme.of(context).colorScheme` and `AppThemeSurface` for theme-aware surfaces before adding palette variants.
- Put protocol logic in `lib/core/network/`, not `utils`.
- Do not revive old `home / drug / scan / settings` pages wholesale.

## UI Priorities

1. Keep daily-record and manual dose-log flows under regression as they expand; current auth, ownership, selected-date reload, Record mobile quick-action create routing, filter chip reload, occurredAt timeline time, common type form mapping, null clearing, same-day dose-log update/create, skipped/taken status, and provider invalidation coverage exists.
2. Refine Record forms further only when Lucent contracts exist for the specific record type; the current active create/edit choices are water, meal, vital, symptom, and note. Mood and activity remain domain enum compatibility only and should not be surfaced as MVP entry points.
3. Keep Today factual: daily-record and dose-log summaries may be real, but unsupported advice/static sections must stay clearly bounded and use placeholders instead of hand-drawn complex graphics.
4. Connect Report mock repository to real report/insight/export data sources after Lucent contracts exist; keep complex charts as placeholders until the data contract and chart requirements are stable.
5. Connect Mine campus services and Settings privacy permission, reminder, export/help/about extras to real Lucent data sources after those contracts exist; keep bounded static/mock entries explicit until then.
6. Keep low-frequency utilities out of the bottom navigation; wire environment or service resources contextually through Today/Mine only after the relevant contracts and user jobs are stable.
7. Treat removed Product_Vision exclusions as product boundaries, not TODOs: More tab, women-health/period management, sport recovery, specialist packs, smart devices, family profiles, skin recognition, and report photo import should not reappear without an explicit product decision.
8. Expand palette variants only after default / blue-pink / yellow-green prove stable across the main settings, mine, today, medicine, report, and record surfaces.

## Verification Baseline

- Lucent: `pnpm lint:check`, `pnpm build`, `pnpm test:ci`, relevant e2e, `pnpm export:openapi`.
- Luminous: `flutter analyze`, `flutter test`, and local device/emulator E2E with `flutter test integration_test` or a single module file under `integration_test/`.
- OpenAPI sync: run `dart run tool/regenerate_lucent_openapi.dart` from `Luminous`.
