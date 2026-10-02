# GitHub Actions Workflows

按**关注点**拆分，而不是一个 `luminous-ci.yml` 装所有 job。好处：粒度权限
（默认 `contents: read`；`pages: write` + `id-token: write` 只给发布），
独立触发与并发组，失败隔离，小 diff。

| 文件 | `name:` | 职责 | 触发 |
| --- | --- | --- | --- |
| `ci.yml` | `CI` | analyze / 单测 / 生成物一致性 / 文档校验；main 上额外出 APK | push, PR, 手动 |
| `deploy-web.yml` | `Deploy web` | 构建 Flutter Web 并发布到 GitHub Pages | push(`refactor`), 手动 |

## 命名

`name:` 用简短的产品动作式短语，文件用 kebab-case。两个 workflow 的
`name:` 在 Actions 侧边栏按字母序排列，便于定位。

## 触发说明

- `ci.yml` 的 `build-apk` job 只在 `push` 到 `main` 时跑（`if:` 门控），
  PR 与手动触发只跑 `verify`。
- `deploy-web.yml` **只在 `refactor` 分支的 push 上自动触发**——这与仓库当前的
  Pages 发布约定一致，不要顺手改成 `main`。手动 `workflow_dispatch` 可在任意
  分支触发。

## 改 `name:` / 文件名的注意

GitHub 用工作流**文件名**关联历史运行记录，重命名会与历史脱钩
（`ci.yml` / `deploy-web.yml` 即由 `luminous-ci.yml` / `luminous-cd.yml`
演进而来）。若其他仓库的 workflow 用 `workflow_run.workflows` 引用了这里的
`name:`，改名时需同步。README 里的 badge 也指向文件名。
