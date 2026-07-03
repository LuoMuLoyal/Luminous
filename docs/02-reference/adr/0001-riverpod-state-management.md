# ADR-0001: Riverpod State Management

- **Status**: accepted
- **Date**: 2026-05-30
- **Deciders**: LuoMuLoyal

## Context

The Flutter app needed a state management solution that supports reactive UI, dependency injection,
and testability. The legacy codebase used GetX (`GetBuilder` + `Get.put`), which coupled business
logic tightly to the widget tree and made testing difficult.

## Decision

Migrate all state management to `flutter_riverpod`. Use `StateNotifier`/`AsyncNotifier` for mutable
state, `Provider` for DI, and `FutureProvider`/`StreamProvider` for async data.

## Options Considered

- Riverpod
  - Pros: Compile-safe, testable without widget tree, auto-dispose, family/modifier API
  - Cons: Learning curve for provider scoping
- Bloc
  - Pros: Strong separation of events/states, popular in enterprise Flutter
  - Cons: Boilerplate-heavy, event classes add indirection for simple state
- Provider
  - Pros: Simpler API, widely adopted
  - Cons: No compile-time safety, manual disposal, less powerful for complex state
- GetX (keep)
  - Pros: Already in place
  - Cons: Tight coupling, hard to test, route/DI/snackbar mixing concerns

## Consequences

- All state is testable without `WidgetTester` (unit-test providers directly).
- `ref.watch`/`ref.listen`/`ref.read` API is consistent across all provider types.
- Legacy `lib/stores/` and `lib/viewmodels/` are frozen; no new GetX code.
- Provider scoping (`ProviderScope`) allows per-test override of dependencies.
- `autoDispose` prevents memory leaks from stale providers.
