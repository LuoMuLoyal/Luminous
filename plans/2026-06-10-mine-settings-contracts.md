# Mine And Settings Contracts Plan

Status: active planning on 2026-06-10.

Report contracts are intentionally paused by user direction. This plan becomes the active next work item for `Luminous`, with Lucent changes added only where a real backend/source contract is needed.

## Goal

Turn the remaining static or toast-only Mine/Settings areas into contract-backed, honest UI without disturbing the flows that already work.

The first pass should define and implement the smallest useful contracts for:

1. campus services,
2. privacy permissions,
3. reminder preference sync,
4. data export request/status,
5. help content,
6. about/app metadata.

## Current Baseline

Already real or intentionally local:

- account settings are backed by Lucent `account` APIs.
- basic health archive, allergies, conditions, and current medicines are backed by Lucent health-context APIs.
- notification permission state is device-local.
- medication reminder local scheduling is device-local and driven by reminder schedules plus local notification settings.
- theme and language are local preferences; language also syncs through health-context profile preferences.

Still static or contract-missing:

- Mine campus service entries are hardcoded in `LucentMineRepository`.
- Settings privacy report and AI/privacy switches are display-only or toast-only.
- Settings export, help, and about rows are toast-only.
- Settings reminder summary rows show static enabled labels, while the real switches live on the notification settings page.

## Product Rule

Do not present static resources as live services. A row can stay visible only if one of these is true:

1. it is backed by a contract,
2. it routes to a real local/settings page,
3. it is explicitly marked unavailable through existing concise status copy.

No marketing copy, onboarding copy, or broad explanatory text should be added.

## Phase 1: Contract Design

Create a tiny public contract doc in Lucent before implementation:

- path: `Lucent/docs/public/mine-settings-contract.md`

The contract should answer:

- Which settings/resources are server-owned and which stay local?
- Which endpoints are needed now?
- Which fields are stable enough for generated OpenAPI?
- Which entries are read-only resources versus user preferences?
- Which rows must remain unavailable until external services are approved?

Suggested minimum endpoints:

```text
GET /api/v1/me/settings
PATCH /api/v1/me/settings
GET /api/v1/public/support-resources?scope=campus
GET /api/v1/public/app-info
POST /api/v1/me/data-export-requests
GET /api/v1/me/data-export-requests/latest
```

Keep this conservative. If export is too large, define request/status only and leave file generation out of scope.

## Phase 2: Lucent Backend

Likely module shape:

- `src/modules/user-settings/`
- `src/modules/support-resources/`
- optional `src/modules/data-export/` if export request/status is included now

Preferred first implementation:

- persist user settings in an existing safe place only if the schema already supports it cleanly; otherwise add a narrow Prisma model such as `UserSetting`.
- serve support resources from static backend reference data first, not from paid external services.
- expose app/about metadata from config/package data or a static DTO.
- return export request status as `unavailable` or `requested` if real archive generation is not implemented.

Do not add paid or credentialed external services in this task.

Lucent verification:

```powershell
cd Lucent
pnpm lint:check
pnpm build
pnpm test:ci
pnpm export:openapi
```

## Phase 3: Luminous Client Regeneration

After Lucent OpenAPI changes:

```powershell
cd Luminous
dart run tool/regenerate_lucent_openapi.dart
```

Do not hand-edit generated client code.

## Phase 4: Luminous Wiring

Likely frontend targets:

- `lib/features/mine/data/repositories/lucent_mine_repository.dart`
- `lib/features/mine/domain/entities/mine_dashboard.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/pages/notification_settings_page.dart`
- new `settings` data-source/provider files if server-backed settings are added
- route/page additions only for real export/help/about flows

Expected behavior:

- Mine campus services come from the backend/static-resource contract or are clearly unavailable.
- Settings privacy rows show server-backed values or route to a real settings surface.
- Reminder rows summarize actual notification setting state instead of hardcoded enabled labels.
- Export row either creates/opens a real export request status or shows a contract-backed unavailable state.
- Help/about rows route to real local pages or contract-backed metadata.

Keep existing account, profile, health archive, language, theme, and local notification permission flows intact.

## Tests

Lucent:

- controller/service tests for settings get/patch.
- resource endpoint tests for stable campus/help/about data.
- export request/status tests if included.
- OpenAPI export must include the new DTOs.

Luminous:

```powershell
cd Luminous
flutter analyze
flutter test test/mine_page_test.dart
flutter test test/settings_page_test.dart
flutter test test/settings_flow_test.dart
flutter test
```

Add focused tests for:

- Mine campus entries use repository/contract data instead of hardcoded-only rows.
- Settings reminder summary reads real notification controller state.
- privacy/export/help/about no longer rely on toast-only fake completion.
- signed-out state does not call protected settings APIs.

## Documentation

Update after implementation:

- `Lucent/docs/public/mine-settings-contract.md`
- `Lucent/docs/README.md`
- `Luminous/docs/Current_State.md`
- `Luminous/docs/Next_Plan.md`
- `Luminous/docs/migration-log/YYYY-MM-DD.md`
- `Luminous/docs/OpenApi_Client.md` if generated client baseline changes
- `Luminous/docs/Localization.md` if new visible strings are added

## Review Checklist

Block the implementation if:

1. it adds broad external-service integrations without explicit approval,
2. it stores sensitive export files without an explicit retention/deletion design,
3. it treats local OS notification permission as a server-owned preference,
4. it breaks existing account/health-context edit flows,
5. it adds new visible copy without ARB/l10n,
6. it leaves static rows looking like live service actions.
