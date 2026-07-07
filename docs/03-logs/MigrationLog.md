# Luminous Migration Log

Last updated: 2026-07-07

Records changes after the full reset only. Detailed entries are split by date under
`docs/03-logs/migration-log/`. Pre-2026-07 entries are archived under `docs/04-archive/migration-log/`.

Pre-reset history and inactive long-form docs were moved outside git to the workspace-level archive,
under the `docs-archive/2026-06-06-doc-cleanup` folder.

## How To Update

- Add new entries to `docs/03-logs/migration-log/YYYY-MM-DD.md`.
- If a date file does not exist yet, create it with the title `# Migration Log - YYYY-MM-DD`.
- Keep newest date files listed first in this index.
- Move older entries to `docs/04-archive/migration-log/` when they are no longer part of the active sprint.
- Use concrete dates. Do not move old history back into this index.

## Active Entries

- [2026-07-07](migration-log/2026-07-07.md) — 审查修复 + 开发者选项 + Talker 迁移 + 开源标准文档
- [2026-07-04](migration-log/2026-07-04.md) — Doc coverage warning automation + phase guide
- [2026-07-03](migration-log/2026-07-03.md) — Docs restructure + Forui debt closeout
- [2026-07-02](migration-log/2026-07-02.md)
- [2026-07-01](migration-log/2026-07-01.md)

## Archived Entries

Browse `docs/04-archive/migration-log/`.

## Quick Navigation by Topic

Major changes grouped by area:

- **Auth / OAuth** (WeChat, Apple, QQ login, security)
  - Key Dates: 05/30, 06/02, 06/10, 06/29
- **UI / Routing** (GoRouter, StatefulShellRoute, back button unification)
  - Key Dates: 06/04, 06/05, 06/07, 06/11, 06/26, 06/27, 06/28, 06/30
- **API / OpenAPI Client** (regeneration, contracts, network layer)
  - Key Dates: 06/01, 06/03, 06/06, 06/12, 06/13, 06/30
- **Medicine** (search, dose logs, reminders, workspace)
  - Key Dates: 06/02, 06/04, 06/06, 06/09, 06/23, 06/25, 06/28
- **Report** (dashboard, generation, export)
  - Key Dates: 06/06, 06/09, 06/19, 06/22
- **Today Dashboard** (analysis, recommendations, empty states)
  - Key Dates: 06/07, 06/09, 06/10, 06/14, 06/28
- **Daily Records** (fast entry, candidate generation)
  - Key Dates: 06/09, 06/10, 06/12, 06/16, 06/20
- **Settings / Mine** (profile, health context, preferences)
  - Key Dates: 06/08, 06/12, 06/17, 06/26
- **Assistant** (AI chat, tool integration)
  - Key Dates: 06/15, 06/18, 06/30
- **Tests** (unit, widget, integration, full-stack E2E)
  - Key Dates: 06/06, 06/07, 06/11, 06/13, 06/30
- **CI / Tooling** (melos, git hooks, GitHub Actions)
  - Key Dates: 06/05, 06/13, 06/30
- **Docs / Governance** (migration log, guardrails, architecture)
  - Key Dates: 06/07, 06/08, 06/30, 07/03, 07/07
