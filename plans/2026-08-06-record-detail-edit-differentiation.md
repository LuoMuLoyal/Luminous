# 记录详情页 / 编辑页 区分度精进方案

## 背景

Record 模块的**详情页**（`lib/features/record/presentation/pages/detail.dart`）与**编辑页**
（`lib/features/record/presentation/pages/edit.dart`）共用同一套页面框架
（`PageScaffold` + `ResponsiveContentFrame` + 单列 `FCard`），视觉骨架高度同构，
用户在两者之间跳转时缺少「只读 / 可写」的形式语言暗示，操作区主次也不够清晰。

本方案的目标是：**在不动框架层的前提下，通过顶部区域、内容容器、底部操作、状态反馈
四个维度的差异化，让两个页面一眼可分、各司其职。**

## 现状诊断

| # | 问题 | 位置 |
|---|------|------|
| 1 | 框架同构：同为标题顶栏 + 单列白卡片堆叠 | 两页 `PageScaffold` 结构 |
| 2 | 无「只读/可写」暗示：需读完内容才能分辨页面 | 详情页 label-value 行 vs 编辑页表单 |
| 3 | 操作权重混乱：「编辑」藏在顶栏小图标，详情页底部 4 个满宽 ghost 按钮 | `detail.dart` actions / 底部区 |
| 4 | 图标弱关联：44px 方形 primary 图标与编辑页 FAvatar 形态不一致 | `_KindIcon` vs `RecordKindIconField` |

## 角色定位

- **详情页 = 记录快照（读）**：信息完整、一屏即懂；操作是次要的。
- **编辑页 = 编辑工作台（写）**：输入优先、保存主导；其余一切降权。

## 分维度方案

### 1. 顶部区域（第一眼区分）

**详情页 → Hero 头部**
- 类型图标放大为 52px 圆形 `FAvatar`，背景用 `action.softColor.subtle(context)`、
  图标色用 `action.accent.solid(context)`（与快速记录瓦片同源）。
- 图标解析复用 `resolveQuickActionIcon`，保证用户自定义图标在详情页延续。
- 标题 + 时间下方新增**来源徽章**（手动 / 本地 / AI / 导入，复用 `_sourceLabel` 映射），
  用弱化 FBadge 呈现。

**编辑页 → 编辑模式标识**
- 保持紧凑表单头（日期/时间字段）不变。
- 表单区顶部新增一行轻量提示：「修改后点击保存生效」。
- dirty 时替换为警告色胶囊「有未保存的更改」，与已有返回丢弃确认对话框呼应。

### 2. 内容容器（读 vs 写）

**详情页 → 票据式信息卡**
- 保留现有 `_DetailRows` 的 label 左列 muted / value 右列加粗结构。
- 核心数值（如 `500 ml`）单独一行大字号呈现（level6/display），强调快照关键数字。
- 行间细分隔线，压缩留白密度。

**编辑页 → 表单面板**
- 时间 / 数值 / 单位 / 备注 / 图标 / 结构化字段 / 图片统一收进一个 `FCard`。
- 字段使用现有 `FTextField` 默认态，焦点高亮。
- 表单面板背景可选用 `colors.secondary`（浅灰底衬），与页面背景产生层次，
  一眼看出「这里是输入区」。

### 3. 底部操作区（主次与危险区）

**详情页**
- 「编辑这条记录」升级为 **primary 满宽按钮**（复用 `editRecord` usecase），成为页面主操作；
  顶栏编辑图标移除。
- 上一条 / 下一条 并排 ghost 小按钮，视觉降权。
- 复制摘要 → ghost 弱化。
- 删除 → destructive 置底，与编辑页危险区位置一致。

**编辑页**
- 保持「保存修改」primary 满宽 +「删除记录」destructive（现状已合理），
  统一间距与文案风格即可。

### 4. 状态与反馈（强化心智）

- 详情页：饮食分析中 / 失败徽章保留；更新时间弱化展示保留。
- 编辑页：dirty 提示条（见维度 1）+ 已有 `PopScope` 返回拦截，形成
  「修改 → 提示 → 确认丢弃」闭环。

### 5. 一致性保障

- 两页继续共用 `PageScaffold` / `ResponsiveContentFrame`，不动框架。
- 类型图标同源（`resolveQuickActionIcon`），同一条记录两页图标一致。
- 全部走现有 token（Spacing / TypographyToken / SemanticColor / FButton variant），
  不引入新视觉语言。

## 决策记录（2026-08-06 与用户确认）

| 决策点 | 结论 |
|--------|------|
| 详情页「编辑」入口位置 | **页面内 primary 主按钮**，顶栏图标移除 |
| 编辑页「未保存更改」提示条 | **加提示条**（警告色，配合已有丢弃确认） |
| 实施节奏 | **先出方案文档**（本文件），代码改动后续分批实施 |

## 实施完成（2026-08-06）

两批均已实施并通过验证（`flutter analyze` 0 issues、`test/record/` 全绿），迁移日志与状态文档已同步；第二批暂未提交（用户要求）。详细改动见 `docs/03-logs/migration-log/2026-08-06.md`。
