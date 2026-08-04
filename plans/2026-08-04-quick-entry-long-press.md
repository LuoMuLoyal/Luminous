# 快速记录 — 各类型长按行为计划

## 背景

记录页面的快速记录面板（`RecordQuickEntryPanel`）提供 6 个网格按钮 + 1 个笔记按钮。
每个按钮有 **点击（tap）** 和 **长按（long-press）** 两种交互。

### 交互约定

| 交互 | 语义 |
|------|------|
| **tap** | 快速记录：用默认设置直接写入，或打开该类型的主录入流程 |
| **long-press** | 打开该类型的设置 / 配置面板，或提供替代录入路径 |

---

## 当前状态

### 已完成

| 类型 | tap | long-press |
|------|-----|------------|
| **water** | ✅ 用默认量直接写入 + undo toast | ✅ 弹出设置弹窗（默认量选择 + 徽章显示模式） |
| **meal** | ✅ 相机优先流程 → 确认弹窗 | ✅ 手动无照片录入（替代路径） |

### 未完成 — long-press 仅显示静态规则文本

| 类型 | tap（已完成） | long-press（待做） |
|------|---------------|---------------------|
| **symptom** | ✅ FastEntryDialog（头痛/腹痛/头晕/发烧，多选） | ❌ 当前只显示 `recordQuickSettingsSymptomRule` 文本 |
| **mood** | ✅ FastEntryDialog（😄🙂😐😟😫） | ❌ 当前只显示 `recordQuickSettingsMoodRule` 文本 |
| **sleep** | ✅ sleep flow（start → wake → merge） | ❌ 当前只显示 `recordQuickSettingsSleepRule` 文本 |
| **medication** | ✅ 自动判断（单药直记 / 多药选择 / 无药提示） | ❌ 当前只显示 `recordQuickSettingsMedicationRule` 文本 |
| **note** | ✅ FastEntryDialog（稳定/疲惫/忙碌/恢复） | — 笔记按钮不在网格中，暂不做 long-press |

---

## 目标

为 symptom / mood / sleep / medication 四种类型的 long-press 设计并实现有意义的设置面板，
让长按从"看一段说明文字"升级为"可配置该类型的快速记录行为"。

---

## 各类型长按设计方案

### 1. Symptom — 长按 = 症状快速选项配置

**设计思路**：用户可能关心不同的症状，默认四项不够用或不合适。

**面板内容**：
- 症状快速选项列表（可勾选 / 取消勾选，决定 FastEntryDialog 中出现哪些选项）
- 默认严重程度选择（mild / moderate / severe），影响点击 chip 时的默认 value
- 严重程度用 `FSelect` 下拉，症状选项用 `FTile` + `FSwitch` 或 `FCheckbox`

**偏好存储**（新增到 `QuickEntryPreferences`）：
```dart
// 症状快速选项 enabled 列表，存储 symptom title 字符串列表
final List<String> symptomEnabledChoices;

// 症状默认严重程度
final String symptomDefaultSeverity; // 'mild' | 'moderate' | 'severe'
```

**影响范围**：
- `quick_entry_preferences.dart` — 新增字段 + controller 方法
- `fast_entry_dialog.dart` — `recordFastEntryChoicesFor(symptom)` 读取偏好过滤 / 调整默认值
- `quick_type_settings_dialog.dart` — 新增 `_SymptomSettings` widget
- ARB 文件 — 新增 l10n key

---

### 2. Mood — 长按 = 心情快速记录配置

**设计思路**：与 water 类似，让 tap 可以直接记录默认心情，长按配置默认值。

**方案 A（推荐）— tap 保持弹窗，长按配置默认心情**：
- 长按面板内容：
  - 默认心情级别选择（great / good / okay / bad / terrible）
  - 心情徽章显示模式（今日最新 / 今日平均 / 隐藏）
- tap 行为不变（仍然弹出 FastEntryDialog 让用户选择），但弹窗会高亮默认项

**方案 B（进阶）— tap = 快速记录默认心情，长按 = 设置**：
- 与 water 一致：tap 直接用默认心情级别记录 + undo toast
- 长按打开设置面板
- 风险：用户可能更需要每次选不同心情，直接记录默认值不太实用

**偏好存储**（方案 A）：
```dart
final String moodDefaultLevel; // 'great' | 'good' | 'okay' | 'bad' | 'terrible'
final QuickEntryMoodBadgeMode moodBadgeMode; // latest | average | hidden
```

**影响范围**：同 symptom，额外需要 mood 徽章计算逻辑（在 `quick_entry_panel.dart` 的 `_badgeFor` 中新增 mood case）

---

### 3. Sleep — 长按 = 睡眠记录配置

**设计思路**：sleep 的 tap 已经是 start/wake 智能流程，长按应配置辅助行为。

**面板内容**：
- 睡眠进行中徽章开关（`sleepInProgressBadgeEnabled`，当前仅在设置页可配，长按弹窗也应暴露）
- 默认睡眠时长选择（影响 FastEntryDialog 中 sleep 选项的默认高亮，或未来 tap 直接记录）
  - 选项：6h / 7h / 8h / 9h（复用 `_sleepDurationOptions`）
- 睡眠目标时长（用于徽章显示"已达标"等提示，可选/后续迭代）

**偏好存储**（新增）：
```dart
final int sleepDefaultDurationMinutes; // 默认 480 (8h)
```

**影响范围**：
- `quick_entry_preferences.dart` — 新增 `sleepDefaultDurationMinutes`
- `quick_type_settings_dialog.dart` — 新增 `_SleepSettings` widget
- `fast_entry_dialog.dart` — sleep 选项高亮默认值

---

### 4. Medication — 长按 = 服药快速记录配置

**设计思路**：medication 的 tap 已经有智能判断逻辑，长按应配置默认行为。

**面板内容**：
- "仅一种当前用药时自动记录" 开关（默认开启）
  - 关闭后，即使只有一种药也弹出选择弹窗
- "已全部记录时显示提示而非静默" 开关
- 跳转到药品管理页面的入口（`Routes.medicineSearch`）

**偏好存储**（新增）：
```dart
final bool medicationAutoRecordSingle; // 默认 true
final bool medicationShowAlreadyRecordedHint; // 默认 true
```

**影响范围**：
- `quick_entry_preferences.dart` — 新增字段
- `quick_type_settings_dialog.dart` — 新增 `_MedicationSettings` widget
- `quick_entry_medication.dart` — `handleMedicationQuickAction` 读取偏好控制行为
- `medication_flow.dart` — `MedicationQuickEntryFlow.handleTap` 接受偏好参数

---

## 实施顺序

```
Phase 1 — 基础设施
  └─ 1.1 QuickEntryPreferences 新增所有字段 + controller 方法
  └─ 1.2 PrefKeys 新增对应 key
  └─ 1.3 ARB fragment 文件新增 l10n key + merge + gen-l10n

Phase 2 — 各类型设置面板
  └─ 2.1 QuickEntryTypeSettingsDialog 重构为 switch-by-type
  └─ 2.2 _SymptomSettings
  └─ 2.3 _MoodSettings（含 mood 徽章逻辑）
  └─ 2.4 _SleepSettings
  └─ 2.5 _MedicationSettings

Phase 3 — 偏好联动
  └─ 3.1 FastEntryDialog 读取 symptom / mood / sleep 偏好
  └─ 3.2 medication quick action 读取偏好
  └─ 3.3 quick_entry_panel _badgeFor 新增 mood 徽章

Phase 4 — 设置页同步
  └─ 4.1 QuickEntrySettingsPage 新增对应设置项
  └─ 4.2 确保长按弹窗与设置页双向同步

Phase 5 — 验证
  └─ 5.1 flutter analyze
  └─ 5.2 flutter test（相关 widget / unit test）
  └─ 5.3 文档检查
```

---

## 文件清单

| 文件 | 改动类型 |
|------|----------|
| `lib/features/record/data/quick_entry_preferences.dart` | 新增字段 + controller 方法 |
| `lib/features/record/presentation/widgets/dialogs/quick_type_settings_dialog.dart` | 重构 + 新增各类型 settings widget |
| `lib/features/record/presentation/widgets/dialogs/fast_entry_dialog.dart` | 读取偏好过滤/高亮 |
| `lib/features/record/application/usecases/quick_entry_medication.dart` | 读取偏好控制行为 |
| `lib/features/record/presentation/quick_entry/medication_flow.dart` | handleTap 接受偏好参数 |
| `lib/features/record/presentation/widgets/sections/quick_entry_panel.dart` | mood 徽章逻辑 |
| `lib/features/record/presentation/pages/quick_entry_settings.dart` | 新增设置项 |
| `lib/core/config/pref_keys.dart` | 新增 pref key |
| `lib/l10n/src/record_zh.arb` | 新增 l10n key |
| `lib/l10n/src/record_en.arb` | 新增 l10n key |

---

## 待确认

1. **Mood 方案选择**：方案 A（tap 保持弹窗 + 长按配默认值）vs 方案 B（tap 直接记录默认心情 + 长按设置）？
2. **Medication 自动记录开关**：是否需要"仅一种药时自动记录"开关，还是保持当前行为？
3. **Symptom 选项自定义**：是仅从预设列表中勾选，还是允许用户自定义症状名称？
4. **Note 长按**：是否需要？note 按钮不在网格中，当前无 long-press 回调。
