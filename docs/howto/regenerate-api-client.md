---
status: active
owner: frontend
updated: 2026-08-31
---

# How-To: 再生 Lucent API 客户端

## 前置

- `../Lucent/docs/reference/generated/openapi.json` 已存在
- Lucent 侧导出方式见 `Lucent/docs/howto/sync-openapi-client.md`

## 步骤

### 1. 导出最新合同（Lucent 侧）

```bash
cd ../Lucent
pnpm export:openapi
```

### 2. 主入口：bootstrap 脚本（Luminous 侧）

```bash
dart run scripts/contract/bootstrap.dart
```

脚本内部按阶段完成全量再生，无需手工调用 openapi-generator-cli：

1. 根目录 `flutter pub get`
2. 并行执行两支：
   - **客户端再生**（`generated/lucent_api`，见下）
   - **应用 codegen**：`flutter gen-l10n` + 根目录 `build_runner`
3. 客户端再生分三阶段：
   1. **全量生成**（临时目录）：一次生成全部 apis/models/supporting，完整
      `lib/` 树归一化拷贝进 `generated/lucent_api`——覆盖
      `_filteredClients` 清单外的客户端（如 `MedicineRemindersApi`）
   2. **过滤生成**：对 `_filteredClients`（TodayAnalysis、Reports、
      ProductEvents、Notifications、UserSettings、ReminderDeliveries）逐
      客户端再生并覆盖 API 文件与命名 schema 模型（过滤生成不产出内联响应模型）
   3. **支撑文件**：再生 `lucent_api.dart` / `deserialize.dart` 并补齐内联
      响应模型，然后在 generated 包内 `dart pub get` + `build_runner`
      （生成 `.g.dart`）+ `dart format`

脚本内置两类归一化/防护（使用层面无需关心）：

- 全部拷贝路径经 `_normalizeGeneratedDart` 剥离 dart-dio 对「枚举数组」字段
  输出的非法 `unknownEnumValue: List<...>` 行
- docs/tests 生成关闭（模型测试模板会重写跟踪中的既有测试并破坏解析）；
  生成器模板文件（`pubspec.yaml` 等）不拷贝，保留仓库跟踪的 SDK 约束

可选参数：`--openapi <path>` 指定合同路径（默认解析兄弟目录 Lucent 的
`docs/reference/generated/openapi.json`）；`--skip-client` /
`--skip-app-codegen` / `--skip-pub-get` 跳过对应阶段。

### 了解内部机制

底层生成器为 `@openapitools/openapi-generator-cli` 的 `dart-dio`
（配置文件 `openapi_gen_config.json`）。**主入口始终是 bootstrap 脚本**，
仅在排查生成问题时阅读 `scripts/contract/bootstrap.dart` 中的
`_generateFullApiClient` / `_generateFilteredApiClient` /
`_generateSupportingFiles`，不要手工执行 generate 命令。

### 3. 验证

```bash
git diff --check   # 无空白错误
flutter analyze    # 无分析错误
flutter test       # 测试通过
```

### 4. 检查生成物边界

- 跟踪路径：`generated/lucent_api/lib/api/**`（除 `**/*.g.dart`）
- 忽略路径：`generated/lucent_api/pubspec.lock`、`**/*.g.dart`
- 不要手动编辑生成物

## 仅验证合同同步（不实际再生）

```bash
dart run scripts/contract/verify_openapi.dart
# 可选 --openapi <path> 指定 Lucent 合同路径（默认同样自动解析）
```

## 详细参考

- [OpenAPI Client](../reference/openapi-client.md) — 生成物边界、使用规则、常见问题
