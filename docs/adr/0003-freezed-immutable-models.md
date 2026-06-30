# ADR-0003: Freezed Immutable Models

- **Status**: accepted
- **Date**: 2026-06-22
- **Deciders**: LuoMuLoyal

## Context

Domain entities need to be immutable for predictable state management with Riverpod. Manual `copyWith` implementations and equality overrides were error-prone and verbose. JSON serialization was also needed for API communication and local persistence.

## Decision

Use the `freezed` package for all domain entities. Freezed generates immutable data classes with `copyWith`, `==`/`hashCode`, `toString`, union types (sealed classes), and JSON serialization via `json_serializable`.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Freezed | Immutable, union types, auto-generated copyWith/equality/JSON | Code generation step, build_runner dependency |
| Manual immutable classes | No code-gen dependency | Boilerplate, error-prone copyWith, union types impractical |
| Equatable + json_serializable | Simpler than freezed, still code-gen | No union types, manual immutability enforcement |
| Mutable classes (no immutability) | Simplest code | Unsafe with Riverpod; accidental mutation bugs |

## Consequences

- All domain entities use `@freezed` annotation with `factory` constructors.
- Union types enable exhaustive `when`/`map`/`maybeWhen` pattern matching.
- `copyWith` is auto-generated for all fields, including nested objects.
- JSON serialization works via `@JsonSerializable` + freezed's `fromJson`/`toJson`.
- `build_runner` must be run after model changes.
- UI-layer `TextEditingController` values are converted to freezed models before state updates.
