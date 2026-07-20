# AGENTS.md — L10n Directory

## CRITICAL: ARB Source-of-Truth Rules

**Never edit `app_zh.arb` or `app_en.arb` directly.**

These two files are **generated** by merging the fragment files in `src/`.
Any direct edit will be **lost** on the next merge.

### Source of truth

The fragment files in `src/` are the canonical source:

| Fragment   | Key prefix(es)                  |
|------------|----------------------------------|
| common     | `app`, `tab`, `state`, `placeholder`, `legal` |
| record     | `record`                         |
| medicine   | `medicine`, `scan`               |
| today      | `today`                          |
| report     | `report`                         |
| settings   | `settings`, `sidebar`            |
| auth       | `auth`                           |
| mine       | `mine`                           |
| assistant  | `assistant`                      |
| notification | `notification`                 |

Each fragment exists as `{name}_zh.arb` and `{name}_en.arb`.

### Correct workflow

1. **Edit** the fragment file(s) in `src/` (e.g., `src/record_zh.arb`).
2. **Merge**: `dart scripts/arb_tools.dart merge` — regenerates `app_zh.arb` and `app_en.arb` from all fragments.
3. **Generate**: `flutter gen-l10n` — regenerates `app_localizations.dart` and related files.

Or run `dart run tool/bootstrap_generated_sources.dart` which includes merge + gen-l10n + build_runner.

### Merge tool

`scripts/arb_tools.dart` supports two commands:

```bash
dart scripts/arb_tools.dart merge    # src/ → app_zh.arb, app_en.arb
dart scripts/arb_tools.dart split    # app_zh.arb → src/ (re-split, rarely needed)
```

### Adding a new feature module

1. Add a new fragment pair: `src/{name}_zh.arb` and `src/{name}_en.arb`.
2. Add the fragment name and its key prefix(es) to `fragmentRules` in `scripts/arb_tools.dart`.
3. Run `dart scripts/arb_tools.dart merge && flutter gen-l10n`.
4. Update `docs/02-reference/Localization.md` with the new fragment ownership.
