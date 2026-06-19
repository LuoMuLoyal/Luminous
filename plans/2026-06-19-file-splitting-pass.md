# Luminous File Splitting Pass

## Goal

Reduce oversized hand-written frontend files toward these thresholds:

- around 300 lines: preferred
- 300-600 lines: acceptable
- 600+ lines: should be split unless the file is generated

This plan only targets hand-written Dart files under `lib/`. Generated `l10n`, `freezed`, and `g.dart` files are tracked separately and are not manual split targets.

## Assumptions

- generated files should be excluded from manual split work
- widget-heavy files should be split by section or responsibility, not by raw line slicing
- page files should mostly assemble sections, not define every section inline

## Current Scan Summary

Hand-written files at or above 600 lines:

- `lib/features/medicine/presentation/pages/medicine_reminder_pages.dart` — 1916
- `lib/features/report/presentation/widgets/report_sections.dart` — 1613
- `lib/features/assistant/presentation/pages/assistant_page.dart` — 1523
- `lib/features/today/presentation/widgets/today_dashboard_view.dart` — 1510
- `lib/features/record/presentation/widgets/record_dashboard_view.dart` — 1366
- `lib/features/medicine/presentation/widgets/medicine_workspace_view.dart` — 1019
- `lib/features/mine/presentation/widgets/mine_sections.dart` — 933
- `lib/features/search/presentation/widgets/search_parts.dart` — 877
- `lib/features/record/presentation/widgets/record_nlp_sheet.dart` — 837
- `lib/features/auth/presentation/pages/account_settings_page.dart` — 754
- `lib/features/medicine/presentation/widgets/medicine_mobile_sections.dart` — 723

Hand-written files in the 300-600 range that should be kept under control:

- `lib/features/settings/presentation/pages/settings_page.dart` — 588
- `lib/features/record/data/repositories/mock_record_repository.dart` — 580
- `lib/features/assistant/presentation/providers/assistant_controller.dart` — 571
- `lib/features/medicine/presentation/pages/medicine_risk_check_page.dart` — 570
- `lib/features/record/presentation/pages/record_detail.dart` — 528
- `lib/features/record/presentation/pages/record_edit.dart` — 518
- `lib/features/auth/presentation/widgets/auth_shell.dart` — 503
- `lib/features/record/presentation/widgets/record_overview.dart` — 501
- `lib/features/medicine/presentation/widgets/medicine_mobile_drugbox_section.dart` — 499
- `lib/features/medicine/domain/services/medicine_risk_checker.dart` — 476
- `lib/features/auth/presentation/pages/login_page.dart` — 440
- `lib/features/record/presentation/widgets/record_components.dart` — 416
- `lib/core/widgets/app_state_views.dart` — 406
- `lib/features/search/presentation/widgets/search_view.dart` — 401
- `lib/features/record/presentation/controllers/record_nlp_controller.dart` — 398
- `lib/features/record/data/repositories/lucent_record_repository.dart` — 398
- `lib/features/record/presentation/pages/record_create.dart` — 373
- `lib/features/auth/data/datasources/auth_remote_data_source.dart` — 359
- `lib/features/search/presentation/pages/search_page.dart` — 358
- `lib/features/medicine/presentation/widgets/medicine_workspace_parts.dart` — 342
- `lib/features/assistant/domain/entities/assistant_models.dart` — 333
- `lib/features/report/presentation/pages/report_page.dart` — 331
- `lib/features/assistant/data/repositories/lucent_assistant_repository.dart` — 331
- `lib/features/today/presentation/widgets/today_components.dart` — 328
- `lib/features/shell/presentation/shell_page.dart` — 328
- `lib/features/medicine/presentation/widgets/medicine_copy.dart` — 325
- `lib/features/record/presentation/widgets/record_timeline.dart` — 324
- `lib/features/mine/presentation/pages/current_medicine_edit.dart` — 324
- `lib/features/mine/presentation/widgets/mine_components.dart` — 314
- `lib/features/record/data/datasources/daily_record_remote_data_source.dart` — 312
- `lib/features/medicine/presentation/pages/medicine_page.dart` — 301

Generated files above threshold but not manual split targets:

- `lib/l10n/app_localizations*.dart`
- `*.freezed.dart`

## Primary Split Targets

### 1. `lib/features/assistant/presentation/pages/assistant_page.dart`

Problem:

- one page file contains route shell, state gates, hero, conversation surface, message bubbles, proposal cards, input composer, recent-conversation sheet, and presentation helper functions

Suggested structure:

```text
lib/features/assistant/presentation/
  pages/
    assistant_page.dart
  widgets/
    assistant_loading_view.dart
    assistant_state_card.dart
    assistant_hero.dart
    assistant_controls_panel.dart
    assistant_conversation_surface.dart
    assistant_message_bubble.dart
    assistant_proposal_card.dart
    assistant_recent_conversation_sheet.dart
    assistant_chips.dart
  presentation_models/
    assistant_message_view_model.dart
  utils/
    assistant_ui_formatters.dart
```

Split plan:

- page keeps route-level wiring only
- conversation-specific widgets move out together
- proposal card and meta section move together
- bottom-sheet widget moves out
- helper functions like tool labels, timestamps, proposal state labels move into `assistant_ui_formatters.dart`

### 2. `lib/features/today/presentation/widgets/today_dashboard_view.dart`

Problem:

- dashboard shell, top bar, assistant entry, summary, priorities, recommendations, todos, overview cards, and view-model-like data classes all live together

Suggested structure:

```text
lib/features/today/presentation/widgets/
  today_dashboard_view.dart
  today_top_bar.dart
  today_overview_section.dart
  today_ai_summary_section.dart
  today_priority_section.dart
  today_recommendation_section.dart
  today_todo_section.dart
  today_view_models.dart
```

### 3. `lib/features/record/presentation/widgets/record_dashboard_view.dart`

Problem:

- mobile dashboard, desktop dashboard, date controls, quick entry, timeline, filters, overview panels, and AI input bar are all in one file

Suggested structure:

```text
lib/features/record/presentation/widgets/dashboard/
  record_dashboard_view.dart
  record_mobile_dashboard.dart
  record_desktop_dashboard.dart
  record_date_bar.dart
  record_quick_entry_panel.dart
  record_timeline_panel.dart
  record_filter_panel.dart
  record_overview_panels.dart
  record_dashboard_tokens.dart
```

Notes:

- this file is likely to keep growing because of the planned fast-entry UX, so split before adding more behavior

### 4. `lib/features/report/presentation/widgets/report_sections.dart`

Problem:

- top bar, hero, metrics grid, trend section, findings, AI summary, export section, patterns, reference notice, and section-local data classes are all co-located

Suggested structure:

```text
lib/features/report/presentation/widgets/
  report_top_bar.dart
  report_score_hero.dart
  report_metrics_grid.dart
  report_trend_section.dart
  report_findings_section.dart
  report_ai_summary_section.dart
  report_export_section.dart
  report_patterns_section.dart
  report_reference_notice.dart
  report_section_models.dart
```

### 5. `lib/features/medicine/presentation/pages/medicine_reminder_pages.dart`

Problem:

- detail page, edit page, large stateful form, logs, delete sheet, row widgets, frequency/time widgets, and formatting helpers are all packed into one file

Suggested structure:

```text
lib/features/medicine/presentation/pages/reminder/
  medicine_reminder_detail_page.dart
  medicine_reminder_edit_page.dart
  medicine_reminder_delete_sheet.dart
lib/features/medicine/presentation/widgets/reminder/
  reminder_detail_body.dart
  reminder_form_body.dart
  reminder_log_panels.dart
  reminder_form_fields.dart
  reminder_frequency_fields.dart
  reminder_rows.dart
lib/features/medicine/presentation/utils/
  medicine_reminder_formatters.dart
```

### 6. `lib/features/medicine/presentation/widgets/medicine_workspace_view.dart`

Problem:

- dashboard shell plus metrics, quick actions, today plan, safety panel, promises, status badge, and local action helpers all live together

Suggested structure:

```text
lib/features/medicine/presentation/widgets/workspace/
  medicine_workspace_view.dart
  medicine_metrics_panel.dart
  medicine_quick_action_section.dart
  medicine_today_plan_section.dart
  medicine_safety_panel.dart
  medicine_promise_panel.dart
  medicine_workspace_badges.dart
```

### 7. `lib/features/record/presentation/widgets/record_nlp_sheet.dart`

Problem:

- page-state widget, retry panel, candidate review list, candidate tile, inline editor, water unit field, sleep fields, and label helpers are all in one file

Suggested structure:

```text
lib/features/record/presentation/widgets/nlp/
  record_nlp_sheet.dart
  record_nlp_retry_panel.dart
  record_nlp_candidate_review_section.dart
  record_nlp_candidate_tile.dart
  record_nlp_candidate_editor.dart
  record_nlp_sleep_fields.dart
  record_nlp_formatters.dart
```

## Secondary Split Targets

### `lib/features/assistant/presentation/providers/assistant_controller.dart`

Problem:

- bootstrap, capability loading, conversation loading, recent conversation loading, send flow, retry, new conversation, proposal confirm, proposal execution, and state patch helpers are all in one controller

Suggested split:

```text
lib/features/assistant/presentation/providers/
  assistant_controller.dart
  assistant_state.dart
  assistant_controller_conversation.dart
  assistant_controller_proposals.dart
```

If partial files feel awkward in Dart, alternative:

- keep one controller
- extract state type to `assistant_state.dart`
- extract pure reducers/helpers to `assistant_controller_helpers.dart`
- extract repository-facing proposal execution helper to `assistant_proposal_executor.dart`

### `lib/features/mine/presentation/widgets/mine_sections.dart`

Split by section groups:

- profile header
- action groups
- cards/rows

### `lib/features/search/presentation/widgets/search_parts.dart`

Split by result type and section:

- search bar / filters
- medicine results
- context actions

### `lib/features/auth/presentation/pages/account_settings_page.dart`

Split into:

- page shell
- email/password section
- connected-identity section
- delete-account section

## Generated File Policy

Do not hand-split:

- `lib/l10n/app_localizations*.dart`
- `*.freezed.dart`
- `*.g.dart`

If these become painful, the fix should come from:

- reducing string sprawl at source only where useful
- changing model shape to reduce generated surface
- wrapping generated code behind smaller hand-written APIs

## Suggested Directory Direction

The current codebase already uses feature folders. The missing layer is section-level folders under heavy presentation areas.

Recommended pattern for large features:

```text
feature/
  presentation/
    pages/
    widgets/
      section/
    providers/
    utils/
```

For especially heavy pages:

```text
pages/<page_name>/
widgets/<page_name>/
```

Either is fine. The key rule is that route/page files should mainly assemble, not define every leaf widget.

## Execution Order

1. `assistant_page.dart`
2. `today_dashboard_view.dart`
3. `record_dashboard_view.dart`
4. `report_sections.dart`
5. `medicine_reminder_pages.dart`
6. `medicine_workspace_view.dart`
7. `record_nlp_sheet.dart`
8. secondary 300-600 files as they are touched

## Validation

For each split step:

- `flutter analyze`
- run focused widget/unit tests for the touched feature

After each major presentation split:

- verify the affected route visually if possible

## Expected Observable Outcome

- no hand-written frontend file above 600 lines without explicit justification
- most page files become route assemblers rather than widget dumps
- section widgets become easier to test and safer to evolve during the next feature passes
