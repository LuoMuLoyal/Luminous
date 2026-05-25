# Knowledge Data Platform Summary

Last updated: 2026-05-25

This is the Luminous-side product/client summary. Backend import details live in `Lucent/docs/data-sources.md`.

## Direction

Luminous is moving from a small medicine lookup app toward a personal health management copilot. Medicine facts should come from a Lucent/PostgreSQL knowledge platform, not bundled Flutter assets or AI-generated text.

## Target Source

External data directory:

```text
D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase
```

Current contents:

- `FullDrugDetail.xlsx`: detailed Chinese product and instruction data.
- DrugBank files: English scientific enrichment data.

These files stay outside Git and outside Flutter assets.

## Ownership

- Lucent owns import scripts, staging tables, normalization, search indexes, and Chinese/DrugBank matching.
- PostgreSQL becomes the durable source for medicine detail, instruction sections, search, and enrichment.
- Flutter consumes Lucent APIs and renders structured sections/Markdown.
- AI/copilot features must cite or derive from stored knowledge and user context; AI is not the source of medicine facts.

## Client Impact

Flutter should prepare for:

- `/api/v1` Lucent endpoints.
- Medicine detail responses with structured `sections` and `detailMarkdown`.
- Markdown rendering for medicine detail, safety output, and copilot explanations.
- No local full medicine database. `lib/assets/data.json` remains a tiny development fallback only.

## Open Decisions

- Chinese-first display versus bilingual display.
- DrugBank licensing and which fields can appear in user-facing responses.
- Mapping rules between Chinese product rows and DrugBank drugs.
- Image URL handling: source reference, proxy, or cache.

## Validation Expectations

- Import reports explain source row counts, accepted rows, rejected rows, and sample rejection reasons.
- Flutter tests cover long Markdown/section rendering and safety disclaimer visibility.
- Core app flows continue to work after switching to Lucent: search, detail, scan, my medicines, reminders, and copilot surfaces.
