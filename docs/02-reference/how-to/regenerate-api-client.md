---
status: active
owner: frontend
quadrant: how-to
updated: 2026-08-16
---

# How-To: 再生 Lucent API 客户端

## 前置

- `../Lucent/docs/reference/generated/openapi.json` 已存在（在 Lucent 运行 `pnpm export:openapi` 生成）
- 如需从 Lucent 导出，参见 `Lucent/docs/howto/sync-openapi-client.md`

## 步骤

### 1. 确认 Lucent 侧已导出最新合同

```bash
cd Lucent
pnpm export:openapi
```

### 2. 在 Luminous 侧再生

```bash
cd Luminous
dart run scripts/bootstrap_generated_sources.dart
```

bootstrap 内部按三个阶段完成全量再生，无需再手工调用 openapi-generator-cli：

1. **全量生成**（临时目录）：一次生成全部 apis/models/supporting 文件，把完整 `lib/` 树
   归一化拷贝进 `generated/lucent_api`——覆盖过滤客户端清单外的客户端（如 `MedicineRemindersApi`）。
2. **过滤生成**：对 `_filteredClients` 清单逐客户端再生并覆盖（过滤生成只产出命名 schema 模型）。
3. **支撑文件**：再生 `lucent_api.dart` / `deserialize.dart` 并补齐内联响应模型，然后
   `dart pub get` + `build_runner`（生成 `.g.dart`）+ `dart format`。

脚本内置两类归一化/防护（how-to 层面无需关心）：

- dart-dio 对「枚举数组」字段会输出非法的
  `unknownEnumValue: List<SomeDtoSourcesEnum>.unknownDefaultOpenApi` 行，全部拷贝路径经
  `_normalizeGeneratedDart` 剥离（规则同步维护于本脚本内）。
- 生成关闭 `modelDocs/apiDocs/modelTests/apiTests`：模型测试模板使用 null-aware 元素语法，
  会重写跟踪中的既有测试并破坏解析；生成器模板文件（`pubspec.yaml` / `.gitignore` 等）
  不拷贝，仓库跟踪的 SDK 约束（与根 pubspec 一致的 Dart 3.12）保持不变。

此脚本会：
1. 使用 `@openapitools/openapi-generator-cli` 的 `dart-dio` 读取 `../Lucent/docs/reference/generated/openapi.json`，生成客户端和 JSON-serializable 模型
2. 运行 `build_runner` 生成 `.g.dart` 文件

### 3. 验证

```bash
git diff --check           # 无空白错误
flutter analyze             # 无分析错误
flutter test                # 测试通过
```

### 4. 检查生成物边界

- 跟踪路径：`generated/lucent_api/lib/api/**`（除 `**/*.g.dart`）
- 忽略路径：`generated/lucent_api/pubspec.lock`、`**/*.g.dart`
- 不要手动编辑生成物

## 仅验证合同同步（不实际再生）

```bash
dart run scripts/verify_lucent_openapi_sync.dart \
  --openapi /absolute/path/to/Lucent/docs/reference/generated/openapi.json
```

## 详细参考

- [[../OpenApi_Client]] — 生成物边界、使用规则、常见问题
