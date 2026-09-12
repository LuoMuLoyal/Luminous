# Luminous Migration Log

Last updated: 2026-09-12

Records changes after the full reset only. The directory is the index: browse
`docs/logs/migration-log/` (one file per date, newest first by name). Older
entries live under `docs/archive/<YYYY-MM>/` — one folder per month, file names
unchanged (e.g. `docs/archive/2026-06/`, `docs/archive/2026-08/`).

Pre-reset history and inactive long-form docs were moved outside git to the
workspace-level archive, under the `docs-archive/2026-06-06-doc-cleanup` folder.

## How To Update

- Append to today's `docs/logs/migration-log/YYYY-MM-DD.md`; if the date file does not
  exist yet, create it with the title `# Migration Log - YYYY-MM-DD`.
- Do not maintain summary lists or topic indexes here — the date files are the record,
  and duplicated indexes rot.
- Move older entries to `docs/archive/<YYYY-MM>/` when they are no longer part of
  the active sprint — one folder per month, `YYYY-MM-DD.md` file name unchanged.
  Use concrete dates; never move old history back.

## Archived Entries

Browse the month folders under `docs/archive/` (e.g. `docs/archive/2026-08/`).
