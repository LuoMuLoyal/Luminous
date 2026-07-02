# Auth Forui Migration Pattern

Last updated: 2026-07-02

This document records the stable migration pattern used to move the auth surface from the old custom widget stack to direct Forui composition. It is meant to be reused by later page migrations.

## Goal

- Remove auth-local wrapper components and old visual tokens.
- Prefer official Forui form, tab, checkbox, toast, dialog, and card patterns directly.
- Keep layout and routing behavior stable while simplifying the UI shell.

## Scope Covered

- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/change_email_page.dart`
- `lib/features/auth/presentation/pages/account_settings_page.dart`
- `lib/features/auth/presentation/pages/account_settings_sections.dart`
- `lib/features/auth/presentation/widgets/auth_shell.dart`
- `lib/features/auth/presentation/widgets/auth_branding.dart`

## What We Replaced

- Removed auth-local input/action/status wrappers:
  - `auth_text_field.dart`
  - `auth_action_row.dart`
  - `auth_status_message.dart`
  - `auth_field_error.dart`
- Replaced old submit-only validation with real `Form` + `GlobalKey<FormState>`.
- Replaced page-local custom section stacks with direct `FCard`, `FTabs`, `FButton`, `FCheckbox`, `FToast`, and `FDialog`.

## Stable Pattern

### 1. Use direct Forui form fields

- Prefer `FTextFormField.email` and `FTextFormField.password` when the field type matches.
- Use `autovalidateMode: AutovalidateMode.onUserInteraction`.
- Put validation on the field instead of separate error widgets.

### 2. Keep page state simple

- Use `useTextEditingController()` in auth pages.
- Use `Form` + `GlobalKey<FormState>` for submit gating.
- Keep submit buttons small and right-aligned when matching official examples.

### 3. Move mode switches outside the form body when they are top-level choices

- Login password/code switch now lives between the header block and the form card.
- Use `FTabs` for the selector itself.
- Do not bury a top-level mode choice deep inside the form content when it changes the entire form branch.

### 4. Use one visible outer card per major pane

- Account settings uses top-level `FTabs`.
- Each tab pane uses one outer `FCard`.
- Avoid nested `card inside card inside section` stacks unless the inner card represents a clearly distinct object.

### 5. Treat agreement flows as form controls, not footer copy

- Registration terms consent now uses `FCheckbox`.
- Submit stays disabled until consent is accepted.
- Terms/privacy links should open real destinations instead of placeholder toasts when possible.

## Auth Shell Rules

- `auth_shell.dart` should stay a thin layout wrapper only.
- It may provide:
  - page spacing
  - centered content width
  - header/logo/subtitle placement
  - optional selector slot between header and form
- It should not become a secondary theme system.
- It should not force a page-local `Theme`/`FTheme` override as a long-term solution.

## Theme Rules

- Prefer fixing theme issues at the shared root theme layer.
- Current root preset is Forui `neutral`.
- Avoid page-local forced theme overrides unless debugging; remove them after the real source is identified.

## Logo Rules

- Do not wrap the auth logo in a custom gradient/shadow tile just to make it feel designed.
- Prefer the raw asset, or replace the asset itself if the source image still feels off.
- If the asset color is wrong, fix the asset or the shared theme, not by stacking more local visual effects by default.

## Things We Tried And Rejected

- Forcing a local auth-only `Theme` + `FTheme` override:
  - It can hide the real source of theme bleed.
  - It can diverge auth from the rest of the app.
  - It already caused collateral UI regressions and was reverted.
- Color-filtering the logo into monochrome:
  - It can break assets with baked backgrounds or non-transparent regions.
  - It is not a safe default replacement for fixing the actual icon asset.

## Recommended Checklist For Future Page Migrations

1. Replace wrapper widgets with direct Forui primitives.
2. Move validation into `Form` + `FTextFormField`.
3. Collapse nested cards into one clear outer card per section.
4. Replace placeholder affordances with real interactions.
5. Verify that theme changes come from the shared root, not local force overrides.
6. Run `flutter analyze` for the touched feature, then full `flutter analyze`.

## Verification Used For This Auth Migration

- `flutter analyze lib/features/auth`
- `flutter analyze`

`flutter test` was intentionally skipped during this migration phase per the active acceleration directive.
