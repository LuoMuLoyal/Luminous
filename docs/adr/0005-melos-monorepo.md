# ADR-0005: Melos Monorepo Management

- **Status**: accepted
- **Date**: 2026-06-05
- **Deciders**: LuoMuLoyal

## Context

The Flutter project needed a way to run multi-step validation scripts (`flutter analyze` + `flutter test` + OpenAPI regeneration checks) consistently across development and CI. Ad-hoc shell scripts and PowerShell wrappers were fragile across platforms (Windows/macOS/Linux) and hard to maintain.

## Decision

Use `melos` as the monorepo/workspace script runner. Define workspace-level scripts in `melos.yaml` that can be invoked with `melos run <script>`. Keep tool-specific logic in Dart scripts under `tool/`.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Melos | Cross-platform, Dart-native, workspace awareness, bootstrap/clean commands | Adds a dependency, yaml configuration |
| Shell scripts (.sh/.ps1) | No dependency, simple | Platform-specific, hard to compose, error-prone |
| Makefile | Cross-platform with gmake | Not native to Flutter/Dart ecosystem, Windows support requires extras |
| VS Code tasks | IDE-integrated | Not CI-friendly, not shareable across editors |

## Consequences

- `melos run daily` — runs gen-l10n + dart format check + flutter analyze + flutter test.
- `melos run fullstack` — starts Lucent test runtime + runs full E2E lane.
- Scripts work identically on Windows, macOS, and Linux.
- `tool/` contains Dart scripts invoked by melos commands (not replaced by melos).
- CI workflow (`flutter-ci.yml`) invokes the same melos commands as local development.
- Git hooks (`pre-commit`, `pre-push`) also use melos commands via `tool/install_git_hooks.dart`.
