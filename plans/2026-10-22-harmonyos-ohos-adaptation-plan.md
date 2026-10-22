# Luminous 鸿蒙（OpenHarmony / ohos）适配执行计划

Created: 2026-10-22

> 状态：**待评审，未开工**。
> **执行位置：独立仓库 `Luminous-ohos`（由 Luminous 源码复制而来，见 §〇），本计划的改动不进 `Luminous`。**
> 本文件是执行清单，不是调研报告。依赖与代码耦合的调研结论已内联进正文，不再外链仓内临时文件。
>
> 标注约定：
> - **V（已验证）** = 已通过本地代码、pub 缓存或官方源确认的事实，执行时可照做；
> - **U（未验证）** = 需在本次执行中或执行后确认，附验证方式；全部收进文末「待核实清单」。
>
> **一件事先说清楚**：本计划唯一的硬阻塞是 `sqlite3` 的 native-assets hook 没有 ohos 目标 ——
> `flutter build hap` 在**构建期**就会失败（V）。它排在所有 Dart 补丁之前，是 Phase 1 的出口条件。
> 如果三种落地方案都不通，本计划整体不可行，需要就此上报而不是继续堆补丁。

## 〇、仓库结构决策（先定这个，再谈适配）

**决策：鸿蒙版是独立仓库 `Luminous-ohos`，由 Luminous 源码复制而来，不保留 git 历史，不与主线双向同步。**

| 项 | 决定 | 理由 |
|---|---|---|
| 仓库形态 | 独立 git 仓库，与 `Luminous` 并列（建议 `D:\25080\Documents\VSCodeProject\Lumos\Luminous-ohos`） | 鸿蒙的依赖链、SDK、平台判定全部与主线不同，混在一个仓库会让主干长期带着一套用不上的 fork 与平台分支 |
| 复制方式 | **拷贝文件，不沿用 `Luminous` 的 git 历史** | 不打算做 cherry-pick / merge，保留历史只会让人误以为两仓会持续同步 |
| `ohos/` 位置 | 在**鸿蒙仓库**根目录，与 `android/ ios/` 同级 | 工具链硬约束：`flutter create --platforms ohos .` 与 `flutter build hap` 只认这个位置 |
| `lib/` 与主线的关系 | **复制起手，此后独立演进**。主线的 UI / feature 改动**不要求**同步到鸿蒙 | 明确放弃一致性目标，换取鸿蒙侧改动的自由度 |
| 主线（`Luminous`）改动 | **零代码改动**。唯一例外是新增 `.fvmrc`（钉住 3.47.1），单列一次提交、单独评审 | 鸿蒙线失败时直接删仓库，主线代码毫发无损 |
| 反向回流 | **禁止**。鸿蒙侧的适配补丁不回灌 `Luminous` | 回灌会让主线被 fork 依赖与平台分支污染，正是拆分要避免的 |

**代价（明知而为，写在这里避免后面反复讨论）**：主线修一个 UI bug 或加一个新功能，鸿蒙版不会自动得到。
接受这个代价的前提是**鸿蒙版定位为独立分支产品**，不承诺与 Android/iOS 版本对齐。

**仍然必须遵守的边界**：

1. `Luminous-ohos` 内部继续遵守 `Luminous/AGENTS.md` 的架构约定（新代码只进 `lib/features|core|shared`、
   Riverpod 不用 GetX、GoRouter 不用 `Navigator.push`、l10n 走分片 ARB 合并）。复制起手就该保持整洁，
   否则鸿蒙仓库一年后会变成无人敢动的泥潭。
2. `Luminous-ohos` 自己的 `pubspec.lock` 由它的 SDK 生成，**不受主线 lockfile 约束**；
   反过来也不要把它的 lock 变更带回 `Luminous`。
3. 两仓之间唯一允许的共享物是 **Lucent 的 API 契约**（`Lucent/docs/reference/generated/openapi.json`）。
   契约变更时两边各自 `dart run scripts/contract/bootstrap.dart` 重新生成，不手工同步生成物。

## 一、目标与基线

| 项 | 当前 | 目标 |
|---|---|---|
| 应用 SDK | Flutter 3.47.1 / Dart 3.13.1（`D:\flutter`, stable）（V） | 鸿蒙 Flutter SDK **3.47.7-ohos-1.0.1**（社区先锋版），克隆到 **`D:\flutter-ohos`**，由 **FVM** 按项目锁定（见 §1.1）；`D:\flutter` 不动 |
| SDK 版本管理 | 无（裸 `flutter` 指向 `D:\flutter`）（V） | **FVM**：`Luminous/.fvmrc`=3.47.1、`Luminous-ohos/.fvmrc`=鸿蒙版；命令统一 `fvm flutter` |
| DevEco Studio | 未装 | **26.0.0**（硬要求） |
| Command Line Tools | — | **26.0.0**（硬要求） |
| 引擎构建最低 API | — | **OpenHarmony API 26.0.0** |
| 应用目标 API | — | **OpenHarmony API 26.0.0** |
| 应用最低运行 API | — | **OpenHarmony API 26.0.0** |
| 目标产物 | APK / IPA / Web / Windows | + `.hap`（AppGallery Connect 分发） |
| 平台目录 | `android/ ios/ linux/ macos/ web/ windows/`（V，无 `ohos/`） | **鸿蒙仓库**新增 `ohos/`（见 §〇，`Luminous` 本身不动） |
| CI | 5 个 workflow，固定 `flutter-version: 3.47.1`（V） | 鸿蒙仓库独立流水线或本地/云真机脚本（U） |
| 代码起点 | 台账见下：平台判定 **84 处 / 29 文件**；四档合计 **44 文件**（V） | 复制到 `Luminous-ohos` 后，收敛为**按能力维度**的判定接缝 |

**选 `3.47.7-ohos-1.0.1` 而不是 1.0.0 的理由**（V）：`1.0.1` 起 `flutter build hap` 支持自动签名
（自动申请 P12 / CSR / 证书 / Profile 并写入 `build-profile.json5`）。用 1.0.0 得手工走签名流程。

**最低运行 API 也是 26.0.0 这件事要一开始就记住**：设备兼容面被卡死在 API 26，没有更低 API 的降级空间。
这是选型时最容易忽略的硬约束，直接决定「能装机的设备池」有多大。

### 1.1 SDK 管理：FVM + 独立鸿蒙目录

**现状（V）**：本机**未安装 FVM**，`Luminous` 无 `.fvmrc` / `fvm_config.json`；鸿蒙 SDK 目录
`D:\flutter-ohos` **尚不存在**；`D:\flutter` 是唯一 SDK（3.47.1）。

**形态**：`Luminous` 与 `Luminous-ohos` 各自用 FVM 钉住自己的 SDK 版本，两个项目**不使用同一个 Flutter**。
鸿蒙 SDK 固定克隆到 **`D:\flutter-ohos`**（下文所有命令按此路径）。

| 步骤 | 命令 / 做法 | 备注 |
|---|---|---|
| 1. 装 FVM | 全局安装 FVM 并确认 `fvm --version` 可用 | FVM 是**前置依赖**，不是可选优化 |
| 2. 克隆鸿蒙 SDK | `git clone` `gitcode.com/oh-flutter/flutter_flutter` 到 **`D:\flutter-ohos`**，切到 `oh-3.47-dev` 分支 | 鸿蒙 SDK **不在 pub.dev 的版本列表里**，FVM 无法替你下载，只能先手动克隆 |
| 3. 注册为 FVM 版本 | 在 `Luminous-ohos` 里把 `D:\flutter-ohos` 注册为一个具名版本（本地目录当作 SDK 源） | 具名后团队其他人可用同一名字对齐，不必记住绝对路径 |
| 4. 钉版本 | `Luminous/.fvmrc` → `3.47.1`；`Luminous-ohos/.fvmrc` → 鸿蒙版本名 | 提交进仓库，`fvm install` 即可复现 |
| 5. 日常命令 | 两个仓库统一走 `fvm flutter ...` / `fvm dart ...` | 不要混用裸 `flutter`（裸命令指向 `D:\flutter`） |

**FVM 管不到、必须单独配的部分**（这是把环境变量表拆成两组的理由）：

| 项 | 是否 FVM 负责 | 说明 |
|---|---|---|
| Flutter / Dart 用哪个版本 | ✅ | FVM 的核心能力 |
| **`PUB_CACHE` 隔离** | ❌ **必须手工单独设** | FVM 不隔离 pub cache。两套 SDK 共用同一个 cache 会让 `package_config.json` 互相覆盖 → `Luminous-ohos` 里设独立 cache（如 `D:\flutter-ohos-pubcache`） |
| 鸿蒙工具链变量 | ❌ | `TOOL_HOME` / `DEVECO_SDK_HOME`、`ohpm` / `hvigor` / `node` 的 bin 进 `PATH` |
| `flutter config --ohos-sdk` | ❌ | 指向 `%TOOL_HOME%\sdk`，否则报 `No Hmos SDK found` |
| **`~/.npmrc`** | ❌ | `registry` 指华为云、`@ohos:registry` 指鸿蒙 npm，否则 hvigor 拉不到 `@jg/push` / `@tencent/wechat_open_sdk` |
| Windows JDK | ❌ | 需 **JDK 17**（`JAVA_HOME` + `PATH`），hvigor 依赖 |
| 镜像变量 | ❌ | `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL`；**切回官方 SDK 前必须恢复**，否则报 `Wrong full snapshot version`（解法：恢复变量 + 删 `<flutter>/bin/cache` + `flutter clean`） |
| Windows 符号链接 | ⚠️ | FVM 的 `.fvm/flutter_sdk` 是软链，Windows 需开发者模式或管理员权限；建不出来时表现为「找不到 SDK」，与鸿蒙无关 |

> 建议把「FVM 管不到」的那组收敛成一个 `scripts/ohos/env.ps1`（PowerShell profile 里 dot-source），
> 不手工改系统环境变量。**FVM 只解决「SDK 指向哪一套」，不解决「鸿蒙工具链怎么配」和「pub cache 怎么隔离」。**

**模拟器**：仅 Mac(arm64) / Windows(x64) 可跑；模拟器不支持 vulkan，需关 impeller。本机（Windows x64）可跑，
但**真机仍是最终门禁**。

### 1.2 平台判定的事实基线（这条推翻了「鸿蒙没法判定平台」的常见说法）

| 事实 | 结论 | 标注 |
|---|---|---|
| 鸿蒙 SDK 的 `TargetPlatform` 枚举**新增了 `TargetPlatform.ohos`** | `defaultTargetPlatform` 在 ohos 上取值就是 `TargetPlatform.ohos` | V |
| 上游 3.47.1 的 `TargetPlatform` 枚举**没有** `ohos` | 直接写 `TargetPlatform.ohos` 会让代码在上游 SDK 下**编译失败** | V |
| `Platform.isOhos` 存在，但**只存在于鸿蒙 SDK** | 同理不能直接写进共用源码 | V |
| `Platform.isAndroid` / `Platform.isIOS` 在 ohos 上**均为 false** | 所有 `isAndroid \|\| isIOS` 二分**静默走 else** —— 这是能力消失的主因 | V |
| `kIsWeb` 在 ohos 原生包为 **false** | 与平台判定无关 | V |
| `dart.library.io` 在 ohos 原生包**为真** | 仓里所有 `_stub` 兜底失效，插件缺失会直接抛异常，而不是降级 | V |

**三条推导**（决定了 §三 的 A/B 档边界）：

1. `TargetPlatform.*` 判定在鸿蒙上「可判定但缺分支」（值为 `ohos`，现有代码没写这个 case）；
   `Platform.isAndroid/isIOS` 判定则是「静默落 else」。**两类问题的修法不同**，不能混为一谈。
2. 判定接缝**只能**用 `Platform.operatingSystem == 'ohos'` 字符串比对，或条件导入 + SDK 专有常量。
3. **独立仓库后这条约束的紧迫性下降，但仍建议保留**：`Luminous-ohos` 只由鸿蒙 SDK 构建，
   理论上可以直接写 `TargetPlatform.ohos` / `Platform.isOhos`。保留字符串比对有两个好处：
   `flutter analyze` / `flutter test` 偶尔要用上游 SDK 跑作对照；复制起手的代码与主线同构，便于对照排查。
   **若确认全程只用鸿蒙 SDK，可放宽为直接写 `TargetPlatform.ohos`**（U，Phase 1 首次验证时定）。

## 二、依赖适配矩阵

> 口径：31 个真插件 → **3 个官方包自带 ohos** / **13 个仅社区 fork 或联邦实现** / **5 个无适配**，
> 另 **2 个本地包**需自建 ohos 端，其余为纯 Dart 不适用。
> 「3.47 可用」列统一为**未核实**：唯一权威的 CPF 清单只有 **3.7 / 3.22 / 3.27 / 3.35 四列**（表头原文
> 「3.35推荐版本」），目标 SDK 是 3.47.7-ohos，跨了 4 个框架大版本，**没有任何官方背书**。

### 2.1 已适配（pub.dev 官方包自带 ohos，零改源）— 3 项

| 依赖 | 版本 | 判定依据（本地 pub 缓存 pubspec 原文，V） | 3.47 可用 | 落地风险 |
|---|---|---|---|---|
| `jpush_flutter` | 3.5.8 | 包内自带 `ohos/`，`pluginClass: JpushHarmonySdkPlugin` | 未核实 | ohos 侧 `oh-package.json5` 依赖 `@jg/push` + `@ohos/flutter_ohos: ../../ohos`（假设 SDK 相对布局） |
| `fluwx` | 6.0.6 | 包内自带 `ohos/`，`pluginClass: FluwxPlugin` | 未核实 | `oh-package.json5` 引用 `file:./har/flutter.har`，**该文件在 pub 包内不存在**（V，实测 `Test-Path` 为 False），需手工补齐 |
| `flutter_image_compress` | 2.5.1 | 声明 `ohos: default_package: flutter_image_compress_ohos`；lockfile 已含 `0.0.3+1` | 未核实 | 无（注意：**ohos 实现不在本包**，在同厂 `flutter_image_compress_ohos`，靠 `default_package` 转接） |

> 这两个已适配包对 SDK 目录结构的假设**互不一致**（jpush 假设 `../../ohos`，fluwx 假设 `./har/flutter.har`），
> 必须在同一个工程里调通。这是 Phase 2 第一波的真实工作量。

### 2.2 仅社区 fork / 联邦实现 — 13 项

分三批，**不能混批替换**：三批的 Dart 约束与 API 面差异完全不同。

**第 1 批：openharmony-tpc 联邦实现（Dart 约束 `<4.0.0`，与 3.13 兼容，2026-08-19 发布）— 先试这批**

| 依赖 | 本项目 | 建议来源 | Dart 约束（V） | 3.47 可用 |
|---|---|---|---|---|
| `path_provider` | 2.1.6 | `path_provider_ohos` **2.2.1**（pub.dev） | `<4.0.0` ✓ | 未核实 |
| `shared_preferences` | 2.5.6 | `shared_preferences_ohos` **2.2.0**（pub.dev） | `<4.0.0` ✓ | 未核实 |
| `url_launcher` | 6.3.3 | `url_launcher_ohos` **6.3.0**（pub.dev） | `<4.0.0` ✓ | 未核实 |
| `webview_flutter` | 4.14.1 | `webview_flutter_ohos` **3.15.0**（pub.dev） | `<4.0.0` ✓ | 未核实 |

连带：`cached_network_image` → `flutter_cache_manager` → `path_provider`，不需单独处理。
**反例要记住**：openharmony-tpc 的**应用层**包（fork 内的 `url_launcher`）是 `sdk: ">=2.17.0 <3.0.0"`，与本仓 Dart 3.13 冲突 —— 只能用 `*_ohos` 实现包，不能用它的应用层包。

**第 2 批：CPF-Flutter fork（基线落后本项目 1–2 个大版本，换包必须同步改 Dart 调用面）**

| 依赖 | 本项目 | fork 基线（V） | 落差 | 必须先确认 |
|---|---|---|---|---|
| `flutter_secure_storage` | 10.3.1 | **8.0.0** + ohos 1.0.0 | 2 个大版本 | **换插件不够**：Dart 侧 `_selectOptions` 的平台分支在 ohos 直接 `throw UnsupportedError`，必须同时打补丁 |
| `flutter_local_notifications` | 22.3.2 | **17.1.0** | 5 个大版本，最大 | 精确闹钟/调度 API 需逐点回退 |
| `mobile_scanner` | 7.4.2 | **3.5.6** | 4 个大版本 | `MobileScannerController` 契约、`onDetect`、facing/torch 参数全变 |
| `share_plus` | 13.3.1 | **7.2.0** | 6 个大版本 | 13.x 的 `SharePlus.instance.share(...)` 在 7.2.0 不存在，**API 必须回退** |
| `permission_handler` | 12.0.3 | **10.4.3**（ohos 实现 10.3.2） | 2 个大版本 | `Permission.*` 枚举是否覆盖 `camera` / `notification`（本仓只用这两项，V） |
| `package_info_plus` | 10.2.2 | **4.2.0** | 6 个大版本 | `PackageInfo` 字段差异 |
| `device_info_plus` | 13.2.0 | **9.1.0** | 4 个大版本 | 有 `Platform.isAndroid/isIOS` 分支，ohos 落 else，需补 |
| `connectivity_plus` | 6.1.5 | **5.0.1** | 1 个大版本 | `ConnectivityResult` 枚举差异 |
| `sentry_flutter` | 9.24.0 | 未取到可验证 pubspec | — | 崩溃上报通道需实测，可能退化为「无原生 crash 捕获」 |
| `app_links` | 7.2.2 | master 无 ohos 键 | — | 清单标 ✓ 与仓库实际不符；深链是 OAuth 回调命门，优先自写 ArkTS（C1） |

**第 3 批：备选替代（仅在批 1/2 失败时启用）**

| 场景 | 备选 | 约束 |
|---|---|---|
| WebView | `flutter_inappwebview` CPF 分支 `br_v6.1.5_ohos`（6.1.5，`sdk >=3.4.0 <4.0.0`，兼容） | 仅内嵌 OAuth 需要时才值得换 |
| 取图 | `file_picker_ohos` 1.0.1（选文件，非拍照） | 只能替代相册，不能替代相机 |

**两条硬约束（违反会直接失败）**

1. **`permission_handler_ohos 0.0.8`（pub.dev）与 CPF 的 `flutter_secure_storage_ohos` 都是 `sdk <3.0.0`，
   与本仓 Dart 3.13 直接冲突。** 这两个包名在 pub.dev 与 gitcode 上是不同的东西：CPF 仓库内的
   `permission_handler_ohos` 是 `>=2.15.0 <4.0.0`。**引入时以仓库地址为准，绝不按名字检索 pub.dev。**
2. 仅社区 fork 的包一律 `git: url + ref: <tag>`，**不用分支**；tag 号当前**未核实**（U3）——gitcode 的 tags 页由
   JS 渲染抓不到，本机对 gitcode API / git 协议的 TLS 握手失败。现有替代证据是 master 分支 pubspec 的
   `version:` 字段。**在拿到真实 tag 前不得提交 pubspec 改动。**

**git dependency 与 override 规则**

1. 每个 fork 条目在 `Luminous-ohos/pubspec.yaml` 保留一行注释：来源仓库 + 基线版本 + 已知缺失能力。
2. ohos 相关的 `dependency_overrides` **只加在 `Luminous-ohos` 里**，`Luminous` 的 overrides 保持原样
   （现状是 `device_info_plus: ^13.0.0`，解决 `health` → `device_info_plus` → `win32` 与
   `package_info_plus` 的冲突，V；另有本地 `paddle_ocr_native`）。
3. `Luminous-ohos/pubspec.lock` 由它自己的 SDK 生成，与 `Luminous` 的 lockfile 互不相干。

> 独立仓库把这一整类「污染」问题消掉了——这是选独立仓库最主要的收益。

### 2.3 无适配 — 5 项

| 依赖 | 版本 | 现状（V） | 处理去向 |
|---|---|---|---|
| `health` | 13.3.2 | 42+ 个版本无一个声明 ohos；实现是 `Platform.isIOS ? appleHealth : googleHealthConnect` 二分 | D1：整块降级 |
| `workmanager` | 0.10.10 | platforms 无 ohos；CPF 清单无此条 | C3 / D3 |
| `add_2_calendar` | 3.1.1 | platforms 无 ohos；CPF 清单无此条 | D5：隐藏按钮 |
| `image_picker` | 1.2.4 | platforms 无 ohos；**pub.dev 上 `image_picker_ohos` 不存在** | C7b：自写或 `file_picker_ohos` |
| `sqlite3_flutter_libs` | 0.6.0+eol | **空壳包**：pubspec 连 `flutter:` 段都没有，`description` 原文 "Not used anymore" | 删除 |

本地包（同属「无适配」，处理见 §四）：`paddle_ocr_native 0.1.1`（platforms 仅 android/ios）、
`luminous_native_bridge 0.1.0`（Pigeon，platforms 仅 android/ios）。

`sqlite3` / `drift` 单独归到 §三 C8：二者是纯 Dart 包，但 `sqlite3 3.7.0` 的 native 供给路径内置了一份
**不含 ohos 的白名单**，这是本计划唯一的硬阻塞。

### 2.4 不适用（纯 Dart / 桌面专用）

`flutter_riverpod` `hooks_riverpod` `riverpod_annotation` `fpdart` `flutter_hooks` `go_router` `dio`
`intl` `units_converter` `timezone` `path` `collection` `json_annotation` `freezed_annotation` `fl_chart`
`table_calendar` `shimmer` `flutter_animate` `flutter_markdown_plus` `email_validator` `photo_view`
`flutter_svg` `forui` `forui_hooks` `forui_lucide` `forui_phosphor` `material_ui` `timeline_tile`
`flutter_slidable` `clock` `crypto` `talker_flutter` `sentry` `sentry_dio` `animations` `crop_your_image`
`flutter_gen_ai_chat_ui` `cached_network_image` `drift`；`window_manager`（桌面专用，手机端不引入）。

三处要复核：`flutter_svg`（经 `vector_graphics` 走 native 编译，ohos 工具链下能否过 —— U4）、
`cached_network_image`（间接依赖 `path_provider`）、`window_manager`（将来做鸿蒙 PC 端则无适配）。

## 三、代码耦合改动清单

四档合计 **44 文件**：A 纯 Dart **17** / B 条件导入 **7**（另新增 5 个文件）/ C 需 ArkTS **13** / D 需降级 **8**。
A、B 有 1 个文件重叠（`database.dart` 同时承担 A 的 `kIsWeb` 分支与 B 的 `connection_*.dart` 分发）。

### A0 前置：判定接缝（先做，所有 A 档改动都依赖它）

| 项 | 内容 |
|---|---|
| 新增 | `lib/core/platform/is_ohos.dart`（条件导出）；实现用 `Platform.operatingSystem == 'ohos'` |
| 为什么不用 `TargetPlatform.ohos` | 它只在鸿蒙 SDK 存在，直接写会让 CI 的 3.47.1 编译失败；`test/` 23 处判定也要在上游 SDK 下跑通 |
| 为什么不用 `Platform.isOhos` | 同理，鸿蒙 SDK 专有 |
| 合规性 | AGENTS.md 明确「Platform conditional exports (`if (dart.library.io)`) 是 barrel 禁令的豁免」 |

**⚠️ 关键设计决定：按能力维度拆，不按平台维度合并。**

把 24 处 `isAndroid \|\| isIOS` 统一替换成一个 `isMobile` getter 是**错的**。这些判定散落 9 个文件，
各自语义并不相同（推送=有推送通道、健康=有 HealthKit/HealthConnect、扫码=有相机、后台同步=有 WorkManager），
而**鸿蒙上这些语义并不一致地成立**（有相机 ≠ 有 HealthKit ≠ 有 WorkManager ≠ 有推送）。
统一换成一个 getter 会把 D1/D2/D3 的降级判定全部写错。

接缝拆成八个能力位，各自独立决定是否含 ohos（与下方 A1 表格的 # 编号一一对应）。
新增站点必须挂到已有能力位或补一行，**不许在 feature 里再散写平台判定**：

| 能力位 | 覆盖 A1 站点 | ohos 初值 |
|---|---|---|
| `supportsBackgroundSync` | A1.1 / A1.2 / A1.3 | Phase 1 false → 产品拍板后定 |
| `supportsPush` | A1.4 | Phase 2 验证 jpush 后定 |
| `supportsLocalNotification` | A1.5 / A1.6 | Phase 1 false → Phase 3 后 true |
| `supportsDeepLink` | A1.7 | Phase 1 false → C1 落地后 true |
| `supportsHealthSync` | A1.8 / A1.9 | **false（永久，D1）** |
| `canScanCode` | A1.10 / A1.11 | Phase 1 false → C7a 落地后 true |
| `canWechatAuth` | A1.14 | Phase 2 第一波后 true（fluwx 已自带 ohos） |
| `canEmbedOAuthWebView` | A1.15 | Phase 1 false → C5 落地后 true |

### A 档：纯 Dart 分支补丁（17 文件 / 24 站点）

**A1 移动端专用判定 → 必须并入 ohos（否则功能静默消失）**

| # | file:line | 现状 | ohos 下的后果 | 改法 |
|---|---|---|---|---|
| A1.1 | `core/database/sync/background.dart:23` | `!(Platform.isAndroid \|\| Platform.isIOS) → return` | WorkManager 从不 initialize，离线队列只在冷启动冲刷 | 走 `supportsBackgroundSync` |
| A1.2 | `core/database/sync/background.dart:42` | `if (Platform.isAndroid)` 注册周期任务 | 无周期任务 | 见 C3 |
| A1.3 | `core/database/sync/background.dart:66` | `cancel` 同上早退 | 取消变 null-op，**掩盖问题** | 同 A1.1 |
| A1.4 | `core/push/jpush_gateway.dart:43-45` | `_platform == android \|\| iOS` | `isConfigured` 永假 → **推送全链路静默失效**（`main.dart` 里 try/catch 吞掉，无日志级错误） | 走 `supportsPush` |
| A1.5 | `core/notifications/local_notification_gateway.dart:277-280` | `_supportsLocalSchedulingOnThisPlatform => android \|\| iOS` | 用药提醒/晚安提醒**全灭**，`schedule()` 永远返回 false | 走 `supportsLocalNotification` |
| A1.6 | `core/notifications/local_notification_gateway.dart:282-298` | `_hasPlatformPluginBinding` 只认 Android/iOS | 返回 false | 补 ohos 绑定探测 |
| A1.7 | `core/router/deep_link.dart:68` | 非 android/iOS/macOS → `NoopDeepLinkSource` | **微信回跳 / 分享链接全失效** | 加 ohos；底层见 C1 |
| A1.8 | `features/health_data/data/datasources/health_platform.dart:29` | `!isIOS && !isAndroid → false` | 健康数据整块不可用 | **保持 false**（D1 的预期降级），不补 ohos |
| A1.9 | `features/health_data/data/repositories/health_sync.dart:38` | `isIOS ? 'apple_health' : 'health_connect'` | ohos 落 `'health_connect'`（**语义错误**），但 A1.8 后不可达 | 建议显式加 `'ohos_health'`；**需 Lucent 接受新枚举值（跨仓契约，另开任务，不混入本计划）** |
| A1.10 | `features/medicine/data/repositories/lucent_workspace.dart:219` | `isAndroid \|\| isIOS` 才给扫码快捷入口 | ohos 无入口、**无提示** | 先只放条码，C7a 落地后放开 |
| A1.11 | `features/search/presentation/widgets/views/content.dart:23` | 同上 | 同上 | 同上 |
| A1.12 | `features/mine/presentation/widgets/sections/account_security.dart:60` | 健康同步磁贴判定 | ohos 不显示（**可接受，D1 已覆盖**） | 不动 |
| A1.13 | `features/mine/presentation/widgets/sections/account_security.dart:72` | `isIOS ? subtitleIos : subtitleAndroid` | 当前不可达 | 若放开需新增 l10n key → 走 `lib/l10n/src/health_sync_{zh,en}.arb` + `arb_tools merge` + `flutter gen-l10n`，**禁止直改 `app_*.arb`** |
| A1.14 | `features/auth/data/datasources/wechat/mobile_auth_client_fluwx.dart:19-24` | `android \|\| iOS` | 微信登录/绑定不可用 | **加 ohos，性价比最高的一项**（fluwx 6.0.6 已自带 ohos） |
| A1.15 | `features/auth/presentation/services/oauth_webview.dart:36-40` | `android \|\| iOS` | 走外部浏览器 → 依赖深链，叠加 A1.7 双失效 | 若 C5 落地则加 ohos，否则保持 false（可接受） |

**A2 桌面专用判定 → ohos 走 else 即正确（确认不动）**

`app/bootstrap.dart:265`、`app/window_manager_setup.dart:18`、`features/shell/presentation/page.dart:180`、
`core/theme/family.dart:386-407`（该 Map 源码注释自述无消费方；即便被消费，OH SDK 的 fallback 已含 ohos）。

> 好消息：**本仓没有一处「桌面专用」判定会被 ohos 误伤**（`isWindows/isLinux/isMacOS` 在 ohos 都是 false）。
> 真正的问题全部是「移动端专用」判定。

> 独立仓库后的简化：`Luminous-ohos` 里 `android/ ios/ linux/ macos/ web/ windows/` 目录已删除，
> 但**平台判定分支仍在 Dart 代码里**（它们编译在 `lib/` 中）。处理方式有两种，Phase 1 二选一：
> ① 保留分支、把 ohos 并入能力位（工作量小，与主线同构，便于对照）；
> ② 直接删掉 Android/iOS 分支、只留 ohos（代码更干净，但彻底失去与主线的可对照性）。
> **建议 ①**：鸿蒙侧第一次适配时，保留原分支能快速定位「这段逻辑原来是给 Android 的哪条路径」。

**A3 其余 Dart 侧分支（确认 / 微调）**

| file:line | 结论 |
|---|---|
| `core/analytics/product_event_service.dart:37-44` | `switch` 有 `_ =>` 兜底，**不会因新增枚举值编译失败**；ohos 上报 `other`，可接受（要区分需改 OpenAPI 契约，不做） |
| `core/network/client/session_store.dart:184` | `_useFallback => kIsWeb`。secure_storage 无 ohos → 首次 `read()` 抛 `MissingPluginException` → **登录态无法持久化**（高危，见 C6） |
| `features/settings/domain/services/notification_permission.dart:45,72,96` | 三处只挡了 `kIsWeb`；插件缺失时 `Permission.notification.status` 是**未捕获异常**，直接崩在设置页（高危，见 D5 前置） |
| `core/widgets/common/avatar/avatar_draft.dart:62` | ohos 走裁剪，依赖 `XFile.name` 带扩展名，低风险 |
| `core/config/developer_settings.dart:76`、`core/network/client/base_url.dart:42` | ohos 取 `127.0.0.1`；真机连宿主机需改可达地址（开发体验项，非功能缺陷） |

**A4 无判定但隐含移动端假设（易漏点）**

| file:line | 风险 |
|---|---|
| `features/scan/presentation/pages/barcode_scanner.dart:76-92` | 直接调 `Permission.camera.status/request()`，**无平台判定** → 需配套 `ohos.permission.CAMERA`（C7a） |
| `features/medicine/presentation/services/reminder_calendar.dart:37` | `Add2Calendar.addEvent2Cal` 无判定 → ohos 抛 `MissingPluginException`（D5） |

### B 档：条件导入新增 ohos 分支（7 文件 / 9 站点，另新增 5 个文件）

**前提（V）**：`dart.library.io` 在 ohos 原生包中**为真**，而 `dart.library.js_interop` 在原生 AOT 下**未核实**。
后果：现有 `_stub` 兜底**全部失效**，插件缺失会直接抛异常而不是降级。这条放大了 C 档所有风险。

| # | 站点 | ohos 落点 | 动作 |
|---|---|---|---|
| B1 | `core/database/database.dart:10-13` | `connection_io.dart`（**落对了分支**） | 保留；底层见 C8 |
| B2 | `core/database/connection.dart:9-14` | 不落（stub） | 不动 |
| B3 | `core/database/connection_web.dart:6` | 原生包不走 | 源码注释里对 HarmonyOS ArkWeb 的期待降级为「未验证」（D7） |
| B4 | `core/router/deep_link_source.dart:3` + `_io.dart:16` | `deep_link_source_io`（依赖 `app_links`） | 若 `app_links` 无 ohos → 新增 `deep_link_source_ohos.dart`（C1） |
| B5 | `features/auth/.../wechat/mobile_auth_client.dart:1-3` | `mobile_auth_client_fluwx.dart` | **无需新分支**，只差 A1.14 |
| B6 | `features/auth/.../desktop_oauth_callback_listener.dart:1-2` | `_io`（`isSupported` false） | 不动 |
| B7 | 新增 `lib/core/platform/is_ohos.dart` | — | A0 的接缝文件 |

### C 档：需原生 ArkTS / NAPI 实现（13 文件）

**按优先级排列 —— C8 排第一，不是因为它最重，而是因为它在构建期就挡死一切。**

| # | 能力 | Dart 侧 | 需要做什么 | 优先级 |
|---|---|---|---|---|
| **C8** | **`sqlite3` / `drift` native 库** | `core/database/connection_io.dart:12-22`、`database.dart:119-125` | 见下方专节 | **P0，硬阻塞** |
| C6 | `flutter_secure_storage` | `core/network/client/session_store.dart:165-280` | `@ohos.security.huks` 实现 read/write/delete/readAll/deleteAll，保持 `session_store.dart:52-65` 的「一对一 key、原子写」不变量 | P0 |
| C4 | 微信登录（fluwx） | `mobile_auth_client_fluwx.dart:19-24` | **插件已自带 ohos**，只需 `module.json5` 配 AppId + `linkUri`（对应 iOS 的 UniversalLink）；风险：鸿蒙微信 SDK 是否接受同一 AppId（U5） | P1，成本最低 |
| C1 | 深链 `app_links` | `core/router/deep_link_source_io.dart:16-22` | `UIAbility.onNewWant` + `want.uri` → MethodChannel/EventChannel；`module.json5` 声明 `uris`（scheme/host 对齐 `LUMINOUS_DEEP_LINK_SCHEME` / `LUMINOUS_DEEP_LINK_HOST`） | P1 |
| C2 | 本地通知 + 提醒 | `local_notification_gateway.dart:60-66,341-366` | `@ohos.notificationManager.publish` + 延迟代理（`reminderAgentManager`）；对齐 `_soundingChannelId` / `_silentChannelId` | P1 |
| C7a | 扫码 | `features/scan/presentation/pages/barcode_scanner.dart:77-98` | `@ohos.multimedia.camera` + 条码识别；`ohos.permission.CAMERA` | P2 |
| C7b | 拍照 / 相册 | `avatar_draft.dart:45-50`、`record/presentation/pages/create.dart:162-206`、`record_edit_controller.dart:302`、`meal_flow.dart:20-21`、`box_scan.dart:7` | `@ohos.file.photoAccessHelper`（Picker **免权限**）+ 相机 | P2 |
| C3 | 后台同步 | `core/database/sync/background.dart:24,42-61,66-68` + `background_entry.dart:24-60` | `reminderAgentManager`（闹钟语义）或 `backgroundTaskManager`（长时任务需前台通知）；`@pragma('vm:entry-point')` 需平台在独立 Ability 拉起 | P2，**语义待产品重谈** |
| C5 | WebView（OAuth 内嵌） | `features/auth/presentation/services/oauth_webview.dart:59-204` | ArkWeb 封装；当前 `isOAuthWebViewSupported` false 已可走外部浏览器 + 深链，**不阻塞登录主链路** | P3，可延后 |
| C9 | 步数桥 | `pkgs/luminous_native_bridge`（Pigeon） + `native/luminous-native`（KMP，只有 android/ios target） | 见 §四 | **不做** |

#### C8 专节：sqlite3 的构建期硬阻塞（本计划最重要的一条）

**机制（V，源码级核实）**：`sqlite3 3.7.0` 已改为 Dart native-assets（hook）机制。

- `lib/src/hook/assets.dart:35-64` 的 `TargetOperatingSystem` 枚举只有 windows / macos / linux / ios /
  iosSimulator / android / **unknown**，没有 ohos；`forConfig` 的 `_ => unknown` 把 ohos 归到
  `unknown(OS.linux, customName: 'unknown')`。
- `:185-207` 的 `_supportedAbis` **没有 `unknown` 键** → `isSupported`（`:82-95`）返回 false →
  `checkSupported()`（`:148-156`）抛 `UnsupportedError('There is no pre-compiled sqlite3 library for this target…')`。
- **结论：`flutter build hap` 在 native-assets hook 阶段就失败，不是运行期。**
- 叠加第二个问题：`sqlite3_flutter_libs 0.6.0+eol` 是空壳包（源码首行注释 "This package does not do anything."），
  曾经负责「把 `libsqlite3.so` 塞进产物」的环节**现在没人做**。

**三种落地方案（按先易后难排列，全部需实测）**

| 方案 | 做法 | 风险 | 标注 |
|---|---|---|---|
| ① `source: system` + 自备 .so | pubspec 配 `sqlite3` 的 hook user_defines 为 `source: system` + 名称；ArkTS 侧把 `libs/arm64-v8a/libsqlite3.so` 打进 HAP | 前提是 OH SDK 把 ohos 的 `targetOS` 传给 hook；若仍被映射成 `unknown`/`linux` 则失败 | 未核实，**先试这个** |
| ② `source: source` + 交叉编译 | 指向 sqlite amalgamation，用 `native_toolchain_c` 交叉编译到 OHOS（需 OH toolchain / clang sysroot） | 步骤最重，但最稳 | 未核实 |
| ③ 绕过 hook | 自己 `DynamicLibrary.open` 打开自备 .so，不走 code-asset 白名单 | 要改 `connection_io.dart` 的 open 逻辑，侵入 drift 的初始化 | 未核实 |

**方案「用 wasm」不可行**（V）：`flutter build hap` 不打包 `web/sqlite3.wasm` / `drift_worker.js`，
AOT 消费不到。

> 这一项**必须排在所有 Dart 补丁之前**。它是 Phase 1 的出口条件：没有本地数据库，drift 是 cache-first
> 底座，App 连启动都过不去。

### D 档：无替代方案需产品降级（8 文件）

| # | 能力 | 降级口径 | 现状是否已自然降级 |
|---|---|---|---|
| D1 | 健康数据同步（HealthKit / Health Connect） | 隐藏「健康同步」入口，本地手动录入保留；未来走华为 Health Service Kit（需独立授权 + SDK，指标集/授权模型不同，血压血糖需单独商业授权） | 是（`health_platform.dart:29` false，`account_security.dart:60` 已隐藏磁贴） |
| D2 | JPush 推送 | 若极光鸿蒙 SDK 不可用 → 仅应用内消息 + 本地通知 | 取决于 §2.1 验证结果 |
| D3 | 15 分钟后台同步 | 降级为「回前台冲刷」；离线记录上云延迟从 ≤15min 变为「下次打开」（**产品须知情**） | 是（`background.dart:23` 静默不启动） |
| D4 | 离线 PaddleOCR 药盒/处方识别 | 第一版不做：不下载模型、隐藏入口，保留云端识别（若 Lucent 提供）。理由：Android 侧是 ONNX Runtime 1.21.1 + OpenCV 4.13.0 + 约 30 个 Kotlin 文件 + JNI，且只打 `arm64-v8a`；鸿蒙等于整套重写（ONNX Runtime OHOS 构建 + OpenCV 交叉编译 + `PixelMap` 转 tensor 的 NAPI 桥） | 是（模型缺失即不可用） |
| D5 | 日历写入 | 隐藏「添加到日历」按钮，保留本地通知 | **否**（会抛未捕获异常，需先修 `reminder_calendar.dart:37`） |
| D6 | 微信桌面 OAuth loopback | ohos 上无完整链路（`isSupported` 已限定桌面三平台），走 C4 移动 SDK | 是 |
| D7 | ArkWeb 内嵌 H5 形态 | **第一版不做**；`connection_web.dart` 注释降级为「未验证」 | 是 |
| D8 | 桌面窗口能力 | ohos 无桌面窗口，走 else 正确 | 是（仅需确认测试无「desktop chrome 一定存在」的断言） |

### 测试侧联动（不属 `lib/`，但会随 A 档一起改）

`test/` 下有 **9 个文件 / 23 处**平台判定（`debugDefaultTargetPlatformOverride` / `TargetPlatform.*` / `Platform.is`），
路径相对 `test/`：`core/config/developer_settings_test.dart`、`core/config/env_reader_web_compat_test.dart`、
`core/network/base_url_test.dart`、`core/notifications/local_notification_gateway_test.dart`、
`core/push/{jpush_gateway,lifecycle,message_handler}_test.dart`、`helpers/mocks/medicine.dart`、
`scripts/support_test.dart`。

→ 这是「接缝必须用 `Platform.operatingSystem == 'ohos'` 而不是 `TargetPlatform.ohos`」的核心理由：
这些测试要在**上游 3.47.1** 下继续跑通。

## 四、原生能力映射

| 能力 | 现实现 | 鸿蒙侧路径 | 档 | 备注 |
|---|---|---|---|---|
| 微信登录/分享 | `fluwx 6.0.6` | 插件自带 ohos + `module.json5` 配 AppId/`linkUri` | 已适配→C4 | 成本最低的完整链路 |
| 推送 | `jpush_flutter 3.5.8` | 插件自带 ohos（`@jg/push`） | 已适配 | 与华为 Push Kit 是否二选一待决 |
| 本地通知/提醒 | `flutter_local_notifications` | `@ohos.notificationManager` + 延迟代理 | C2 | 与 C3 的后台机制存在取舍，**必须一起设计** |
| 健康数据 | `health 13.3.2` | 华为 Health Service Kit | D1 | 第一版隐藏入口 |
| 扫码 | `mobile_scanner` + `permission_handler` | `@ohos.multimedia.camera` + 条码识别 | C7a | 入口在 A1.10/A1.11 |
| 拍照/相册 | `image_picker` | `photoAccessHelper` Picker（免权限） | C7b | 或 `file_picker_ohos`（仅文件） |
| 图片压缩 | `flutter_image_compress` | 插件自带 `_ohos` 联邦实现 | 已适配 | 可能开箱可用 |
| OCR | `paddle_ocr_native`（ONNX） | ONNX Runtime OHOS 构建（U7）+ NAPI | D4 | 第一版不做 |
| WebView | `webview_flutter` | `webview_flutter_ohos` 3.15.0 / ArkWeb | C5 | 不阻塞登录 |
| 深链 | `app_links` | `UIAbility.onNewWant` + `want.uri` | C1 | OAuth 回调命门 |
| SQLite / drift | `drift` + `sqlite3` + 空壳 libs | 自建 `libsqlite3.so` + hook 配置 | **C8** | 硬阻塞 |
| 安全存储 | `flutter_secure_storage` | `@ohos.security.huks` | C6 | 缺失 = 冷启动掉登录 |
| 日历 | `add_2_calendar` | `@ohos.calendarManager` | D5 | 隐藏按钮 |
| 后台同步 | `workmanager` | `reminderAgentManager` / `backgroundTaskManager` | C3/D3 | 语义需重谈 |
| 步数 KMP 桥 | Pigeon + KMP | **不做**；`nativeStepsEnabledProvider` 返回 false | 不做 | 见下 |
| 权限 | `AndroidManifest.xml` / `Info.plist` | `ohos/entry/src/main/module.json5` | B | 见下表 |

### 4.1 步数 KMP 桥：加 target 还是整条重写

| 组件 | 现状（V） | 加 ohos 需要做什么 |
|---|---|---|
| `pkgs/luminous_native_bridge`（Pigeon） | `flutter.plugin.platforms` 只声明 android / ios；`pigeon/steps.dart:32-39` 定义 `@HostApi() StepHostApi { capability(); read(request); }`；Dart 入口 `lib/luminous_native_bridge.dart:8-26` | ① pubspec 加 `ohos: pluginClass: ...`；② **Pigeon 是否支持生成 ArkTS host：U6**。若不支持，需手写 ArkTS 复刻 `dev.flutter.pigeon.StepHostApi.*` 的 BasicMessageChannel 协议（通道名与编解码格式要按 `steps.g.dart` 反推，比「手写一个 MethodChannel」重得多） |
| `native/luminous-native`（KMP） | `build.gradle.kts:12-47` 只有 `androidLibrary` + `iosArm64/iosSimulatorArm64`；`commonMain` 13 文件 / `androidMain` 5 文件（`steps/{sensor,permission,day,baseline,source}.kt`）/ `iosMain` 7 文件 | 需新增 `ohosArm64()` 目标 + `ohosMain` sourceSet，把 `androidMain` 的传感器实现用 OHOS 传感器 API 重写。**这不是「加个 target」，是一条新平台实现链**（Kotlin/OHOS 原生互操作成熟度：U13） |

**决策：不做。** 现成出口已经存在 —— `lib/core/native/bridge.dart:8` 的 `nativeStepsEnabledProvider`
可整体关闭 native 步数，`features/health_data/data/providers/health_sync.dart:24-27` 在 false 时返回 null。
ohos 上让它返回 false，步数走 D1 的降级路径（无健康数据 → 无步数），省下整条 KMP ohos 链。

### 4.2 权限映射（Android / iOS → 鸿蒙 `module.json5`）

| 能力 | Android | iOS | 鸿蒙（U8，需按 DevEco 权限表核对） |
|---|---|---|---|
| 网络 | `INTERNET`（`:2`） | — | `ohos.permission.INTERNET` |
| 相机 | `CAMERA`（`:3`） | NSCameraUsageDescription（`:62-63`） | `ohos.permission.CAMERA` |
| 通知 | `POST_NOTIFICATIONS`（`:5`） | remote-notification（`:93-97`） | 发布用 `NOTIFICATION_CONTROLLER`；授权走 `requestEnableNotification` |
| 精确闹钟 | `SCHEDULE_EXACT_ALARM`（`:7`） | — | 无直接等价；`reminderAgentManager` 需 `PUBLISH_AGENT_REMINDER` |
| 开机自启 | `RECEIVE_BOOT_COMPLETED`（`:8` + `:89-98`） | — | 无等价；依赖系统调度 |
| 相册 | `READ_EXTERNAL_STORAGE`（`:10-12`） | PhotoLibrary（`:64-67`） | Picker 免权限；直读需 `READ_IMAGEVIDEO` |
| 健康 | 7 个 `android.permission.health.READ_*`（`:14-20`） | NSHealthShareUsageDescription（`:60-61`） | 无系统权限，走 Health Service Kit 应用授权（D1） |
| 日历 | 未声明（插件运行时授权） | NSCalendarsUsageDescription（`:68-69`） | `READ_CALENDAR` / `WRITE_CALENDAR`（D5） |
| 深链 | 2 个 intent-filter（`:52-68`） | CFBundleURLTypes（`:25-57`） | `module.json5` 的 `uris` + `skills` |
| 微信 | 插件 Manifest 合并 | weixin scheme + queries（`:25-47/:52-57`） | fluwx ohos + `linkUri` |

> Dart 侧实际只用到 `Permission.camera`（`barcode_scanner.dart:77,86`）与 `Permission.notification`
> （`notification_permission.dart:56,83`）两项，其余权限靠插件 Manifest 合并。
> **所以「权限适配」的真实工作量在插件侧，不在 Dart 侧。**

### 4.3 构建 / 资产 / CI

| 项 | 复制来的现状（V） | 在 `Luminous-ohos` 里的处理 |
|---|---|---|
| `.metadata` | 只有 `platform: root` / `platform: android` | 删到只剩 `platform: root`，再由 `flutter create --platforms ohos .` 补 `platform: ohos` |
| CI | `ci.yml:37` 固定 `flutter-version: 3.47.1`；`:99-102` 跑 KMP host 测试 | **整个 `.github/workflows/` 重写**：复制来的 Android/iOS/Web/CodeQL 流水线在鸿蒙仓里跑不起来，只留 ohos 需要的（U，Phase 0 一并处理） |
| 发布流 | `deploy-android.yml:104` / `deploy-ios.yml:142` / `deploy-web.yml` | 删除；新增 `deploy-ohos.yml`：`flutter build hap --release --target-platform ohos-arm64` + AGC 证书签名（**签名与上架流程本次未调研**） |
| KMP 脚本 | `scripts/native/build_kmp_ios*.{ps1,sh}` | 本计划不做 ohos target，脚本连同 `native/` 一起删 |
| sqlite3 二进制脚本 | `scripts/setup/fetch_sqlite3_binary.ps1:52-84` 硬编码 `windows-*` / `android-*` | 上游 release **没有 ohos 产物**，脚本改造成出 ohos .so 或删掉（C8） |
| 资源 | `pubspec.yaml:200-206` 的 `assets:` 无平台特定项；`web/sqlite3.wasm` 仅 Web 用 | 保留 `assets/`；删 `web/` 目录与其 wasm |
| 图标/启动图 | `pubspec.yaml:155-189` 只配 android/ios/web/windows/macos | 改为只配 ohos，并手工出 OHOS `icon.png` 与 `startIcon` |

## 五、分阶段执行

**排序原则：先解构建阻塞，再谈功能。** 每个阶段都有明确的出口条件；出口条件不满足不许进下一阶段。

| Phase | 内容 | 出口条件 | 可并行边界 |
|---|---|---|---|
| **0 环境与仓库初始化** | 装 **FVM**；克隆鸿蒙 SDK 到 **`D:\flutter-ohos`**（`oh-3.47-dev`）并注册进 FVM；装 DevEco 26.0.0；配齐 §1.1「FVM 管不到」那组变量并收敛为 `scripts/ohos/env.ps1`；**按 §5.1 复制建仓 + `git init` + 删多余平台目录 + `fvm flutter create --platforms ohos .`** | ① `fvm flutter --version` 在 `Luminous-ohos` 下解析到鸿蒙 SDK、在 `Luminous` 下解析到 3.47.1；② `fvm flutter doctor -v` 里 **Flutter 与 OpenHarmony 两处都 ok**；③ `fvm flutter build hap --debug` **成功出包**；④ `Luminous-ohos` 工作树里**没有** `android/ ios/ linux/ macos/ web/ windows/` 与残留产物；⑤ `Luminous` 侧 `git status` 干净；⑥ `.metadata` 只有 `platform: ohos` | 与 §二 的依赖复核并行（只读） |
| **1 `ohos/` 骨架 + 最小可启动（含 C8 验证）** | **C8 三方案逐个验证**；A0 接缝 + A 档 17 文件；D5/A3 的未捕获异常先修；所有能力位初始 false | **C8 至少一条路径跑通**（本地数据库首读写成功）；`flutter build hap --release` 出包；真机装机、冷启动进五 tab 壳、登录页可发请求；`flutter analyze` + `flutter test` 在鸿蒙 SDK 下全绿 | A0 必须先落，之后 A 档各文件可并行 |
| **2 依赖波次替换** | 第 1 波：已适配 3 个（jpush / fluwx / image_compress）+ 补 `flutter.har` 与 `@jg/push`；第 2 波：openharmony-tpc 联邦 4 项；第 3 波：CPF fork 逐项（先确认 tag） | 每波次 `flutter pub get` 干净、analyze 零新增、对应功能真机冒烟 | 波次内串行（lock 冲突），**波次间可并行** |
| **3 ArkTS 自研** | 按 C 档优先级：C4 微信 → C1 深链 → C6 安全存储 → C2 本地通知 → C7a 扫码 → C7b 相册 → C3 后台；D2/D3 的降级口径按产品裁决落地 | 每项能力有独立真机验收清单 + 「失败如何降级」路径写清；D 档各项的 UI 上已无死入口 | 能力之间相互独立可并行；**C2 与 C3 必须一起设计** |
| **4 真机回归 + CI** | 六处静默失效点逐条回归；新增 `deploy-ohos.yml` 或本地真机脚本；文档收尾 | 见 §六验收表 | 与文档收尾并行 |

每阶段收尾：在 **`Luminous-ohos` 仓库**的迁移日志追加 `docs/logs/migration-log/YYYY-MM-DD.md`（append，不覆盖）；
本计划完成的条目**直接删除**（本仓约定，不加标记）。`Luminous` 侧不产生任何迁移日志、不需要补任何文档。

> 本计划文件本身留在 `Luminous/plans/`：它是决策与任务清单的归属地，不随代码迁移。
> 但**清单里所有 file:line 都指向 `Luminous-ohos` 内的文件**（内容与复制时的 `Luminous` 一致）。

### 5.1 Phase 0 的仓库初始化（不是风险备注，是入口纪律）

独立仓库把「lockfile 分裂」这个问题从根上消掉了一半，但初始化顺序仍要写死，顺序错了会白跑一遍：

1. **拷贝，不用 clone**：`robocopy` / `Copy-Item` 把 `Luminous` 的工作树复制到 `Luminous-ohos`，
   **排除** `.git/`、`build/`、`.dart_tool/`、`coverage/`、`outputs/`（后四项是产物与临时目录）。
2. 在 `Luminous-ohos` 里 `git init` 建**全新历史**，首个 commit 记为「复制自 Luminous（无历史）」。
   在 `README.md` 顶部与 `.github/` 说明文件里写清来源 commit 号与「不承诺与主线同步」。
3. **复制来的文件里，只保留 ohos 需要的部分**：`android/ ios/ linux/ macos/ web/ windows/` 六个平台目录、
   `.github/workflows/` 里 Android/iOS/Web 的流水线都可以删。保留它们只会让鸿蒙仓库背着一堆跑不起来的构建。
4. `pubspec.lock` **删除后用鸿蒙 SDK 重新生成**（不由 3.47.1 的 lock 起手），避免残留 `sdks:` 段与平台相关的联邦实现条目。
5. 在 `Luminous-ohos` 里写 `.fvmrc` 指向鸿蒙版本，并把 `Luminous` 的 SDK 交给 FVM 钉成 3.47.1
   （`Luminous` 侧只新增 `.fvmrc` 一个文件，属于本计划**唯一**触碰主线的动作，需单列一次提交并单独评审）。
6. 在鸿蒙 SDK 环境下 `fvm flutter create --platforms ohos .` 生成 `ohos/`，`.metadata` 补 `platform: ohos`。
7. 提交前检查：`Luminous-ohos` 的工作树里不应残留任何 `.git` 与产物目录；`Luminous` 侧除 `.fvmrc` 外 `git status` 必须干净。

**Phase 1 起必须逐条回归的「静默失效」清单（V）**：

| 站点 | 失效表现 |
|---|---|
| `background.dart:23` | 后台同步整体不启动 |
| `jpush_gateway.dart:41-45` | 推送全链路失效（try/catch 吞掉，无日志级错误） |
| `local_notification_gateway.dart:277-280` | 本地通知/用药提醒 `schedule()` 永远 false |
| `deep_link.dart:68` | 深链退化为 Noop，微信回跳/分享链接失效 |
| `health_platform.dart:29` | 健康数据整块不可用 |
| `lucent_workspace.dart:219` + `content.dart:23` | 相机识别/条码扫描入口从快捷操作里整体消失 |

这六处**不报错、不记日志、UI 正常**。没有真机对照清单，会被误判成「鸿蒙上推送有 bug」而不是「根本没启用」。
**这就是为什么 Phase 4 必须有一份逐项打勾的真机能力清单。**

## 六、验收标准与风险回退

**验收**

| 项 | 验收 |
|---|---|
| 主线零代码改动 | `Luminous` 侧只允许新增 `.fvmrc` 一个文件（单独提交、单独评审）；其余 `git status` 与开工前一致 |
| 鸿蒙仓库自洽 | `Luminous-ohos` 能独立 `fvm flutter pub get` + `fvm flutter build hap`，不依赖 `Luminous` 目录存在 |
| 起动静默 | 冷启动无 native 崩溃、无异常权限弹窗；C8 后本地数据库首读写成功 |
| 静默失效 | §五 六处清单逐条确认「生效」或「已显式降级并有 UI 说明」，二选一，不许含糊 |
| 能力矩阵 | §四 每行都有明确落地结论，无残留「待定」 |
| 回退 | 任一硬阻塞（C8 三方案都不通 / 关键插件无替代且不接受降级）→ 保留 Phase 0-2 成果，Phase 3 起挂起，**并上报本计划整体可行性** |

**风险与回退**

| # | 风险 | 影响 | 缓解 / 回退 |
|---|---|---|---|
| 1 | **C8 硬阻塞**：`sqlite3` hook 无 ohos 目标，构建期 `UnsupportedError` | 整个 App 起不来（drift 是 cache-first 底座） | Phase 1 必须先解；三方案按「先易后难」试。**若三方案都不通，本计划整体不可行，立即上报，不要继续堆补丁** |
| 2 | **「静默失效」比「编译失败」难排查一个数量级** | 会被误判为「鸿蒙上某功能有 bug」，实际是「根本没启用」 | Phase 4 的真机能力清单是硬交付物；六处清单逐项打勾 |
| 3 | 鸿蒙 SDK 生态滞后：CPF 清单只有 3.7 / 3.22 / 3.27 / 3.35 四列，**无 3.44 / 3.47 列** | 全部 fork 的 3.47 可用性未知 | 锁定一个已验证可用的 SDK 版本，计划期内不追新；每个 fork 单独设「能否在 3.47 上编译通过」验证点 |
| 4 | **CPF tag 号未核实**：gitcode tags 页 JS 渲染抓不到，本机对 gitcode API / git 协议 TLS 握手失败 | pubspec 无法写死 ref | 现有替代证据是 master 分支 pubspec 的 `version:` 字段；**拿到真实 tag 前不提交 pubspec** |
| 5 | `dart.library.io` 在 ohos 为真 → 所有 `_stub` 兜底失效 | 插件缺失直接抛异常，而非降级 | Phase 1 起禁止依赖 stub 兜底；每个插件调用点补「探测为空 → 降级」显式分支 |
| 6 | 后台同步语义要重谈：Android 15 分钟硬下限 / iOS 机会式 / 鸿蒙闹钟或长时任务，三套模型完全不同 | 「离线记录 15 分钟内上云」在鸿蒙大概率不成立 | C3/D3 由产品先拍板再动代码 |
| 7 | **两仓漂移**：复制后 Luminous 的 UI/业务继续演进，鸿蒙仓停在复制那一刻 | 鸿蒙版功能落后于主线，用户可感知 | **本计划接受此代价**（§〇 已明确不承诺同步）。若要搬改动，只能人工挑拣到 `Luminous-ohos`，**禁止反向回灌**；因此鸿蒙仓应尽量冻结 UI 演进，只修 bug 与做平台适配 |
| 8 | 社区 fork 维护风险（停更/删库/签名） | 依赖链断裂 | 每个 fork 记录来源 tag + 本地补丁点；必要时 vendored 到 `pkgs/`（先例：`paddle_ocr_native-0.1.1`） |
| 9 | 工具链并存：AGP 9.1.0 / Gradle 9.3.1（V）与 hvigor 两套 | 互相踩踏 | 鸿蒙仓库只构建 `ohos/`，**Phase 0 删掉复制来的 `android/ ios/ ...` 平台目录与对应流水线**即可根除 |
| 10 | CI 无鸿蒙 runner | 无自动化门禁 | 不承诺「CI 全绿」前不声称鸿蒙可交付；退化为本地真机脚本 + 人工门禁 |
| 11 | 上架（AGC 应用登记、资质、隐私合规） | 交付延期 | 至少留一个迭代周期；签名与上架流程本次**未调研**（U9） |
| 12 | 最低运行 API 卡在 26.0.0 | 能装机的设备池被限死 | 选型阶段就要确认目标用户设备是否达标 |

## 七、不做项

- 不做 Web / 桌面的鸿蒙化；不借本次恢复桌面/Web 产品面（ADR-0008 不变）。
- 不做鸿蒙 **ArkWeb 内嵌 H5 形态**（D7）。
- 不做 `paddle_ocr_native` 的鸿蒙移植（D4）。
- 不做 KMP `ohosArm64` 目标与 Pigeon ohos 生成（C9）；ohos 上 `nativeStepsEnabledProvider` 返回 false。
- 不改后端 `Lucent/`；`health_sync` 新增 source tag 等需服务端配合的改动**另开任务**，不混入本计划。
- 不并入 DDD 重构主线（`2026-10-21-ddd-refactor-frontend.md`）。
- **不向 `Luminous` 提交任何代码改动**，也不回灌鸿蒙适配补丁（§〇）；唯一例外是新增 `.fvmrc` 钉住 3.47.1。
- **不做两仓同步机制**：不建 submodule、不建 remote 跟踪、不写 cherry-pick 流程。
- 不保留复制来的 Android/iOS/桌面/Web 平台目录与对应 CI 流水线（Phase 0 删除）。

## 八、待决问题

| # | 问题 | 需要谁拍 | 影响 |
|---|---|---|---|
| 1 | 鸿蒙是否进 0.1.0 交付范围 | 产品 | 决定 §五 是否压缩到 Phase 0-2 收口 |
| 2 | 健康数据的降级口径：整块隐藏 / 只读部分指标 / 接华为 Health Service Kit | 产品 | D1 范围 |
| 3 | `jpush` 与华为 Push Kit 是否二选一 | 后端 + 产品 | §四 推送行；决定是否有统一推送通道 |
| 4 | 包名 / bundleName 与现有 Android `applicationId` 的关系 | 发布 | Phase 0 签名与 AGC 登记 |
| 5 | 后台同步的鸿蒙口径：接受「回前台冲刷」还是申请长时任务/精确提醒 | 产品 | C3 vs D3 |
| 6 | secure_storage 若最终不可用，是否接受明文 `SharedPreferences` 兜底 | 安全 + 产品 | C6 回退路径 |
| 7 | 步数传感器是否确认不做 | 产品 | C9；取决于 U6/U13 的调查结果与该能力的实际价值 |
| 8 | 目标用户设备是否能覆盖 API 26.0.0 | 产品 | 最低运行 API 被卡死带来的设备池限制 |

## 九、待核实清单（U）

| # | 事项 | 验证方式 |
|---|---|---|
| U1 | 鸿蒙 SDK 3.47.7-ohos-1.0.1 对应的 DevEco / Command Line Tools 精确版本（本文件按 26.0.0 写） | SDK release note + `flutter doctor -v` |
| U2 | `flutter build hap` 自动签名的覆盖范围与实际行为 | 实际出包 |
| U3 | 各 CPF fork 的**具体 tag 名**（现有证据只有 master 分支 pubspec 的 `version:` 字段） | DevEco / gitcode 网页人工确认后再写入 pubspec |
| U4 | `flutter_svg` → `vector_graphics` 的 native 编译在 ohos 工具链下能否通过 | Phase 2 第 1 波 `flutter pub get` + build |
| U5 | 鸿蒙版微信 SDK 是否接受同一 AppId | 微信开放平台 + 真机注册 |
| U6 | Pigeon 是否支持生成 ArkTS host 代码（决定 C9 是「加 target」还是「整条重写」） | Pigeon 文档 |
| U7 | ONNX Runtime 是否有官方 OpenHarmony 构建（决定 D4 是否永久放弃） | ONNX Runtime release 页 |
| U8 | §4.2 权限表中 `ohos.permission.*` 的可用性与授权形态 | DevEco 权限表逐条核对 |
| U9 | AGC 上架要求与审核流程 | 官方文档 |
| U10 | 所有 fork / 联邦实现在 **3.47.7-ohos** 上的实际可用性 | 每个包在 Phase 2 的打点验收 |
| U11 | FVM 注册「本地目录 SDK」（`D:\flutter-ohos`）的**具体命令与版本名形态** | 装完 FVM 后在其文档中确认；本文件只写语义（注册为具名版本），不写死命令 |
| U12 | FVM 在 Windows 下的软链（`.fvm/flutter_sdk`）是否需要开发者模式 | 首台机器实测 `fvm use` 后的链接创建 |
| U11 | `dart.library.js_interop` 在 ohos 原生 AOT 下是否为真 | 实测（D7 已排除该路径，此项仅存档） |
| U12 | OHOS 文件系统对 SQLite WAL 的支持 | Phase 1 首读写；**建议同时给 `beforeOpen` 加 try/catch 降级到 `DELETE` journal**（当前所有平台都无兜底，这是应在 A 档就做的健壮性加固） |
| U13 | Kotlin Multiplatform 对 ohos target 的官方支持状态 | KMP 文档（C9 已排除，此项仅存档） |
| U14 | `sentry_flutter` CPF fork 的实际内容（本轮未取到可验证 pubspec） | 仓库人工确认 |

## 参考来源

- 鸿蒙 Flutter SDK 仓库：<https://gitcode.com/oh-flutter/flutter_flutter>（分支 `oh-3.47-dev`，tag `3.47.7-ohos-*`）
- 环境搭建指导：<https://raw.gitcode.com/oh-flutter/flutter_samples/raw/master/ohos/docs/03_environment/OpenHarmony-flutter%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E6%8C%87%E5%AF%BC.md>
- 平台判定（`Platform.isOhos` / `defaultTargetPlatform`）：<https://raw.gitcode.com/oh-flutter/platform_demo/raw/main/Flutter%E5%BA%94%E7%94%A8%E4%B8%9A%E5%8A%A1%E5%BC%80%E5%8F%91%E4%B8%AD%E5%A6%82%E4%BD%95%E5%8C%BA%E5%88%86%E5%B9%B3%E5%8F%B0%E7%B1%BB%E5%9E%8B.md>
- CPF-Flutter 三方库适配清单（固定 commit）：<https://raw.gitcode.com/CPF-Flutter/docs/raw/1740090f63af366f36023b75c7990e698b4fdad6/ThirdpartyLibrarites.md>
- openharmony-tpc 联邦实现：<https://pub.dev/packages/path_provider_ohos> · <https://pub.dev/packages/shared_preferences_ohos> · <https://pub.dev/packages/url_launcher_ohos> · <https://pub.dev/packages/webview_flutter_ohos>
- CPF 仓库：<https://gitcode.com/CPF-Flutter/flutter_permission_handler> · <https://gitcode.com/CPF-Flutter/flutter_plus_plugins> · <https://gitcode.com/CPF-Flutter/fluttertpc_flutter_local_notifications> · <https://gitcode.com/CPF-Flutter/fluttertpc_flutter_secure_storage> · <https://gitcode.com/CPF-Flutter/fluttertpc_mobile_scanner> · <https://gitcode.com/CPF-Flutter/fluttertpc_app_links> · <https://gitcode.com/CPF-Flutter/flutter_webview_flutter> · <https://gitcode.com/CPF-Flutter/flutter_inappwebview>

> 本计划的逐依赖与逐文件调研产物（2026-10-22）存放在 `outputs/ohos-survey/`，该目录 gitignored、
> 不入库；结论已内联进正文，正文不依赖该目录存续。
