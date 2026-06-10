# Luminous Docs

Last updated: 2026-06-08

This directory keeps current product, frontend, and workflow documentation for the Luminous Flutter client. Historical execution plans are not active docs. If a complex task needs a live execution plan, put it under `../plans/` instead of `docs/`.

## Document Boundaries

| Document | Responsibility | Do not put here |
| --- | --- | --- |
| `Product_Vision.md` | Product positioning, MVP scope, tab responsibilities, AI/safety boundaries | Current implementation status or task logs |
| `Current_State.md` | What is implemented or intentionally deferred right now | Future plans, long rationale, or change history |
| `Next_Plan.md` | The next implementation order and explicit non-start items | Completed work details or historical plans |
| `MigrationLog.md` + `migration-log/YYYY-MM-DD.md` | Date-based change history only | Source-of-truth product rules |
| `Project_Guardrails.md` | Reusable project-specific mistakes to avoid | One-off task notes |
| `OpenApi_Client.md` | Flutter client regeneration workflow and current generated-client boundary | Endpoint prose or old regeneration history |
| `Localization.md` | Flutter l10n workflow and locale ownership | Lists of every current string |

## Update Map

| Change | Update |
| --- | --- |
| Product scope or positioning | `Product_Vision.md` |
| Current UI/data/auth/runtime facts | `Current_State.md` |
| Next implementation order | `Next_Plan.md` |
| Visible text or l10n mechanics | `Localization.md` |
| Lucent OpenAPI/client generation flow | `OpenApi_Client.md` |
| Reusable guardrail | `Project_Guardrails.md` |
| Any frontend-visible change | Today's `migration-log/YYYY-MM-DD.md` |

## Archive Policy

Old plans, audits, and superseded design references should not stay in active docs. If they are needed for archaeology, use the workspace archive outside this repo:

```text
D:\25080\Documents\VSCodeProject\Lumos\docs-archive
```

Active repo-local plans, when needed, belong in:

```text
Luminous/plans/
```

After the task is complete, move stable facts into the owning docs and delete the plan file.
