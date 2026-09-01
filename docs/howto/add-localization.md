---
status: active
owner: frontend
updated: 2026-08-31
---

# How-To: 添加本地化文案

## 前置

- 阅读 [Localization](../reference/localization.md) 了解完整规则

## 步骤

### 1. 确定 key

使用 `{feature}.{section}.{purpose}` 命名，key 前缀决定所属分片：

- `today.suggestion.feedbackLabel` → `today` 分片
- `medicine.safetyCheck.warning` → `medicine` 分片

### 2. 编辑分片文件

分片位于 `lib/l10n/src/`（12 分片 × 2 locale：common / network / record /
medicine / today / review / settings / auth / mine / assistant / notification /
health_sync）。在对应分片的 zh / en 文件中同时添加：

```json
"today.suggestion.feedbackLabel": "这条建议有帮助吗？",
"@today.suggestion.feedbackLabel": {}
```

`@` 开头的元数据键跟随对应值键写入同一分片。

**禁止直接编辑 `lib/l10n/app_zh.arb` / `app_en.arb`** —— 它们是合并生成物
（已 git-ignore），直接编辑会在下次 merge 时丢失。

### 3. 合并并生成本地化代码

在 Luminous 根目录：

```bash
dart scripts/l10n/arb_tools.dart merge   # lib/l10n/src/ → app_{zh,en}.arb
flutter gen-l10n                    # app_*.arb → Dart 本地化代码
```

### 4. 在代码中使用

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.todaySuggestionFeedbackLabel)
```

ARB key 中的 `.` 在 Dart 里转为驼峰。

## 验证

```bash
flutter analyze   # 无分析错误
```

## 规则

- 用户可见文案不得硬编码在页面或 widget 中
- zh / en 两个分片必须同步添加
- 新 feature 模块：在 `scripts/l10n/arb_tools.dart` 的 `fragmentRules` 中加一行，
  并新建 `{name}_zh.arb` / `{name}_en.arb` 分片对
- 生成物 `lib/l10n/app_localizations*.dart` 已 git-ignore，不要手工编辑；
  本地验证通过 `dart run scripts/contract/bootstrap.dart` 再生
