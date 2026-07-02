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

### Root Removal Layer

- Files:
  - `lib/core/theme/app_theme_extensions.dart`
  - `lib/core/design/app_typography_tokens.dart`
  - `lib/core/widgets/common/app_section_surface.dart`
  - `lib/core/widgets/settings/*`
- Action:
  - Replace the remaining wrapper/bridge surfaces with official Forui components where possible, and use `dart run forui style create ...` only when a generated style file is genuinely needed.
  - Feature-level call sites are now cleared from `lib`, and the three bridge files have been shrunk to compatibility-only shims. The remaining work is to clean matching tests and decide whether those shims can be deleted outright afterward.
  - Sweep references after the reduction.

### Final Cleanup

- Action:
  - Run `rg` across the repo for `AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\.`
  - Clear the remaining migration debt based on results.
  - Run final validation and manual page review at the end of the whole migration.
