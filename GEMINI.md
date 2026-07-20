# Luminous Gemini Entry

Read these files before editing:

1. `AGENTS.md`
2. `README.md`
3. `docs/README.md`
4. `docs/02-reference/AI_Development_Workflow.md`

Project boundaries:

- Keep to Riverpod, GoRouter, and Forui patterns already used in the repo.
- Treat `generated/lucent_api/` and generated l10n files as generated.
- Keep app-side AI experimentation inside `lib/core/ai/` unless the task
  explicitly changes product architecture.
- After code changes, update the required `docs/` files and the daily migration
  log.

## L10n (CRITICAL)

**Never edit `lib/l10n/app_zh.arb` or `app_en.arb` directly.**

The source of truth for l10n strings is the fragment files in `lib/l10n/src/`.
Correct workflow:
1. Edit the fragment file(s) in `lib/l10n/src/`
2. `dart scripts/arb_tools.dart merge` — merge fragments → `app_zh.arb` / `app_en.arb`
3. `flutter gen-l10n` — generate Dart localization code

Direct edits to `app_zh.arb` / `app_en.arb` will be lost on the next merge.
