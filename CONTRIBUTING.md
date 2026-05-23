# Git Workflow

## Branches

- Keep `main` deployable.
- Create short-lived branches with `feat/`, `fix/`, `docs/`, `refactor/`, or `chore/`.
- Use one branch for one task.

## Commits

- Prefer Conventional Commits: `type(scope): summary`.
- Keep each commit focused on one change.
- Do not mix code changes with generated files or local config.

Examples:

- `feat(auth): add reminder code login`
- `fix(scan): guard empty image result`
- `chore(repo): standardize git hygiene`

## Never Commit

- Local IDE files such as `.vscode/` and `.idea/`
- Build artifacts such as `build/`, `android/build/`, `backend/dist/`
- Local dependencies such as `backend/node_modules/`
- Presentation exports such as `outputs/`, `Roadshow/`, `feature_timeline_transparent*.png`
- Real environment files such as `backend/.env.development` and `backend/.env.production`

## Before Push

- Run `flutter analyze`
- Run `flutter test`
- Run `npm test --prefix backend`
- Run `npm run build --prefix backend`
