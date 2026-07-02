# Luminous Forui Migration Plan

> Active execution order only. Completed phases are removed from this file and recorded in `docs/Current_State.md` plus `docs/migration-log/2026-07-02.md`.

## Goal

Continue the aggressive `Luminous` -> `Forui` migration by removing the remaining old `AppThemeSurface` / `AppTypographyTokens` / `AppSectionSurface` rendering paths feature-by-feature, committing once per completed phase.

## Assumptions

- This run is speed-first.
- Broad test coverage is intentionally deferred until the final cleanup stage.
- Each completed phase still updates repo docs before commit.

## Remaining Phases

### Record

- Files:
  - remaining larger record desktop/section shells after the visible-panel + page/detail passes:
    `lib/features/record/presentation/widgets/views/record_dashboard_view.dart`
    `lib/features/record/presentation/widgets/sections/record_sidebar.dart`
    `lib/features/record/presentation/widgets/sections/record_timeline.dart`
    `lib/features/record/presentation/widgets/sections/record_summary_grid.dart`
    `lib/features/record/presentation/widgets/sections/record_quick_actions.dart`
    `lib/features/record/presentation/widgets/shared/record_components.dart`
    `lib/features/record/presentation/widgets/shared/record_shared_widgets.dart`
- Action:
  - Continue from the now-finished visible-panel + page/detail passes and remove the old theme stack from the remaining desktop/section shells.

### Shared Common Widgets

- Files:
  - `lib/core/widgets/common/app_state_views.dart`
  - `lib/core/widgets/common/app_text_action.dart`
  - `lib/core/widgets/common/app_status_pill.dart`
  - `lib/core/widgets/common/app_image_placeholder.dart`
  - `lib/core/widgets/common/app_header_action_chip.dart`
- Action:
  - Remove remaining `AppThemeSurface` / `AppTypographyTokens` dependencies.
  - Keep only Forui colors and Material `textTheme` where the components still need to exist.

### Root Removal Layer

- Files:
  - `lib/core/theme/app_theme_extensions.dart`
  - `lib/core/design/app_typography_tokens.dart`
  - `lib/core/widgets/common/app_section_surface.dart`
  - `lib/core/widgets/settings/*`
- Action:
  - Once call sites are low enough, delete the bridge layer or shrink it into a minimal compatibility shell.
  - Sweep references after the reduction.

### Final Cleanup

- Action:
  - Run `rg` across the repo for `AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\.`
  - Clear the remaining migration debt based on results.
  - Run final validation and manual page review at the end of the whole migration.
