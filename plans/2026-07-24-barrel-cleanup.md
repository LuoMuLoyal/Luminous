# Barrel 导出清理 — Luminous

> **创建日期**: 2026-07-24
> **状态**: 待执行
> **审查基线**: `lib/` 中 20 个含 `export` 语句的文件

## 目标

移除 Luminous 中的 barrel 滥用：删除 5 个纯 widget barrel 文件、移除 10 个非 barrel 文件中夹带的跨层 `export` 语句，保留 5 个合理的 `core/` barrel 和平台条件 export。

Luminous 不引入模块根 barrel — Dart 无 DI 容器，跨 feature 已全部使用 `package:luminous/features/...` 深路径导入，这一模式正确，不需改变。

## 执行原则

- 每个阶段结束后运行 `flutter analyze && flutter test`
- 不改变运行时行为 — 纯结构调整和导入路径替换
- 用户可见文本不改动，无需 ARB 流程
- 每阶段结束后追加 `docs/03-logs/migration-log/2026-07-24.md` 条目，运行 `dart run tool/check_doc_coverage.dart --warning-only`

---

## 背景与问题

### 现状

Luminous 的 `lib/` 中有 20 个文件含 `export` 语句，分为四类：

| 类别 | 数量 | 评价 |
|---|---|---|
| `core/` 跨切面 barrel | 3 | **合理** — 设计 token、网络层、状态视图的聚合 |
| 平台条件 export | 2 | **合理** — Dart 条件导入模式 |
| 纯 widget barrel 文件 | 5 | **滥用** — 文件只有 export 语句，无实际代码 |
| 非 barrel 文件夹带 export | 10 | **滥用** — provider/service/page 文件中夹带跨层 re-export |

### 与 Lucent 的差异

Lucent 用 NestJS DI 容器，服务通过 `@Module().exports` 暴露，barrel 只管类型/DTO 导入。
Luminous 无 DI 容器，所有依赖直接 import。跨 feature 已全部用深路径（`package:luminous/features/...`），
不需要 feature 级 barrel。

---

## 保留的 barrel（不动）

以下 5 个文件不做任何改动：

| 文件 | 导出数 | 保留理由 |
|---|---|---|
| `core/design/design.dart` | 11 | 设计 token 聚合，所有 feature 都依赖，barrel 减少大量重复 import |
| `core/network/api.dart` | 13 | 网络层符号聚合，同上 |
| `core/widgets/common/state_views.dart` | 3 | 状态视图三件套（page_state / skeleton / state_message）内聚 |
| `features/auth/data/datasources/wechat/mobile_auth_client.dart` | 2 | Dart 平台条件导入模式（`if (dart.library.io)`），不是 barrel |
| `features/auth/data/datasources/wechat/desktop_oauth_callback_listener.dart` | 1 | 同上 |

---

## 阶段 1 — 移除非 barrel 文件中的跨层 export（P0）

**目标**: 从 10 个 provider/service/page 文件中移除夹带的 `export` 语句，消费者改为直接导入源文件。

### 1a. 跨层 re-export（provider → data 层）

| 文件 | 移除的 export | 消费者需改为 |
|---|---|---|
| `notification/presentation/providers/notification.dart` | `export '../../data/repositories/lucent.dart' show notificationRepositoryProvider;` | `import 'package:luminous/features/notification/data/repositories/lucent.dart';` |
| `notification/presentation/providers/notification.dart` | `export '../../data/providers/unread_count.dart' show notificationUnreadCountProvider;` | `import 'package:luminous/features/notification/data/providers/unread_count.dart';` |
| `legal/presentation/providers/legal.dart` | `export '../../data/repositories/lucent.dart' show legalRepositoryProvider;` | `import 'package:luminous/features/legal/data/repositories/lucent.dart';` |
| `settings/presentation/providers/user_settings.dart` | `export 'package:luminous/features/settings/data/repositories/lucent.dart' show userSettingsRepositoryProvider;` | `import 'package:luminous/features/settings/data/repositories/lucent.dart';` |
| `support/data/providers/resources.dart` | `export 'package:luminous/features/support/data/repositories/lucent.dart' show supportRepositoryProvider;` | `import 'package:luminous/features/support/data/repositories/lucent.dart';` |

**操作**:
1. 删除 export 语句
2. 查找所有通过这些 provider 文件间接获取 repository provider 的消费者
3. 在消费者文件中添加直接 import 语句

### 1b. 跨层 re-export（provider → domain 层）

| 文件 | 移除的 export | 消费者需改为 |
|---|---|---|
| `medicine/presentation/providers/reminders.dart` | `export 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';` | `import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';` |
| `medicine/presentation/providers/safety_tips.dart` | `export 'package:luminous/features/medicine/presentation/utils/safety_tip_style.dart';` | `import 'package:luminous/features/medicine/presentation/utils/safety_tip_style.dart';` |
| `medicine/domain/services/risk_checker.dart` | `export 'package:luminous/features/medicine/domain/entities/risk_medicine_detail.dart';` | `import 'package:luminous/features/medicine/domain/entities/risk_medicine_detail.dart';` |

### 1c. datasource 间 re-export

| 文件 | 移除的 export | 消费者需改为 |
|---|---|---|
| `medicine/data/datasources/dose_log_cached.dart` | `export 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';` | `import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';` |

> 注意：`dose_log_cached.dart` 的消费者可能同时需要 cached 和 remote 的类型。移除 export 后，每个消费者需分别 import 两个文件。

### 1d. widget/page 间 re-export

| 文件 | 移除的 export | 消费者需改为 |
|---|---|---|
| `auth/presentation/widgets/shared/shell.dart` | `export 'branding.dart';` | `import 'package:luminous/features/auth/presentation/widgets/shared/branding.dart';` |
| `auth/presentation/pages/account_settings.dart` | `export 'account_settings_sections.dart';` | `import 'package:luminous/features/auth/presentation/pages/account_settings_sections.dart';` |

**操作**:
1. 删除 export 语句
2. 查找所有通过这些文件间接获取被导出符号的消费者
3. 在消费者文件中添加直接 import 语句

**验证**: `flutter analyze && flutter test`

---

## 阶段 2 — 删除纯 widget barrel 文件（P1）

**目标**: 删除 5 个只含 `export` 语句、无实际代码的 barrel 文件，消费者改为直接导入具体 widget。

### 删除清单

| 文件 | 导出数 | 导出内容 |
|---|---|---|
| `report/presentation/widgets/shared/sections.dart` | 11 | report 模块 8 个 section widget + 3 个 shared widget |
| `mine/presentation/widgets/shared/sections.dart` | 7 | mine 模块 6 个 section widget + shared.dart |
| `search/presentation/widgets/shared/headers.dart` | 6 | search 模块 6 个 section widget |
| `record/presentation/widgets/shared/overview.dart` | 2 | record 模块 2 个 section widget |
| `medicine/presentation/pages/reminders.dart` | 2 | 2 个 reminder 子页面 |

### 特殊处理：`mine/sections.dart` barrel 链

`mine/presentation/widgets/shared/sections.dart` 的第 10 行：

```dart
export '../shared/shared.dart';
```

这是一个 barrel 重导出另一个非 barrel 文件（`shared.dart` 中含 `MineSectionTitle` widget）。删除 `sections.dart` 后，需要 `MineSectionTitle` 的消费者应直接 import `shared.dart`。

### 操作

1. 对每个 barrel 文件，查找所有 import 它的消费者
2. 将消费者的 import 路径改为具体 widget 文件路径
3. 删除 barrel 文件

**示例**:

```dart
// 之前
import 'package:luminous/features/report/presentation/widgets/shared/sections.dart';

// 之后
import 'package:luminous/features/report/presentation/widgets/sections/ai_summary.dart';
import 'package:luminous/features/report/presentation/widgets/sections/findings.dart';
import 'package:luminous/features/report/presentation/widgets/sections/metrics_grid.dart';
```

> **注意**: 如果某个消费者文件同时引用了 barrel 导出的多个 widget，import 行数会增加。这是可接受的 — 每个 import 行都明确指向具体文件，可追溯。

**验证**: `flutter analyze && flutter test`

---

## 阶段 3 — 更新 AGENTS.md（P2）

**目标**: 在 Luminous `AGENTS.md` 中补充 barrel 导出规范，防止回退。

当前 `AGENTS.md` 未提及 barrel。在 "Architecture" 章节后添加：

```markdown
## Barrel Exports

- `core/` cross-cutting barrels (`design.dart`, `api.dart`, `state_views.dart`) are the
  only legitimate barrel files — they aggregate design tokens, network symbols, and
  state views consumed by all features.
- No feature-level barrel files — cross-feature imports use full `package:` paths:
  - ❌ `export '../sections/ai_summary.dart';` in a `shared/sections.dart` barrel
  - ✅ `import 'package:luminous/features/report/presentation/widgets/sections/ai_summary.dart';`
- No cross-layer re-exports — a provider file must not `export` a repository or entity;
  consumers import from the correct layer directly.
- Platform conditional exports (`if (dart.library.io)`) are exempt.
```

**验证**: `flutter analyze`

---

## 阶段 4 — `core/network/api.dart` 外部包 re-export 审查（P2）

**目标**: 确认 `api.dart` 中 `export 'package:lucent_api/api/export.dart';` 是否合理。

当前 `api.dart` 第一行：

```dart
export 'package:lucent_api/api/export.dart';
```

这是对外部生成包的 re-export。如果消费者经常同时需要 `lucent_api` 的类型和 `api.dart` 中的本地网络层符号，保留是合理的。如果消费者几乎不直接使用 `lucent_api` 的类型，可以移除并让消费者直接 `import 'package:lucent_api/api/export.dart';`。

**行动**:
1. 搜索消费者是否通过 `api.dart` 间接使用了 `lucent_api` 的类型
2. 如果使用量大 → 保留，添加注释说明理由
3. 如果使用量小 → 移除，消费者改为直接 import

**验证**: `flutter analyze`

---

## 验收检查清单

每个阶段结束后执行：

```bash
flutter analyze           # 零问题
flutter test              # 全部通过
dart run tool/check_doc_coverage.dart --warning-only
```

## 文档更新

- 每阶段追加 `docs/03-logs/migration-log/2026-07-24.md` 条目
- 阶段 3 更新 `AGENTS.md`（新增 barrel 导出规范章节）
- 如有架构变更描述需更新，同步 `docs/00-current/` 对应文件
