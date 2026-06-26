# 2026-06-26 Bottom Sheet 统一改为弹窗 / 侧边栏

## 目标

统一 Luminous 的弹窗交互范式，减少底部弹出滥用，改善 Record 等页面的移动端体验。

## 改造范围

全部 10 处 `showModalBottomSheet` 调用统一改造：

| 原组件 | 新组件 | 交互形态 |
|---|---|---|
| `RecordFastEntrySheet` | `RecordFastEntryDialog` | 系统 `AlertDialog` |
| `RecordNlpSheet` | `RecordNlpDialog` | 自定义居中弹窗（手机 90% 宽 / 平板最大 600dp / 最大高度 85%） |
| `showMedicineReminderDeleteSheet` | `showMedicineReminderDeleteDialog` | 标准 `AlertDialog` |
| `showMedicineAddPrecheckSheet` | `showMedicineAddPrecheckDialog` | 自定义居中弹窗（手机 90% 宽 / 平板最大 480dp / 最大高度 80%） |
| `ReportRangePickerSheet` | `showReportRangePickerDialog` | 系统 `AlertDialog` |
| Settings `_showHelpSheet` / `_showAboutSheet` | `_showHelpDialog` / `_showAboutDialog` | 系统 `AlertDialog` |
| `AssistantRecentConversationSheet` | `AssistantConversationDrawer` | 右侧滑出 `Drawer`（手机 80% 宽 / 平板 360dp） |

## 共享组件调整

- `PageScaffoldShell` 新增 `drawer`、`endDrawer`、`scaffoldKey` 参数；当提供 drawer 时用 `Scaffold` 包裹内容，否则保持原有 `Material` 行为。
- `AssistantPage` 使用 `endDrawer` + `GlobalKey<ScaffoldState>` 打开最近对话侧边栏。

## 删除的旧文件

- `lib/features/record/presentation/widgets/record_fast_entry_sheet.dart`
- `lib/features/record/presentation/widgets/record_nlp_sheet.dart`
- `lib/features/medicine/presentation/widgets/reminder/medicine_reminder_delete_sheet.dart`
- `lib/features/report/presentation/widgets/report_range_picker_sheet.dart`
- `lib/features/assistant/presentation/widgets/assistant_recent_conversation_sheet.dart`

## 行为约定

- 全部弹窗允许点击遮罩关闭 + 返回键关闭。
- 全部弹窗使用 Flutter 默认淡入缩放动画，统一维护。
- 破坏性确认（删除提醒）使用红色按钮的标准 `AlertDialog`。

## 验证

- `flutter analyze`：0 issues
- `flutter test`：全绿
