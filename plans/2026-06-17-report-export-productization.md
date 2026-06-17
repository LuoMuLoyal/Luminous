# Goal

把现有“已经是真导出”的报表导出能力收口成一个更像成品的切片，而不是继续停留在“后端能吐 PDF，前端能点一下”的证明状态。

## Scope

这轮只做报表/导出产品化第一阶段，不重新定义 MVP，也不扩张到新平台：

- 统一 Report 与 Mine 的导出状态表达
- 收紧导出生命周期文案和页面反馈
- 明确下载链接缺失/过期时的边界提示
- 保持当前三种真实 PDF 导出能力：
  - `hospital + pdf + last_7_days`
  - `monthly + pdf + last_30_days`
  - `print + pdf + last_7_days`

不做：

- 新增 docx、图片、分享链接、历史列表
- 改 Web 端
- 引入新的报告类型
- 重新设计导出后端合同

## Assumptions

- 这是判断：当前导出最大的问题已经不是“假按钮”，而是“状态不够清楚、Report 和 Mine 的说法不够一致、完成但打不开链接时体验太像失败”。
- Lucent 当前合同足够支撑第一轮产品化，不需要先改 OpenAPI。

## Affected Areas

- `lib/features/report/presentation/pages/report_page.dart`
- `lib/features/report/presentation/widgets/report_sections.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/providers/data_export_controller.dart`
- `lib/l10n/*.arb`
- `test/report/report_page_test.dart`
- `test/settings/settings_page_test.dart`
- `docs/Current_State.md`
- `docs/Next_Plan.md`
- `docs/TODO.md`

## Milestones

1. **状态模型收口**
   - Report 与 Mine 使用同一套导出状态理解：`requested / processing / completed / failed / unavailable`
   - 对 completed-but-no-link 保持单独提示，不把它伪装成正常完成

2. **前端反馈收口**
   - Report 导出点击后的 toast 更明确
   - Mine 导出入口不再只显示粗粒度“处理中/完成/失败”
   - 能清楚看出当前是最新一次导出状态，而不是笼统的功能入口

3. **验证补齐**
   - 补最小 widget/unit tests 覆盖关键状态
   - 跑 repo-safe 检查

## Validation

- `flutter test test/report/report_page_test.dart`
- `flutter test test/settings/data_export_controller_test.dart`
- `flutter test test/settings/settings_page_test.dart`
- `flutter analyze`

## Observable Done

- Report 页三张导出卡片仍然是真入口，但用户能明确区分“请求已提交”“正在处理”“已完成并尝试打开”“已完成但链接失效/缺失”“失败/不可用”。
- Mine 设置页的导出行不再像一个历史遗留入口，而是和 Report 的真实导出合同一致。
- 文档里不再同时出现“导出已经是真能力”和“真实导出还没做完”这种冲突说法。
