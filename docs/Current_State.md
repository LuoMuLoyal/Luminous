# Lumos Current State

Last updated: 2026-06-07

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
- Real Lucent-backed flows: auth/account, health-context edits, medicine search/detail, current medicines, manual dose logs, daily-record timeline/detail/create/edit/delete, selected-date timeline reload, occurredAt-based timeline time, daily-record single-image attachment upload/display.
- Mobile north-star UI is active for Today, Record, Medicine, and Report. Record keeps real daily-record timeline/detail data while symptom, mood trend, period/diet, and specialist pack sections are static placeholders. Medicine keeps real current-medicine and manual dose-log data where available while safety engine, scan/OCR, report, reference notice, and safety tips are bounded mock/placeholder sections. Report uses a feature-local mock repository for weekly score, trends, findings, exports, privacy controls, and pattern analysis until Lucent exposes report/insight APIs.
- Environment snapshot is backend-ready but frontend-deferred: More still uses static mock data until core modules are steadier.
- Still mock/static or planned: live reminders, Report insights/export data, Medicine OCR/barcode scanning and richer safety-engine data, smart devices, family profiles, push notifications, richer record analytics.

## Verification Baseline

- Lucent: `pnpm lint:check`, `pnpm build`, `pnpm test:ci`, relevant e2e, `pnpm export:openapi`.
- Luminous: `flutter analyze`, `flutter test`, and local device/emulator E2E with `flutter test integration_test` or a single module file under `integration_test/`.
- OpenAPI sync: run `dart run tool/regenerate_lucent_openapi.dart` from `Luminous`.
