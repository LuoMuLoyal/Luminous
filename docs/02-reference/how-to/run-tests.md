# How-To: 运行测试与检查

## 日常开发

```bash
cd Luminous

# 分析（最快反馈）
flutter analyze

# 单元/Widget 测试
flutter test

# 单个测试文件
flutter test test/features/today/presentation/providers/today_suggestion_provider_test.dart
```

## 生成物准备

在 analyze/test 之前，确保生成物已就位（全新 clone 或 ARB/OpenAPI 变更后必须）：

```bash
dart run tool/bootstrap_generated_sources.dart
```

## 仓库安全级检查

```bash
dart run tool/run_daily_checks.dart
```

此脚本运行 analyze + test + 文档覆盖率检查。

## 全栈检查

需要 Lucent 后端运行时：

```bash
dart run tool/run_fullstack_checks.dart
```

## 集成测试

```bash
# 全部 E2E
flutter test integration_test

# 单个场景
flutter test integration_test/{scenario}_e2e_test.dart
```

## 文档覆盖率检查

```bash
# 阻断模式（有代码变更但无 docs/ 文件时 exit 1）
dart run tool/check_doc_coverage.dart

# 仅警告模式（报告缺少的文档但不阻断）
dart run tool/check_doc_coverage.dart --warning-only

# 旁路
$env:SKIP_DOC_CHECK=1
```
