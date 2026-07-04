# Record 页视觉与组件统一修复计划

> **目标文档位置**：`Luminous/plans/record-page-fixes.md`  
> 当前为 plan-mode 工作草案，获批后将同步落一份到项目内的 `Luminous/plans/` 目录，作为项目计划存档。

## 目标

基于用户反馈“记录页问题比较多”，对 `lib/features/record/presentation/` 下的移动端记录页进行一轮视觉与组件统一收敛。优先使用 Forui 内置组件与已引入的第三方组件（`timeline_tile`），迫不得已再手写；不引入新的重型依赖。

## 已确认的问题

### 1. 快速记录网格（`RecordQuickEntryPanel`）样式混乱

- 当前实现：外层 `FCard.raw` + 内部 2×2 / 1×3 网格，每个格子是 `FButton.raw(variant: outline)` 并强行把背景改成 `colors.background`，再用手写的 `_ShortVerticalDivider` / `_ShortHorizontalDivider` 画分隔线。
- 视觉问题：
  - 每个按钮自带 outline 边框，又与手写分隔线叠加，边界重复、显得脏。
  - 图标外圈是 `FAvatar.raw`（圆形），与整个 App 最近收敛的 pill 胶囊风格不一致。
  - 按钮是 `outline` variant，按下/悬停态跟随 theme，但自定义背景会覆盖默认 hover，交互反馈弱。

### 2. 记录筛选 chips（`RecordMobileFilter`）圆角与 locked 态粗糙

- 当前实现：`_FilterChip` 使用 `FButton.raw(variant: outline)`，手写 `RoundedSuperellipseBorder(borderRadius: sm)`，selected 时手动设置背景/边框色。
- 视觉问题：
  - `sm` 圆角与当前 theme pill 不统一。
  - `locked` 时在 chip 内部再塞一个 `DecoratedBox` 小标签，没有圆角、没有内边距约束，像临时补丁。

### 3. 时间轴条目（`RecordMobileTimeline` / `RecordTimelinePanel`）细节不统一

- 当前实现：
  - 左侧图标外圈是手写 `Container` + `BoxDecoration` + `BorderRadius.circular(level4)`。
  - 右侧 `badgeKey` 用 `FBadge.raw` 包一层手写 `DecoratedBox` + `RoundedSuperellipseBorder(borderRadius: level2)`。
- 视觉问题：
  - 图标外圈圆角 token 与 FAvatar 默认不一致。
  - 右侧 badge 圆角、颜色、字号都像临时标签，和顶部 pill 风格脱节。

### 4. 新建记录页语音输入按钮（`RecordNewEntryPanel`）圆角不统一

- 当前实现：`FButton(variant: ghost)` 但显式覆盖了 `borderRadius.sm` 和 secondary 背景。
- 问题：与 theme pill 不一致；且 `child: Flexible(...)` 放在 FButton 的 child 位置，布局不够稳健。

### 5. （可选）AI 输入条（`RecordAiInputBar`）微调

- 当前实现基本可用：外层 `FCard.raw` + `FTappable` hint + `FBadge.raw` pill + `FButton.icon` 操作。
- 可以顺手把 `FBadge.raw` 换成标准 `FBadge(variant: secondary)`，减少手写装饰。

## 修复方案

### A. 快速记录网格重构（`record_quick_entry_panel.dart`）

**思路**：把“网格”从“按钮”降级为“可点击卡片格子”，去掉重复边框，利用 `FCard.raw` + `AppDivider` 做行列分隔。

1. `_QuickRecordTile` 不再使用 `FButton.raw`，改为 `FTappable` 包裹 `Column`（图标 + 标签）。
   - `FTappable` 提供 hover/pressed 反馈。
   - 图标外圈改用 `FAvatar.raw`（圆形 soft 背景），与 App 其他 avatar 一致。
   - 标签使用 `AppTypographyToken.level5` + `FontWeight.w700`，居中对齐，最多两行。
2. `_QuickRecordGrid2x2` 保持 2 列，但在列之间使用 `AppDivider.vertical()`，行之间使用 `AppDivider()`。
3. `_QuickRecordRow3` 底部 3 列同样使用 `AppDivider.vertical()` 分隔，顶部与上方网格之间用 `AppDivider()`。
4. 移除 `_ShortVerticalDivider` / `_ShortHorizontalDivider`（如果它们只被此处使用则删除文件引用，否则保留但本文件不再使用）。
5. 外层 `FCard.raw` 保持，内边距统一为 `AppSpacingTokens.level5`。

### B. 筛选 chips 重构（`record_mobile_filter.dart`）

**思路**：用标准 `FButton` + theme pill 替换手写 `FButton.raw`，并把 locked 态改成后缀图标。

1. `_FilterChip` 改为：
   - `variant: selected ? FButtonVariant.primary : FButtonVariant.outline`
   - `mainAxisSize: MainAxisSize.min`
   - `size: FButtonSizeVariant.sm`
   - `prefix: locked ? Icon(FLucideIcons.lock, size: 14) : null`
   - `child: Text(label)`
   - 去掉所有手写 `RoundedSuperellipseBorder`、手写背景色、嵌套 `DecoratedBox` 标签。
2. 选中逻辑保持不变：点击已选中 chip 取消筛选回到“全部”。
3. 如果 Forui `FSelectGroup` 能更自然地表达单选，可作为备选；但“全部 / 单类型”的互斥逻辑在现有回调里已经清晰，先用 `FButton` 方案，改动最小。

### C. 时间轴条目统一（`record_mobile_timeline.dart` + `record_timeline.dart`）

**思路**：图标外圈统一用 `FAvatar`，右侧 badge 统一用标准 `FBadge`。

1. `_TimelineRow` / `_TimelineCard` 中的手写图标外圈 `Container` 改为 `FAvatar.raw`：
   - `size: AppSpacingTokens.level8`
   - `style: .delta(backgroundColor: entry.softColor.resolve(colors))`
   - `child: Icon(entry.icon, color: entry.accent.resolve(colors), size: AppSpacingTokens.level5)`
2. 右侧 `badgeKey` 的 `FBadge.raw` + 手写 `DecoratedBox` 改为标准 `FBadge`：
   - `variant: FBadgeVariant.secondary`（或 primary，根据accent 语义）
   - `style: .delta(decoration: .shapeDelta(color: resolvedColor.withValues(alpha: 0.12), shape: RoundedSuperellipseBorder()))`
   - `child: Text(recordCopy(l10n, entry.badgeKey!))`
   - 文字颜色通过 `labelTextStyle` delta 设置。
3. `_TimelineDot` 保持圆形，属于时间轴语义。
4. `_TimelineCard` 的外层 `FCard.raw` 圆角保持 `lg`，这是卡片不是按钮。

### D. 新建记录页语音按钮（`record_new_entry_panel.dart`）

1. 把底部语音输入按钮从 `FButton` ghost + 自定义 sm 圆角改为：
   - `FButton(variant: ghost, mainAxisSize: MainAxisSize.max, prefix: Icon(FLucideIcons.mic), child: Text(...))`
   - 通过 `style.delta` 只改背景色（`colors.secondary.withValues(alpha: 0.18)`）和 padding，**不传 `borderRadius`**，让 theme pill 生效。
2. 移除 `child: Flexible(...)`，直接用 `Text`；`mainAxisSize: MainAxisSize.max` 已经占满。

### E. AI 输入条微调（`record_quick_entry_panel.dart`）

1. 把 `FBadge.raw` 包裹的手写 pill badge 替换为标准 `FBadge(variant: secondary)`，文字颜色通过 `style.delta(labelTextStyle: .delta(color: colors.primary))` 微调。
2. 保留 `_IconActionButton` 的 `FButton.icon` 不变，已经符合 theme。

## 文件改动清单

| 文件 | 改动 |
|------|------|
| `lib/features/record/presentation/widgets/sections/record_quick_entry_panel.dart` | 重构 `_QuickRecordTile`/`_QuickRecordGrid2x2`/`_QuickRecordRow3`；用 `FTappable` + `FAvatar` + `AppDivider` 替换 `FButton.raw`；简化 AI badge |
| `lib/features/record/presentation/widgets/sections/record_mobile_filter.dart` | `_FilterChip` 改用标准 `FButton`；移除手写 decoration；locked 用前缀锁图标 |
| `lib/features/record/presentation/widgets/sections/record_mobile_timeline.dart` | 图标外圈改 `FAvatar`；badge 改标准 `FBadge` |
| `lib/features/record/presentation/widgets/sections/record_timeline.dart` | 桌面端时间轴同步：图标外圈改 `FAvatar`；badge 改标准 `FBadge` |
| `lib/features/record/presentation/widgets/sections/record_new_entry_panel.dart` | 语音按钮移除显式圆角，改用 theme pill |

## 验收标准

1. `flutter analyze`：No issues found!
2. `flutter test test/record`：现有通过用例不回落；若测试依赖旧实现细节则同步更新。
3. 移动端 Record 页截图检查：
   - 快速记录网格无重复边框，分隔线清爽。
   - 筛选 chips 为统一 pill 圆角，locked 态显示锁图标而不是嵌套方块。
   - 时间轴图标外圈与 App 其他 avatar 一致，右侧 badge 为统一 pill。
   - 语音输入按钮为 pill 圆角。

## 风险与回退

- **风险**：`_QuickRecordTile` 从 `FButton` 改为 `FTappable` 后，键盘焦点/语义可能略有变化；需要确认 `FTappable` 的 `semanticsLabel` 正确。
- **回退**：若 `FTappable` 方案在测试中表现不佳，可回退为 `FButton(variant: ghost)` + `style.delta` 只覆盖背景，保留 theme pill。

## 备注

- 本计划不涉及 Record 创建/编辑表单页、桌面端 `RecordSummaryGrid` 的大结构改动。
- 不引入新依赖；所有改动基于现有 `forui`、`timeline_tile` 和项目内组件。
