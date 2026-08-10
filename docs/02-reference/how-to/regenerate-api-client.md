---
status: active
owner: frontend
quadrant: how-to
updated: 2026-08-10
---

# How-To: 再生 Lucent API 客户端

## 前置

- `../Lucent/docs/openapi.json` 已存在（在 Lucent 运行 `pnpm export:openapi` 生成）
- 如需从 Lucent 导出，参见 `Lucent/docs/01-reference/how-to/sync-openapi-client.md`

## 步骤

### 1. 确认 Lucent 侧已导出最新合同

```bash
cd Lucent
pnpm export:openapi
```

### 2. 在 Luminous 侧再生

```bash
cd Luminous
openapi-generator-cli generate \
  -i ../Lucent/docs/openapi.json \
  -g dart-dio \
  -o generated/lucent_api \
  -c openapi_gen_config.json
dart run scripts/bootstrap_generated_sources.dart
```

此脚本会：
1. 使用 `@openapitools/openapi-generator-cli` 的 `dart-dio` 读取 `../Lucent/docs/openapi.json`，生成客户端和 JSON-serializable 模型
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
  --openapi /absolute/path/to/Lucent/docs/openapi.json
```

## 详细参考

- [[../OpenApi_Client]] — 生成物边界、使用规则、常见问题
