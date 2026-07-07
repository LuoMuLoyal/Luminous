# Mine Page Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the mobile Mine root page into a single-readiness-card layout with archive-first information hierarchy.

**Architecture:** Keep the existing Mine dashboard data model and routes, but restructure presentation into three layers: one primary readiness card, one archive tile group, and one secondary account/privacy tile group. Remove the mobile status-overview card and fold completeness/sign-in messaging into the hero card.

**Tech Stack:** Flutter, Riverpod, Forui, widget tests, Flutter l10n

---

### Task 1: Lock new mobile hierarchy with tests

**Files:**
- Modify: `test/mine/page_test.dart`

- [ ] Add/adjust widget assertions for the new mobile hierarchy
- [ ] Verify the updated tests fail against the old UI

### Task 2: Rebuild the Mine mobile sections

**Files:**
- Modify: `lib/features/mine/presentation/pages/page.dart`
- Modify: `lib/features/mine/presentation/widgets/views/dashboard_view.dart`
- Modify: `lib/features/mine/presentation/widgets/sections/account_hero.dart`
- Modify: `lib/features/mine/presentation/widgets/sections/archive_section.dart`
- Modify: `lib/features/mine/presentation/widgets/sections/service_privacy.dart`
- Modify: `lib/features/mine/presentation/widgets/shared/sections.dart`

- [ ] Remove the standalone signed-out hint from the page body
- [ ] Turn the hero into a readiness card with explicit primary CTA
- [ ] Convert archive rows to Forui tile-group structure
- [ ] Convert privacy/account area into a lower-priority grouped section
- [ ] Remove the mobile status-overview section from the layout

### Task 3: Update copy and docs, then verify

**Files:**
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_localizations*.dart` via `flutter gen-l10n`
- Modify: `docs/00-current/Current_State.md`
- Modify: `docs/00-current/Active_UI_Mine_Settings.md`
- Modify: `docs/03-logs/migration-log/2026-07-07.md`

- [ ] Add any missing Mine readiness/account/privacy strings
- [ ] Regenerate l10n if ARB changes
- [ ] Run focused Mine tests, then broader analyze
- [ ] Sync frontend docs with the new Mine page structure
