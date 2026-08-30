# Luminous 模块边界卫生审计与修复

Created: 2026-08-30

## 一、背景

参照 `deepseek-harness` 的 package 组织模式（每个 package 有独立 barrel export、`tests/` 同级、`README.md`），对 Luminous 的模块边界纪律进行审计。

Luminous 是 Flutter monolith，不拆独立 pub package。

### 关键区别：Flutter 移动端 vs NestJS 服务端

**barrel export 在服务端和移动端的影响完全不同：**

| 维度 | Lucent（NestJS 服务端） | Luminous（Flutter 移动端） |
|------|----------------------|------------------------|
| 打包方式 | 不打包，`node dist/main.js` 直接 require | AOT 编译为单一机器码 bundle |
| Tree-shaking | Commonjs 按文件加载 | Dart 符号级 tree-shake ✓ |
| 启动时间 | 不敏感 | **敏感**（冷启动 <2s） |
| 包体大小 | 不关心 | **APK/IPA 大小直接影响下载率** |
| 代码分割 | 不需要 | `deferred as` 可延迟加载，减少首屏 |
| barrel 的代价 | 零 | **阻碍 deferred 加载粒度控制** |
| barrel 的收益 | 开发者不用记路径 | 同左，但代价更高 |

**结论**：Lucent 大量使用 barrel 没有任何问题。但 Luminous 是移动端应用，**深引用（直接 import 具体文件路径）比 barrel export 更优**——编译器可以看到精确依赖路径，tree-shaking 效果最好，且为未来引入 `deferred imports` 保留精确的代码分割粒度。

因此，本计划**不为 feature 建 barrel export**，而是聚焦于：
1. 把跨 feature 依赖改为跨层依赖（feature → core）
2. 测试同位
3. 文档覆盖

## 二、审计数据快照

以下数据来自 2026-08-30 的全量 `rg` 扫描。

### 2.1 Barrel export 覆盖率

| 检查项 | 结果 | 说明 |
|--------|------|------|
| `lib/core/design/design.dart` | ✅ 完整 — 17 个文件 | core 层 barrel 是合理的——token 定义是纯常量，不涉及 deferred 加载 |
| `lib/core/network/api.dart` | ✅ 有 | 同上 |
| `lib/core/widgets/common/state_views.dart` | ✅ 有 | 同上 |
| `lib/core/auth/session_provider.dart` | ✅ 有 | 同上 |
| `lib/features/*/` feature 级 barrel | **0 个** | **✅ 不建是正确的** — feature 层应保持深引用 |

### 2.2 跨 feature 深引用

共扫描出 **~80+ 处**跨 feature 深引用。在 Flutter 移动端，深引用本身是**好习惯**——每个文件只拉入它真正需要的符号，编译器依赖路径清晰。

但以下两类深引用需要修正：

#### 类型 A：应该提取到 `core/` 的跨切面依赖

| 被 deep-import 的目标 | 引用方数 | 问题 | 修正方向 |
|---------------------|---------|------|---------|
| `auth/presentation/widgets/shared/required_dialog.dart` | **~40 个文件** | 这是一个跨切面工具（auth 检查 + 路由跳转），不是 auth feature 的业务逻辑，应该放在 `core/` | 提取到 `core/widgets/auth/` |

#### 类型 B：正常的跨 feature 业务依赖（保持现状）

| 被 deep-import 的目标 | 引用方数 | 说明 |
|---------------------|---------|------|
| `health_context/domain/entities/snapshot.dart` | ~15 个文件 | ✅ 正常 — 健康档案是跨 feature 的共享领域模型 |
| `health_context/data/providers/health_context.dart` | ~15 个文件 | ✅ 正常 — 健康档案 provider 被 6 个 feature 依赖 |
| `medicine/domain/entities/dose_log.dart` | ~8 个文件 | ✅ 正常 — 服药记录 entity 被 today/record 依赖 |
| `medicine/domain/entities/reminder.dart` | ~6 个文件 | ✅ 正常 — 提醒 entity 被 today/record 依赖 |
| `medicine/data/datasources/dose_log_cached.dart` | ~5 个文件 | ⚠️ 可接受 — 缓存 datasource 被跨 feature 使用，可考虑提取到 core |
| `record/domain/entities/record.dart` | ~5 个文件 | ✅ 正常 — 日报记录 entity 被 today 依赖 |
| `settings/presentation/providers/user_settings.dart` | ~4 个文件 | ✅ 正常 — 用户设置 provider 被跨 feature 依赖 |
| `shell/presentation/desktop_tab_shell.dart` | ~5 个文件 | ✅ 正常 — 桌面布局被各 tab feature 依赖 |
| `notification/data/providers/unread_count.dart` | ~3 个文件 | ✅ 正常 — 未读计数 provider 被多个 feature 依赖 |
| `scan/presentation/pages/box_scan.dart` | ~3 个文件 | ✅ 正常 — 扫码页面被 medicine/search 依赖 |
| `search/presentation/pages/page.dart` | ~2 个文件 | ✅ 正常 — 搜索页面被 medicine 依赖 |

**类型 B 的深引用全部保持现状，不做修改。**

#### `required_dialog.dart` 深引用详情

`features/auth/presentation/widgets/shared/required_dialog.dart` 被 ~40 个文件直接深引用。该文件本身是一个薄包装：

```dart
// features/auth/presentation/widgets/shared/required_dialog.dart
export 'package:luminous/core/widgets/auth/required_dialog.dart';

Future<void> pushAuthRequiredRoute(BuildContext context, String route) async { ... }
```

它 re-export 了 `core/widgets/auth/required_dialog.dart`（纯 UI 组件），并添加了一个依赖 auth 路由的 `pushAuthRequiredRoute` 函数。40 个文件 import 它来调用 `pushAuthRequiredRoute`。

这不是"跨 feature 业务依赖"——它是"跨切面工具函数放错了位置"。auth 检查是一个横切关注点，不是 auth feature 的业务逻辑。

### 2.3 测试与源码同级归位

| 检查项 | 结果 |
|--------|------|
| `lib/features/` 内的 `*_test.dart` | **0 个** — 零同位测试 |
| `test/` 目录组织 | 按 feature 子目录组织 ✓（`test/today/`、`test/medicine/` 等），但与 `lib/features/today/` 物理分离 |

### 2.4 模块 README 覆盖

| 检查项 | 结果 |
|--------|------|
| `lib/features/*/README.md` | **0 个** |
| `lib/core/*/README.md` | 0 个（但 `lib/theme/README.md` 有 1 个） |

## 三、修复计划

### Phase 2: P2 — 测试归位

将 `test/` 下的测试文件移到对应 feature 的 `tests/` 子目录：

- [ ] 2.1 `test/today/` → `lib/features/today/tests/`
- [ ] 2.2 `test/medicine/` → `lib/features/medicine/tests/`
- [ ] 2.3 `test/record/` → `lib/features/record/tests/`
- [ ] 2.4 `test/settings/` → `lib/features/settings/tests/`
- [ ] 2.5 其他 feature 同理
- [ ] 2.6 `test/core/` → `lib/core/tests/` 或保持 `test/core/`（core 是跨 feature 共享层，放 `test/` 可接受）
- [ ] 2.7 `test/helpers/` 保持 `test/helpers/`（共享测试工具）
- [ ] 2.8 调整 `flutter test` 配置确保新路径被发现
- [ ] 2.9 `flutter test` 验证全部通过

### Phase 3: P2 — 补 README

- [ ] 3.1 `lib/core/design/README.md` — 记录 token 体系、Forui 集成方式、命名规范（与 `docs/02-reference/Design_System.md` 互补，README 面向代码阅读者，docs 面向架构理解者）
- [ ] 3.2 `lib/features/health_context/README.md` — 记录 snapshot 数据模型、provider 依赖图、为什么被 6 个 feature 依赖
- [ ] 3.3 `lib/features/today/README.md` — 记录 dashboard 聚合模式、跨 feature 依赖关系

## 四、不建议做的

- **不为 feature 建 barrel export**：Flutter 移动端的深引用是**更优模式**——编译器可以看到精确依赖路径，tree-shaking 效果最好，且为未来 `deferred imports` 保留精确的代码分割粒度。`core/` 层的 barrel 是合理的（纯常量/token，不涉及 deferred），feature 层不应建 barrel
- **不拆独立 pub package**：Flutter widget 树、Riverpod provider、GoRouter 路由都在同一编译单元，拆 package 会导致开发体验大幅退化
- **不为所有 feature 补 README**：大部分 feature 是标准 MVP 页面，README 价值低
- **不引入 invariant 模式**：Flutter 没有等价的运行时不变量检查框架
- **不把跨 feature 业务依赖改为 barrel**：`health_context/domain/entities/snapshot.dart` 被 15 个文件深引用是正常的——健康档案是跨 feature 的共享领域模型，深引用直接指向具体文件是最清晰的

## 五、风险与注意事项

1. **Phase 1 的 `pushAuthRequiredRoute` 依赖 auth 路由**：该函数调用 `context.push(LoginRoute().location)`。如果 `LoginRoute` 定义在 `features/auth/presentation/routes.dart`，移到 `core/` 会引入 core → feature 的反向依赖。解法：用回调注入（`{required String Function() loginRouteBuilder}`）或将路由常量提取到 `core/router/routes.dart`。

2. **Phase 2 的测试归位影响 CI**：`flutter test` 默认扫描 `test/`，改为 `lib/` 内需要确认 CI 配置和 `flutter test` 命令是否需要调整。

3. **`core/` 层 barrel 保持现状**：`design.dart`、`api.dart`、`state_views.dart` 等 core 层 barrel 是合理的——它们导出的是纯常量、token 定义和静态组件，不涉及 deferred 加载。不需要拆解。
