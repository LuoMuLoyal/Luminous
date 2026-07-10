# How-To: 新增 Feature 模块

## 前置

- 阅读 [[../architecture]] 了解目录结构约定
- 阅读 `AGENTS.md` 了解文件命名规则和状态管理约定
- 确认对应的 Lucent API 合同已就绪（见 `docs/00-current/Lucent_Contract_Snapshot.md`）

## 步骤

### 1. 创建目录结构

在 `lib/features/{feature}/` 下创建标准分层：

```
lib/features/{feature}/
├── data/
│   ├── repositories/
│   │   └── lucent_repository.dart    # Lucent API 实现
│   └── datasources/
│       └── remote_data_source.dart
├── domain/
│   ├── entities/
│   └── repositories/
│       └── repository.dart            # 抽象接口
└── presentation/
    ├── pages/
    ├── widgets/
    │   └── sections/                  # 页面内区段
    └── providers/
        └── provider.dart              # Riverpod provider
```

### 2. 实现分层

- **domain/**：定义实体和仓库接口，不依赖任何外部包
- **data/**：实现 `domain/repositories/` 中的接口，使用 `LucentDioClient` 或生成的 API 客户端
- **presentation/**：使用 Riverpod `Notifier` + `NotifierProvider`，`@freezed` 状态类

### 3. 注册路由

在 `lib/app/router/` 的路由配置中添加新页面的路由。Tab 内子页面使用 `StatefulShellRoute` branch；全屏页面使用 top-level route。

```dart
// lib/app/router/routes.dart
GoRoute(
  path: '/{feature}',
  builder: (context, state) => const {Feature}Page(),
),
```

### 4. 添加本地化文案

在 `lib/l10n/app_zh.arb` 和 `lib/l10n/app_en.arb` 中添加所有用户可见文案。参见 [[add-localization]]。

### 5. 添加设计系统引用

- 使用 Forui 组件优先于自定义 widget
- 使用 `SemanticColor` / `Spacing` / `TypographyToken` / `RadiusTokens` 设计 token
- 参见 [[../Design_System]] 和 [[../Design_System_Components]]

### 6. 编写测试

- 单元测试：`test/features/{feature}/`
- Widget 测试：`test/features/{feature}/presentation/`
- Mock 仓库命名为 `Mock{Feature}Repository`
- 测试文件镜像 `lib/` 路径，`_test.dart` 后缀

### 7. 验证

```bash
dart run tool/bootstrap_generated_sources.dart   # 确认生成物正常
flutter analyze                                    # 无分析错误
flutter test test/features/{feature}/              # feature 测试通过
```

### 8. 更新文档

- 追加今日 `docs/03-logs/migration-log/YYYY-MM-DD.md` 条目
- 在 `docs/00-current/` 下创建 `Active_UI_{Feature}.md` 描述当前状态
- 在 `docs/00-current/Current_State.md` 添加链接
- 更新 `docs/doc-map.yaml` 添加代码→文档映射规则
- 如有重大架构决策，在 `docs/02-reference/adr/` 下创建 ADR
