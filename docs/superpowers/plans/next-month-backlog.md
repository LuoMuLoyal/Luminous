# Next-Month Backlog

Last updated: 2026-06-06

This is a scoped candidate list for the next execution window (after Task 20 handoff).
Not a full plan — each item needs a contract design task before implementation.

## Ready For Implementation

These have Lucent contracts defined and can move to implementation when scheduled:

1. **Local notification scheduling** — Use `reminder-contract.md` to implement Phase B (device-local notification triggers based on preferences). The settings page already has permission + preference bridges.
2. **Environment snapshot API** — Use `environment-contract.md` to implement static reference data + `GET /api/v1/environment/snapshot` in Lucent. Luminous swaps mock data for real API.

## Needs Contract Design

These need a contract document (like environment-contract.md) before implementation:

3. **Family profiles** — Multi-user health context sharing within a family group. Needs: Prisma models for family groups, invite flow, permission model.
4. **Device registry** — Multi-device sync (push tokens, device management). Needs: UserDevice model expansion, push token registration API.
5. **Health timeline/analytics** — Weekly/monthly summaries, trend visualizations. Needs: aggregation API design, data warehouse considerations.

## Blocked (External Dependencies)

6. **Push notification delivery (FCM/APNs)** — Requires: Firebase project setup, APNs certificates, FCM server key, delivery worker infrastructure.
7. **WeChat OAuth production** — Requires: WeChat Open Platform app review, production AppID/AppSecret.
8. **Apple/Google OAuth** — Requires: Apple Developer Program, Google Cloud Console app registration.

## Deferred

9. **OCR/Barcode scanning** — No backend contract yet. Requires camera integration + ML model or third-party API.
10. **Watch companion app** — Requires separate Flutter/watchOS project.
11. **Medical record import** — Requires document parsing infrastructure.

## Technical Debt

12. **E2E test suite** — Currently skipped (Docker not available in sandbox). Needs Docker CI integration.
13. **Flutter integration tests** — Only widget tests exist; no integration/UI-level tests.
14. **fluwx KGP migration** — The fluwx plugin still applies KGP internally; needs plugin update or workaround.

## Reference

- Active contracts: `reminder-contract.md`, `environment-contract.md`
- Product roadmap: `Lucent/docs/public/ROADMAP.md`
- Current guardrails: `Luminous/docs/Project_Guardrails.md`
