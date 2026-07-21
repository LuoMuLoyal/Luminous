# Luminous 审查回查报告 — 2026-07-21

**回查日期**: 2026-07-21  
**回查来源**: 2026-07-20 审查报告  
**代码版本**: 87d4f2d5（无新 commit）

---

## 回查范围

读取 2026-07-20 审查报告中标记的 1 项 🔴 严重问题和 4 项 🟡 警告问题，在仓库中逐条验证修复状态。

---

## 🔴 严重问题

### 1. 公共分享页错误提示误导用户 — 所有错误都显示"链接已过期"

- **文件**: `lib/features/report/presentation/pages/clinic_summary_shared.dart`
- **行号**: 51
- **修复状态**: ❌ 未修复

```dart
// 当前代码（第 46-55 行）
error: (_, __) => AppStateErrorView(
  title: l10n.reportClinicSummarySharedExpired,  // "链接已过期或无效"
  description: l10n.reportClinicSummaryLoadFailed,
  icon: FLucideIcons.triangleAlert,
  tone: AppStateTone.warning,
),
```

**验证说明**: 网络断开、服务器 500、token 过期等所有错误场景仍统一显示"链接已过期或无效"，用户无法区分是网络问题还是链接真的失效，会导致不必要的重新生成分享链接操作。

**剩余风险**: 用户在弱网环境下会误以为分享链接失效，放弃重试并重新生成链接，增加后端无效请求。

---

## 🟡 警告问题

### 2. PDF 下载逻辑在多处重复 — 维护隐患

- **文件**:
  - `lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`
  - `lib/features/report/presentation/pages/clinic_summary_shared.dart`
- **修复状态**: ❌ 未修复

**验证说明**: 两段代码仍保持几乎完全相同的逻辑：Dio 请求 → 判空 → 写临时文件 → SharePlus 分享。仅 API endpoint、文件名模板、分享标题不同。后续若需修改下载逻辑（如添加进度条、修复文件泄漏），仍需改两处，遗漏风险持续存在。

**剩余风险**: 重复代码导致维护成本增加，一处修改容易遗漏另一处。

---

### 3. 通知列表 hover 状态管理使用 setState — 频繁 rebuild 隐患

- **文件**: `lib/features/notification/presentation/widgets/shared/list_item.dart`
- **行号**: 55-56
- **修复状态**: ❌ 未修复

```dart
onEnter: (_) => setState(() => _isHovered = true),
onExit: (_) => setState(() => _isHovered = false),
```

**验证说明**: 鼠标在通知列表项上移动时仍频繁触发 `setState`，重建整个列表项 widget。虽然当前列表项不复杂，但快速滚动时仍会造成不必要的重建开销。

**剩余风险**: 列表项数量增多或动画变复杂时，性能问题会显现。

---

### 4. `_formatDateTime` 和 `_MetaRow` 在两个文件中重复定义

- **文件**:
  - `lib/features/report/presentation/widgets/shared/clinic_summary_content.dart:188-193` / `214-238`
  - `lib/features/report/presentation/widgets/dialogs/suggestion_history_detail_sheet.dart:218-223` / `228-252`
- **修复状态**: ❌ 未修复

**验证说明**: 两个文件中仍各自定义了完全相同的 `_formatDateTime` 方法和结构一致的 `_MetaRow` widget（80px 固定 label 宽度的横向键值布局）。项目内已有 `lib/core/utils/date_format_utils.dart` 提供日期格式化工具，但未复用。

**剩余风险**: 若需统一调整日期格式或元数据行样式，需修改多处，容易遗漏。

---

### 5. 分享失败时错误消息拼接格式不一致

- **文件**: `lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`
- **行号**: 197
- **修复状态**: ❌ 未修复

```dart
'${l10n.reportExportFailedToast}: ${error.message}',
```

**验证说明**: 硬拼接的英文冒号 `: ` 仍保留在代码中。中文 locale 下显示为"分享失败: 网络错误"，中英文混合格式不协调。

**剩余风险**: 低，但影响产品 polish 度。

---

## 新代码检查

2026-07-20 至 2026-07-21 期间 Luminous 仓库无新 commit，未引入新的 🔴/🟡 级别问题。

---

## 总结

2026-07-20 审查报告中标记的 **全部 5 项问题（1 个 🔴 + 4 个 🟡）目前均未修复**。代码版本停留在 `87d4f2d5`，无后续修复 commit。

| 问题 | 级别 | 状态 |
|------|------|------|
| 公共分享页错误提示误导用户 | 🔴 | ❌ 未修复 |
| PDF 下载逻辑多处重复 | 🟡 | ❌ 未修复 |
| Hover setState 频繁重建 | 🟡 | ❌ 未修复 |
| `_formatDateTime` / `_MetaRow` 重复定义 | 🟡 | ❌ 未修复 |
| 错误消息拼接格式不一致 | 🟡 | ❌ 未修复 |

---

*报告生成时间: 2026-07-21 03:07 (Asia/Shanghai)*
