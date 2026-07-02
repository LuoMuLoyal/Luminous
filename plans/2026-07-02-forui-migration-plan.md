# Forui Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Luminous's hand-written base UI system with Forui as the primary UI foundation in one aggressive migration window, while preserving only business-semantic shells and product-specific flows.

**Architecture:** This is a near-one-shot frontend migration, not a wrapper exercise. Forui becomes the new primitive layer for theme, surface, form, dialog, sheet, navigation primitives, and interactive controls. Existing `core/design`, `core/theme`, and generic shared widgets are either rewritten as thin product-structure shells on top of Forui or removed entirely; business-specific flows such as auth gating, delete confirmation, error/loading semantics, and page skeletons stay local.

**Tech Stack:** Flutter 3.44.0, Dart 3.12.0, Riverpod, GoRouter, hooks_riverpod, flutter_hooks, Forui `^0.23.0`, existing l10n and Lucent-generated client.

---

## Assumptions

- The migration is intentionally aggressive: short-term diff size and page rewrites are acceptable.
- A temporary frontend feature freeze is acceptable during the migration window, except for blocker bugs required to land the migration safely.
- Visual reset is explicitly allowed. The goal is not to preserve the current handcrafted aesthetic.
- Future library swap cost is not optimized here. This plan values replacing the old hand-written base layer quickly over preserving a generic abstraction layer.
- No git commit steps are included in this plan. Repository policy requires commits to happen only in a dedicated task named exactly `Execute Git Commit`.

## Non-Goals

- Do not build generic `AppButton`, `AppInput`, `AppSwitch`, `AppDialog` aliases that only forward Forui APIs.
- Do not preserve the old token contract just to minimize call-site churn.
- Do not run old and new primitive systems in parallel for an open-ended period.
- Do not opportunistically refactor data/domain code unrelated to UI migration.
- Do not treat desktop-first polish as a primary acceptance target; mobile remains the product surface.

## Success Criteria

- All five main tab surfaces (`today / record / medicine / report / mine`) render with the new Forui-led visual system.
- Shared primitive usage no longer depends on old handcrafted token entry points such as `AppTypographyTokens`, `AppThemeSurface`, `AppSpacingTokens`, or `AppRadiusTokens` for active page rendering.
- Generic shared widgets that exist only to emulate primitive controls are either removed or rewritten as product-structure shells.
- No new page or feature code introduced during the migration window extends the old UI system.
- `flutter analyze`, `flutter test`, and the repo daily gate pass after migration.
- Manual mobile walkthrough verifies shell navigation, auth gating, record CRUD, medicine reminder flows, report range/export actions, and settings interactions still work.

## Freeze Rules

- Freeze new frontend feature work until the migration branch reaches the success criteria above.
- Allow only blocker fixes that are required to land or validate the migration.
- Do not add new capabilities to `lib/core/design/`, `lib/core/theme/`, `lib/core/widgets/common/`, or `lib/core/widgets/settings/` unless the change is directly part of migration removal/bridging.
- During migration, any touched page must move forward to the new primitive layer; do not patch touched pages back into the old handcrafted styling system.

## File Map

### Direct foundation files

- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\pubspec.yaml`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\app\app.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\theme\app_theme.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\theme\app_theme_extensions.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\theme\app_theme_controller.dart`
- Review for deletion/freeze: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\design\*.dart`

### Shared structure widgets to keep or rewrite

- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\layout\page_scaffold_shell.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_back_button.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_state_views.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_dialog.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_header_action_chip.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_text_action.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_section_surface.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\settings\app_setting_row.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\settings\app_settings_navigation_row.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\settings\app_settings_switch_row.dart`
- Review for deletion/rewrite: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\settings\app_settings_section.dart`

### Main page surfaces that must migrate in the same window

- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\shell\presentation\shell_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\today\presentation\pages\today_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\medicine_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\report\presentation\pages\report_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\mine\presentation\pages\mine_page.dart`

### High-risk secondary flows that must not remain visually stranded

- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_create.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_detail.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_edit.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\medicine_risk_check_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\reminder\medicine_reminder_detail_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\reminder\medicine_reminder_edit_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\search\presentation\pages\search_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\assistant\presentation\pages\assistant_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\notification\presentation\pages\notification_list_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\notification\presentation\pages\notification_detail_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\auth\presentation\pages\login_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\auth\presentation\pages\register_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\auth\presentation\pages\forgot_password_page.dart`

### Docs and plan artifacts

- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\docs\Current_State.md`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\docs\architecture.md`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\docs\migration-log\2026-07-02.md`
- Modify if rules change materially: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\AGENTS.md`
- Delete when execution is complete: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\plans\2026-07-02-forui-migration-plan.md`

---

## Working Inventory

Freeze rule recorded for execution: during this migration window, no new frontend feature work and no new additions to the old handcrafted UI system are allowed. Any touched UI must move toward Forui primitives.

Dependency inventory snapshot:

- Old token usage (`AppThemeSurface`, `AppTypographyTokens`, `AppSpacingTokens`, `AppRadiusTokens`) still spans shared infrastructure plus high-traffic feature surfaces such as `record`, `report`, `search`, `auth`, `today`, and `settings`.
- `PageScaffoldShell` remains a critical shared wrapper with many inbound callers across record, medicine, mine, assistant, and settings pages, so it must be rewritten rather than removed first.
- `AppStateErrorView` is also a critical shared state surface used across today, report, mine, medicine, search, and record paths, so it should stay but be visually rewritten on Forui.
- Dialog usage is still mixed: shared `AppDialog` exists, but several flows still call raw `AlertDialog`, `Dialog`, and `showDialog` directly. The migration should move shared dialog structure to Forui first, then clean call sites.
- Modal bottom sheets are still present in record/scan flows; those are in-scope later, but they do not block the shared-shell rewrite.

Shared UI classification:

- `keep as product shell`:
  - `PageScaffoldShell`
  - `PageSectionCard`
  - `AppBackButton`
  - `AppStateErrorView`
  - `AppDialog`
- `rewrite on Forui`:
  - `AppTextAction` if still needed after page rewrites
  - `AppHeaderActionChip` if still needed after page rewrites
- `delete after call-sites move`:
  - `AppSectionSurface`
  - `AppSettingRow`
  - `AppSettingsSection`
  - `AppSettingsNavigationRow`
  - `AppSettingsSwitchRow`

Execution note:

- Shared-shell work should land before broad page rewrites so the remaining page migrations can consume the new Forui-based structure instead of entrenching more old token usage.

### Task 3: Rewrite shared shells, not shared aliases

**Files:**
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\layout\page_scaffold_shell.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_back_button.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_state_views.dart`
- Modify or replace: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_dialog.dart`
- Modify or delete: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_text_action.dart`
- Modify or delete: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_header_action_chip.dart`
- Modify or delete: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\app_section_surface.dart`

- [ ] Keep `PageScaffoldShell` only if it still expresses product layout structure that Forui should not own. Rewrite its internals so it composes Forui surfaces, spacing, and headers instead of old handcrafted tokens.
- [ ] Keep `AppBackButton` only as navigation semantics (`pop` or fallback route). Move its visuals to Forui-compatible button/icon primitives.
- [ ] Keep `AppStateErrorView` and loading shells only as shared product states. Remove any styling code that exists only to mimic an old token palette.
- [ ] Replace `AppDialog` internals with Forui dialog primitives if the file still earns its keep as a common shell; otherwise delete it and migrate its few call sites directly.
- [ ] Delete any shared widget whose only job was “styled button/chip/text action” if Forui already provides the needed primitive cleanly.

**Expected observable result:**
- The remaining shared widget layer expresses product structure and behavior, not generic primitive aliases.

### Task 4: Rebuild the app shell and the five main tab surfaces in one visual pass

**Files:**
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\shell\presentation\shell_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\today\presentation\pages\today_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\medicine_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\report\presentation\pages\report_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\mine\presentation\pages\mine_page.dart`

- [ ] Rewrite the shell navigation visuals first so every migrated page lands inside the same new frame.
- [ ] Migrate the five main tab surfaces in the same window. Do not leave one or two tabs visibly on the old system after the shell changes.
- [ ] Replace card, list item, header, section, tab, pill, and filter visuals with Forui primitives or new Forui-based shells.
- [ ] Remove old per-page dependence on `AppThemeSurface`, `AppTypographyTokens`, `AppSpacingTokens`, and handcrafted panel decoration helpers.
- [ ] Keep route structure, provider wiring, and business logic stable while the visuals are rebuilt.

**Expected observable result:**
- The main signed-in experience reads as one coherent new product rather than a partially migrated shell.

### Task 5: Migrate high-frequency drill-down pages before reopening feature work

**Files:**
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_create.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_detail.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\record\presentation\pages\record_edit.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\medicine_risk_check_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\reminder\medicine_reminder_detail_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\medicine\presentation\pages\reminder\medicine_reminder_edit_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\search\presentation\pages\search_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\settings_page.dart`

- [ ] Migrate the record create/detail/edit flow as one bundle so form fields, validation messages, dialogs, and quick actions share the same new primitive system.
- [ ] Migrate medicine reminder and risk-check pages in the same pass because they rely heavily on dialog/form/status UI.
- [ ] Migrate search and settings immediately after, since they are dense with input rows, list items, filters, and confirmation interactions.
- [ ] Remove old handcrafted row/card/dialog helpers once these call sites stop needing them.

**Expected observable result:**
- The highest-traffic sub-pages no longer snap users back into the old UI language.

### Task 6: Finish the remaining auth, assistant, notification, and secondary settings surfaces

**Files:**
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\auth\presentation\pages\login_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\auth\presentation\pages\register_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\auth\presentation\pages\forgot_password_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\assistant\presentation\pages\assistant_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\notification\presentation\pages\notification_list_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\notification\presentation\pages\notification_detail_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\about_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\advanced_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\ai_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\data_export_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\help_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\language_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\notification_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\sleep_reminder_settings_page.dart`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\features\settings\presentation\pages\theme_settings_page.dart`

- [ ] Migrate auth pages as a mini-suite so sign-in, register, forgot-password, and account shells feel consistent.
- [ ] Migrate assistant and notification surfaces after the main pages so any streaming/list/detail affordances are expressed in the new system too.
- [ ] Finish the remaining settings sub-pages before declaring the migration window complete.

**Expected observable result:**
- There are no obvious “old UI islands” left in the currently supported mobile product surface.

### Task 7: Delete dead handcrafted infrastructure and tighten rules against regression

**Files:**
- Delete or drastically shrink: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\design\*.dart`
- Delete or drastically shrink: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\theme\app_theme_extensions.dart`
- Delete obsolete files in: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\common\`
- Delete obsolete files in: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\lib\core\widgets\settings\`
- Modify if needed: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\AGENTS.md`

- [ ] Remove old token files and widget helpers that no longer have legitimate call sites.
- [ ] Add or tighten project instructions so future work does not reintroduce handcrafted base components or mixed primitive systems.
- [ ] Run `rg` again for old token and widget symbols; the remaining matches should be only intentional compatibility shims or historical comments slated for removal.

**Expected observable result:**
- The old handcrafted UI system is materially gone, not just abandoned while still linked everywhere.

### Task 8: Verify broadly, update docs, and close the migration window

**Files:**
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\docs\Current_State.md`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\docs\architecture.md`
- Modify: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\docs\migration-log\2026-07-02.md`
- Delete when done: `D:\25080\Documents\VSCodeProject\Lumos\Luminous\plans\2026-07-02-forui-migration-plan.md`

- [ ] Run:
  - `flutter pub get`
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test`
  - `dart run tool/run_daily_checks.dart`
- [ ] If shared shell behavior or major navigation interactions changed in unexpected ways, also run `dart run tool/run_fullstack_checks.dart` or the narrower relevant integration lane(s).
- [ ] Perform a manual emulator walkthrough covering:
  - five-tab shell navigation
  - login gating and return flows
  - record create/detail/edit
  - medicine reminder create/detail/edit/delete
  - report range switching and export actions
  - settings toggles and sub-pages
- [ ] Update `Current_State.md` to describe the new Forui-led UI foundation and removal of the old handcrafted base system.
- [ ] Update `architecture.md` so the design-system section no longer claims handcrafted token ownership as the active base layer.
- [ ] Append the migration outcome to `docs/migration-log/2026-07-02.md`.
- [ ] After stable facts are captured in repo docs, delete this plan file.

**Expected observable result:**
- The migration is validated, documented, and no longer driven by a temporary execution plan.

---

## Verification Notes

- Because this migration replaces shared visual infrastructure rather than isolated business logic, narrow checks are not enough. Broad repo-level validation is required before calling the work done.
- The most likely hidden regressions are:
  - shell navigation spacing and safe-area handling
  - auth form focus/error states
  - dialog and bottom-sheet dismissal behavior
  - settings row interactions
  - record and medicine form density/overflow on small screens

## Rollback Trigger

If, after Task 4 and Task 5, the main product path still requires substantial old token infrastructure to render correctly, stop and reassess rather than dragging a mixed system forward. The accepted risk is a large rewrite, not an indefinite half-migrated codebase.
