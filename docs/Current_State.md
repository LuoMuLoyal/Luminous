# Lumos Current State

Last updated: 2026-06-06

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
- Current OpenAPI export after Tencent COS upload signing: 35 paths / 89 schemas.
- Daily records support CRUD, detail by id, attachment metadata, and Tencent COS image upload signing.
- Object storage provider is intentionally only Tencent COS for now.
- CI/CD deploys the app image as `latest`; there is no automatic rollback to a `sha-<commit>` image tag.

## Luminous

- Flutter five-tab shell: `today / record / medicine / mine / more`.
- State/navigation: Riverpod + GoRouter.
- Generated Lucent client: `packages/lucent_openapi`.
- Current generated client includes `DailyRecordsApi.dailyRecordsControllerCreateImageUploadV1`.
- Real Lucent-backed flows: auth/account, health-context edits, medicine search/detail, current medicines, manual dose logs, daily-record timeline/create/edit/delete.
- Still mock/static or planned: live reminders, OCR/barcode scanning, smart devices, family profiles, push notifications, richer record analytics.

## Verification Baseline

- Lucent: `pnpm lint:check`, `pnpm build`, `pnpm test:ci`, relevant e2e, `pnpm export:openapi`.
- Luminous: `flutter analyze`, `flutter test`.
- OpenAPI sync: run `dart run tool/regenerate_lucent_openapi.dart` from `Luminous`.
