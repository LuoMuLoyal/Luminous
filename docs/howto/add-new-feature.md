---
status: active
owner: frontend
updated: 2026-08-31
---

# How-To: 新增 Feature 模块

## 前置

- 分层规则、文件命名、状态管理约定见仓库根 `AGENTS.md`
- 目录结构约定见 [Architecture](../reference/architecture.md)
- 涉及 Lucent API 时确认合同已导出，见 [OpenAPI Client](../reference/openapi-client.md)

## 步骤

### 1. 创建 feature 目录

在 `lib/features/{feature}/` 下按 AGENTS.md 的分层规则创建
`domain/`、`data/`、`presentation/`（有业务编排需求时加 `application/`），
不再赘述分层细节。

### 2. 注册 ARB 分片

1. 在 `scripts/l10n/arb_tools.dart` 的 `fragmentRules` 中加一行：
   `'{feature}': ['{feature}'],`
2. 新建 `lib/l10n/src/{feature}_zh.arb` / `{feature}_en.arb` 分片对
3. 生成：`dart scripts/l10n/arb_tools.dart merge` + `flutter gen-l10n`

不要直接编辑 `lib/l10n/app_zh.arb` / `app_en.arb`（合并生成物）。

### 3. 接线路由

在 feature 的 `presentation/routes.dart` 用 `@TypedGoRoute` 定义路由类，
完整示例见 `lib/features/notification/presentation/routes.dart`：

```dart
part 'routes.g.dart';

@TypedGoRoute<NotificationListRoute>(path: '/notifications')
class NotificationListRoute extends GoRouteData with $NotificationListRoute {
  const NotificationListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const NotificationListPage());
  }
}
```

在 `lib/app/router.dart` 中 import 并 spread 进顶层 routes 列表：

```dart
import 'package:luminous/features/{feature}/presentation/routes.dart'
    as {feature}_routes;
// ...
...{feature}_routes.$appRoutes,
```

- 五个 Tab 根页面在 `StatefulShellRoute.indexedStack` 的 branch 中注册
- 其余子页面为 top-level 全屏路由（由 go_router_builder 生成）
- 运行 `dart run build_runner build --delete-conflicting-outputs`
  生成 `routes.g.dart`

### 4. 设计系统

- Forui 组件优先于自定义 widget；`SemanticColor` / `Spacing` /
  `IconSizeTokens` 经 barrel `lib/core/design/design.dart` 引用
- 参见 [Design System](../reference/design-system.md)

### 5. 编写测试

- 测试文件镜像 `lib/` 源码路径 + `_test.dart` 后缀；多数 feature 位于
  `test/{feature}/`（如 `test/medicine/`）
- Mock 仓库命名为 `Mock{Feature}Repository`，共享 helper 在 `test/helpers/`
- 测试不启动真实设备能力，注入 platform-interface fake

### 6. 验证

```bash
dart run scripts/contract/bootstrap.dart   # 生成物正常
flutter analyze                                     # 无分析错误
flutter test test/{feature}/                        # feature 测试通过
```

### 7. 更新文档

- 追加 `docs/logs/migration-log/YYYY-MM-DD.md` 条目（只追加，不覆写）
- 在 `docs/doc-map.yaml` 登记 feature → 文档映射规则
- per-feature 约束写入 `lib/features/{feature}/README.md`
- 重大架构决策在 `docs/reference/adr/` 下创建 ADR
- 不创建 `Active_*` / `*_Snapshot` 式现状文档
