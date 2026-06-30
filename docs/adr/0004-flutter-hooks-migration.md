# ADR-0004: flutter_hooks Migration

- **Status**: accepted
- **Date**: 2026-06-28
- **Deciders**: LuoMuLoyal

## Context

Form-heavy pages used `StatefulWidget` with manual `TextEditingController` and `FocusNode` lifecycle management (`initState` → `dispose`). This pattern caused boilerplate, lifecycle bugs (controllers not disposed), and unnecessary widget rebuilds when controller state changed independently of other state.

## Decision

Migrate `TextEditingController` and `FocusNode` management from `StatefulWidget` to `flutter_hooks` (`useTextEditingController`, `useFocusNode`). Widgets that only manage form controllers can be converted from `StatefulWidget` to `HookWidget`.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| flutter_hooks | Auto-dispose, reduces boilerplate, scoped rebuilds | Additional package, learning curve for hook rules |
| Keep StatefulWidget | No dependency change | Manual lifecycle, boilerplate, dispose bugs |
| HookWidget for everything | Maximum consistency | Overkill for non-form widgets; not all widgets benefit from hooks |

## Consequences

- `TextEditingController` and `FocusNode` are auto-disposed when the widget is removed from the tree.
- Form widgets that only manage controllers become `HookWidget` (from `StatefulWidget`).
- Widgets with complex business logic remain `StatefulWidget` or `ConsumerWidget`.
- Auth form validation was simplified by eliminating manual controller cleanup.
- The migration was completed as part of the 2026-06-30 UX audit remediation.
