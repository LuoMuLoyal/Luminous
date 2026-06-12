# Goal

把当前仍然值得补的前端测试缺口收敛成一轮可独立执行的小计划，不打断主线业务推进。

## Scope

仅处理当前 `Luminous` 已确认、且与现有真实合同/真实页面直接相关的测试缺口：

1. `UserSettingsController` toggle flows
2. `DataExportController` request/refresh flow
3. health-context 写接口 HTTP-layer tests beyond payload serialization
4. Report weekly AI summary local state / request-path coverage

不在这轮里处理：

- 已完成的 `ReportRemoteDataSource` request path
- 新功能开发
- 睡眠合同/placeholder 业务改造
- AI 架构或 agent 方案

## Assumptions

- Lucent 合同当前以 `docs/openapi.json` 和已生成 `packages/lucent_openapi` 为准。
- 本轮优先补单元/仓储/HTTP 层测试，不新建额外 E2E lane。
- 只验证当前真实行为，不顺手重构页面或 provider 结构。

## Affected Areas

- `test/settings/`
- `test/mine/` or `test/settings/` if data-export UI/controller tests live there
- `test/health_context/`
- `test/report/`
- related frontend data/controller files under:
  - `lib/features/settings/`
  - `lib/features/mine/`
  - `lib/features/health_context/`
  - `lib/features/report/`

## Milestones

1. **UserSettingsController**
   - cover initial load -> toggle -> optimistic/pending -> success path
   - cover remote failure rollback/error path if current implementation supports it
   - verify AI summaries and relevant privacy/report-sharing toggles do not drift from controller state

2. **DataExportController**
   - cover request submit success path
   - cover refresh/latest-status reload path
   - cover duplicate/pending/error state handling if current controller exposes it

3. **Health-context HTTP-layer**
   - extend beyond current payload-serialization-only confidence
   - verify create/update/delete request method, path, and key field mapping for:
     - profile
     - allergy
     - condition
     - current medicine
   - keep tests at remote-data-source/repository boundary; do not duplicate widget coverage

4. **Report weekly AI summary**
   - add raw request-path coverage for `ReportAiSummaryRemoteDataSource`
   - add controller/provider coverage for:
     - signed-out idle path
     - `aiSummariesEnabled=false` disabled path
     - loading -> success path
     - backend `403` -> disabled path
     - backend failure -> local error state with previous summary retention
   - if the current widget/page test file stays readable, extend `test/report/report_page_test.dart`
   - if it starts mixing too many concerns, split into:
     - `test/report/report_ai_summary_provider_test.dart`
     - `test/report/report_ai_summary_widget_test.dart`

5. **Verification**
   - run only the touched test files while iterating
   - finish with:
     - `flutter test`
     - `flutter analyze`

## Suggested File Targets

- `test/settings/settings_flow_test.dart`
- new `test/settings/user_settings_controller_test.dart` if current file is too mixed
- new `test/mine/data_export_controller_test.dart` or colocated settings export test file depending on current ownership
- extend `test/health_context/health_context_repository_test.dart` or split into narrower remote-data-source/request-path tests if the file is already too broad
- new `test/report/report_ai_summary_provider_test.dart`
- new `test/report/report_ai_summary_remote_data_source_test.dart`

## Expected Observable Result

- 剩余测试缺口从“控制器/HTTP 层还有空白”变成“核心用户设置、导出状态、健康档案写操作都有明确自动化保护”。
- Report weekly AI summary 不再只靠仓储映射和页面 smoke 覆盖，而是把 request-path 和局部状态机也补上自动化保护。
- 主线业务可以继续推进 AI 总结与真实健康闭环，而不是被基础回归风险反复打断。
