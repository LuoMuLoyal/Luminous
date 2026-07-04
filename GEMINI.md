# Luminous Gemini Entry

Read these files before editing:

1. `AGENTS.md`
2. `README.md`
3. `docs/README.md`
4. `docs/02-reference/AI_Development_Workflow.md`

Project boundaries:

- Keep to Riverpod, GoRouter, and Forui patterns already used in the repo.
- Treat `packages/lucent_openapi/` and generated l10n files as generated.
- Keep app-side AI experimentation inside `lib/core/ai/` unless the task
  explicitly changes product architecture.
- After code changes, update the required `docs/` files and the daily migration
  log.
