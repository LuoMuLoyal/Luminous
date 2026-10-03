# GitHub Actions Workflows

按**关注点**拆分：`ci.yml` 只做校验，各平台的发布各占一个文件。好处：粒度权限
（默认 `contents: read`；`pages: write` + `id-token: write` 只给 Web 发布）、
独立触发与并发组、失败隔离、小 diff。把产物构建塞进门禁文件里会让触发条件被迫取并集
（一条 main 分支的产物失败会把 PR 门禁也染红），也让「校验」这个语义失真。

| 文件 | `name:` | 职责 | 触发 |
| --- | --- | --- | --- |
| `ci.yml` | `CI` | 校验：ARB 合并 / 生成物准备 / 生成客户端 / 生成文档一致性 / analyze / 全量单测 | push, PR, 手动 |
| `deploy-android.yml` | `Deploy Android` | 构建 release APK 并上传产物 | push(`main`), 手动 |
| `deploy-ios.yml` | `Deploy iOS` | 构建未签名 IPA（macOS runner）并上传产物 | push(`main`), 手动 |
| `deploy-web.yml` | `Deploy web` | 构建 Flutter Web 并发布到 GitHub Pages | push(`refactor`), 手动 |

## 命名

`name:` 用简短的产品动作式短语，文件用 kebab-case。`ci.yml` 是门禁，`deploy-*.yml`
是发布；同一平台的校验与产物分属两个文件，不互相牵连。四个 `name:` 在 Actions
侧边栏按字母序排列，便于定位。

## 触发说明

- `ci.yml` 是唯一的门禁面：任何分支的 push 与 PR 都跑。
- `deploy-*.yml` 都支持手动 `workflow_dispatch`（可在任意分支出包），自动触发各自绑定
  分支：Android / iOS = `main`，Web = `refactor`。
- `deploy-web.yml` **只在 `refactor` 分支的 push 上自动触发**——这与仓库当前的 Pages
  发布约定一致，不要顺手改成 `main`。
- `deploy-ios.yml` 跑在 GitHub 托管 `macos-latest` 上：开发机是 Windows，本地编译不了
  iOS，CI 同时是唯一的编译验证面。公开仓库的标准托管 runner 不额外计费。

## 发布产物

| 工作流 | 产物 | 备注 |
| --- | --- | --- |
| `deploy-android.yml` | `luminous-android-apk`、`luminous-android-symbols` | 无 `key.properties` 时 APK 走 debug 签名：可安装，不可上架 |
| `deploy-ios.yml` | `luminous-ios-unsigned-ipa`、`luminous-ios-symbols`、`luminous-ios-podfile-lock` | 未签名，本机用 Sideloadly / AltStore 重签后装真机；签名分发与 TestFlight 见 `docs/TODO.md` |
| `deploy-web.yml` | GitHub Pages | |

`deploy-android.yml` 不再跑 `dart compile js web/drift_worker.dart`：那是 Web 端
drift worker（只有 `lib/core/database/connection_web.dart` 消费），移动端产物不需要。

## 环境变量

三个发布工作流都从 Repository Settings → Secrets and variables → Actions 读取。
`LUCENT_BASE_URL` 必填（缺失直接失败，避免发出访问不到后端的包）；其余缺失只 warning，
仅关闭对应能力。

| 变量 | 类型 | Android | iOS | Web |
| --- | --- | --- | --- | --- |
| `LUCENT_BASE_URL` | Secret（必填） | ✅ | ✅ | ✅ |
| `SENTRY_DSN` | Secret | ✅ | ✅ | ✅ |
| `SUPPORT_EMAIL` | Variable（默认 `support@luminous.app`） | ✅ | ✅ | ✅ |
| `JPUSH_APP_KEY` | Secret | ✅ Dart define + Gradle/manifest | ✅ Dart define | — |
| `WECHAT_MOBILE_APP_ID` | Secret | ✅ Dart define | ✅ Dart define + `Wechat.xcconfig` | — |
| `WECHAT_IOS_UNIVERSAL_LINK` | Variable | — | ✅ Dart define | — |
| `LUMINOUS_EXPERIMENTAL_AI_RUNTIME`、`LUMINOUS_AI_RUNTIME_PROVIDER`、`LUMINOUS_ENABLE_GEN_UI` | Variable | — | — | ✅ |

Web 的三个 `LUMINOUS_*` 是 Web 实验运行时开关，移动端发布不注入，保持产品默认（关闭）。
`WECHAT_IOS_UNIVERSAL_LINK` 还要求 Apple 账号侧配好 Associated Domains 才可用。

## 生成物前置步骤

每个跑 `flutter build` 的 workflow（`ci.yml`、`deploy-web.yml`、`deploy-android.yml`、
`deploy-ios.yml`）都按顺序跑 `Bootstrap generated sources` → `Build generated API client`：
`generated/lucent_api` 是独立 package，根 `build_runner` 不会替它生成各 model 的
`part '*.g.dart'`（这些 `.g.dart` 被 gitignore）。缺后者时 `flutter build` 会在编译期
直接失败。

## 改 `name:` / 文件名的注意

GitHub 用工作流**文件名**关联历史运行记录，重命名会与历史脱钩
（`ci.yml` / `deploy-web.yml` 即由 `luminous-ci.yml` / `luminous-cd.yml`
演进而来）。若其他仓库的 workflow 用 `workflow_run.workflows` 引用了这里的
`name:`，改名时需同步。README 里的 badge 也指向文件名。

所以新增发布面时**新建文件**（`deploy-*.yml`），不要把产物塞回 `ci.yml`。
