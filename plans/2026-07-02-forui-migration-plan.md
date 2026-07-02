# Luminous Forui Migration Plan

> Active execution order only. Completed phases are removed from this file and recorded in `docs/Current_State.md` plus `docs/migration-log/2026-07-02.md`.

## Goal

Continue the aggressive `Luminous` -> `Forui` migration by removing the remaining old `AppThemeSurface` / `AppTypographyTokens` / `AppSectionSurface` rendering paths feature-by-feature, committing once per completed phase.

## Assumptions

- This run is speed-first.
- Broad test coverage is intentionally deferred until the final cleanup stage.
- Each completed phase still updates repo docs before commit.
- When Forui already provides the needed component/style, prefer the official widget or CLI-generated style over maintaining another local wrapper.

## Remaining Phases

### Final Cleanup

- Action:
  - Run `rg` across the repo for `AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\.`
  - Clear the remaining migration debt based on results.
  - Run final validation and manual page review at the end of the whole migration.
