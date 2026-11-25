# Luminous Plans

Use this directory for active, repo-local execution plans that are too detailed for
`docs/TODO.md`.

## What Goes Here

- multi-step implementation plans
- review/handoff checklists for a specific Luminous task
- temporary task docs that are still actively driving work

## What Does Not Go Here

- current product facts: no narrative docs — assert in tests, constrain in feature READMEs
- next work ordering for the repo as a whole: put that in `docs/TODO.md`
- historical change logs: put those in `docs/logs/migration-log/YYYY-MM-DD.md`
- completed plans that no longer drive work

## Naming

Use task-specific names such as:

```text
YYYY-MM-DD-short-task-name.md
```

## Lifecycle

1. Create or update the plan here while the task is active.
2. Execute the task and verify it.
3. Move stable decisions and outcomes into the owning docs.
4. Delete the plan file once it is no longer the active source of work.
