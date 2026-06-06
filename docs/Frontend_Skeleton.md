# Luminous Frontend Skeleton

Last updated: 2026-06-06

This document is the owner reference for Luminous frontend structure, visual direction, component rules, styling system, module boundaries, and implementation order. Current product status still lives in `UI_Implementation_Plan.md`; historical changes live in `MigrationLog.md`.

## Positioning

Luminous is a personal health assistant app, not a marketing site. The UI should feel calm, precise, and useful for repeated daily use.

Design direction:

- Low-saturation flat health-tool style with gentle depth.
- Default light/dark themes plus blue-pink and yellow-green palette variants.
- White/soft canvas surfaces, restrained color accents, and readable data hierarchy.
- Cards/surfaces should not feel heavy; page-level surfaces use `AppShadowTokens.level1`.
- Keep page chrome and static content visible while data loads; only backend-backed sections use local shimmer.
- Avoid narrative, onboarding, or promotional copy in normal app pages.
- Avoid pretending unsupported features are real. More/device/OCR/barcode/push/reminder execution stays planned until backend contracts exist.

## Technical Stack

- Flutter with Material 3.
- Riverpod for dependency injection and state.
- GoRouter for routing and deep links.
- Dio plus generated `lucent_openapi` for Lucent API access.
- ARB + `flutter gen-l10n` for all visible text.
- Shared design tokens under `lib/core/design/`.
- Shared theme generation under `lib/core/theme/`.
- Shared feedback via `lib/core/feedback/app_toast.dart`.
- Shimmer skeletons via shared state widgets.
- `flutter_animate` only for restrained page/content entrance motion where it does not complicate tests.

## Directory Structure

Top-level layout:

```text
lib/
  app/                 App entry wiring and router composition
  core/                Shared infrastructure, tokens, network, theme, widgets
  features/            Business features
  l10n/                ARB files and generated localization output
assets/
  icons/               Source app icons and reusable static assets
test/                  Widget, provider, mapper, and repository tests
```

Core layout:

```text
lib/core/
  constants/           Breakpoints and global constants
  design/              Color, spacing, radius, shadow, layout, typography tokens
  errors/              Shared error types
  extensions/          Generic Dart/Flutter extensions
  feedback/            Toast and lightweight feedback primitives
  i18n/                Locale helpers
  network/             Dio, generated-client wrapper, auth headers
  router/              Shared routing helpers
  theme/               ThemeData, extensions, theme preference controller
  widgets/             Shared UI primitives
```

Feature layout:

```text
lib/features/<feature>/
  data/
    datasources/       Remote/local service wrappers
    mappers/           DTO to domain mapping
    providers/         Data-layer provider wiring when needed
    repositories/      Repository implementations
  domain/
    entities/          Immutable feature models and write inputs
    repositories/      Repository interfaces
    usecases/          Optional only when business logic is meaningfully reused
  presentation/
    pages/             Route-level screens
    providers/         UI state providers/notifiers
    widgets/           Feature-specific visual components
```

Do not add code to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`, or `lib/components/`.

## Module Boundaries

`core/`:

- May contain framework-neutral or app-wide primitives.
- Must not know feature business rules.
- Owns design tokens, theme, network client wrapper, common state views, feedback, and shell scaffolding.

`features/<feature>/domain/`:

- Owns local domain entities, repository interfaces, and write input types.
- Must not import generated OpenAPI DTOs.
- May expose types consumed by another feature only when the data is a real cross-feature concept.

`features/<feature>/data/`:

- May import `lucent_openapi`.
- Wraps generated clients in datasources/repositories.
- Maps DTOs into local domain entities.
- For nullable writes, preserve omitted / explicit null / concrete value semantics. Use raw Dio JSON maps when generated DTO serializers would drop explicit null.

`features/<feature>/presentation/`:

- Owns pages, UI state, and feature widgets.
- Must use ARB text.
- Should not import another feature's presentation widgets.
- Cross-feature refreshes happen through provider invalidation, not by reaching into another page.

Cross-feature examples:

- Record writes refresh Record and Today providers.
- Medicine dose actions refresh Medicine and Today providers.
- Search add-to-current-medicines refreshes Health Context, Medicine, and Today when those depend on it.
- Account mutations refresh auth/account state and Mine account summary when applicable.

## Component Library

Shared components live in `lib/core/widgets/` and should be promoted only when two or more features need the same behavior.

Current shared primitives:

- `PageScaffoldShell`: standard app page shell with responsive content frame.
- `ResponsiveContentFrame`: content width constraints for mobile/desktop.
- `AppStateErrorView`: page-level error state.
- `AppStateMessageView`: compact message/empty/error card.
- `AppStateSkeletonView`: page skeleton when the whole non-scrollable body is genuinely unavailable.
- `AppInlineSkeleton`, `AppInlineSkeletonBlock`, `AppInlineSkeletonCircle`, `AppInlineSkeletonSection`: local loading placeholders inside real page structure.
- `AppImagePlaceholder`: localized static media placeholder.
- `AppToast`: lightweight overlay feedback.

Feature components stay local until reuse is proven:

- Header action chips may remain feature-specific if copy, color, or behavior differs.
- Section surfaces may remain feature-specific while visual density differs.
- Feature copy helpers such as `medicineCopy`, `mineCopy`, and `moreCopy` stay in the feature.

Promotion rule:

- Promote to `core/widgets` only when the component has no feature vocabulary, no feature routing, no feature provider dependency, and at least two features need the same contract.

## Styling System

Use tokens instead of page-local magic values:

- Colors: `AppColorTokens`, `Theme.of(context).colorScheme`, `AppThemeSurface`.
- Spacing: `AppSpacingTokens`.
- Radius: `AppRadiusTokens`.
- Shadows: `AppShadowTokens`.
- Typography: `AppTypographyTokens`.
- Layout width and padding: `AppLayoutTokens`, `AppBreakpoints`.

Rules:

- Do not fix inconsistent page usage by changing token numeric values.
- Do not create one-off page colors when a theme surface or token exists.
- Page-level surfaces normally use `AppShadowTokens.level1`.
- Higher shadows are reserved for floating feedback, modal-like overlays, and auth panels.
- Text size must fit the container; avoid viewport-scaled font sizes.
- Cards should have restrained radius and should not be nested inside other cards.
- Page sections are full-width layouts or single surfaces, not stacked decorative card shells.
- Loading states preserve page chrome and static content.

## Routing And Navigation

- Use GoRouter.
- Do not add `Navigator.push(MaterialPageRoute(...))`.
- Settings, Mine, and account child pages use standard child-page header: back arrow and centered title.
- Do not use bottom sheets for routine settings/account flows.
- Route tests should prove important taps open the intended path.

## State And Data Flow

Default flow:

```text
Page / Widget -> presentation provider/notifier -> domain repository interface -> data repository -> datasource -> Lucent/OpenAPI/local storage
```

Rules:

- Widgets render state and call callbacks; they do not call Dio or generated APIs.
- Repositories are the data boundary and error normalization point.
- Use Riverpod overrides in tests.
- Signed-out providers must avoid repeated protected API calls.
- Successful writes invalidate all affected providers.
- Use domain input objects for writes; generated write DTOs are not presentation/domain API.

## Localization

- All visible text goes through `lib/l10n/app_zh.arb` and `lib/l10n/app_en.arb`.
- Run `flutter gen-l10n` after ARB changes.
- Do not hardcode user-facing toast, button, label, empty, error, or title strings.
- Feature copy helpers may map enum keys to localized strings inside presentation widgets.

## Testing Rules

Minimum checks for frontend changes:

```bash
flutter analyze
flutter test
```

Targeted checks:

- Theme/settings: `test/app_theme_controller_test.dart`, `test/settings_flow_test.dart`.
- Auth/account: `test/login_page_test.dart`, `test/account_settings_page_test.dart`, auth-specific page tests.
- Record: `test/record_page_test.dart`.
- Medicine: `test/medicine_page_test.dart`.
- Today: `test/today_page_test.dart`.
- Search: `test/search_page_test.dart`.
- More: `test/more_page_test.dart`.

Layout-sensitive work should verify mobile and desktop widths. When environment allows, inspect screenshots or run the app.

## Implementation Plan

Phase 1: stabilize the skeleton.

- Treat this document as the frontend skeleton owner.
- Keep `UI_Implementation_Plan.md` focused on current product/UI status.
- Keep `MigrationLog.md` focused on timeline.
- Add missing tests for skeleton rules when bugs repeat.

Phase 2: consolidate shared primitives.

- Audit duplicated section surfaces and header chips.
- Promote only feature-neutral components to `core/widgets`.
- Keep feature-specific visual language local.

Phase 3: harden data boundaries.

- Search for generated DTO leakage after every OpenAPI regeneration.
- Add payload tests for nullable writes.
- Keep signed-out states stable.

Phase 4: tighten visual consistency.

- Audit token usage across Today, Record, Medicine, Mine, More, Settings, Account, and Search.
- Fix inconsistent token usage at call sites.
- Do not change token values just to hide inconsistency.

Phase 5: expand real integrations only after contracts.

- More, reminders, OCR/barcode, and device features need Lucent contracts before real UI claims.
- Until then, show planned/static states honestly.

## Review Checklist

- [ ] New files live under `core/`, `features/`, `app/`, `l10n/`, or `assets/`.
- [ ] Feature code follows data/domain/presentation boundaries where applicable.
- [ ] No generated OpenAPI DTOs in domain/presentation.
- [ ] Visible text is localized.
- [ ] Loading is local unless the whole page truly has no static structure.
- [ ] Error states use shared state views.
- [ ] Writes invalidate dependent providers.
- [ ] Routes use GoRouter.
- [ ] Tokens are used consistently without changing token values opportunistically.
- [ ] Docs updated when behavior, API, l10n, or UI plan changes.
