# Repository Guidelines

## Project Structure & Module Organization

`lib/` is the Flutter app. Legacy code still lives in `pages/`, `components/`, `stores/`, and `viewmodels/`, but new migration work should move toward `lib/core/`, `lib/shared/`, and `lib/features/`. Keep platform runners in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`. Flutter tests live in `test/`, with fakes in `test/support/`. `backend/` is a Node 20+ Express service; source is under `backend/src/{routes,handlers,http,db,ai,config}`. Long-form plans and alignment notes belong in `docs/`. Generated presentation artifacts in `outputs/` must stay out of commits.

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
- `docker compose up -d --build`: start the full local stack.

## Coding Style & Migration Rules

Follow `.editorconfig`: UTF-8, LF, final newline, trimmed trailing whitespace; only `.bat` and `.ps1` use CRLF. Use 2-space indentation. Keep Dart files `snake_case.dart`, Flutter classes `UpperCamelCase`, and backend modules `kebab-case.ts`.

During migration, split large files early: aim for a single file under 300 lines, 300-600 lines is acceptable, and anything over 600 lines should be split before adding more behavior. Do not keep adding new migration code to old layer-based folders unless it is a small compatibility patch; prefer landing new shared infrastructure in `lib/core/`, reusable widgets in `lib/shared/`, and business slices in `lib/features/`.

## Testing Guidelines

Name Flutter tests `*_test.dart` and backend tests `*.test.ts`. Every behavior change should add or update at least one focused regression test. The default gate is `flutter analyze`, `flutter test`, `npm test --prefix backend`, and `npm run build --prefix backend`.

## Commit & Pull Request Guidelines

Use Conventional Commits with concise Chinese summaries, for example `refactor(settings): 迁移装饰状态到 Riverpod`. Keep branches short-lived (`feat/*`, `fix/*`, `docs/*`, `refactor/*`, `chore/*`) and keep each commit scoped to one change. PRs should include the change summary, validation commands, linked issues when relevant, and screenshots for UI changes. Never commit `.idea/`, `build/`, `backend/dist/`, `backend/node_modules/`, `outputs/`, or real backend env files.
