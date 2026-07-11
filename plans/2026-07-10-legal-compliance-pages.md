# Luminous 合规/法律页面补全计划

> 创建日期：2026-07-10
> 状态：待实施（非当前优先级，上架前必须完成）
> 涉及仓库：Luminous（主）、Luminous-website（辅）、Lucent（后端，可选）

---

## 一、背景

Luminous 作为健康类 App，涉及用药安全、健康记录、AI 建议，在法律合规层面存在明显缺口。当前所有法律文档入口均依赖外链，且部分链接为死链。应用商店审核（App Store / Google Play / 国内应用市场）和法规遵从（PIPL / 网安法 / 未保法）均要求 App 内可查看完整法律文档。

---

## 二、现有状态

| 页面 | 当前实现 | 问题 |
|------|----------|------|
| 隐私政策 | About 页 → 外链 `https://luminous.app/privacy` | 网站内容过于简单，不符合 PIPL 告知要求；App 内无法离线查看 |
| 服务条款 | About 页 → 外链 `https://luminous.app/terms` | **死链** — 网站此页面不存在 |
| 开源许可 | About 页 → Flutter 内置 `showLicensePage` | 可用，无需改动 |
| 帮助与反馈 | `help_settings_page.dart`，后端驱动 | 可用 |
| 账号注销 | `account_settings_sections.dart` | 有功能，缺注销政策说明 |
| 注册协议勾选 | `register_page.dart` checkbox + 外链 | 外链，无强制阅读流程 |
| 医疗免责声明 | 无 | **缺失** — 健康类 App 硬性要求 |
| 未成年人保护说明 | 无 | **缺失** — 未保法要求 |
| 第三方 SDK 清单 | 无 | **缺失** — 工信部要求 |
| 权限使用说明 | 无 | **缺失** — 应用商店审核要求 |
| ICP 备案信息 | 无 | **缺失** — 中国上架要求 |

---

## 三、目标页面清单

### P0 — 上架前必须完成

| # | 页面 | 路由路径 | 内容来源 |
|---|------|----------|----------|
| 1 | 用户协议（服务条款） | `/legal/terms` | 法务撰写 |
| 2 | 隐私政策（完整版） | `/legal/privacy` | 法务撰写，参考 PIPL 模板 |
| 3 | 医疗免责声明 | `/legal/disclaimer` | 法务撰写 |
| 4 | 法律文档列表页 | `/legal` | 聚合入口 |

### P1 — 上架后尽快补齐

| # | 页面 | 路由路径 | 内容来源 |
|---|------|----------|----------|
| 5 | 未成年人保护说明 | `/legal/minor-protection` | 法务撰写 |
| 6 | 第三方 SDK 清单 | `/legal/sdk-list` | 整理依赖清单 |
| 7 | 权限使用说明 | `/legal/permissions` | 整理 Android/iOS 权限 |
| 8 | 账号注销政策 | `/legal/account-cancellation` | 法务撰写 |

### P2 — 完善合规体系

| # | 页面 | 路由路径 | 内容来源 |
|---|------|----------|----------|
| 9 | ICP 备案信息 | About 页直接展示 | 需备案号 |
| 10 | 关于页面增强 | `/settings/about` | 增加公司信息、联系方式 |

---

## 四、技术方案

### 4.1 新建 `legal` feature 模块

```
Luminous/lib/features/legal/
├── data/
│   ├── datasources/
│   │   └── legal_content_data_source.dart     # 从 Lucent 获取法律文档，fallback 到本地 assets
│   └── repositories/
│       └── lucent_repository.dart
├── domain/
│   ├── entities/
│   │   └── legal_document.dart                 # LegalDocument { type, title, content, updatedAt }
│   └── repositories/
│       └── legal_repository.dart
└── presentation/
    ├── pages/
    │   ├── legal_list_page.dart                # 法律文档列表页
    │   └── legal_detail_page.dart              # 单个法律文档详情页（Markdown 渲染）
    ├── providers/
    │   └── legal_providers.dart
    └── routes.dart                             # @TypedGoRoute 类型安全路由
```

### 4.2 路由定义

在 `legal/presentation/routes.dart` 中声明：

```dart
@TypedGoRoute<LegalListRoute>(path: '/legal')
class LegalListRoute extends GoRouteData with $LegalListRoute {
  const LegalListRoute();
  // → 法律文档列表页
}

@TypedGoRoute<LegalDetailRoute>(path: '/legal/:docType')
class LegalDetailRoute extends GoRouteData with $LegalDetailRoute {
  final String docType;
  // docType 枚举：terms | privacy | disclaimer | minor-protection | sdk-list | permissions | account-cancellation
  // → 单个法律文档详情页
}
```

在 `app/router.dart` 的 `routes` 列表中追加 `...legal_routes.$appRoutes`。

在 `app/router.dart` 的 `AppRoutes` 类中添加常量：

```dart
static const legal = '/legal';
static const legalTerms = '/legal/terms';
static const legalPrivacy = '/legal/privacy';
static const legalDisclaimer = '/legal/disclaimer';
static const legalMinorProtection = '/legal/minor-protection';
static const legalSdkList = '/legal/sdk-list';
static const legalPermissions = '/legal/permissions';
static const legalAccountCancellation = '/legal/account-cancellation';
```

### 4.3 法律文档详情页

使用 `flutter_markdown`（或 `markdown_widget`）渲染 Markdown 格式的法律文档。

页面结构遵循现有 subpage 模式：
- `PageScaffold` + `ResponsiveContentFrame`
- 顶部显示文档标题 + 最后更新日期
- 主体为 Markdown 内容滚动区域
- 加载态使用 `AppStateSkeletonView`
- 错误态使用 `AppStateErrorView`

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

**后期（P2 阶段）**：后端 Lucent 管理法律文档

- 在 Lucent 新建 `legal-documents` 模块或扩展 `support-resources`
- `GET /api/v1/legal-documents` — 列表
- `GET /api/v1/legal-documents/:type` — 详情
- 返回 Markdown 内容 + 更新时间戳
- App 端 data source 改为远程优先 + 本地 assets fallback

### 4.5 改造现有页面

#### About 页面 (`about_settings_page.dart`)

将外链改为 App 内导航：

```dart
// 之前
FTile(
  title: Text(l10n.settingsAboutPrivacyPolicy),
  suffix: const Icon(FLucideIcons.chevronRight),
  onPress: () => _openUrl(context, 'https://luminous.app/privacy'),
),

// 之后
FTile(
  title: Text(l10n.settingsAboutPrivacyPolicy),
  suffix: const Icon(FLucideIcons.chevronRight),
  onPress: () => context.push(AppRoutes.legalPrivacy),
),
```

同样改造服务条款、新增医疗免责声明等入口。

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

#### 注册页 (`register_page.dart`)

将 `_TermsLinks` 中的外链改为 App 内导航：

```dart
// 之前
onTerms: () => _openLegalUrl(context, urlLauncher, 'https://luminous.app/terms'),
onPrivacy: () => _openLegalUrl(context, urlLauncher, 'https://luminous.app/privacy'),

// 之后
onTerms: () => context.push(AppRoutes.legalTerms),
onPrivacy: () => context.push(AppRoutes.legalPrivacy),
```

### 4.6 网站补齐

在 `Luminous-website/app/pages/` 中：

- 新建 `terms.vue` — 服务条款页面
- 增强 `privacy.vue` — 补全 PIPL 要求的告知内容
- 新建 `disclaimer.vue` — 医疗免责声明

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
"settingsAboutDisclaimer": "医疗免责声明",
"settingsAboutMinorProtection": "未成年人保护",
"settingsAboutSdkList": "第三方 SDK",
"settingsAboutPermissions": "权限使用说明",
"settingsAboutAccountCancellation": "账号注销政策"
```

---

## 五、依赖项

| 依赖 | 用途 | 是否已在 pubspec |
|------|------|-----------------|
| `flutter_markdown` | 渲染 Markdown 法律文档 | 需确认，可能需新增 |
| `go_router_builder` | 类型安全路由 | 已有 |

---

## 六、实施步骤与工作量

### P0（上架前，约 3-4 工作日）

| 步骤 | 内容 | 工作量 | 依赖 |
|------|------|--------|------|
| 1 | 创建 `legal` feature 模块骨架（目录 + 路由 + provider） | 0.5d | 无 |
| 2 | 实现 `LegalDetailPage`（Markdown 渲染 + 加载/错误态） | 0.5d | Step 1 |
| 3 | 实现 `LegalListPage`（文档列表聚合页） | 0.5d | Step 2 |
| 4 | 编写法律文档 Markdown 内容（terms + privacy + disclaimer） | 1d | 需法务审阅 |
| 5 | 改造 About 页外链为 App 内导航 | 0.5d | Step 2 |
| 6 | 改造注册页协议链接为 App 内导航 | 0.25d | Step 2 |
| 7 | ARB 国际化 + `flutter gen-l10n` | 0.25d | Step 5-6 |
| 8 | 网站新建 `terms.vue` + 增强 `privacy.vue` | 0.5d | Step 4 内容可复用 |

### P1（上架后尽快，约 2-3 工作日）

| 步骤 | 内容 | 工作量 | 依赖 |
|------|------|--------|------|
| 9 | 未成年人保护说明（内容 + 页面） | 0.5d | P0 完成 |
| 10 | 第三方 SDK 清单（整理 + 内容 + 页面） | 0.5d | 需整理依赖列表 |
| 11 | 权限使用说明（整理 + 内容 + 页面） | 0.5d | 需整理权限列表 |
| 12 | 账号注销政策（内容 + 页面） | 0.5d | P0 完成 |
| 13 | About 页补充 P1 入口 | 0.25d | Step 9-12 |
| 14 | ARB 国际化更新 | 0.25d | Step 13 |

### P2（完善体系，约 2-3 工作日）

| 步骤 | 内容 | 工作量 | 依赖 |
|------|------|--------|------|
| 15 | Lucent 新建法律文档管理 API | 1d | 可选，初期可用 assets |
| 16 | App 端 data source 改为远程优先 + assets fallback | 0.5d | Step 15 |
| 17 | ICP 备案信息 + About 页增强 | 0.5d | 需备案号 |
| 18 | OpenAPI 导出 + Flutter 客户端重新生成 | 0.5d | Step 15 |

---

## 七、验证清单

- [ ] `flutter analyze` 零问题
- [ ] `flutter test` 全部通过
- [ ] About 页所有法律入口可正常跳转到 App 内页面
- [ ] 注册页协议链接可正常跳转到 App 内页面
- [ ] 法律文档详情页正确渲染 Markdown
- [ ] 法律文档详情页加载/错误态正常显示
- [ ] 中英文 ARB 完整同步
- [ ] `https://luminous.app/terms` 不再是死链
- [ ] `https://luminous.app/privacy` 内容符合 PIPL 要求

---

## 八、注意事项

1. **法务审阅**：所有法律文档内容（特别是隐私政策和用户协议）需经法务审阅后才能上线。
2. **PIPL 合规要点**：隐私政策必须包含 — 数据处理者信息、处理目的/方式/种类/保存期限、用户权利清单（查阅/复制/更正/删除/撤回同意/注销/投诉）、第三方共享情况、跨境传输情况。
3. **医疗免责声明**：必须明确"不构成医疗建议、不替代医生诊断、用药决策应遵医嘱"。
4. **内容更新机制**：初期用 assets，但需预留后端更新路径，避免每次修改法律文档都要发版。
5. **深度链接**：考虑支持从外部直接打开 `/legal/privacy` 等路径。
