# ADR-0008: Result Type and Unified Error Handling

- **Status**: accepted (amended 2026-08-18; previous self-built Result decision superseded)
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal
- **Related**: Lucent ADR-0012, RFC 9457 Problem Details

## Context

Luminous previously relied on repository methods returning `Future<T>` and exceptions being caught in
providers or widgets. The same error was therefore handled differently in different features. The
repository signature did not tell callers which failures were expected, and the client had several
copies of the same `try-catch` and toast mapping logic.

The original decision introduced a small local `Result<T>` type, `AppError`, and `runGuarded`. That
reduced some repetition, but it created another project-specific abstraction and did not establish
a complete repository boundary. The 2026-08-17 inventory also found many silent catches, direct throws,
and old helper call sites. The original self-built Result decision is superseded by this amendment.

## Decision

### 1. Use fpdart only at the repository/provider boundary

Use the stable fpdart 1.x API, pinned to `^1.2.0` during this migration:

```dart
typedef AppEither<T> = Either<LucentFailure, T>;
typedef AppTaskEither<T> = TaskEither<LucentFailure, T>;
```

- Datasources keep `Future` and `Stream` because they own transport and streaming behavior.
- Repository interfaces and implementations expose `AppTaskEither<T>` for expected, recoverable
  failures.
- Providers run and fold the result into Riverpod `AsyncValue` or an explicit action state.
- Widgets consume `AsyncValue` and action state; they do not import fpdart or catch network errors.
- Only `Either` and `TaskEither` are in scope. Do not introduce fpdart `Option`, `Reader`, `State`,
  or unrelated functional abstractions.

fpdart is a control-flow/container dependency. It does not define the HTTP contract or error
vocabulary.

### 2. Use `LucentFailure` as the client failure vocabulary

`LucentFailure` represents a normalized, actionable failure at the client boundary. It may contain:

- a stable Lucent business `code`;
- a categorized kind such as network, authentication, business, server, or unknown;
- the HTTP status when a response exists;
- optional `traceId` for diagnostics;
- client-only `networkErrorCode` when no HTTP response exists;
- the original cause for logging/crash reporting, never for user-visible serialization.

`requestId` is not part of the target HTTP contract. It is retired in Lucent ADR-0010. HTTP Problem
Details fields such as `type`, `title`, `detail`, `errors`, `retryable`, and `traceId` are parsed by
the network layer and mapped into `LucentFailure`.

`LucentFailure` is not a programming exception. Protocol invariants, malformed generated payloads,
programming errors, cancellation, and SSE stream termination remain explicit throws or stream
errors and must not be disguised as an ordinary Left value.

### 3. Keep the layer responsibilities explicit

```text
Dio / datasource       Future<T> or Stream<T>
repository             TaskEither<LucentFailure, T>
provider               run() + fold/match -> AsyncValue / action state
widget                 render state and local UI effects only
```

The network layer maps RFC 9457 `application/problem+json` and transport failures to
`LucentFailure`. The API contract itself is defined by Lucent ADR-0012: successful responses return
the endpoint resource representation directly, and ordinary HTTP errors use Problem Details.

### 4. Perform a hard cut, not a permanent dual system

The migration is deliberately a concentrated freeze-window task. After it is complete:

- the local `Result<T>` type is deleted;
- `runGuarded` and feature-local equivalents are deleted;
- repositories no longer hide expected failures behind `Future<T>`;
- network `try-catch` is removed from widgets except for documented local UI-only behavior;
- no new code may introduce a second result abstraction or an undocumented silent fallback.

A catch is permitted only when it has an explicit recovery/degraded contract, structured logging,
an OTel event or metric where applicable, and a test for the user-visible outcome. `rethrow` is
permitted for programming errors, cancellation, protocol invariants, and intentionally propagated
stream failures.

### 5. HTTP response contract

The HTTP response shape is defined by Lucent ADR-0012. This ADR does not define a second wire format:
successful responses use endpoint resource representations, and ordinary HTTP errors use Problem
Details.

## Options Considered

### Keep the local Result, AppError, and runGuarded

Rejected. It is already under-adopted, duplicates a third-party functional container, and leaves
multiple call conventions for AI-assisted development to choose between.

### Use fpdart `Either` / `TaskEither`

Accepted. It is established in the Dart ecosystem, provides asynchronous composition, makes the
recoverable failure part of repository contracts, and integrates cleanly with Riverpod after a
single provider-side fold.

### Use `AsyncValue` as the repository result

Rejected. `AsyncValue` is a provider state container, not a domain/repository contract, and it does
not model one-shot actions or composition cleanly.

## Consequences

- Repository, provider, mock, and feature tests change together during the hard cut.
- The project pays a large one-time migration cost, but future AI-generated code has one repository
  failure convention and one client failure name.
- fpdart is isolated behind project typedefs, so replacing the package later does not change domain
  vocabulary.
- The generated API client remains transport-facing; it does not become the domain error contract.
- HTTP response fields and media types follow Lucent ADR-0012.

## References

- [Lucent ADR-0012: Error Contract and Result Boundary](../../../../Lucent/docs/01-reference/adr/0012-error-contract-and-result-boundary.md)
- Luminous research: `research/03-技术决策/api-response-error-contract-响应信封与问题详情.md`
- [RFC 9457: Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457.html)
- [ADR-0007: Network Layer Separation](0007-network-layer-separation.md)
