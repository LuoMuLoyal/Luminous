# Repository Guidelines

## Project Structure & Module Organization

`lib/` is the Flutter app. Legacy code has mostly moved out of the old `pages/`, `components/`, `stores/`, and `viewmodels/` roots; new migration work should continue toward `lib/core/`, `lib/shared/`, and `lib/features/`. Keep platform runners in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`. Flutter tests live in `test/`, with fakes in `test/support/`. `Lucent/` is the Git submodule for the target backend. The old `backend/` Express service is deprecated and low-priority reference material only, except for temporary checks against the currently deployed legacy service. Long-form plans and alignment notes belong in `docs/`. Generated presentation artifacts in `outputs/` must stay out of commits.

## Build, Test, and Development Commands

- `flutter pub get`: install Flutter dependencies.
- `flutter run`: run the app locally.
- `flutter analyze`: run Dart static analysis.
- `flutter test`: run Flutter unit and widget tests.
- `dart format lib test`: format Flutter code before commit.
- `flutter gen-l10n`: regenerate `lib/l10n/app_localizations*.dart` after editing `lib/l10n/app_*.arb`.
- `npm install --prefix backend`: install backend dependencies.
- `npm run dev --prefix backend`: start the backend in development.
- `npm test --prefix backend`: run backend `*.test.ts` files.
- `npm run build --prefix backend`: compile TypeScript to `backend/dist`.
- `pnpm install --dir Lucent`: install target backend dependencies.
- `pnpm --dir Lucent start:dev`: start the target NestJS backend during Lucent development.
- `docker compose up -d --build`: start the full local stack.

## Coding Style & Migration Rules

Follow `.editorconfig`: UTF-8, LF, final newline, trimmed trailing whitespace; only `.bat` and `.ps1` use CRLF. Use 2-space indentation. Keep Dart files `snake_case.dart`, Flutter classes `UpperCamelCase`, and backend modules `kebab-case.ts`.

During migration, split large files early: aim for a single file under 300 lines, 300-600 lines is acceptable, and anything over 600 lines should be split before adding more behavior. Do not keep adding new migration code to old layer-based folders unless it is a small compatibility patch; prefer landing new shared infrastructure in `lib/core/`, reusable widgets in `lib/shared/`, and business slices in `lib/features/`.

Backend migration work belongs in `Lucent/`, not in the deprecated Express `backend/` tree. The target backend stack is NestJS + PostgreSQL + Prisma + Redis + Passport JWT. New backend APIs should be versioned, starting at `/api/v1`, and should derive user identity from JWT guards rather than trusting a client-supplied `userId`. The new Lucent protocol is allowed to break from the legacy Express `/api/*` request bodies and `{ code, msg, result }` envelope; use `Lucent/docs/api-contract.md` as the protocol source of truth.

The target medicine data source is outside Git at `D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase`. It contains the detailed Chinese `FullDrugDetail.xlsx` and English DrugBank files. Treat these files as import sources for Lucent/PostgreSQL only: do not commit them, do not add them to Flutter assets, and do not make Flutter scan them directly.

Document boundaries: Luminous docs cover Flutter/client migration and cross-project coordination; Lucent docs cover backend protocol, data imports, database, modules, and deployment. Keep root READMEs as entrypoints and move detailed plans into `docs/`.

## Testing Guidelines

Name Flutter tests `*_test.dart`, legacy backend tests `*.test.ts`, and Lucent tests using the Nest/Jest conventions already in the submodule. Every behavior change should add or update at least one focused regression test. The default Flutter gate is `flutter analyze` and `flutter test`. Legacy Express checks are `npm test --prefix backend` and `npm run build --prefix backend` only when touching legacy reference code. Lucent backend checks should use the `pnpm --dir Lucent ...` scripts.

## Commit & Pull Request Guidelines

Use Conventional Commits with concise Chinese summaries, for example `refactor(settings): 迁移装饰状态到 Riverpod`. Keep branches short-lived (`feat/*`, `fix/*`, `docs/*`, `refactor/*`, `chore/*`) and keep each commit scoped to one change. PRs should include the change summary, validation commands, linked issues when relevant, and screenshots for UI changes. Never commit `.idea/`, `build/`, `backend/dist/`, `backend/node_modules/`, `outputs/`, real backend env files, or local copies of `DrugDataBase`.
