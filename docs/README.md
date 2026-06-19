# Luminous Docs

Last updated: 2026-06-19

This directory keeps current product, frontend, and workflow documentation for the Luminous Flutter client. Historical execution plans are not active docs. If a complex task needs a live execution plan, put it under `../plans/` instead of `docs/`.

## Document Boundaries

| Document | Responsibility | Do not put here |
| --- | --- | --- |
| `Product_Vision.md` | Product positioning, MVP scope, tab responsibilities, AI/safety boundaries | Current implementation status or task logs |
| `Current_State.md` | What is implemented or intentionally deferred right now | Future plans, long rationale, or change history |
| `Next_Plan.md` | The next implementation order and explicit non-start items | Completed work details, current-state facts, or historical plans |
| `TODO.md` | Remaining MVP gaps and gated backlog that still needs delivery | Current-state facts or historical change logs |
| `MigrationLog.md` + `migration-log/YYYY-MM-DD.md` | Date-based change history only | Source-of-truth product rules |
| `Project_Guardrails.md` | Reusable project-specific mistakes to avoid | One-off task notes |
| `OpenApi_Client.md` | Flutter client regeneration workflow and current generated-client boundary | Endpoint prose or old regeneration history |
| `Localization.md` | Flutter l10n workflow and locale ownership | Lists of every current string |
| `MVP_Demo_Baseline.md` | Repeatable deployed-MVP demo baseline: deploy smoke, demo account/data, pre-demo checks | Product scope or long change history |
| `MVP_Demo_Script.md` | Short operator script for demo/defense of the current real MVP path | Source-of-truth scope, current-state facts, or backlog |

## Update Map

| Change | Update |
| --- | --- |
| Product scope or positioning | `Product_Vision.md` |
| Current UI/data/auth/runtime facts | `Current_State.md` |
| Next implementation order | `Next_Plan.md` |
| Remaining MVP gaps or gated backlog | `TODO.md` |
| Visible text or l10n mechanics | `Localization.md` |
| Lucent OpenAPI/client generation flow | `OpenApi_Client.md` |
| Reusable guardrail | `Project_Guardrails.md` |
| Demo baseline / rehearsal prerequisites | `MVP_Demo_Baseline.md` |
| Demo/defense operator walkthrough | `MVP_Demo_Script.md` |
| Any frontend-visible change | Today's `migration-log/YYYY-MM-DD.md` |

## Archive Policy

Old plans, audits, and superseded design references should not stay in active docs. If they are needed for archaeology, use the workspace archive outside this repo, such as the sibling `docs-archive/` directory at the workspace level:

Active repo-local plans, when needed, belong in:

```text
Luminous/plans/
```

After the task is complete, move stable facts into the owning docs and delete the plan file.

## Boundary Reminder

- If a sentence says what is already done or what is currently true, it belongs in `Current_State.md` or the migration log, not `Next_Plan.md`.
- `Next_Plan.md` should stay focused on sequencing, priorities, and explicit non-start items.
- When a plan starts collecting status bullets, move those bullets out instead of letting the plan become a second state document.
