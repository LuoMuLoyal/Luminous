## Summary

<!-- Brief description of what this PR does and why. -->

## Type of change

- [ ] feat — new feature
- [ ] fix — bug fix
- [ ] docs — documentation only
- [ ] refactor — code restructuring without behavior change
- [ ] perf — performance improvement
- [ ] test — test additions or fixes
- [ ] chore — tooling, dependencies, CI
- [ ] ci — CI/CD configuration

## Checklist

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] `dart run tool/run_daily_checks.dart` passes (if applicable)
- [ ] ARB files changed → ran `flutter gen-l10n`
- [ ] Lucent API changed → ran `cd generated/lucent_api && dart run build_runner build`
- [ ] No hardcoded user-visible strings (all text through ARB / l10n)
- [ ] Proper loading / empty / error states (shimmer skeletons, `AppStateErrorView`)
- [ ] New code only under `lib/features/`, `lib/core/`, or `lib/shared/`
- [ ] Documentation updated (migration log, current state, localization ref if applicable)

## Breaking changes

<!-- If this PR introduces breaking changes, describe them here and why they are necessary.
If there are no breaking changes, delete this section. -->

## Related issues

<!-- Link any related issues, e.g. "Closes #123". -->
