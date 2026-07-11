# Luminous 合规/法律页面补全计划

> 创建日期：2026-07-10
> 最后修订：2026-07-11（根据代码库审阅细化）
> 状态：待实施（非当前优先级，上架前必须完成）
> 涉及仓库：Luminous（主）、Luminous-website（辅）、Lucent（后端，可选）

---

## 一、背景

Luminous 作为健康类 App，涉及用药安全、健康记录、AI 建议，在法律合规层面存在明显缺口。当前所有法律文档入口均依赖外链，且部分链接为死链。应用商店审核（App Store / Google Play / 国内应用市场）和法规遵从（PIPL / 网安法 / 未保法）均要求 App 内可查看完整法律文档。

---

## 二、现有状态

> 以下信息均已与代码库实际实现核实。

| 页面             | 当前实现                                                              | 问题                                                       |
| ---------------- | --------------------------------------------------------------------- | ---------------------------------------------------------- |
| 隐私政策         | About 页 → `appInfoProvider.privacyPolicyUrl ?? 'https://luminous.app/privacy'`（外链） | 网站内容过于简单，不符合 PIPL 告知要求；App 内无法离线查看 |
| 服务条款         | About 页 → `appInfoProvider.termsOfServiceUrl ?? 'https://luminous.app/terms'`（外链） | **死链** — 网站此页面不存在                                |
| 开源许可         | About 页 → Flutter 内置 `showLicensePage`                              | 可用，无需改动                                             |
| 帮助与反馈       | `help_settings_page.dart`，后端驱动                                    | 可用                                                       |
| 账号注销         | `account_settings_sections.dart` 中的 `DeleteAccountSection`           | 有功能，缺注销政策说明入口                                 |
| 注册协议勾选     | `register_page.dart` → `_TermsLinks` widget，外链                      | 外链，无强制阅读流程                                       |
| 医疗免责声明     | 无                                                                    | **缺失** — 健康类 App 硬性要求                             |
| 未成年人保护说明 | 无                                                                    | **缺失** — 未保法要求                                      |
| 第三方 SDK 清单  | 无                                                                    | **缺失** — 工信部要求                                      |
| 权限使用说明     | 无                                                                    | **缺失** — 应用商店审核要求                                |
| ICP 备案信息     | 无                                                                    | **缺失** — 中国上架要求                                    |

**代码库关键发现：**

- About 页（`about_settings_page.dart`）的隐私政策和服务条款 URL 来自后端 `appInfoProvider`（`AppInfoDataDto.privacyPolicyUrl` / `termsOfServiceUrl`），以硬编码 URL 作为 fallback。改造时需决定后端字段的废弃策略（见 4.5）。
- 注册页（`register_page.dart`）通过 `ExternalUrlLauncher` 打开外链，`_TermsLinks` widget 已封装为 `onTerms` / `onPrivacy` 回调，改造只需替换回调实现。
- 现有路由模式统一使用 `@TypedGoRoute` + `go_router_builder` 代码生成，嵌套页面用父子路由声明（参见 `settings/presentation/routes.dart`）。
- 页面过渡动画统一使用 `app/router/helpers.dart` 中的 `slidePage()`（sub-pages）或 `fadePage()`（auth pages）。
- `flutter_markdown_plus: ^1.0.12` 已在 `pubspec.yaml` 中，无需新增依赖。
- `AppStateSkeletonView` 和 `AppStateErrorView` 分别位于 `core/widgets/common/skeleton.dart` 和 `core/widgets/common/state_message.dart`。
- 网站实际目录名为 `Luminous-website/`（非 `Luminous-site/`），Nuxt 文件路由自动映射 `app/pages/*.vue`。
- 网站 `privacy.vue` 当前内容仅 3 个 section（数据收集 / 敏感数据处理 / 数据使用），严重缺乏 PIPL 必需章节。

---

## 三、目标页面清单

### P0 — 上架前必须完成

| #   | 页面                 | 路由路径            | 内容来源                 |
| --- | -------------------- | ------------------- | ------------------------ |
| 1   | 用户协议（服务条款） | `/legal/terms`      | 法务撰写                 |
| 2   | 隐私政策（完整版）   | `/legal/privacy`    | 法务撰写，参考 PIPL 模板 |
| 3   | 医疗免责声明         | `/legal/disclaimer` | 法务撰写                 |
| 4   | 法律文档列表页       | `/legal`            | 聚合入口                 |

### P1 — 上架后尽快补齐

| #   | 页面             | 路由路径                      | 内容来源              |
| --- | ---------------- | ----------------------------- | --------------------- |
| 5   | 未成年人保护说明 | `/legal/minor-protection`     | 法务撰写              |
| 6   | 第三方 SDK 清单  | `/legal/sdk-list`             | 整理依赖清单          |
| 7   | 权限使用说明     | `/legal/permissions`          | 整理 Android/iOS 权限 |
| 8   | 账号注销政策     | `/legal/account-cancellation` | 法务撰写              |

### P2 — 完善合规体系

| #   | 页面         | 路由路径          | 内容来源               |
| --- | ------------ | ----------------- | ---------------------- |
| 9   | ICP 备案信息 | About 页直接展示  | 需备案号               |
| 10  | 关于页面增强 | `/settings/about` | 增加公司信息、联系方式 |

---

## 四、技术方案

### 4.1 新建 `legal` feature 模块

```
Luminous/lib/features/legal/
├── data/
│   ├── datasources/
│   │   └── legal_content_data_source.dart     # P0: 从本地 assets 读取；P2: 远程优先 + assets fallback
│   └── repositories/
│       └── legal_repository.dart              # LegalRepository 抽象 + LegalRepositoryImpl
├── domain/
│   ├── entities/
│   │   ├── legal_document.dart                # LegalDocument { type, title, content, updatedAt }
│   │   └── legal_doc_type.dart                # LegalDocType 枚举（见 4.2）
│   └── repositories/
│       └── legal_repository.dart              # abstract class LegalRepository
└── presentation/
    ├── pages/
    │   ├── legal_list_page.dart               # 法律文档列表页
    │   └── legal_detail_page.dart             # 单个法律文档详情页（Markdown 渲染）
    ├── providers/
    │   └── legal_providers.dart               # Riverpod providers
    ├── routes.dart                            # @TypedGoRoute 类型安全路由
    └── routes.g.dart                          # build_runner 生成（勿手编）
```

### 4.2 路由定义

#### 4.2.1 `LegalDocType` 枚举

在 `domain/entities/legal_doc_type.dart` 中定义：

```dart
enum LegalDocType {
  terms('terms'),
  privacy('privacy'),
  disclaimer('disclaimer'),
  minorProtection('minor-protection'),
  sdkList('sdk-list'),
  permissions('permissions'),
  accountCancellation('account-cancellation');

  final String pathSegment;
  const LegalDocType(this.pathSegment);

  /// 从路由参数解析；非法值返回 null，由页面重定向到列表页。
  static LegalDocType? fromPathSegment(String? value) {
    if (value == null) return null;
    for (final type in LegalDocType.values) {
      if (type.pathSegment == value) return type;
    }
    return null;
  }
}
```

#### 4.2.2 路由声明

在 `legal/presentation/routes.dart` 中声明，**采用与 `settings/presentation/routes.dart` 一致的嵌套父子路由模式**：

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/features/legal/presentation/pages/legal_list_page.dart';
import 'package:luminous/features/legal/presentation/pages/legal_detail_page.dart';

part 'routes.g.dart';

@TypedGoRoute<LegalRoute>(
  path: '/legal',
  routes: [
    TypedGoRoute<LegalDetailRoute>(path: ':docType'),
  ],
)
class LegalRoute extends GoRouteData with $LegalRoute {
  const LegalRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const LegalListPage());
  }
}

class LegalDetailRoute extends GoRouteData with $LegalDetailRoute {
  const LegalDetailRoute({required this.docType});

  final String docType;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: LegalDetailPage(docType: docType),
    );
  }
}
```

**关键设计决策：**

- `/legal` → `LegalListPage`（列表页）
- `/legal/:docType` → `LegalDetailPage`（详情页）
- `docType` 作为 `String` 传入（GoRouteData 要求），在 `LegalDetailPage` 内部通过 `LegalDocType.fromPathSegment()` 解析为枚举。解析失败时显示错误态或重定向到 `/legal`。
- 过渡动画使用 `slidePage()`，与现有所有 sub-page（Settings、Account 等）保持一致。

#### 4.2.3 注册到全局路由

在 `app/router.dart` 中：

**1. 添加 import（顶部 import 区）：**

```dart
import 'package:luminous/features/legal/presentation/routes.dart'
    as legal_routes;
```

**2. 在 `routes` 列表末尾追加：**

```dart
...legal_routes.$appRoutes,
```

**3. 在 `AppRoutes` 类中添加常量：**

```dart
// -- Legal --
static const legal = '/legal';
static const legalTerms = '/legal/terms';
static const legalPrivacy = '/legal/privacy';
static const legalDisclaimer = '/legal/disclaimer';
static const legalMinorProtection = '/legal/minor-protection';
static const legalSdkList = '/legal/sdk-list';
static const legalPermissions = '/legal/permissions';
static const legalAccountCancellation = '/legal/account-cancellation';
```

#### 4.2.4 代码生成

路由声明完成后，**必须运行**：

```powershell
cd Luminous
dart run build_runner build --delete-conflicting-outputs
```

这会生成 `routes.g.dart`（包含 `$LegalRoute`、`$LegalDetailRoute` mixin）。不运行此步骤会导致编译失败。

### 4.3 法律文档详情页

使用 `flutter_markdown_plus`（已在 `pubspec.yaml` 中，`^1.0.12`）渲染 Markdown 格式的法律文档。

页面结构遵循现有 subpage 模式：

- `PageScaffold` + `ResponsiveContentFrame`
- 顶部显示文档标题 + 最后更新日期
- 主体为 Markdown 内容滚动区域
- 加载态使用 `AppStateSkeletonView`（`core/widgets/common/skeleton.dart`）
- 错误态使用 `AppStateErrorView`（`core/widgets/common/state_message.dart`）
- `docType` 解析失败时，显示错误态并提供"返回法律文档列表"按钮

### 4.4 内容存储策略

**初期（P0 阶段）**：本地 Markdown assets

```
Luminous/assets/legal/
├── terms_zh.md
├── terms_en.md
├── privacy_zh.md
├── privacy_en.md
├── disclaimer_zh.md
├── disclaimer_en.md
├── minor_protection_zh.md
├── minor_protection_en.md
├── sdk_list_zh.md
├── sdk_list_en.md
├── permissions_zh.md
├── permissions_en.md
├── account_cancellation_zh.md
└── account_cancellation_en.md
```

在 `pubspec.yaml` 的 `assets` 中注册 `assets/legal/`。

> **注意**：Flutter assets 目录注册**不会递归**包含子目录。当前 `pubspec.yaml` 已有 `- assets/`，但 `- assets/legal/` 需单独添加，否则运行时加载会抛 `Unable to load asset` 异常。

```yaml
flutter:
  assets:
    - assets/
    - assets/legal/        # ← 新增
    - assets/icon/app_icon.png
```

**后期（P2 阶段）**：后端 Lucent 管理法律文档

- 在 Lucent 新建 `legal-documents` 模块或扩展 `support-resources`
- `GET /api/v1/legal-documents` — 列表
- `GET /api/v1/legal-documents/:type` — 详情
- 返回 Markdown 内容 + 更新时间戳
- App 端 data source 改为远程优先 + 本地 assets fallback
- 按照跨项目契约流程：`pnpm export:openapi` → `dart run build_runner build`

### 4.5 改造现有页面

#### About 页面 (`about_settings_page.dart`)

**当前实现**（已核实，`about_settings_page.dart` 第 88-104 行）：

隐私政策和服务条款的 URL 来自后端 `appInfoProvider`（`AppInfoDataDto.privacyPolicyUrl` / `termsOfServiceUrl`），以硬编码 `https://luminous.app/privacy` / `https://luminous.app/terms` 作为 fallback。

**改造策略：统一改为 App 内导航，忽略后端 URL 字段。**

理由：
1. App 内法律页面必须可离线查看，外链无法保证。
2. 后端 URL 字段后续可在 `AppInfoDataDto` 中标记废弃（P2 阶段清理）。
3. 即使后端返回了 URL，法律内容的一致性应由 App 内 Markdown assets 保证。

```dart
// 之前（实际代码，第 88-95 行）
FTile(
  title: Text(l10n.settingsAboutPrivacyPolicy),
  suffix: const Icon(FLucideIcons.chevronRight),
  onPress: () => _openUrl(
    context,
    infoAsync.asData?.value?.privacyPolicyUrl ??
        'https://luminous.app/privacy',
  ),
),

// 之后
FTile(
  title: Text(l10n.settingsAboutPrivacyPolicy),
  suffix: const Icon(FLucideIcons.chevronRight),
  onPress: () => context.push(AppRoutes.legalPrivacy),
),
```

同样改造服务条款入口。新增医疗免责声明等入口。

About 页 FTileGroup 扩展为：

```
隐私政策       → /legal/privacy
服务条款       → /legal/terms
医疗免责声明   → /legal/disclaimer       （新增）
未成年人保护   → /legal/minor-protection （新增，P1）
第三方 SDK    → /legal/sdk-list         （新增，P1）
权限使用说明   → /legal/permissions       （新增，P1）
账号注销政策   → /legal/account-cancellation （新增，P1）
开源许可       → showLicensePage（不变）
帮助与反馈     → /settings/help（不变）
```

> 改造后 `_openUrl` 方法仅保留给 `_openSupport`（邮件链接）使用。如果 About 页不再有其他外链需求，可考虑将 `_openUrl` 内联或删除。

#### 注册页 (`register_page.dart`)

**当前实现**（已核实，`register_page.dart` 第 171-182 行）：

`_TermsLinks` widget 通过 `onTerms` / `onPrivacy` 回调 + `ExternalUrlLauncher` 打开外链。

```dart
// 之前
onTerms: () => _openLegalUrl(
  context, urlLauncher, 'https://luminous.app/terms',
),
onPrivacy: () => _openLegalUrl(
  context, urlLauncher, 'https://luminous.app/privacy',
),

// 之后
onTerms: () => context.push(AppRoutes.legalTerms),
onPrivacy: () => context.push(AppRoutes.legalPrivacy),
```

> 改造后 `urlLauncher` 变量和 `_openLegalUrl` 函数如果不再被使用，应一并清理。注意检查 `externalUrlLauncherProvider` 的 import 是否仍被其他代码引用。

#### 账号注销区域 (`account_settings_sections.dart`)

**当前实现**（已核实，`DeleteAccountSection` 第 287-370 行）：

账号注销功能区域只有密码输入 / 验证码输入 + 注销按钮，缺少注销政策说明。

**改造：** 在 `DeleteAccountSection` 的 `_SectionColumn` children 顶部，添加注销政策链接：

```dart
// 在 DeleteAccountSection.build() 的 _SectionColumn children 中添加：
_MutedText(l10n.authDeleteAccountPolicyHint),
FButton(
  variant: FButtonVariant.ghost,
  size: FButtonSizeVariant.sm,
  mainAxisSize: MainAxisSize.min,
  onPress: () => context.push(AppRoutes.legalAccountCancellation),
  child: Text(l10n.settingsAboutAccountCancellation),
),
```

需要在 ARB 中新增 `authDeleteAccountPolicyHint` 文案（如："注销后账户数据将在 30 天内永久删除，详见注销政策。"）。

### 4.6 网站补齐

网站实际目录为 `Luminous-website/`（Nuxt 4，文件路由）。在 `Luminous-website/app/pages/` 中：

#### 新建 `terms.vue` — 服务条款页面

- Nuxt 文件路由自动映射到 `/terms`
- 内容与 App 内 `terms_zh.md` 保持一致（法务审阅后同步）

#### 增强 `privacy.vue` — 补全 PIPL 要求的告知内容

当前 `privacy.vue` 仅有 3 个 section（数据收集 / 敏感数据处理 / 数据使用），严重不足。需补全以下 PIPL 必需章节：

1. **数据处理者信息** — 公司名称、联系邮箱、DPO（如有）
2. **处理目的、方式、种类、保存期限** — 逐项列出数据类型与对应目的
3. **用户权利清单** — 查阅、复制、更正、删除、撤回同意、注销账户、投诉的行使方式
4. **第三方共享情况** — SDK / 第三方服务清单、共享数据范围
5. **跨境传输情况** — 是否涉及、目的地、法律依据
6. **未成年人特别说明** — 未保法要求的监护人同意机制
7. **政策更新通知机制** — 重大变更如何告知用户

#### 新建 `disclaimer.vue` — 医疗免责声明

- Nuxt 文件路由自动映射到 `/disclaimer`
- 内容与 App 内 `disclaimer_zh.md` 保持一致

#### 网站导航与 SEO 同步

- 更新 `default.vue` 布局中的 footer 链接（如有），确保 `/terms`、`/disclaimer` 可从网站导航到达
- 更新 `robots.txt` 或 sitemap（如已配置），纳入新页面
- 各新页面需配置 `useSeoMeta`（标题、描述），与 `privacy.vue` 现有模式一致

### 4.7 ARB 国际化

在 `app_zh.arb` 和 `app_en.arb` 中添加：

```json
"legalPageTitle": "法律与政策",
"legalTermsTitle": "用户协议",
"legalPrivacyTitle": "隐私政策",
"legalDisclaimerTitle": "医疗免责声明",
"legalMinorProtectionTitle": "未成年人保护说明",
"legalSdkListTitle": "第三方 SDK 清单",
"legalPermissionsTitle": "权限使用说明",
"legalAccountCancellationTitle": "账号注销政策",
"legalLastUpdated": "最后更新：{date}",
"legalContentLoadedError": "无法加载文档内容",
"legalInvalidDocType": "未找到该文档",
"legalBackToList": "返回法律文档列表",
"settingsAboutDisclaimer": "医疗免责声明",
"settingsAboutMinorProtection": "未成年人保护",
"settingsAboutSdkList": "第三方 SDK",
"settingsAboutPermissions": "权限使用说明",
"settingsAboutAccountCancellation": "账号注销政策",
"authDeleteAccountPolicyHint": "注销后账户数据将在 30 天内永久删除，详见注销政策。"
```

> 每个带参数的 key（如 `legalLastUpdated`）需同步添加 `@` 元数据声明。运行 `flutter gen-l10n` 后确认生成的 `AppLocalizations` 类无编译错误。

### 4.8 深度链接配置

法律文档页面应支持从外部（邮件、网站、应用商店审核）直接通过 URL 打开。

#### P0 预留（配置不阻塞，可在 P0 后期补充）

**Android** — `android/app/src/main/AndroidManifest.xml`：

确保 `<intent-filter>` 中已包含 `/legal` 路径前缀的 Deep Link 配置（如果项目已有 Universal Links / App Links 配置，则 `/legal/*` 自动支持）。

**iOS** — `ios/Runner/Info.plist`：

确认 Associated Domains 已覆盖法律页面路径（同上，已有配置则自动支持）。

> 如果项目尚未配置 Deep Link，此项降级为 P1，不影响 P0 上架。但建议至少在 P0 阶段验证 `context.push('/legal/privacy')` 在 App 内可用。

---

## 五、依赖项

| 依赖                    | 用途                   | 是否已在 pubspec   |
| ----------------------- | ---------------------- | ------------------ |
| `flutter_markdown_plus` | 渲染 Markdown 法律文档 | **已有**（`^1.0.12`） |
| `go_router_builder`     | 类型安全路由代码生成   | 已有               |

> 无需新增任何依赖。

---

## 六、实施步骤与工作量

### P0（上架前，约 3-4 工作日）

| 步骤 | 内容                                                       | 工作量 | 依赖              |
| ---- | ---------------------------------------------------------- | ------ | ----------------- |
| 1    | 创建 `legal` feature 模块骨架（目录 + 实体 + 枚举 + provider） | 0.5d   | 无                |
| 2    | 声明路由（`routes.dart` + 嵌套父子模式 + `slidePage`）     | 0.25d  | Step 1            |
| 3    | **运行 `dart run build_runner build`** 生成路由代码        | 0.25d  | Step 2            |
| 4    | 注册到 `app/router.dart`（import + `$appRoutes` + `AppRoutes` 常量） | 0.25d  | Step 3            |
| 5    | 实现 `LegalDetailPage`（Markdown 渲染 + 加载/错误态 + docType 解析） | 0.5d   | Step 4            |
| 6    | 实现 `LegalListPage`（文档列表聚合页）                     | 0.5d   | Step 5            |
| 7    | 编写法律文档 Markdown 内容（terms + privacy + disclaimer） | 1d     | 需法务审阅        |
| 8    | 注册 `assets/legal/` 到 `pubspec.yaml`                     | 0.1d   | Step 7            |
| 9    | 改造 About 页外链为 App 内导航（含清理后端 URL fallback）  | 0.5d   | Step 5            |
| 10   | 改造注册页协议链接为 App 内导航（含清理 `urlLauncher`）    | 0.25d  | Step 5            |
| 11   | ARB 国际化 + `flutter gen-l10n`                            | 0.25d  | Step 9-10         |
| 12   | 编写 widget 测试 + 单元测试（见第七节）                    | 0.5d   | Step 6            |
| 13   | 网站新建 `terms.vue` + `disclaimer.vue` + 增强 `privacy.vue` + 导航/SEO 同步 | 0.75d  | Step 7 内容可复用 |
| 14   | 验证：`flutter analyze` + `flutter test` + `build_runner`  | 0.25d  | 全部              |

### P1（上架后尽快，约 2-3 工作日）

| 步骤 | 内容                                                        | 工作量 | 依赖           |
| ---- | ----------------------------------------------------------- | ------ | -------------- |
| 15   | 未成年人保护说明（内容 + 页面 + assets）                    | 0.5d   | P0 完成        |
| 16   | 第三方 SDK 清单（整理 `pubspec.lock` 依赖 + 内容 + 页面）   | 0.5d   | 需整理依赖列表 |
| 17   | 权限使用说明（整理 Android `AndroidManifest.xml` + iOS `Info.plist` 权限 + 内容 + 页面） | 0.5d   | 需整理权限列表 |
| 18   | 账号注销政策（内容 + 页面 + assets）                        | 0.5d   | P0 完成        |
| 19   | 改造 `DeleteAccountSection` 添加注销政策链接                | 0.25d  | Step 18        |
| 20   | About 页补充 P1 入口（FTile 新增 4 项）                     | 0.25d  | Step 15-18     |
| 21   | ARB 国际化更新 + `flutter gen-l10n`                         | 0.25d  | Step 20        |
| 22   | 验证：`flutter analyze` + `flutter test`                    | 0.25d  | 全部           |

### P2（完善体系，约 2-3 工作日）

| 步骤 | 内容                                              | 工作量 | 依赖                  |
| ---- | ------------------------------------------------- | ------ | --------------------- |
| 25   | ICP 备案信息 + About 页增强（公司信息、联系方式） | 0.5d   | 需备案号              |
| 27   | 废弃 `AppInfoDataDto.privacyPolicyUrl` / `termsOfServiceUrl` 字段 | 0.25d  | Step 24（已完成）     |

---

## 七、测试计划

### 单元测试

| 测试文件 | 测试内容 |
| -------- | -------- |
| `test/features/legal/domain/legal_doc_type_test.dart` | `LegalDocType.fromPathSegment()` — 合法值返回正确枚举；非法值返回 null；null 返回 null |
| `test/features/legal/data/legal_content_data_source_test.dart` | 从 assets 加载 Markdown 内容 — 正确加载、文件不存在时抛异常、中英文切换正确 |

### Widget 测试

| 测试文件 | 测试内容 |
| -------- | -------- |
| `test/features/legal/presentation/legal_detail_page_test.dart` | 1. 加载态显示 `AppStateSkeletonView`；2. 加载成功显示 Markdown 内容 + 标题 + 更新日期；3. 加载失败显示 `AppStateErrorView`；4. 非法 `docType` 显示错误态 + 返回列表按钮 |
| `test/features/legal/presentation/legal_list_page_test.dart` | 1. 显示所有法律文档条目；2. 点击条目跳转到对应详情页 |

### 集成测试（可选，P1 阶段）

| 测试文件 | 测试内容 |
| -------- | -------- |
| `integration_test/legal_flow_e2e_test.dart` | 从 About 页 → 隐私政策 → 返回 → 服务条款 → 返回 → 法律文档列表 |

---

## 八、验证清单

### P0 验证

- [ ] `dart run build_runner build --delete-conflicting-outputs` 无错误
- [ ] `flutter analyze` 零问题
- [ ] `flutter test` 全部通过（含新增 legal feature 测试）
- [ ] `flutter gen-l10n` 无错误
- [ ] About 页所有法律入口可正常跳转到 App 内页面
- [ ] 注册页协议链接可正常跳转到 App 内页面
- [ ] 法律文档列表页显示所有 P0 文档条目
- [ ] 法律文档详情页正确渲染 Markdown
- [ ] 法律文档详情页加载态 / 错误态正常显示
- [ ] 非法 `docType` 路由参数正确处理（显示错误态或重定向）
- [ ] 中英文 ARB 完整同步（`app_zh.arb` 和 `app_en.arb` 的 key 一一对应）
- [ ] `assets/legal/` 已在 `pubspec.yaml` 中注册
- [ ] `https://luminous.app/terms` 不再是死链
- [ ] `https://luminous.app/privacy` 内容符合 PIPL 要求（7 个必需章节齐全）
- [ ] `https://luminous.app/disclaimer` 可访问
- [ ] 网站导航 / footer / sitemap 已纳入新页面

### P1 验证

- [ ] About 页 P1 入口（未成年人保护 / SDK 清单 / 权限使用 / 注销政策）可正常跳转
- [ ] `DeleteAccountSection` 注销政策链接可正常跳转
- [ ] 新增 ARB key 中英文同步
- [ ] `flutter analyze` + `flutter test` 通过

### P2 验证

- [ ] `pnpm export:openapi` 成功
- [ ] `dart run build_runner build`（generated client）成功
- [ ] App 端远程优先 + assets fallback 逻辑正确（断网时 fallback 到本地）
- [ ] `AppInfoDataDto` 废弃字段已清理

---

## 九、注意事项

### 9.1 法务审阅与 Placeholder 策略

所有法律文档内容（特别是隐私政策和用户协议）需经法务审阅后才能上线。

**P0 Placeholder 策略：** 如果法务内容未及时交付，可以先用结构化 placeholder 上线——即 Markdown 文件包含 PIPL 必需章节标题（如"数据处理者信息"、"用户权利清单"等），但内容标注"待法务审阅填充"。这样可以验证技术链路完整性和页面渲染效果，不阻塞开发。但**上线前必须替换为法务审阅通过的正式内容**。

### 9.2 PIPL 合规要点

隐私政策必须包含以下 7 个章节：

1. **数据处理者信息** — 公司名称、联系邮箱、个人信息保护负责人
2. **处理目的、方式、种类、保存期限** — 逐项列出
3. **用户权利清单** — 查阅、复制、更正、删除、撤回同意、注销账户、投诉，及行使方式
4. **第三方共享情况** — SDK / 第三方服务清单、共享数据范围、目的
5. **跨境传输情况** — 是否涉及、目的地、法律依据
6. **未成年人特别说明** — 监护人同意机制
7. **政策更新通知机制** — 重大变更如何告知用户

### 9.3 医疗免责声明

必须明确以下要点：

- "本应用提供的信息不构成医疗建议"
- "不替代医生诊断和处方"
- "用药决策应遵医嘱"
- "AI 生成的总结和报告仅供参考，不作为诊疗依据"

### 9.4 内容更新机制

初期用 assets，但需预留后端更新路径，避免每次修改法律文档都要发版。P2 阶段实现远程优先 + assets fallback 后，可通过后端更新内容、App 端缓存。

### 9.5 后端 URL 字段废弃

About 页改造后，`AppInfoDataDto.privacyPolicyUrl` 和 `termsOfServiceUrl` 不再被 App 端使用。P2 阶段应在 Lucent 中标记废弃（添加 `@deprecated`），确认无其他消费方后再移除。

### 9.6 深度链接

法律页面应支持从外部直接打开 `/legal/privacy` 等路径。P0 阶段至少验证 App 内 `context.push` 可用；P1 阶段配置 Android `intent-filter` 和 iOS Associated Domains（如项目尚未配置 Deep Link）。
