# 2026-09-06 账号体系重构：个人信息 / 账号管理 / 账号安全中心

## 背景与动机

当前「账号与安全」页 (`/account`) 同时承载了个人资料编辑（昵称/头像）、
账号状态概览、邮箱管理、第三方绑定、登录设备、修改密码、注销账号等所有功能，
导致页面过长且信息层级扁平；同时「修改密码」tab 在仅使用验证码登录的用户
（无密码）场景下文案不够友好（提示"未设置密码"），注销账号放在修改密码 tab
下也与用户直觉不符。设置页顶部头像区域当前导航到同一 `/account` 页面，
与期望的"头像/昵称 → 个人信息"的用户心智不一致。

## 目标信息架构

```
设置页 (SettingsPage)
├─ [头像/昵称/邮箱卡片] ──────────── 点击 → 个人信息页 (ProfilePage)
│
├─ 账号与安全  section
│  ├─ 账号管理 ← 原"账号与安全"tile，改名/入口不变 (/account)
│  ├─ （其余现有设置项保留）
│
├─ 快捷入口 section
│
├─ 隐私 section
│
└─ 关于 section
```

### 个人信息页 (ProfilePage) — 新增

路径: `/profile`（顶级全屏路由，不在 settings shell 内）。

内容:
- 头像（可编辑/更换）
- 昵称
- 过敏史（来自 health_context feature，当前在 `/mine` 页面中）
- 个人档案：身高、体重、血型、出生日期等（迁移自 mine page
  目前散落的 health-profile tile）

数据来源: 保持 `HealthContextSnapshotProvider` + `UserSettingsController`，
不新增 provider；mine page 中「健康档案」编辑入口从 mine 移入此页面。

### 账号管理页 (AccountManagePage) — 重命名自 AccountSettingsPage

路径: `/account`（沿用现有路由）。

结构（垂直列表，各 item 带右箭头/开关，无 tabs）:

| 行 | 说明 |
|---|---|
| 头像 + 昵称 + 邮箱（概要卡片） | 顶部展示，非可点击 |
| 用户名 | 若有则显示；未设置则显示"未设置"，点击 → 设置用户名 |
| 邮箱 | 显示当前邮箱 + 验证状态，点击 → `/account/change-email` |
| 登录密码 | 有密码显示"已设置"→ 修改密码页；无密码显示"未设置"→ 设置密码页 |
| 第三方账号 | 显示已绑定列表（微信/QQ/Google），点击 → 展开详情或管理 |
| 登录设备 | 点击 → `/account/sessions`（现有 SessionsPage） |
| 账号安全中心 | 点击 → 新路由 `/account/security-center` |
| 账号注销 | 危险操作，红色文字，点击 → 注销流程 |

底部横向排列: 我的客服 | 意见反馈 | 帮助中心

底部横向按钮的交互:
- 我的客服 → 外部链接或 Webview（跳转客服系统）
- 意见反馈 → 跳转反馈渠道
- 帮助中心 → 跳转帮助文档

### 账号安全中心 (SecurityCenterPage) — 新增

路径: `/account/security-center`。

内容:
- 顶部头像 + 昵称（概要）
- 授权记录（OAuth 授权历史）
- 敏感操作记录（改密、注销、解绑等）
- 登录记录（现有 SessionsPage 的设备/登录历史，可复用 `SessionsPage`）
- 账号保护（二次验证设置入口，预留；暂无具体功能）

## 分阶段实施

### Phase 1 — 即时修复（已完成）

移除 `AccountSettingsPage` 两个 tab 内容区的内层 `FCard`，
消除"盒子套盒子"视觉问题。验证通过后合入。

### Phase 2 — 个人信息页 (ProfilePage)

1. 新建 `lib/features/settings/presentation/pages/profile.dart`
2. 新增路由 `Routes.mineProfile` → `/profile`（或复用现有 `mineProfileEdit`）
3. 从 mine page 中迁移「头像/昵称编辑」和「健康档案（身高/体重/血型/过敏史）」
   编辑能力到 ProfilePage
4. 设置页顶部 `AccountHeader` 的 `onTap` 改为导航到 `/profile`
5. mine page 中对应的健康档案编辑入口改为导航到 `/profile`
6. 补充 widget 测试

### Phase 3 — 账号管理页重命名 + 重构

1. 将 `AccountSettingsPage` 改名/重构为 `AccountManagePage`
   （保留 `/account` 路由路径）
2. 移除 `FTabs`，改为单一垂直列表布局
3. 把原本在"帐号状态" tab 里的 sections（邮箱、第三方绑定、登录设备）提升为列表项
4. 把"修改密码"tab 里的密码管理和注销账号提升为列表项
5. 把 SessionManagementSection 合并到「登录设备」列表项
6. 补充/更新 widget 测试

### Phase 4 — 账号安全中心

1. 新建 `lib/features/settings/presentation/pages/security_center.dart`
   （或 `lib/features/auth/presentation/pages/security_center.dart`）
2. 新增路由 `/account/security-center`
3. 授权记录: 复用 `LinkedIdentitiesSection` 的数据展示逻辑
4. 敏感操作记录: 后端需提供审计日志端点（若暂无，显示"暂无记录"占位）
5. 登录记录: 复用现有 `SessionsPage` 的展示
6. 账号保护: 预留入口，暂显示"即将推出"

### Phase 5 — 底部服务入口

1. 在账号管理页底部添加横向三按钮
2. 「我的客服」→ 外部链接或客服 Webview
3. 「意见反馈」→ 反馈渠道（邮箱 / 表单链接）
4. 「帮助中心」→ 外部帮助文档链接
5. l10n 文案补全

## 路由变更

| 旧路由 | 新路由 | 说明 |
|---|---|---|
| `/account` | `/account` | 改名 AccountManagePage（路由路径不变） |
| `/account/sessions` | `/account/sessions` | 保留，被安全中心"登录记录"项跳转 |
| `/account/change-email` | `/account/change-email` | 保留 |
| `/mine/profile/edit` | `/profile` | 新增，设置页头像区 & mine 页健康档案入口统一跳转 |
| — | `/account/security-center` | 新增 |

## 文件影响面

### 新增文件
- `lib/features/settings/presentation/pages/profile.dart`
- `lib/features/settings/presentation/pages/security_center.dart`
- `lib/features/settings/presentation/widgets/account_manage_sections.dart`（可选，
  若从 account_settings_sections.dart 拆出）

### 修改文件
- `lib/features/auth/presentation/pages/account_settings.dart`
  → 重命名/重构为 account_manage.dart
- `lib/features/auth/presentation/pages/account_settings_sections.dart`
  → 重构 sections，可能拆分为 manage / profile / security_center 各自 sections
- `lib/features/settings/presentation/pages/page.dart`
  → AccountHeader onTap 改为 /profile
- `lib/features/settings/presentation/widgets/account_header.dart`
  → onTap 注入改为导航到 /profile
- `lib/features/auth/presentation/routes.dart`
  → 新增 ProfileRoute、SecurityCenterRoute
- `lib/features/auth/presentation/routes.g.dart`（生成）
- `lib/features/mine/presentation/pages/page.dart`
  → 健康档案编辑入口改跳 ProfilePage
- `lib/l10n/src/`（l10n 文案分片，新增 tile/页面文案）
- `test/mine/account_settings_page_test.dart`
  → 更新断言（tabs → 列表布局）
- `test/settings/page_test.dart`
  → 头像卡片导航断言改为 `/profile`

## l10n 文案新增（后续实施时分片更新）

- `settingsProfileTitle` / `settingsProfileSubtitle`（个人信息标题/副标题）
- `settingsAccountManageTitle` / `settingsAccountManageSubtitle`（账号管理）
- `settingsSecurityCenterTitle`（账号安全中心）
- 各列表行 title/subtitle/action
- 底部客服/反馈/帮助中心按钮文案
- 占位状态文案（无授权记录/无敏感记录等）

## 测试计划

- `test/mine/profile_page_test.dart` — 新增，覆盖个人信息页渲染与导航
- `test/mine/security_center_page_test.dart` — 新增，覆盖安全中心渲染
- 更新 `test/mine/account_settings_page_test.dart` — 适配新布局断言
- `flutter analyze` / `flutter test` 全量通过
- `dart run scripts/docs/verify.dart --warning-only` 提示时更新 `doc-map.yaml` 或对应 docs

## 备注

- 本计划与 Lucent 后端无关（前端重构为主），无需 Lucent 契约变更。
- 后续若在安全中心展示"敏感操作记录/授权记录"需后端审计日志接口，
  可在 Lucent 新开端点并走 `pnpm export:openapi` → `dart run scripts/contract/bootstrap.dart`。
