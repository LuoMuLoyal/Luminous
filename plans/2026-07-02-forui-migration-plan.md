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
  - remaining feature leftovers still leaning on the bridge, mainly `lib/features/auth/presentation/widgets/*`, `lib/features/mine/presentation/pages/mine_page.dart`, `lib/features/mine/presentation/widgets/shared/mine_components.dart`, `lib/features/mine/presentation/widgets/views/mine_skeleton_view.dart`, `lib/features/shell/presentation/shell_deferred_content.dart`, and a few formatter/helper files that still encode `AppThemeSurface`
- Action:
  - Replace the remaining wrapper/bridge surfaces with official Forui components where possible, and use `dart run forui style create ...` only when a generated style file is genuinely needed.
  - Once call sites are low enough, delete the bridge layer or shrink it into a minimal compatibility shell.
  - Sweep references after the reduction.

### Final Cleanup

- Action:
  - Run `rg` across the repo for `AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\.`
  - Clear the remaining migration debt based on results.
  - Run final validation and manual page review at the end of the whole migration.
