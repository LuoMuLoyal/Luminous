# Goal

把 sleep 从当前的 placeholder / insufficient-data 状态，收敛成一条最小可用的真实业务链路：

- 用户可以手动新增、查看、编辑睡眠记录
- Today 可以基于真实持久化数据展示 sleep 概览
- Report 可以基于真实数据生成 sleep trend，而不是硬编码零值

# Why This First

- 这不是“以后可能会做”的想法，而是当前 `Today / Record / Report / Settings` 已经同时露出但又彼此矛盾的真实缺口。
- 现在继续做新的 AI 能力，只会建立在一个明显缺口之上。
- 当前不需要兼容旧方案时，尽早收敛 sleep 合同，比继续用 placeholder 拖着更便宜。

# Working Assumptions

- 先做手动录入，不接 Apple Health、Health Connect、穿戴设备。
- 先做最小真实闭环，不做睡眠评分、智能提醒、睡眠阶段分析。
- 当前默认判断：
  - 使用独立的 `DailyRecordKind.sleep`
  - 不复用 `DailyRecordKind.vital` 再靠 `payload` 约定伪装 sleep
- 上面这条是当前实现判断，不是已验证事实。理由是：
  - `Record`、`Today`、`Report` 都已经把 sleep 当作一类一等业务对象，而不是普通 vital
  - sleep 天然需要时间区间、时长、可选质量字段，语义上和零散 vital 不同
  - 如果继续塞进 `vital.payload`，后面筛选、聚合、OpenAPI、前端映射都会更绕

# Affected Repos And Files

## Lucent

- `prisma/schema.prisma`
- `src/modules/daily-records/`
- `src/modules/today-analysis/analysis/today-analysis-context.service.ts`
- `src/modules/reports/dashboard/reports-context.service.ts`
- `src/modules/reports/dashboard/reports-computation.service.ts`
- `src/modules/reports/ai-summary/reports-ai-summary-context.service.ts`
- `docs/openapi.json`
- 如合同/命令变化影响说明：
  - `README.md`
  - `docs/environment.md`
  - `docs/TODO.md`

## Luminous

- `lib/features/record/domain/entities/daily_record.dart`
- `lib/features/record/domain/entities/record_type_mapping.dart`
- `lib/features/record/data/repositories/lucent_record_repository.dart`
- `lib/features/record/presentation/`
- `lib/features/today/data/repositories/lucent_today_repository.dart`
- `lib/features/today/presentation/`
- `lib/features/report/data/repositories/lucent_report_repository.dart`
- `packages/lucent_openapi/` regenerated output
- `docs/Current_State.md`
- `docs/Next_Plan.md`
- `docs/OpenApi_Client.md` if the regeneration boundary changes
- `docs/migration-log/2026-06-13.md` once implementation starts

# Milestones

## 1. Contract Decision And Backend Shape

目标：

- 在 Lucent 中把 sleep 变成真实可持久化的 daily record kind
- 定清 sleep payload 的最小字段

建议的最小字段：

- `startAt`
- `endAt`
- `durationMinutes`
- `quality` 可选
- `note` 可选
- `deepMinutes` 可选（深睡时长）
- `lightMinutes` 可选（浅睡时长）
- `remMinutes` 可选（REM 时长）

动作：

- Prisma 增加 `DailyRecordKind.sleep`
- 创建/更新 daily-record DTO、service、summary 映射
- 明确 sleep 的最小校验规则
- 导出 OpenAPI

可观察结果：

- `DailyRecordKind` 在 Lucent 合同里出现 `sleep`
- `/api/v1/user/daily-records*` 可以真实存取 sleep 记录

## 2. Record Page Real Sleep CRUD

目标：

- Luminous 的 sleep 不再只是锁定占位入口

动作：

- `RecordEntryType.sleep` 真正映射到 `DailyRecordKind.sleep`
- 打通 create / detail / edit / timeline / filter
- 表单只做最小必填，不提前加复杂睡眠分析字段
- 删除或改写之前的 locked placeholder 提示

可观察结果：

- Record 页面可以实际新增一条 sleep
- 同一天 timeline、详情页、编辑页能读回同一条数据

## 3. Today Sleep Summary From Real Data

目标：

- Today 页的 sleep row 不再固定回退 `--`

动作：

- Lucent Today 分析上下文读取当天最近一条或聚合后的 sleep 数据
- Luminous Today repository 用真实返回值映射 sleep
- 如果当天无数据，才显示缺失态

可观察结果：

- 录入当天睡眠后，Today sleep value 有真实值
- 无记录时仍然是明确缺失态，不伪造数值

## 4. Report Sleep Trend From Persisted Data

目标：

- Report dashboard 不再把 sleep trend 硬编码成全零数组

动作：

- Lucent report context 聚合区间内 sleep duration / tracked days
- report computation/presenter 基于真实数据输出 metric/pattern
- Luminous report repository 按合同消费结果，不再依赖“睡眠恒不足”的假前提

可观察结果：

- 有 sleep 数据时，7 天 / 30 天报告里出现真实 sleep sparkline
- 没数据时，仍允许返回 `insufficient_data`

## 5. Tests And Docs

目标：

- 把这次切片收口成可验证、可继续叠代的基线

动作：

- 补 Lucent daily-record、today-analysis、reports 相关测试
- 补 Luminous record/today/report 相关 repository/provider/widget tests
- 更新当前状态与迁移日志

# Validation

## Lucent

```powershell
cd Lucent
pnpm typecheck
pnpm build
pnpm test:ci
pnpm export:openapi
```

如果迭代阶段只跑最小相关验证，至少保证：

```powershell
cd Lucent
pnpm typecheck
pnpm build
pnpm export:openapi
```

## Luminous

```powershell
cd Luminous
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
flutter test
```

如果迭代阶段只跑最小相关验证，至少补跑受影响的 record / today / report tests，再在收尾时跑完整 `flutter test`。

# Risks

- 如果 sleep 字段定义过度保守，后面会补迁移；但这仍然比继续塞进 `vital.payload` 更可控。
- Prisma enum 变更会触发 OpenAPI 和 Flutter 客户端联动更新，不能只改一边。
- 现有 Today AI / Report AI 文案里对 sleep 缺失的假设会被影响；这次先让数据层真实，再决定明天的 AI 文案和推理怎么跟进。

# Done Means

- `Record` 里可以真实录 sleep
- `Today` 能看到真实 sleep 概览
- `Report` 的 sleep trend 不再是硬编码零值
- `Current_State.md` 不再把 sleep persistence 记为未接入
- 下一轮 AI 工作可以基于真实 sleep 数据继续，而不是继续围着 placeholder 打补丁
