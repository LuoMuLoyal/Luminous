# 记录页移动端输入区 & 时间线条目重构计划

> 创建日期: 2026-07-27
> 涉及项目: Luminous (前端)
> 关联文件: `lib/features/record/presentation/`

---

## 一、背景与决策

### 1.1 产品职责重新判定

根据 `docs/01-product/Product_Tab_Component_Blueprint.md`，Record tab 的职责是"原始事实写入与回看"，首屏组件清单为：

1. 快速记录区（症状、用药、饮水、饮食、睡眠、情绪/备注）
2. 自然语言入口（文本输入、候选记录确认）
3. 日期条 / 时间范围入口
4. 记录筛选区
5. 记录时间线区

### 1.2 语音 & OCR 功能移除决策

经过产品文档对照和功能可行性分析，语音和 OCR 两个功能被移除：

- **OCR（拍照 → 文字 → NLP）**: 功能逻辑不成立。用户不会把"今天头疼，喝了两杯水"这样的自然语言写在纸上再拍照。能拍到的文字（药品说明书、处方、体检报告）是结构化/半结构化文档，不是 NLP 管道能解析的自然语言叙述。

- **语音（STT → 文字 → NLP）**: 链路结构合理，但当前使用 `speech_to_text` 平台原生 STT，对中文医疗词汇（药名、症状术语）的准确率无法保证。短期无法在不改后端的前提下解决质量问题。

两个功能均属产品文档中的"合同门控项"（`Product_MVP_Scope.md`），不应在当前阶段作为首屏入口展示。

### 1.3 NLP 入口位置决策

砍掉语音和 OCR 后，`RecordAiInputBar` 这个独立区域不再需要。NLP 入口移至 header 右上角，替换原来的 `+` 按钮（`+` 跳转的 `/record/create` 完整创建表单已由每个快速记录 tile 的 fast-entry dialog "更多"按钮覆盖）。

---

## 二、现状分析

### 2.1 AI 输入栏（RecordAiInputBar）— 将被移除

**文件**: `presentation/widgets/sections/quick_entry_panel.dart` L20–120

**问题**:
1. **语义混淆**: 视觉上像搜索框（单行文本 + 图标 + 右侧操作按钮），但实际是 NLP 弹窗触发器。
2. **溢出风险**: Row 中 sparkles(24) + gap(16) + badge(~44) + gap(4) + micButton(~36) + cameraButton(~36) ≈ 160px 固定宽度，compact 断点下 Expanded 空间不足。
3. **视觉层级混乱**: sparkles + "AI" 徽标 + 麦克风 + 相机四个元素挤在一行。

### 2.2 NLP 弹窗（RecordNlpDialog）— 将重构为 Sheet

**文件**: `presentation/widgets/dialogs/nlp_dialog.dart`

**问题**:
1. **盒子套盒子**: `FDialog`（自带卡片装饰）→ `FTextField`（自带边框）→ `RecordNlpCandidateReview`（内嵌 FCard）。
2. **弹窗内容溢出**: `maxHeight` 未设置，候选列表较长时可能超出屏幕。

### 2.3 语音 Sheet — 将被删除

**文件**: `presentation/widgets/dialogs/voice_entry_dialog.dart`

**问题**: 背景透明、固定高度 380px、交互割裂（sheet → dialog）。

### 2.4 OCR Sheet — 将被删除

**文件**: `presentation/widgets/dialogs/ocr_entry_dialog.dart`

**问题**: 同语音 Sheet，且功能逻辑不成立。

### 2.5 时间线图标背景太黑

**文件**: `presentation/widgets/sections/mobile_timeline.dart` L220

```dart
color: entry.softColor.solid(context),  // ← BUG
```

**根因**: `entry.softColor` 硬编码为 `SemanticColor.neutral`，`neutral.solid()` = `mutedForeground`（深灰/黑）。`solid()` 是全饱和前景色，不应做背景。对比 `_QuickRecordTile` 正确使用 `action.softColor.subtle(context)`。

### 2.6 时间线条目未按时间排序

**文件**: `data/repositories/lucent.dart` L60

```dart
final timeline = records.map(_toTimelineEntry).toList();
```

无客户端排序，完全依赖后端返回顺序。

### 2.7 时间线条目内容显示需精修

**文件**: `presentation/widgets/sections/mobile_timeline.dart` `_TimelineRow`

1. 冗余 `SkeletonText`（`isLoading` 始终为 false，shimmer 功能无用）。
2. badge 区域 `SkeletonSlot` + `FBadge.raw` + `DecoratedBox` 嵌套过深。
3. 图标容器圆角 `RadiusTokens.level4` 与整体不协调。
4. 时间标签宽度 32px 不足以稳定显示 "14:30"。

---

## 三、重构方案

### 3.1 移除语音 & OCR 功能

**删除文件**:
- `presentation/widgets/dialogs/voice_entry_dialog.dart`
- `presentation/widgets/dialogs/ocr_entry_dialog.dart`
- `domain/services/voice_recording.dart`
- `core/i18n/speech_locale_resolver.dart`（仅被 voice_entry_dialog 引用）

**删除代码**:
- `page.dart` 中的 `_openVoiceEntry()` / `_openOcrEntry()` 方法
- `page.dart` / `dashboard_view.dart` 中的 `onMicTap` / `onCameraTap` 回调
- `quick_entry_panel.dart` 中 `RecordAiInputBar` 的 `onMicTap` / `onCameraTap` 参数

**删除测试**:
- `test/record/voice_recording_test.dart`

**删除依赖**:
- `pubspec.yaml` 中 `speech_to_text` 依赖（仅 record feature 使用，已确认无其他引用）

**SDK 列表更新**:
- `assets/legal/sdk-list_zh.md` / `sdk-list_en.md` 中移除 speech_to_text 条目

### 3.2 移除 RecordAiInputBar，NLP 入口移至 Header

**移除**: `quick_entry_panel.dart` 中的 `RecordAiInputBar` 类整体删除。

**Header 变更**（`page.dart`）:

移动端 header 的 `+` 按钮替换为 NLP 入口：

```dart
// Before
RecordHeaderActionChip(
  key: const Key('record-add-action'),
  label: l10n.recordAddCompactAction,
  icon: FLucideIcons.plus,
  emphasized: true,
  onTap: () => pushAuthRequiredRoute(context, '/record/create?date=...'),
  iconOnly: true,
)

// After
RecordHeaderActionChip(
  key: const Key('record-nlp-action'),
  label: l10n.recordNlpHeaderAction,  // 新文案: "智能记录" / "AI 记录"
  icon: FLucideIcons.sparkles,
  emphasized: true,
  onTap: () => _openNlpSheet(context, ...),
  iconOnly: true,
)
```

**图标选择**: 用 `sparkles` 而非 `mic` —— 这是一个纯文字输入入口，麦克风图标会误导用户期望语音功能。

**回调精简**: `RecordDashboardView` 和 `_MobileRecordDashboard` 中移除 `onAiInputTap` / `onMicTap` / `onCameraTap`，NLP 入口由 header 直接触发，不再经过 dashboard view 传递。

### 3.3 NLP Dialog → Bottom Sheet 重构

**目标**: 消除"盒子套盒子"，统一为底部 sheet。

**新建**: `presentation/widgets/dialogs/nlp_sheet.dart`，替代 `nlp_dialog.dart`。

**新结构**:
```
showFSheet (btt, useSafeArea, resizeToAvoidBottomInset)
  └─ _RecordNlpSheet (HookConsumerWidget)
       └─ DecoratedBox (bg: colors.background, border: top)
            └─ Column
                 ├─ SheetDragHandle
                 ├─ _SheetHeader (标题 + 关闭按钮)
                 ├─ Expanded → SingleChildScrollView
                 │    └─ Padding
                 │         └─ Column
                 │              ├─ FTextField (无 label, 仅 hint, minLines:3)
                 │              ├─ Row(重置 + 生成)
                 │              ├─ [条件] RecordNlpCandidateReview
                 │              └─ [条件] error / progress
                 └─ _SheetFooter (保存按钮, 固定在底部)
```

**关键变更**:
- 外层 `DecoratedBox` 显式设置 `colors.background` 背景 + 顶部边框，解决透明背景问题。
- `FTextField` 移除 `label`，只用 `hint`，减少视觉嵌套。
- 保存按钮固定在 sheet 底部，不随内容滚动。
- 候选列表区域用 `Column` 直接排列，不再嵌套 `FCard`。
- 用 `mainAxisMaxRatio` 替代固定高度，让 sheet 按屏幕比例自适应。

**调用方变更**（`page.dart`）:
```dart
// Before
Future<void> _openNlpDialog(BuildContext context, ...) async {
  ...
  await showAppDialog<void>(
    context: context,
    builder: (dialogContext) =>
        RecordNlpDialog(occurredAt: formatRecordDate(selectedDate)),
  );
}

// After
Future<void> _openNlpSheet(BuildContext context, ...) async {
  ...
  await showFSheet<void>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    builder: (sheetContext) => RecordNlpSheet(
      occurredAt: formatRecordDate(selectedDate),
    ),
  );
}
```

**删除**: 原 `nlp_dialog.dart` 文件（功能完全由 `nlp_sheet.dart` 替代）。

### 3.4 时间线图标背景修复

**文件**: `mobile_timeline.dart` L220

```dart
// Before
color: entry.softColor.solid(context),

// After
color: entry.softColor.muted(context),
```

**理由**: `muted()`（alpha 0.10/0.18）是 chips/badges/小图标容器的设计语义，在 32px 容器上视觉合适。`solid()` 是全饱和前景色，不应做背景。

### 3.5 时间线条目排序

**文件**: `data/repositories/lucent.dart` L60

在 `records` 列表上直接排序（map 前）:

```dart
final sortedRecords = List<DailyRecordItem>.from(records)
  ..sort((a, b) {
    final ta = a.occurredTime ?? a.occurredAt;
    final tb = b.occurredTime ?? b.occurredAt;
    return tb.compareTo(ta);
  });
final timeline = sortedRecords.map(_toTimelineEntry).toList();
```

**理由**: 在原始 `DailyRecordItem` 上排序比在格式化后的 `RecordTimelineEntry.time` 字符串上排序更健壮。`occurredTime` 是 "HH:mm:ss" 格式，字典序与时间顺序一致。

### 3.6 时间线条目内容精修

**文件**: `mobile_timeline.dart` `_TimelineRow`

1. **移除 `SkeletonText` → `Text`**: `SkeletonScope` 在时间线区域 `isLoading` 始终为 false（loading 时显示 `RecordSkeletonView`），shimmer 功能无用。
2. **移除 badge 的 `SkeletonSlot` 包装**: 直接用 `FBadge.raw` + `DecoratedBox`。
3. **图标容器圆角**: `RadiusTokens.level4` → `RadiusTokens.level3`，与 `FAvatar` 风格统一。
4. **时间标签宽度**: `Spacing.level8`(32px) → 44px，稳定显示 "14:30"。
5. **subtitle 格式**: 保持 `[value, detail].join(' · ')`，确保 detail 不重复 value 信息。

---

## 四、实施步骤

### 阶段 1: 移除语音 & OCR（低风险，纯删除）

| 步骤 | 文件 | 内容 |
|------|------|------|
| 1.1 | `page.dart` | 删除 `_openVoiceEntry()` / `_openOcrEntry()` 方法 |
| 1.2 | `page.dart` / `dashboard_view.dart` | 删除 `onMicTap` / `onCameraTap` 回调和参数 |
| 1.3 | `voice_entry_dialog.dart` | 删除文件 |
| 1.4 | `ocr_entry_dialog.dart` | 删除文件 |
| 1.5 | `domain/services/voice_recording.dart` | 删除文件 |
| 1.6 | `core/i18n/speech_locale_resolver.dart` | 删除文件（仅被 voice_entry_dialog 引用） |
| 1.7 | `test/record/voice_recording_test.dart` | 删除文件 |
| 1.8 | `pubspec.yaml` | 移除 `speech_to_text` 依赖 |
| 1.9 | `assets/legal/sdk-list_zh.md` / `sdk-list_en.md` | 移除 speech_to_text 条目 |

### 阶段 2: 移除 RecordAiInputBar，NLP 入口移至 Header

| 步骤 | 文件 | 内容 |
|------|------|------|
| 2.1 | `quick_entry_panel.dart` | 删除 `RecordAiInputBar` 类 |
| 2.2 | `dashboard_view.dart` | 移除 `onAiInputTap`，移除 `_MobileRecordDashboard` 中的 `RecordAiInputBar` 渲染 |
| 2.3 | `page.dart` | header `+` 按钮替换为 sparkles NLP 入口 |
| 2.4 | l10n fragment (`record_zh.arb` / `record_en.arb`) | 新增 `recordNlpHeaderAction` 文案 |
| 2.5 | 执行 l10n 合并 | `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` |

### 阶段 3: NLP Dialog → Sheet 重构

| 步骤 | 文件 | 内容 |
|------|------|------|
| 3.1 | 新建 `widgets/dialogs/nlp_sheet.dart` | 基于 bottom sheet 的 NLP 输入 + 候选确认 |
| 3.2 | `page.dart` `_openNlpDialog` | 改为 `_openNlpSheet`，调用 `showFSheet` |
| 3.3 | 删除 `widgets/dialogs/nlp_dialog.dart` | 功能完全由 nlp_sheet 替代 |

### 阶段 4: 时间线修复

| 步骤 | 文件 | 内容 |
|------|------|------|
| 4.1 | `mobile_timeline.dart` L220 | `softColor.solid` → `softColor.muted` |
| 4.2 | `lucent.dart` L60 | 添加时间倒序排序 |
| 4.3 | `mobile_timeline.dart` `_TimelineRow` | 移除 `SkeletonText` → `Text`，移除 `SkeletonSlot` 包装 badge，图标圆角 level4 → level3，时间标签宽度 → 44 |

---

## 五、涉及文件清单

| 文件 | 操作 |
|------|------|
| `presentation/widgets/sections/quick_entry_panel.dart` | 删除 `RecordAiInputBar` 类 |
| `presentation/widgets/sections/mobile_timeline.dart` | 修复图标背景、精修条目 |
| `presentation/widgets/dialogs/nlp_dialog.dart` | **删除**，由 nlp_sheet 替代 |
| `presentation/widgets/dialogs/nlp_sheet.dart` | **新建** |
| `presentation/widgets/dialogs/voice_entry_dialog.dart` | **删除** |
| `presentation/widgets/dialogs/ocr_entry_dialog.dart` | **删除** |
| `domain/services/voice_recording.dart` | **删除** |
| `core/i18n/speech_locale_resolver.dart` | **删除** |
| `data/repositories/lucent.dart` | 添加排序 |
| `presentation/widgets/views/dashboard_view.dart` | 移除 AI 输入栏相关回调 |
| `presentation/pages/page.dart` | Header 改 NLP 入口、删除 voice/ocr 方法、NLP 改 sheet |
| `test/record/voice_recording_test.dart` | **删除** |
| `pubspec.yaml` | 移除 `speech_to_text` 依赖 |
| `assets/legal/sdk-list_zh.md` / `sdk-list_en.md` | 移除 speech_to_text 条目 |
| l10n fragment (`lib/l10n/src/record_zh.arb` / `record_en.arb`) | 新增 `recordNlpHeaderAction` 文案 |

---

## 六、验收标准

1. **语音/OCR 完全移除**: 无残留文件、无残留引用、无残留依赖、无残留测试。
2. **Header NLP 入口**: 右上角为 sparkles 图标按钮，点击弹出 bottom sheet。图标为 `sparkles` 而非 `mic`。
3. **无 RecordAiInputBar**: 首屏不再有独立的 AI 输入栏区域。快速记录区恢复原样（note 保持整行）。
4. **NLP Sheet**: 以底部 sheet 展示，背景不透明（`colors.background`），无"盒子套盒子"，保存按钮固定底部，内容可滚动。
5. **图标背景**: 时间线图标容器背景为浅色 tint（`muted` tone），不再是黑色/深灰。
6. **时间排序**: 时间线条目按时间倒序排列（最新在最上方）。
7. **条目精修**: 无冗余 `SkeletonText`/`SkeletonSlot`，badge 简洁，图标圆角统一。
8. **flutter analyze**: 0 issues。
9. **现有测试**: `flutter test` 全部通过（删除 voice_recording_test 后无引用错误）。

---

## 七、风险与注意事项

1. **Forui FSheet 背景行为**: 需确认 `showFSheet` 在当前 Forui 版本下是否提供默认背景。如果不提供，NLP sheet 的 `DecoratedBox` 是必须的。
2. **l10n 文案**: 新增的 `recordNlpHeaderAction` 需要同时更新 `record_zh.arb` 和 `record_en.arb` fragment 文件，然后执行 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n`。
3. **NLP Dialog → Sheet 迁移**: `RecordNlpDialog` 被 `page.dart` 的 `_openNlpDialog` 调用。迁移时需确保调用点更新，避免遗留引用。
4. **测试更新**: 如果有测试引用了 `RecordNlpDialog` 或 `showAppDialog` 调用路径，需同步更新为 `RecordNlpSheet` + `showFSheet`。
5. **speech_to_text 平台插件清理**: 删除依赖后需执行 `flutter clean` + `flutter pub get`，确保平台插件注册文件（`generated_plugin_registrant.cc` 等）不再包含 speech_to_text。
6. **SDK 列表文档**: `assets/legal/` 下的 SDK 列表是用户可见的隐私合规文档，移除 speech_to_text 条目时需确认格式正确。
7. **桌面端 header**: 桌面端 header 中的 `+` 按钮也需同步处理 —— 桌面端是否也需要 NLP 入口，还是保留 `+` 按钮跳转完整创建表单？需根据桌面端布局决定。
