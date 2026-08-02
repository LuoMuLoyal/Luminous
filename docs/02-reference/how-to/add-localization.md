---
status: active
owner: frontend
quadrant: how-to
updated: 2026-08-02
---

# How-To: 添加本地化文案

## 前置

- 阅读 [[../Localization]] 了解完整的本地化工作流和规则

## 步骤

### 1. 确定文案 key

使用 `{feature}.{section}.{purpose}` 命名约定。例如：

- `today.suggestion.feedbackLabel`
- `record.timeline.seeAll`
- `medicine.safetyCheck.warning`

### 2. 添加到 ARB 文件

在 `lib/l10n/app_zh.arb` 和 `lib/l10n/app_en.arb` 中同时添加：

```json
{
  "today.suggestion.feedbackLabel": "这条建议有帮助吗？",
  "@today.suggestion.feedbackLabel": {}
}
```

```json
{
  "today.suggestion.feedbackLabel": "Was this suggestion helpful?",
  "@today.suggestion.feedbackLabel": {}
}
```

### 3. 重新生成本地化代码

```bash
dart run tool/bootstrap_generated_sources.dart
```

或仅生成 l10n：

```bash
flutter gen-l10n
```

### 4. 在代码中使用

```dart
final l10n = context.l10n;
Text(l10n.todaySuggestionFeedbackLabel)
```

注意：ARB key 中的 `.` 在 Dart 中变为驼峰。

## 规则

- 不要在页面或 widget 中硬编码用户可见文案
- 两个 ARB 文件必须同步更新
- Assistant 文案使用 `assistant*` 前缀的 key
- 生成文件 `app_localizations*.dart` 是本地忽略的（git-ignored）
- CI 和本地验证通过 `bootstrap_generated_sources.dart` 再生这些文件
