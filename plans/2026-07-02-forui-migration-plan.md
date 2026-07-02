# Luminous Forui Migration Plan

> Active execution order only. Completed phases are removed from this file and recorded in `docs/Current_State.md` plus `docs/migration-log/2026-07-02.md`.

## Goal

Continue the aggressive `Luminous` -> `Forui` migration by removing the remaining old `AppThemeSurface` / `AppTypographyTokens` / `AppSectionSurface` rendering paths feature-by-feature, committing once per completed phase.

## Assumptions

- This run is speed-first.
- Broad test coverage is intentionally deferred until the final cleanup stage.
- Each completed phase still updates repo docs before commit.

## Remaining Phases

### Today

- Files:
  - `lib/features/today/presentation/widgets/today_top_bar.dart`
  - `lib/features/today/presentation/widgets/sections/today_overview_section.dart`
  - `lib/features/today/presentation/widgets/sections/today_priority_section.dart`
  - `lib/features/today/presentation/widgets/sections/today_recommendation_section.dart`
  - `lib/features/today/presentation/widgets/sections/today_todo_section.dart`
- Action:
  - Replace `AppSectionSurface` with Forui card/group composition.
  - Remove major old-homepage design-system remnants.

### Mine

- Files:
  - `lib/features/mine/presentation/widgets/views/mine_dashboard_view.dart`
  - `lib/features/mine/presentation/widgets/mine_top_bar.dart`
  - `lib/features/mine/presentation/widgets/sections/mine_account_hero.dart`
  - `lib/features/mine/presentation/widgets/sections/mine_archive_section.dart`
  - `lib/features/mine/presentation/widgets/sections/mine_status_overview.dart`
- Action:
  - Replace Mine page `surface + typography + section surface` compositions with Forui card/tile structure.

### Report

- Files:
  - `lib/features/report/presentation/widgets/views/report_dashboard_view.dart`
  - `lib/features/report/presentation/widgets/report_top_bar.dart`
  - `lib/features/report/presentation/widgets/sections/report_score_hero.dart`
  - `lib/features/report/presentation/widgets/sections/report_metrics_grid.dart`
  - `lib/features/report/presentation/widgets/sections/report_findings_section.dart`
  - `lib/features/report/presentation/widgets/sections/report_patterns_section.dart`
  - `lib/features/report/presentation/widgets/sections/report_export_section.dart`
  - `lib/features/report/presentation/widgets/sections/report_ai_summary_section.dart`
- Action:
  - Remove the report dashboard's remaining old surface/token stack.

### Medicine / Reminder / Risk / Search

- Files:
  - `lib/features/medicine/presentation/widgets/views/medicine_workspace_view.dart`
  - `lib/features/medicine/presentation/widgets/views/medicine_mobile_dashboard_view.dart`
  - `lib/features/medicine/presentation/widgets/sections/medicine_mobile_*_section.dart`
  - `lib/features/medicine/presentation/widgets/reminder/medicine_reminder_form_body.dart`
  - `lib/features/medicine/presentation/widgets/reminder/reminder_rows.dart`
  - `lib/features/medicine/presentation/widgets/reminder/reminder_log_panels.dart`
  - `lib/features/medicine/presentation/widgets/risk/medicine_risk_*`
  - `lib/features/search/presentation/pages/search_view.dart`
  - `lib/features/search/presentation/widgets/search_result_widgets.dart`
  - `lib/features/medicine/presentation/widgets/dialogs/medicine_add_precheck_dialog.dart`
- Action:
  - Remove the `AppSectionSurface + AppThemeSurface + AppTypographyTokens` trio from the largest remaining shared medical UI surface.

### Record

- Files:
  - `lib/features/record/presentation/widgets/panels/record_nlp_candidate_review.dart`
  - `lib/features/record/presentation/widgets/panels/record_nlp_retry_panel.dart`
  - `lib/features/record/presentation/widgets/cards/meal_analysis_summary_card.dart`
  - `lib/features/record/presentation/widgets/fields/daily_record_image_attachment_field.dart`
  - visible sibling card/panel surfaces found during this phase
- Action:
  - Prioritize directly visible legacy cards/panels.

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
