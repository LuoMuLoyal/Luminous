---
status: active
owner: frontend
updated: 2026-10-23
---
# Luminous 鸿蒙（HarmonyOS）ArkTS 壳 + ArkWeb 渲染执行计划

Created: 2026-10-23
> 状态：

**待评审，未开工**。
> **执行位置：ArkTS 工程独立成仓（`Luminous-harmonyos`，见 §二）；本计划对 `Luminous` 的改动只允许「新增一条 CI 流水线」（`Luminous/.github/workflows/deploy-harmonyos.yml`）与「本计划文件 / 迁移日志」，Dart 代码零改动。**
> 本文件是执行清单，不是调研报告。ArkWeb 侧的调研结论未验证的部分全部进 §十三，正文不依赖外部链接存活。
>
> 标注约定：
> - **V（已验证）** = 已通过本地代码、本地构建产物或本机 SDK 源码确认的事实，执行时可照做；
> - **U（未验证）** = 需在本次执行中或执行后确认，附验证方式；全部收进文末「待核实清单」。
>
> **一件事先说清楚**：本方案把「Luminous 能不能在鸿蒙上跑」换成「Luminous 的 **Web 产物** 能不能在 ArkWeb 里跑」。
> 前者被上游包卡死（§〇），后者只依赖浏览器能力与 ArkWeb 的兼容性 —— 后者**目前一条都没有在真机上验证过**（U1~U6）。
> Phase 0 的唯一任务就是把 U1~U6 一次性打穿；打不穿则本计划不成立，需要上报而不是继续堆壳代码。

## 〇、背景：为什么放弃 SDK 适配，转向 Web 壳

### 0.1 已放弃的路线（不再论证，只作背景）

**放弃「用鸿蒙 Flutter SDK（`3.47.7-ohos-1.0.1`）直接构建 Luminous」**。原因是**上游包不兼容，不是本项目代码问题**：
- 鸿蒙 SDK 的 `TargetPlatform` 枚举新增了 `ohos`（V，`D:\flutter-ohos\packages\flutter\lib\src\foundation\platform.dart:85`；上游 stable 的同名文件无此值），
  导致所有未覆盖该值的 `switch` 穷尽性检查失败。
- 实测编译报错 **35 处，分布在 6 个包**（V，`docs/logs/migration-log/2026-10-23.md:9-13`）：
  `cupertino_ui`（16 处）、`material_ui`（11 处）—— **Flutter 官方把 material/cupertino 拆出的包，官方版不支持 `ohos`**，
  这是最致命的一条，无法靠项目侧打补丁绕过；`flutter_math_fork`（4 处）、`forui`（2 处，本项目全部 UI 的设计系统）、  `gpt_markdown`（1 处）、`flutter_gen_ai_chat_ui`（间接）。
- 另有 `Abi.ohosArm` 在 Dart SDK 的 `dart:ffi` 中缺失（`code_assets` / `native_toolchain_c` 需定制 Dart SDK 才能编译）。
- 结论：**瓶颈在上游包对 `TargetPlatform.ohos` 的覆盖，短期不可控。**

### 0.2 新路线：ArkTS 壳 + ArkWeb 渲染 Web 产物

**决策：做一个原生 ArkTS 应用（`Web` 组件 / ArkWeb），在壳内加载 `flutter build web` 的产物。**为什么这样能绕开 `TargetPlatform` 问题（V，机制级）：
| 项 | SDK 适配路线 | ArkWeb 壳路线 |
|---|---|---|
| 编译 Luminous 的工具链 | 鸿蒙 Flutter SDK（`TargetPlatform.ohos` 存在） | **上游 Flutter 3.47.7**（`TargetPlatform` 只有 6 个值，无 `ohos`） |
| `TargetPlatform` 穷尽性检查 | 35 处失败 | **不触发**：`switch` 的目标枚举里根本没有 `ohos` 这个值 |
| 产物形态 | `.hap` 内含 Flutter 引擎 + AOT 快照 | `.hap` 内含 **Web 静态资源** + 系统 ArkWeb |
| 上游包要求 | 每个包都要覆盖 `TargetPlatform.ohos` | 只要包的 **Web 实现** 可用即可（Web 是各包的一等目标） |
| 本项目 Dart 代码 | 需补 44 文件平台分支 | **零改动**（走的是已有的 Web 分支，见 §六） |
关键点：鸿蒙壳里跑的是 **dart2js 编译的 JS**，不是 Dart AOT 快照。`TargetPlatform.ohos` 这个值只存在于鸿蒙 SDK 的 **Dart 侧枚举**里；Web 产物由上游 SDK 编译，枚举里没有 `ohos`，穷尽性检查自然成立。**这条是本方案成立的唯一理由，也是它唯一的价值主张。**

**代价（明知而为，写在这里避免后面反复讨论）**：Web 壳拿到的是 Luminous 的 **Web 能力集**，不是移动端能力集。推送、后台同步、本地通知、健康数据、原生扫码/OCR 全部拿不到（§七逐条列）。产品必须接受「鸿蒙版 = 移动 Web 版 + 少量原生桥」这个定位。

### 0.3 仓里已有的铺垫（不是从零开始）
| 铺垫 | 位置（V） | 对本方案的意义 |
|---|---|---|
| drift 已支持 Web（`WasmDatabase`） | `lib/core/database/connection_web.dart:13-30` | 离线随手记在 Web 上本来就可用 |
| 条件导入已预留 ArkWeb 风险注释 | `lib/core/database/database.dart:6-9` | 记录了「ArkWeb 可能不暴露 `dart.library.js_interop`」并给出候选解法 |
| Web 版本就是「移动 web 主战场」 | `docs/explanation/project-governance.md:94` | 产品面已把「鸿蒙过渡」写进治理口径 |
| 产品方向已列「打包为鸿蒙 WebView 容器」 | `plans/2026-08-14-product-surface-route.md:89` | 本计划是该待定项的执行 |
| Web 发布流水线已存在且可用 | `.github/workflows/deploy-web.yml` | 构建链路与坑位清单已固化，见 §八 |

## 一、目标与基线
| 项 | 当前（V） | 目标 |
|---|---|---|
| 编译 Luminous Web 的 SDK | Flutter **3.47.7** / Dart 3.13.5（`D:\flutter`，`flutter --version` 实测） | **不动**。壳方案不引入鸿蒙 Flutter SDK |
| 本机 SDK 状态 | `D:\flutter`（3.47.7，`TargetPlatform` 无 `ohos`） | 保持唯一 SDK；

**不要**再引入 `D:\flutter-ohos` |
| 鸿蒙工具链 | **DevEco Studio 26.0.0.851 已装于 `E:\DevEco Studio`**（含 API 26 SDK `sdk\default`、`tools\ohpm` 26.0.0.630、`tools\hvigor` 6.26.8、`tools\node` 24.14.1）；`ohpm` / `hvigorw` **不在 PATH**，需按 §9.1 前置（V，本机实测） | 复用已装的 DevEco，无需重装 |
| 产物 | APK / IPA / Web（GitHub Pages）/ Windows（V） | + `.hap`（AppGallery Connect 分发） |
| Web 产物 | `build/web/` 本地已存在：**203 文件 / 51.46 MB**（V） | 进 HAP 的 rawfile（体积需裁剪，见 §三） |
| 仓库平台目录 | `android ios linux macos web windows`（V，无 `ohos/`） | **`Luminous` 不新增平台目录**；ArkTS 工程独立（§二） |
| CI | **7 个 workflow**（V）：`ci.yml` `codeql.yml` `deploy-android.yml` `deploy-ios.yml` `deploy-web.yml` `osv-scanner.yml` `scorecard.yml` | 新增 `deploy-harmonyos.yml`（或独立仓流水线，见 §八） |
| `deploy-web.yml` 触发分支 | `push: branches: [refactor]`（V，`.github/workflows/deploy-web.yml:10`）；当前分支为 **`develop`** | 新增的鸿蒙流水线**不复用**这条触发约定，见 §八 |

### 1.1 本计划的硬约束（先记住这四条）1.

**`Luminous` 的 Dart 代码零改动。** 所有能力差异靠已有的 Web 分支承接（§六逐条核实过）；一旦需要改 Dart，说明该能力在 Web 上本来就缺，走 §七 降级而不是打补丁。
2. **不引入鸿蒙 Flutter SDK。** 本机此前试装过 `D:\flutter-ohos`（`3.47.7-ohos-1.0.1`），**已于 2026-10-23 删除**；不要再接回来，否则 §〇 的 35 处报错立刻复现。
3. **Web 产物的两个已知坑必须继承**：不能加 `--wasm`（skwasm 在移动浏览器有内容区高度 0 的布局 bug，`web/flutter_bootstrap.js:4-20` 已显式钉 `renderer: 'canvaskit'`）；`drift_worker.js` 与 `sqlite3.wasm` 必须存在（`.gitignore:76-80` 说明二者都是**构建期产物、不入库**）。
4. **CanvasKit 默认从 CDN 取，壳内必须显式改成本地**（V，见 §四）—— 这是最容易漏、且表现为「白屏」的一条。

## 二、仓库 / 工程放哪

### 2.1 三个选项
| 选项 | 形态 | 代价 |
|---|---|---|
| **A. `Luminous/ohos-shell/` 子目录** | ArkTS 工程与 Flutter 工程同仓 | 同仓便于「一次提交同时改 Web 构建参数与壳」；但把 hvigor/ohpm 工具链、`.hvigor/`、签名材料、`oh_modules/` 引入一个 Flutter 仓，`.gitignore` 与 CI 复杂度上升；且 Web 产物进 rawfile 会把**构建产物**（51 MB 级）带进 Flutter 仓的工作树 |
| **B. 独立仓库 `Luminous-harmonyos`** | 只放 ArkTS 壳 + 一条从 `Luminous` 取 Web 产物的流水线 | 仓界清晰，签名与 AGC 材料不外溢到主仓；代价是**跨仓取产物**需要一条制品通道（release asset / artifact / Pages），且「Web 构建参数变了、壳没跟上」这类漂移不会被同仓 diff 拦住 |
| **C. 放到 `Luminary/` monorepo** | 与 `apps/lumine`（Tauri 壳）并列 | `Luminary` 是 pnpm/Tauri 生态，塞一个 hvigor 工程进去会污染它的 `pnpm build` / `sync:docs` 门禁，且 `AGENTS.md` 明确 `Luminary/apps/lumine` 的约束是「同构 Web + Tauri」，与本方案无关。

**不推荐** |

### 2.2 推荐：

**B（独立仓库 `Luminous-harmonyos`）**，理由与代价**推荐理由（基于本仓既有事实）**：
1. **工具链完全异构**。ArkTS 侧需要 hvigor + ohpm + DevEco + JDK；`Luminous` 侧是 Flutter/Dart。同仓会让 `Luminous` 的 CI 必须区分「Flutter job」与「HarmonyOS job」，而 GitHub 托管 runner **没有鸿蒙工具链**（V：本机 `ohpm`/`hvigorw` 均不在 PATH，说明工具链是本地安装的），CI 天然只能做一半。
2. **产物不该进主仓**。`build/web` 是 51.46 MB / 203 文件（V）；即使裁剪到仅 canvaskit 一档也仍有数 MB 级二进制。主仓 `.gitignore:46` 已把 `/build/` 整个忽略，同仓方案必须为 rawfile 开一个例外目录，等于在主仓里养一份构建产物。
3. **签名与上架材料不外溢**。AGC 的证书、Profile、`build-profile.json5` 属于发布凭据类材料，放独立仓的边界更干净。
4. **主仓边界最小**。`AGENTS.md`「Do not touch unrelated dirty or untracked files in sibling projects」与「Repository Boundaries」的口径都是「一个仓一件事」。本方案对 `Luminous` 的改动收敛为：**新增一条 CI 流水线**（用于产出可下载的 Web 制品），Dart 代码零改动。

**代价（必须写清，否则后面会反复讨论）**：
- **跨仓漂移**：`deploy-web.yml` 的构建参数（`--dart-define` 列表、`--base-href`、canvaskit 本地化开关）改了，鸿蒙壳不会自动跟着改。
  缓解：把「Web 制品契约」写成一份**清单**（§8.1），任何一侧改动必须同时改清单版本号；壳侧启动时校验制品版本，不匹配则拒绝加载（§三 方案 c 的一部分）。
- **跨仓取产物需要制品通道**：见 §八，推荐走 GitHub Release asset 或 artifact 下载，而不是让壳仓 clone 主仓。
> **若评审最终选 A（同仓子目录）**，本计划的 §三/§四/§六/§七/§九 **全部不变**，只有 §八 的流水线位置与 `.gitignore` 条目需要改。这是本计划唯一一处「决策影响面可控」的选择。

### 2.3 独立仓的初始化纪律
1. `git init` 全新历史，首个 commit 记为「Luminous 鸿蒙 ArkTS 壳初始化」。
2. 仓内

**只放**：`entry/`（ArkTS 源码）、`AppScope/`、`build-profile.json5`、`oh-package.json5`、`hvigorfile.ts`、   `scripts/fetch-web-artifact.ps1`（拉取并校验 Web 制品）、`README.md`。
3. **不放**：任何 Dart 源码、任何 `flutter build` 产物（产物由脚本按需拉取到 gitignored 目录）。
4. `.gitignore` 至少忽略：`oh_modules/`、`.hvigor/`、`build/`、`entry/src/main/resources/rawfile/web/`（拉取下来的制品）。

## 三、Web 资源交付方式（核心决策点）

### 3.1 三种方式比较
| 维度 | **(a) 打进 HAP 的 rawfile，本地加载** | **(b) 远端加载（HTTPS）** | **(c) 混合：壳内基线 + 热更新** |
|---|---|---|---|
| 首屏 | 无网络等待（除 API 请求） | 依赖网络，首屏 = 下载 9.16 MB `main.dart.js` + 6.95 MB `canvaskit.wasm`（V，本地产物实测） | 同 (a) |
| 离线可用 | ✅ | ❌ | ✅（基线部分） |
| 更新 | 必须发版 | 改远端即可 | 发版 + 可选热更新 |
| 包体 | HAP 直接 +数 MB~数十 MB（V，`build/web` 全量 51.46 MB；裁剪后见 §3.2） | 最小 | 基线部分同 (a) |
| 与后端的 CORS / Origin | **`Origin` 为本地资源来源，不是 `https://` 站点** → Lucent 的 `CORS_ORIGIN` 白名单（V，`Lucent/src/setup-app.ts:281-300`，`corsOrigin` 必须列显式 origin）**大概率匹配不上** | 与 Web 版同源，CORS 已可用 | 同 (a) |
| 认证回调 URI | Web 版的 `webWechatCallbackUri` / `webQqCallbackUri` / `webGoogleCallbackUri` 都基于 `Uri.base`（V，`lib/features/auth/presentation/pages/oauth_uris.dart:31-74`）→ 本地加载时 `Uri.base` 不是 https 站点，**OAuth 回调拼不出来** | `Uri.base` 是真实站点 → 可用 | 同 (a)，需壳侧覆盖 |
| 失败表现 | 本地资源加载失败 = 白屏（无网络错误可查） | 网络错误可提示、可重试 | 复杂 |

### 3.2 体积：rawfile 不能放全量产物`build/web` 实测（V，本地 `flutter build web --release` 产物，`--base-href` 未加）：
| 项 | 大小 |
|---|---|
| 总计 | **203 文件 / 51.46 MB** |
| `main.dart.js` | 9.16 MB |
| `canvaskit/canvaskit.wasm` | 6.95 MB |
| `canvaskit/chromium/canvaskit.wasm` | 5.18 MB |
| `canvaskit/skwasm_heavy.wasm` | 4.97 MB |
| `canvaskit/webparagraph/canvaskit.wasm` | 3.56 MB |
| `canvaskit/skwasm.wasm` | 3.43 MB |
| `canvaskit/wimp.wasm` | 3.42 MB |
| 其余 `canvaskit/*.symbols`（调试符号，4 个） | 合计约 6.08 MB |
| `assets/NOTICES` | 1.50 MB |
**可裁剪项（V，基于上表）**：`*.js.symbols`（调试符号，生产不需要）与 `skwasm*` / `wimp*`（本方案钉死 canvaskit，用不到 wasm 渲染器）合计可省约 **14 MB**。裁剪后估算 **约 37 MB**（U，需在 Phase 0 实测裁剪后总量）。**`assets/NOTICES` 不可删** —— pub 依赖许可清单是合规项。

### 3.3 推荐：

**(c) 混合，但第一版只做 (a) 的形态****推荐 `(c)` 的形态，(a) 作为 Phase 1 的落地方式，(b) 只作为 Phase 2 的可选热更新通道。**理由（按权重排序）：
1. **离线是 Luminous 的既有产品承诺**。drift 是 cache-first 底座（`lib/core/database/README.md:1-5`），Web 版本就保留 `web/drift_worker.js` + `sqlite3.wasm`（`plans/2026-08-14-product-surface-route.md:40`）。如果壳改成纯远端加载，断网时连壳都进不去，与 cache-first 的产品语义直接冲突。
2. **`(b)` 会引入本方案最不想碰的问题：Origin**。Lucent 的 CORS 是**显式 origin 白名单 + `credentials: true`**（V，`Lucent/src/setup-app.ts:281-300`），
  且 OAuth 回调 URI 的合法性由 `isTrustedOrigin` 用同一份 `corsOrigin` 数组校验（V，`Lucent/src/modules/auth/services/oauth/state.service.ts:251-257`）。
  本地 rawfile 加载时，页面来源不是 `https://` 站点；远端加载时则要求壳能拿到一个已备案、已加入白名单的 HTTPS 站点。**这两条都涉及后端配置变更，不该由壳方案单方面决定。**
3. **`(c)` 的热更新部分不要第一版做**。热更新意味着「壳内的 Web 产物可以被替换」，等价于在应用内引入一个可执行代码的下载通道 —— 鸿蒙侧对动态加载代码有合规与审核要求（U9）。
  第一版只做「基线打进 rawfile」，把热更新留到 Phase 3 且**必须先确认合规口径**。

### 3.4 加载本地 rawfile 的具体方式与限制（

**全部 U**）以下是本计划**最需要先打穿**的一块。已知的候选手法（均需真机验证，**本计划未核实任何一条**）：
| # | 候选手法 | 需要确认什么 | 验证方式 |
|---|---|---|---|
| U1 | `WebviewController.loadUrl()` 传 `$rawfile('web/index.html')` | 该写法是否被接受；加载后**同目录相对路径**（`flutter_bootstrap.js`、`main.dart.js`、`canvaskit/canvaskit.wasm`）能否解析 | 真机跑最小页面，逐条打 console 日志 |
| U2 | 是否需要 `setPathAllowingUniversalAccess` / 等价的跨域放行配置，否则 rawfile 内的 `fetch()` / `WebAssembly.instantiateStreaming()` 被跨域拦截 | 是否必需、参数形态 | 同 U1；重点看 `canvaskit.wasm` 是否被 CORS 拦 |
| U3 | `domStorageAccess`（DOM Storage）/ 数据库存储开关的默认值与开启方式 | 默认是否为 false（若默认 false，`shared_preferences` 的 Web 实现直接失效 → 见 §五） | 真机读写 localStorage 并重启 |
| U4 | `javaScriptProxy` / `registerJavaScriptProxy` 注册原生对象的调用约定（方法名、回调、注入时机） | 必须在页面加载前还是 `onControllerAttached` 时注册 | 真机调用一个 echo 方法 |
| U5 | 本地加载下 ArkWeb 的 `Origin` 到底是什么（`file://`？空？`resource://`？） | 决定 Lucent 的 `CORS_ORIGIN` 要不要加白名单项 | 真机打印 `location.origin` 与请求头 |
| U6 | 本地资源的 MIME 处理：`.wasm` 是否被以 `application/wasm` 提供 | 若 MIME 不对，`WebAssembly.instantiateStreaming` 会失败（这是**白屏的头号嫌疑**） | 真机看 `fetch('canvaskit/canvaskit.wasm')` 的 `Content-Type` |
**已知的风险信号（V，仓内自述）**：`lib/core/database/database.dart:6-9` 与 `lib/core/database/README.md:52-53` 都记录了「**ArkWeb 可能不暴露 `dart.library.js_interop`**，web stub 将抛 `UnsupportedError`」。这条如果成立，**drift 的 Web 连接会走到 `connection.dart:9-13` 的 stub 并抛异常**，即本地数据库在 ArkWeb 内不可用。但注意：**这条注释写于 2026-07（`docs/archive/2026-07/2026-07-14.md:34`），当时的判断是「可能」**，而 dart2js 的 `dart.library.js_interop` 是**编译期常量**（由编译器决定，不由宿主 WebView 决定）——如果 ArkWeb 里跑的是同一份 `main.dart.js`，这个条件在**编译时**就已确定为真。**这条极可能是过时风险，但必须实测**（U7）。若实测发现真的落 stub，本方案需要先解决 drift 的 Web 连接，见 §七 D-1。

## 四、CanvasKit 与 wasm 资源（**最容易漏、且表现为白屏**）

**最容易漏、且表现为白屏**）

### 4.1 事实：当前 Web 构建把 CanvasKit 指向公网 CDN（V，源码级）- `web/flutter_bootstrap.js:13-23` 只钉了 `renderer: 'canvaskit'`，

**没有指定 `canvasKitBaseUrl`**。
- 本地产物的 `build/web/flutter_bootstrap.js` 里，`_flutter.buildConfig` **不含 `useLocalCanvasKit`**（V，实测该文件内容：
  `{"engineRevision":"5d531788691ec3404cac0cee66ead4007b177363","wasmHashes":{...}}`）。
- 该 loader 的取址逻辑为（V，`build/web/flutter_bootstrap.js` 内联）：
  `n.canvasKitBaseUrl ? n.canvasKitBaseUrl : (e.engineRevision && !e.useLocalCanvasKit ? "https://www.gstatic.com/flutter-canvaskit/<rev>" : "canvaskit")`。
- 上游工具链侧同一逻辑（V，`D:\flutter\packages\flutter_tools\lib\src\build_system\targets\web.dart:129-138`）：
  **`kUseLocalCanvasKitFlag != 'true'` 时注入 `FLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/<engineRevision>/`**。
- `useLocalCanvasKit` 的取值（V，`D:\flutter\packages\flutter_tools\lib\src\runner\flutter_command.dart:1489-1496`）：
  `useLocalCanvasKit = forcedUseLocalCanvasKit ?? (!useCdn |
| useLocalWebSdk)`，
  而 `--web-resources-cdn` **`defaultsTo: true`**（V，同文件 `:811-817`）。

**结论（V）**：**默认构建出来的 `build/web` 在运行时从 `www.gstatic.com` 拉 CanvasKit，而不是用本地 `canvaskit/` 目录。**在 ArkWeb 里，这条 CDN 请求是否可达、是否被网络策略拦、是否被 CSP 拦，都未验证；**即使本地 rawfile 放对了，只要这条 CDN 请求失败，页面就是白屏。**

### 4.2 处理方式（Phase 0 必做）

**推荐：构建时显式本地化 CanvasKit**，二选一（都需在 Phase 0 验证产物，U8）：
| 方式 | 命令 | 备注 |
|---|---|---|
| ① 关闭 CDN | `flutter build web --release --web-resources-cdn=false ...` | 由上游工具链保证 `useLocalCanvasKit: true` 与本地 `canvaskit/` 齐全（V，`web.dart:702-718` 会额外补 Roboto fallback 字体） |
| ② 显式指定 URL | `--dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/` | 走 `web.dart:130-137` 的 `canvasKitUrlAlreadySet` 分支，不改其他行为；**相对路径形态需实测**（U8） |
**验证判据（可离线判定，不需要真机）**：产物 `build/web/flutter_bootstrap.js` 里的 `_flutter.buildConfig` **必须含 `"useLocalCanvasKit":true`**（方式①），或构建日志里出现 `FLUTTER_WEB_CANVASKIT_URL=canvaskit/`（方式②）。这条应当进 CI 断言。

### 4.3 其余 wasm / worker 资源
| 资源 | 谁消费（V） | 在 ArkWeb 内的关注点 |
|---|---|---|
| `canvaskit/canvaskit.wasm` | Flutter 引擎渲染 | 见 4.1 / 4.2；MIME 见 U6 |
| `sqlite3.wasm` | `lib/core/database/connection_web.dart:19-23`（`sqlite3Uri: Uri.parse('sqlite3.wasm')`） | **相对路径**，说明它必须与 `index.html` 同级；MIME 同样影响 `instantiateStreaming` |
| `drift_worker.js` | 同上（`driftWorkerUri: Uri.parse('drift_worker.js')`） | 走 **Web Worker**。ArkWeb 对 Worker + `importScripts` / 模块化的支持度未验证（U10）；Worker 起不来时 `WasmDatabase.open` 会回落到同线程 executor（V，`connection_web.dart:25-28` 注释自述） |
| `flutter_service_worker.js` | 由 Flutter loader 注册（V，`flutter_command.dart` 的 serviceWorker 逻辑） | 产物里的这份**会自我注销**（V，实测 `build/web/flutter_service_worker.js` 内容即 `install → skipWaiting` + `activate → registration.unregister()`），对离线无帮助，也不构成风险 |
> **`sqlite3.wasm` 与 `drift_worker.js` 都是 gitignored 的构建期产物**（V，`.gitignore:76-80`）。
> 任何「从仓库直接取 Web 产物」的脚本都拿不到这两个文件，**必须跑完整 `flutter build web` 流程**（§八）。

## 五、认证与会话（决定用户要不要每次登录）

### 5.1 事实：Web 版把 token 存在 `localStorage`（V，源码级）
| 事实 | 位置（V） |
|---|---|
| 会话存储抽象 | `lib/core/network/client/session_store.dart:23-33`（`LucentSessionStore` 接口） |
| Provider 选择的是**安全存储实现** | `lib/core/network/client/client_providers.dart:40-41` → `const SecureLucentSessionStore()` |
| 安全存储实现在 **Web 上回落到 SharedPreferences** | `session_store.dart:181-185`：`bool get _useFallback { ... return kIsWeb; }` |
| 回落实现是 `SharedPrefsLucentSessionStore` | `session_store.dart:66-119`；`shared_preferences` 的 Web 后端即 **`localStorage`** |
| 存储不变量：**一对 token 写在同一个 JSON 里、单 key 原子写** | `session_store.dart:52-65`（注释明确说明：半更新的 token 对会让刷新流程提交已作废的 refresh token） |
**推导（V，代码级）**：鸿蒙壳里的登录态持久化 = **ArkWeb 的 DOM Storage / localStorage 是否持久化**。如果 ArkWeb 的 DOM Storage 默认关闭或不被持久化，则**每次冷启动都要重新登录**（因为 `restore()` 读不到 refresh token，直接落 `AuthSessionState()`，见 `lib/core/auth/session_provider.dart:41-46`）。**这不是「体验问题」，是「能不能用」的问题**，因为 Lucent 的 refresh 是**一次性轮换 + 重放检测**（见 `AGENTS.md`「Luminary / lumine 约束」一节）：反复登录会不断产生新 token family，不会自愈。

### 5.2 待验证（

**Phase 0 的第一优先项**）
| # | 待验证 | 判据 | 失败时的回退 |
|---|---|---|---|
| U3 | ArkWeb 的 `domStorageAccess` 默认值；开启后 `localStorage` 是否跨重启保留 | 写入 → 杀进程 → 重启 → 读回 | 若不可用：**必须桥接**（§六 B-6，把 token 存到 ArkTS 侧的安全存储），否则鸿蒙版无法保持登录 |
| U11 | `localStorage` 的容量上限（会话 payload 很小，但 drift 的 OPFS/IndexedDB 路径可能共用配额） | 写入 1 MB 探测 | 影响的是 drift，不是会话 |

### 5.3 与登录流程的耦合（V）Web 版的 OAuth 回调

**不走深链，走 GoRouter 的 query 参数**（V）：
- `lib/core/router/deep_link.dart:66-72`：`kIsWeb → const NoopDeepLinkSource()`。
- `lib/features/auth/presentation/pages/oauth_callback_hook.dart:18-73`：`useOAuthCallbackHandler` 从 query 参数取 `code`/`state` 完成登录。
- `lib/features/auth/presentation/pages/oauth_uris.dart:31-74`：三个 `web*CallbackUri` 都由 **`Uri.base`** 拼出（scheme/host/port 取自当前页面地址）。**这意味着**：ArkWeb 本地加载（`(a)` 方案）时，`Uri.base` 的 scheme/host **取决于 U5 的结论**。若 `Uri.base` 是 `file://` 或空 origin，则：
- 三个 `web*CallbackUri` 会拼出非法 URI，OAuth 起不来；
- 且即使拼出来，Lucent 侧 `isTrustedOrigin`（V，`state.service.ts:251-257`）也会拒绝。

**处理方向（Phase 2 决策，见 §十二 待决 2）**：
1. 让壳提供 `LUMINOUS_WEB_ORIGIN` 之类的注入值，覆盖 `Uri.base`（**需要改 Dart，与 §1.1 第 1 条冲突**）；或
2. 壳侧加载一个**受控的 HTTPS 站点**（即退化为方案 `(b)` 的登录路径，仅登录走远端）；或
3. 鸿蒙版第一版**只支持邮箱/验证码登录**（不依赖 `Uri.base`），OAuth 入口按 §七 隐藏。

**本计划倾向 3**：改动面为零，且与「鸿蒙版 = 移动 Web 版 + 少量原生桥」的定位一致。

## 六、原生能力桥接清单

桥接手段（U，需与 U4 一并验证）：ArkTS 侧 `javaScriptProxy` / `registerJavaScriptProxy` 向页面注入对象；或 `runJavaScript` 从壳侧调页面函数。**方向约定**：壳 → 页面用「调用页面暴露的全局函数」，页面 → 壳用「注入对象上的方法」。两条通道都要在 Phase 0 打通一个 echo 用例。

### 6.1 逐个能力：Web 版本就有 / 必须桥接 / 直接砍
| # | 能力 | Web 版现状（V，证据） | 结论 |
|---|---|---|---|
| B-1 | **返回键 / 系统手势** | Web 版无此概念；GoRouter 的返回由页面内按钮触发 | **必须桥接**。壳侧拦返回键 → 调页面 `history.back()` 或注入对象的 `onBack()`；页面栈为空时再退出 Ability。**U12**：ArkWeb 的 `history` 与 Flutter 的 `Uri.base` 路由是否一致 |
| B-2 | **状态栏 / 安全区** | `web/index.html:36-39` 已声明 `viewport-fit=cover`；`index.html:25-26` 有 `mobile-web-app-capable` 等 meta | **部分已有**。Web 侧 `MediaQuery` 的 `padding` 来自 CSS env(safe-area-inset-*)，ArkWeb 是否提供该值 **U13**；不提供则顶部/底部会被状态栏遮挡，需要壳侧调 Web 容器 inset |
| B-3 | **推送** | `lib/core/push/jpush_gateway.dart:41-45`：`isConfigured = appKey.isNotEmpty && !kIsWeb && (android \|\| iOS)` → **Web 上恒 false**，整条链路不启用（`main.dart:27-31` 的 try/catch 会吞掉异常） | **直接砍**（第一版）。要做得走 ArkTS 侧接入华为 Push Kit，再桥到页面 —— 但 Web 版**没有任何接收推送的代码路径**，等于从零做。

**不做**（§十一） |
| B-4 | **权限（相机 / 通知）** | `lib/features/settings/domain/services/notification_permission.dart:45,72,96`：`kIsWeb → unsupported`（三处早退） | **已有降级**。壳侧若开放相机权限给 Web 容器，需在 `module.json5` 声明（U14）；但见 B-7，相机在 Web 版本来就没入口 |
| B-5 | **文件选择 / 拍照** | `lib/core/widgets/common/avatar/avatar_draft.dart:62-68`：`kIsWeb` 跳过裁剪、直接用 `image.name`；`image_picker` 在 Web 上走 `<input type="file">` | **Web 版就有**（选文件），**拍照在 Web 上退化为「选文件」**。壳侧若要真拍照需桥接（U15）。第一版**不桥接** |
| B-6 | **安全存储（token）** | 见 §5.1：Web 用 `localStorage` | **条件性必须桥接**：仅当 U3 证明 `localStorage` 不持久化时才做。桥接形态 = ArkTS 侧 `@ohos.security` 系列安全存储 + 注入对象的 `readToken/writeToken/clearToken`。

**注意**：Web 版 Dart 侧不会主动调用它，所以这条桥接**需要改 Dart**（与 §1.1 第 1 条冲突）→ 因此**若 U3 失败，本计划需重新评估**，见 §十 风险 1 |
| B-7 | **扫码** | `lib/features/search/presentation/widgets/views/content.dart:23`：`(!kIsWeb && (Platform.isAndroid \|\| Platform.isIOS))` → **Web 上快捷入口列表为空**；`lib/features/medicine/data/repositories/lucent_workspace.dart:219` 同一判定 | **直接砍**（第一版）。Web 版没有入口，也就没有「桥接点」；要做得先在 Web 版加回入口（改 Dart），再桥 `@ohos.multimedia.camera` |
| B-8 | **分享 / PDF 导出** | `lib/features/review/presentation/utils/pdf_download.dart:1-73`：用 `dart:io` 的 `File` + `path_provider` 的 `getTemporaryDirectory()` + `SharePlus.instance.share`，**全程在 try/catch 内**（`:46,69-72`） | **Web 上会落 `PdfDownloadResult.failed`**（V，代码级推导：`dart:io` 在 Flutter Web 上可 import 但运行时抛 `Unsupported operation`，该异常被 `:69` 捕获）。**降级为「失败提示」**，第一版不桥接；要做得桥接 `@ohos.file.picker` + 系统分享（U16） |
| B-9 | **网络状态** | `lib/core/database/sync/worker.dart:3,50` 用 `connectivity_plus` 的 `onConnectivityChanged`；`connectivity_plus` 有 Web 实现（V，`lib/oss_licenses.dart:2750` 依赖里含 `web`） | **Web 版就有**（浏览器 `online`/`offline` 事件）。ArkWeb 是否上报正确状态 **U17**；上报错误会导致「以为在线 → 同步失败」或「以为离线 → 不重试」 |
| B-10 | **外部链接打开** | `lib/core/router/external_url_launcher.dart:9-11`：`launchUrl(uri, mode: LaunchMode.externalApplication)`；`url_launcher` 的 Web 实现是 `window.open` | **必须桥接**。ArkWeb 里的 `window.open` / 新窗口行为需确认（U18）；壳侧应拦 `onWindowOpen` / `onLoadIntercept`，把外部域名交给系统浏览器（`@ohos.app.ability.wantAgent`）。

**这是最值得做的一条桥**：法务页、帮助页、OAuth 外链都走它 |
| B-11 | **深链 / OAuth 回调** | `deep_link.dart:66-72`：Web 上 `NoopDeepLinkSource` | **不需要桥接**（Web 版本就不走深链，走 query 参数，见 §5.3） |

### 6.2 桥接的通用约束1.

**注入对象的可用时机**：页面在 `onEntrypointLoaded` 之后才开始跑 Flutter，注入必须早于页面脚本（U4）。注入失败的表现是「页面功能静默缺一块」，**必须有探测**：页面启动时调一次 `bridge.ping()`，失败则在 UI 上显式降级而不是静默。
2. **不要用桥接绕过安全边界**：注入对象上**不要**放「任意 URL 请求」「任意文件读写」这类通用方法，只放语义化的窄接口（`openExternal(url)`、`onBack()`）。
3. **桥接失败的降级路径要写进 §七**，不能只写「桥接成功怎么办」。

## 七、已知会缺失 / 降级的功能（基于 §六 侦察结果）
| # | 能力 | 鸿蒙壳内表现 | 口径 |
|---|---|---|---|
| D-1 | **本地数据库（drift）** | **取决于 U7**。若 ArkWeb 落 `connection.dart:9-13` 的 stub → 抛 `UnsupportedError`，**离线缓存与离线写队列全部不可用** | **本计划的头号风险**。若不成立，本计划需要先解决 Web 连接（可能只需在 `database.dart:12` 后补 `if (dart.library.html)` 回退，**但那要改 Dart**，超出「零改动」边界） |
| D-2 | **后台同步** | `lib/core/database/sync/background.dart:23,35,66`：`kIsWeb` 直接 return → Workmanager 从不 initialize，无周期任务 | **降级为「回前台冲刷」**。离线记录上云延迟从 ≤15 min 变为「下次打开」。**产品须知情** |
| D-3 | **本地通知 / 用药提醒** | `lib/core/notifications/local_notification_gateway.dart:56-58`：`kIsWeb \|\| !_supportsLocalSchedulingOnThisPlatform → false` → `schedule()` 永远返回 false | **整块不可用**。用药提醒/晚安提醒在鸿蒙壳内**不会响**。要么砍入口，要么由壳侧 ArkTS 实现（等于重做调度 + 与 Lucent 的提醒契约对齐，**不在本计划**） |
| D-4 | **推送（JPush）** | 见 B-3，Web 上 `isConfigured` 恒 false | **不做**。应用内消息（`features/notification/`）仍可用，因为它走 HTTP 拉取 |
| D-5 | **健康数据（HealthKit / Health Connect）** | `lib/features/health_data/data/datasources/health_platform.dart:24-35`：`kIsWeb → false`；`lib/features/health_data/data/repositories/health_sync.dart:37`：`kIsWeb → 'health_connect'`（该分支因前者为 false 而不可达） | **整块不可用**，健康同步入口隐藏。与已删除的 SDK 适配计划（D1）结论一致 |
| D-6 | **步数（原生 KMP 桥）** | `pkgs/luminous_native_bridge` 只声明 android/ios；`lib/core/native/bridge.dart` 的 `nativeStepsEnabledProvider` 可整体关闭 | **不做**。走 D-5 的降级路径 |
| D-7 | **原生扫码 / OCR** | 见 B-7（入口在 Web 上就不存在）；OCR 走 `lib/features/scan/domain/services/paddle_ocr_provider.dart` → `paddle_ocr_native`（platforms 仅 android/ios） | **不做**。第一版隐藏入口；若 Lucent 有云端识别能力可后续接（**另开任务**） |
| D-8 | **日历写入** | `add_2_calendar` 无 Web 实现 | **不做**，隐藏按钮（与 `plans/2026-10-22-*` 的 D5 同口径） |
| D-9 | **图片压缩** | `lib/core/utils/image_compressor.dart:58-62`：`kIsWeb` 直接返回原图（自述「no stable web backend」） | **已有降级**：上传原图，流量更大。可接受 |
| D-10 | **微信登录** | `lib/features/auth/data/datasources/wechat/mobile_auth_client_fluwx.dart:20`：`!kIsWeb && ...`；且登录页 `showWechat: false`（V，`lib/features/auth/presentation/pages/login.dart:330-332`，注释「WeChat 入口暂隐藏」） | **入口本就不显示**，无需处理 |
| D-11 | **Apple 登录** | `lib/features/auth/presentation/widgets/shared/oauth_panels.dart:106-117`：`SignInWithApple.isAvailable()` 失败 → `_appleAvailable = false` → 按钮不渲染 | **自然隐藏**，无需处理 |
| D-12 | **内嵌 OAuth WebView** | `lib/features/auth/presentation/services/oauth_webview.dart:36-40`：`kIsWeb → false` | 走「外部浏览器 + 手工粘贴回调」路径（V，`oauth_handlers.dart:35-44` 的 `WechatLoginWebFallback`）。体验差但**不阻塞**；结合 §5.3，第一版倾向直接隐藏 OAuth |
| D-13 | **桌面能力（侧栏 / 窗口拖拽）** | `lib/features/shell/presentation/page.dart:180`、`lib/app/window_manager_setup.dart:17`：`kIsWeb` 早退 | 走移动布局。

**注意**：`Breakpoints.desktop = 1200`（V，`lib/core/design/tokens/breakpoints.dart:19`）—— 折叠屏/平板展开时若逻辑宽度 ≥1200，会切到桌面布局（`features/shell/presentation/page.dart:35`）。**鸿蒙设备的目标宽度需确认**（U19） |
> **降级口径的统一要求**：D-2/D-3/D-5/D-7/D-8 这五项在 UI 上**不能留死入口**。Web 版已经自然隐藏了大部分（V，§六/§七 逐条有证据），
> Phase 2 必须逐条真机确认「入口不存在」或「入口存在但点了有明确提示」，**不允许含糊**。

## 八、构建与 CI

### 8.1 Web 制品契约（跨仓唯一接口）壳侧只需要一个

**目录**（`index.html` + 全部相对路径资源），外加一份清单：
| 清单字段 | 来源 | 用途 |
|---|---|---|
| `app_version` / `build_number` | 产物 `build/web/version.json`（V，实测内容 `{"app_name":"luminous","version":"0.1.0","build_number":"1"}`） | 壳侧展示版本、判断是否需要更新 |
| `engine_revision` | 产物 `flutter_bootstrap.js` 的 `_flutter.buildConfig.engineRevision`（V，实测存在） | 诊断「canvas 版本不匹配」类问题 |
| `use_local_canvaskit` | 同上 buildConfig（§4.2） | **CI 断言必须为 true**，否则壳内会去拉 CDN |
| `sha256`（逐文件或整包） | 构建后计算 | 壳侧下载校验（方案 `(c)` 的热更新部分） |
| `base_href` | 构建参数 | **本地加载时必须是 `/`**，不能是 GitHub Pages 的 `/<repo>/`（V，本地产物实测 `<base href="/" />`；`deploy-web.yml:94` 用的是 `--base-href "/${{ github.event.repository.name }}/"`） |
> **`--base-href` 是本方案与现有 Web 流水线的第一个冲突点**：现有流水线为 GitHub Pages 打了仓库名前缀，
> 壳内本地加载必须用 `/`。**两条产物不能共用同一个构建配置**，见 8.2。

### 8.2 Web 产物的产出方式

**推荐：新增一条 workflow，而不是改 `deploy-web.yml`。** 依据是本仓既有约定（V，`.github/workflows/README.md:88-95`：「新增发布面时**新建文件**（`deploy-*.yml`），不要把产物塞回 `ci.yml`」）。新增 `.github/workflows/deploy-harmonyos.yml`，内容以 `deploy-web.yml` 为模板，**差异只有三处**：
| 项 | `deploy-web.yml`（现状，V） | 新增流水线 |
|---|---|---|
| `--base-href` | `"/${{ github.event.repository.name }}/"`（`:94`） | **去掉或显式 `"/"`** |
| CanvasKit | 默认（走 CDN，V，§4.1） | **`--web-resources-cdn=false`** |
| 产物去向 | `actions/upload-pages-artifact` → GitHub Pages（`:102-105`） | `actions/upload-artifact` 或 **GitHub Release asset**（供壳仓拉取） |
| 触发分支 | `push: branches: [refactor]`（`:10`） | **`develop`**（V，当前分支为 `develop`）或 `workflow_dispatch` 为主 |
**必须保留的步骤（V，`deploy-web.yml:33-100` 的既有坑位，逐条不能少）**：
1. `Validate required secrets`（`:33-50`）：`LUCENT_BASE_URL` **必填**（缺失直接失败，因为 `lib/core/network/client/base_url.dart:36-38` 在 `kReleaseMode` 下会抛 `StateError`）；`SENTRY_DSN` 可选且**不能是占位值**。
2. `Merge ARB fragments` → `dart scripts/l10n/arb_tools.dart merge`（`:66-67`）。
3. `Bootstrap generated sources` → `dart run scripts/contract/bootstrap.dart --skip-client`（`:69-70`）。
4. `Build generated API client` → `generated/lucent_api` 里 `dart pub get` + `build_runner build --delete-conflicting-outputs`（`:72-77`）。
  **缺这步 `flutter build` 编译期直接失败**（V，`.github/workflows/README.md:80-86`）。
5. `Compile drift web worker` → `dart compile js web/drift_worker.dart -o web/drift_worker.js -O4`（`:79-80`）。
  **`drift_worker.js` 与 `sqlite3.wasm` 都不入库**（V，`.gitignore:76-80`），必须现场生成/准备。
6. `flutter build web --release`，**不加 `--wasm`**（V，`:83-87` 的注释与 `web/flutter_bootstrap.js:4-20` 一致）。
7. `--dart-define` 列表（V，`:95-100`）：`LUCENT_BASE_URL` / `SENTRY_DSN` / `SUPPORT_EMAIL` / `LUMINOUS_EXPERIMENTAL_AI_RUNTIME` / `LUMINOUS_AI_RUNTIME_PROVIDER` / `LUMINOUS_ENABLE_GEN_UI`。
  全部 define 名称的权威清单在 `lib/core/config/env_reader.dart:44-79`。**新增的 CI 断言（本计划要求）**：
- 产物 `flutter_bootstrap.js` 的 `_flutter.buildConfig` **含 `"useLocalCanvasKit":true`**（§4.2）。
- 产物 `index.html` 的 `<base href>` 为 `/`。
- 产物根目录存在 `drift_worker.js` 与 `sqlite3.wasm`。
- 裁剪步骤（去掉 `canvaskit/*.js.symbols`、`canvaskit/skwasm*`、`canvaskit/wimp*`）后，**总量打印进日志**（用于确认 §3.2 的估算）。

### 8.3 制品进 HAP
| 步骤 | 做法 | 标注 |
|---|---|---|
| 1 | 壳仓的 `scripts/fetch-web-artifact.ps1` 从 Release asset 下载并解压到 `entry/src/main/resources/rawfile/web/` | U20：rawfile 是否支持子目录与任意层级 |
| 2 | `hvigorw assembleHap`（或 DevEco 构建） | V：本机 `hvigorw` **不在 PATH**，需先装 DevEco 并把 `hvigorw`/`ohpm` 加进 PATH |
| 3 | 签名 | **U21**：AGC 证书 / Profile / `build-profile.json5` 的具体形态；本计划**未调研** |
| 4 | 上架 | **U9**：AGC 应用登记、资质、隐私合规、动态加载代码的审核口径 |
**JDK 约束（V，本机实测，结论已更新）**：本机全局 `java -version` = **OpenJDK 25**（Zulu），DevEco 自带 JBR 亦为 25。**实测 `hvigorw --version` 在 JDK 25 下正常返回 `6.26.8`**，故「hvigor 必须 JDK 17」这一常见说法在本机未被证实——**不要预设必须降级 JDK**。Phase 0 先按现状跑；若 `assembleHap` 阶段出现 Java 版本相关报错，再考虑把 `JAVA_HOME` 指向 JDK 17（DevEco 安装目录下 `jbr\` 可直接用）。

### 8.4 对现有 7 条 workflow 的影响
| workflow | 是否要改 | 说明 |
|---|---|---|
| `ci.yml` | **不改** | 门禁面（analyze / test / 生成物一致性）与鸿蒙无关 |
| `deploy-web.yml` | **不改** | 它服务 GitHub Pages，产物 `--base-href` 与壳内不同，**不要为了壳去改它** |
| `deploy-android.yml` / `deploy-ios.yml` | **不改** | 与本方案无关 |
| `codeql.yml` / `osv-scanner.yml` / `scorecard.yml` | **不改** | 安全面 |
| **新增 `deploy-harmonyos.yml`** | — | 见 8.2 |
> 结论：**Luminous 侧 CI 只增不改**。这与「Dart 代码零改动」一起，构成本方案对主仓的最小侵入面。

## 九、分阶段执行

**排序原则：先把「Web 产物能不能在 ArkWeb 里跑起来」打穿，再谈壳的工程化。**Phase 0 不产出任何可交付物，但它决定本计划是否成立。
| Phase | 内容 | 出口条件 | 可并行边界 |
|---|---|---|---|
| **0 可行性打穿（Spike）** | **复用已装的 DevEco Studio**（`E:\DevEco Studio`，含 API 26 SDK / ohpm / hvigor / node）；把 `ohpm` / `hvigorw` / `node` 的 bin 与 `jbr\bin` 前置到 `PATH`，设 `TOOL_HOME` / `DEVECO_SDK_HOME`；建一个**最小 ArkTS 工程**（一个 `Web` 组件 + 一个按钮）；用现有 `build/web`（V，本机已有）**手工**推进 rawfile；逐条打 U1~U7、U8、U10、U13 | ① 真机/模拟器上**页面渲染出来**（不是白屏）；② CanvasKit 从**本地**加载（无 gstatic 请求）；③ `sqlite3.wasm` 与 `drift_worker.js` 加载成功、drift 首读写成功（**U7 判定**）；④ `localStorage` 跨重启保留（**U3 判定**）；⑤ `javaScriptProxy` echo 通（**U4 判定**） | 与「Web 制品本地化构建」（§4.2）并行：先手工把 `--web-resources-cdn=false` 的产物做出来 |
| **1 Web 制品契约 + CI** | 新增 `deploy-harmonyos.yml`（§8.2）；实现制品裁剪与清单（§8.1）；壳仓的 `fetch-web-artifact.ps1` | ① 流水线产出可下载制品；② 4 条 CI 断言全绿；③ 壳侧脚本能从零拉取并校验 | 与 Phase 2 的 ArkTS 骨架并行 |
| **2 壳工程化 + 桥接** | ArkTS 工程结构落地；B-1（返回键）、B-2（安全区）、B-10（外部链接）三条桥接；启动探测（`bridge.ping()`）与降级 UI | ① 三条桥接各有真机验收清单 + 失败降级路径；② 返回键在五 tab 与子页行为正确；③ 外链在系统浏览器打开 | 三条桥互不依赖，可并行；**B-6 只在 U3 失败时才做** |
| **3 降级口径与产品面** | §七 的 D-2/D-3/D-5/D-7/D-8 逐条真机确认「无死入口」；§5.3 的登录范围决策落地；热更新（方案 c）**仅在合规口径确认后**评估 | ① 五项降级逐条打勾；② 登录路径唯一且可用；③ 热更新有明确 go/no-go 结论 | 与 Phase 4 的文档收尾并行 |
| **4 真机回归 + 发布** | 逐条回归 §七 的降级清单；签名 + AGC 流程；文档收尾 | 见 §十 验收表 | 与文档收尾并行 |
**每阶段收尾**：在 **`Luminous` 仓**追加 `docs/logs/migration-log/YYYY-MM-DD.md`（append，不覆盖；本阶段对主仓的实际改动只有 CI 与可能的本计划文件）；壳仓按其自身约定记录。本计划完成的条目**直接删除**（本仓约定，不加标记）。
> **Phase 0 的出口条件不满足时不要进 Phase 1。** 具体地：如果 U7（drift）或 U3（localStorage）失败，
> 本计划需要先解决「Dart 零改动」与「能力可用」的冲突（§十二 待决 1），而不是继续做壳。

## 十、验收标准与风险回退

**验收**
| 项 | 验收 |
|---|---|
| 主仓侵入面 | `Luminous` 侧改动只允许：新增 `.github/workflows/deploy-harmonyos.yml`、新增本计划文件、追加迁移日志；**Dart 代码零 diff**（`git -C Luminous diff --stat -- lib/` 为空） |
| 渲染 | 真机冷启动进五 tab 壳；无白屏；CanvasKit 无 gstatic 请求（抓包或 console 断言） |
| 本地数据库 | drift 首读写成功（**这是 U7 的判定，也是本计划的硬门禁**） |
| 会话 | 杀进程重启后仍处于登录态（**U3 的判定**）；不满足则必须走 B-6 并重新评审 |
| 静默失效 | §七 的 D-2/D-3/D-5/D-7/D-8 逐条确认「入口不存在」或「有明确提示」，二选一，不许含糊 |
| 桥接 | B-1/B-2/B-10 各有真机清单；探测失败时有显式降级 UI，不静默 |
| 制品 | 4 条 CI 断言全绿；制品清单可被壳侧校验 |
| 回退 | 任一硬门禁（U7 / U3 / U1-U2 本地加载不通）→ **停止壳工程化，上报本计划可行性**，保留 Phase 0 的结论 |
**风险与回退**
| # | 风险 | 影响 | 缓解 / 回退 |
|---|---|---|---|
| 1 | **U3 失败：`localStorage` 不持久化** | 每次冷启动掉登录；且绕过修复需要改 Dart（与零改动冲突） | Phase 0 第一优先验证。失败则：要么放宽「Dart 零改动」并走 B-6，要么本计划降级为「鸿蒙版不做持久登录」（产品不可接受，等于不做） |
| 2 | **U7 失败：drift 落 stub** | 离线缓存与离线队列全废，cache-first 语义崩 | 先确认 `dart.library.js_interop` 在 dart2js 下是编译期常量（V，是）—— 若仍失败，说明是运行期问题而非条件导入问题，按 `database.dart:6-9` 注释的候选解法（补 `dart.library.html` 回退）评估，**需要改 Dart，另开任务** |
| 3 | **U1/U2/U6 失败：本地资源加载不通（白屏）** | 方案 (a) 不成立 | 回退到方案 (b)（远端加载），但会引入 §3.3 的 Origin/CORS 问题 → 需后端 `CORS_ORIGIN` 配合（**跨仓变更，另开任务**） |
| 4 | **U5：本地加载的 Origin 不被 Lucent 接受** | 所有 API 请求被 CORS 拦 | 确认后由后端加白名单（**Lucent 侧改动，另开任务**），或改用方案 (b) |
| 5 | **§4.1 的 CDN 依赖被漏掉** | 白屏，且现象与「资源没打进包」一模一样，排查成本高 | 4.2 的 CI 断言是硬要求；Phase 0 用抓包确认无 gstatic 请求 |
| 6 | 体积：HAP 带 37 MB 级 Web 资源 | 安装包大、审核可能关注 | §3.2 的裁剪清单；进一步可只保留 `canvaskit.wasm` 的**单一变体**（chromium/webparagraph 两档可删，U22） |
| 7 | 跨仓漂移：Web 构建参数变了、壳没跟上 | 白屏或功能静默缺失 | §8.1 的制品清单 + 壳侧启动校验（不匹配即拒绝加载并提示） |
| 8 | 鸿蒙工具链门槛（DevEco / DevEco / 签名 / AGC） | 交付延期 | 至少留一个迭代周期；签名与上架本次**未调研**（U21/U9） |
| 9 | 动态加载代码的合规口径不明 | 方案 (c) 的热更新部分不可做 | 第一版只做 (a)；热更新留 Phase 3 且先拿结论 |
| 10 | CI 无鸿蒙 runner | 无自动化门禁 | 不承诺「CI 全绿」前不声称鸿蒙可交付；退化为本地构建 + 人工门禁 |

## 十一、不做项

**不向 `Luminous` 提交任何 Dart 代码改动**（§1.1 第 1 条）。唯一例外需重新评审，见 §十二 待决 1。
- **不引入鸿蒙 Flutter SDK**（`D:\flutter-ohos`），不恢复 `TargetPlatform.ohos` 相关适配。
- **不做推送**（B-3/D-4）、**不做本地通知与用药提醒的原生实现**（D-3）。
- **不做扫码与 OCR 的原生桥**（B-7/D-7）；第一版隐藏入口。
- **不做健康数据桥**（D-5/D-6），与已删除的 SDK 适配计划结论一致。
- **不做后台同步的鸿蒙实现**（D-2），降级为「回前台冲刷」。
- **不做动态加载代码的热更新**（方案 c 的后半），Phase 3 拿到合规结论前不动。
- **不改 `deploy-web.yml`**，也不改其 `push: [refactor]` 的触发约定。
- **不碰 `Lucent/`**；CORS 白名单、OAuth 回调来源等需服务端配合的改动**另开任务**。
- **不碰 `Luminary/`**（§2.1 选项 C 已否决）。
- **不重新引入鸿蒙 Flutter SDK**：`D:\flutter-ohos` 已于 2026-10-23 删除，不恢复。

## 十二、待决问题（需要产品或他人拍板）
| # | 问题 | 需要谁拍 | 影响 |
|---|---|---|---|
| 1 | 若 U3（`localStorage`）或 U7（drift）失败，「Dart 零改动」是否放宽？放宽到什么程度？ | 技术 + 产品 | 决定本计划是否成立；也决定 B-6 做不做 |
| 2 | 鸿蒙版的登录范围：**仅邮箱/验证码**（本计划倾向）还是必须支持 QQ/Google/微信？ | 产品 | §5.3；决定是否要走方案 (b) 的登录路径与后端 CORS 配合 |
| 3 | 鸿蒙版是否进 0.1.0 交付范围？ | 产品 | 决定 §九 是否压缩到 Phase 0-2 收口 |
| 4 | 后台同步降级为「回前台冲刷」是否可接受？ | 产品 | D-2 |
| 5 | 用药提醒在鸿蒙版缺失是否可接受？若不可接受，是否单开一条 ArkTS 提醒任务？ | 产品 | D-3；这是鸿蒙版与移动端最大的能力落差 |
| 6 | 制品交付通道：GitHub Release asset / artifact / 私有对象存储？ | 工程 | §8.2 |
| 7 | 包名 / bundleName 与现有 Android `applicationId` 的关系 | 发布 | Phase 4 签名与 AGC 登记 |
| 8 | 壳工程放独立仓（推荐 B）还是 `Luminous/ohos-shell/`（A）？ | 工程 | §二；只影响 §八 与 `.gitignore` |

## 十三、待核实清单（U）
| # | 事项 | 验证方式 |
|---|---|---|
| U1 | ArkWeb 加载 rawfile 的**具体写法**（`$rawfile(...)` / `resource://rawfile/...` / `WebviewController.loadUrl` 的组合）与**相对路径**能否解析 | 最小工程真机实测，逐条打 console |
| U2 | 是否需要跨域放行配置（如 `setPathAllowingUniversalAccess`）才能让 rawfile 内的 `fetch()` / `WebAssembly.instantiateStreaming()` 工作 | 同 U1；重点看 `canvaskit.wasm` |
| U3 | `domStorageAccess` 默认值；`localStorage` 是否跨重启保留 | 写入 → 杀进程 → 重启 → 读回 |
| U4 | `javaScriptProxy` / `registerJavaScriptProxy` 的调用约定与**注入时机** | 真机 echo 用例 |
| U5 | 本地加载下 `location.origin` 的实际值 | 真机打印 + 抓包看请求头 |
| U6 | 本地资源的 MIME 处理，`.wasm` 是否以 `application/wasm` 提供 | 真机看 `fetch` 的 `Content-Type` |
| U7 | **ArkWeb 内 `dart.library.js_interop` 是否成立**（即 drift 走 `connection_web.dart` 还是 `connection.dart` 的 stub） | 真机启动后看本地库首读写；或加临时探针打印分支 |
| U8 | `--web-resources-cdn=false` 与 `--dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/` 两条路径的产物差异 | 构建后检查 `flutter_bootstrap.js` 的 `useLocalCanvasKit` 与 `canvaskit/` 目录 |
| U9 | 鸿蒙侧对**动态加载代码**（热更新）的合规与审核口径 | 官方文档 / AGC 审核说明 |
| U10 | ArkWeb 对 Web Worker 的支持度（`drift_worker.js` 依赖） | 真机看 drift 是否走跨线程 executor |
| U11 | `localStorage` / OPFS / IndexedDB 的容量上限 | 真机写入探测 |
| U12 | ArkWeb 的 `history` 与 Flutter/GoRouter 的路由状态是否一致（B-1 的前提） | 真机在子页按返回键 |
| U13 | ArkWeb 是否提供 CSS `env(safe-area-inset-*)`（B-2 的前提） | 真机看 `MediaQuery.padding` |
| U14 | 壳侧开放相机/通知权限给 Web 容器的声明方式（`module.json5`） | DevEco 权限表逐条核对 |
| U15 | ArkWeb 内 `<input type="file">` 与相机采集的实际行为 | 真机走一次头像上传 |
| U16 | 系统分享 / 文件选择（B-8 若要做）的 ArkTS API 形态 | 官方文档 + 真机 |
| U17 | ArkWeb 是否上报正确的网络状态（`connectivity_plus` 的前提） | 真机断网/恢复 |
| U18 | ArkWeb 内 `window.open` / 新窗口的行为；拦截外部链接的 API | 真机点外链 |
| U19 | 目标鸿蒙设备的逻辑宽度是否可能 ≥ `Breakpoints.desktop`（1200），即会不会切到桌面布局 | 真机 `MediaQuery.sizeOf` |
| U20 | rawfile 是否支持子目录与多层嵌套 | 真机实测 |
| U21 | AGC 签名材料（证书 / Profile / `build-profile.json5`）与自动签名能力 | 实际出包 |
| U22 | `canvaskit/chromium/` 与 `canvaskit/webparagraph/` 两档能否安全删除（取决于 ArkWeb 的浏览器能力判定） | 删除后真机渲染回归 |
| U23 | 若 `assembleHap` 出现 Java 版本报错，DevEco 自带 `jbr\`（当前 25）是否够用；不够时 JDK 17 的安装与 `JAVA_HOME` 切换方式 | 出报错后再定；`hvigorw --version` 在 25 下已实测可用 |

## 参考来源

- ArkWeb 本地资源加载与查询参数：<https://developer.huawei.com/consumer/cn/doc/harmonyOS-faqs/faqs-arkweb-39>
- ArkWeb 本地资源跨域问题与解决方案：<https://developer.huawei.com/consumer/cn/doc/doccenter-dev-faq/faqs-arkweb-193>
- ArkWeb 前端页面调用应用侧函数（`javaScriptProxy` 方向）：<https://developer.huawei.com/consumer/en/doc/harmonyos-guides/web-in-page-app-function-invoking>
- ArkWeb Cookie 与数据存储管理：<https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/web-cookie-and-data-storage-mgmt-V13>
- 本地离线资源白屏（社区讨论，仅作排查线索）：<https://developer.huawei.com/consumer/cn/forum/topic/0203223572311373061>

> 上述链接均为**外部资料**，本计划只把它们当作**候选线索**；U1~U22 的结论以真机实测为准，
> 不以文档表述为准（文档站为 JS 渲染，本次抓取只拿到骨架，未能核实具体 API 签名）。
>
> 本计划的逐项侦察产物（Web 能力分支、构建参数、产物体积）**已内联进正文**，正文不依赖任何仓内临时文件存续。
>
> **索引待补**：`plans/README.md` 的 Current Plans 表格需新增本计划一行（状态：待评审 / 未开工）。
> 本次改动范围限定为「只写本文件」，故该索引行**尚未添加**，执行 Phase 0 时一并补上。
