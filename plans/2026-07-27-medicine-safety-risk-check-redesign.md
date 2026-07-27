# 用药安全卡片 & 风险检查页面重构计划

> 创建日期: 2026-07-27
> 涉及项目: Lucent (后端) / Luminous (前端)

---

## 一、现状分析

### 1.1 用药安全卡片（用药 Tab 内嵌）

**文件**: `lib/features/medicine/presentation/widgets/sections/mobile_safety.dart`

**当前结构**:
```
_SafetyEngineSection (Column)
  └─ FCard                          ← 外层卡片
       └─ Padding
            └─ Column
                 ├─ _SafetySummaryBanner (DecoratedBox + border)  ← 内层带边框容器
                 ├─ Wrap [_SafetyMetricBadge x3]  ← 全部 neutral 色，无区分
                 └─ Column [_SafetyAlertRow x N]   ← 每条 alert 带 FAvatar
```

**问题**:
1. **盒子套盒子**: `FCard` 内嵌 `DecoratedBox`(带 `ShapeDecoration` + `border`)，视觉层次混乱
2. **颜色单调**: 三个 `_SafetyMetricBadge` 全用 `SemanticColor.neutral.muted`，数值标签完全同色，无法快速区分"发现数"和"覆盖数"
3. **信息密度低**: banner 占据大量空间但信息量有限；metric badge 只是 `label + value`，缺乏视觉权重
4. **alert 行**与 banner 风格割裂: alert 行用 `FAvatar` + 文字，banner 用 `FAvatar` + 文字 + 按钮，风格不统一
5. **view 按钮**挤在 banner 行尾，布局局促
6. **无最后检查时间**: 用户无法判断安全结论的新鲜度

### 1.2 风险检查页面（独立页面）

**文件**: `lib/features/medicine/presentation/pages/risk_check.dart`
**子组件**: `risk_finding_tile.dart`, `risk_coverage_issue_tile.dart`, `risk_red_flag.dart`, `risk_metric_chip.dart`

**当前结构**:
```
MedicineRiskCheckPage
  └─ _MedicineRiskCheckBody
       ├─ MedicineRiskRedFlagBanner (Container + border)         ← 红旗
       │    └─ MedicineRiskRedFlagAlertRow (Container + bg)      ← 内嵌容器
       ├─ _RiskCheckSectionCard (FCard)                          ← 概览卡
       │    └─ Wrap [MedicineRiskMetricChip x4]                   ← 每个chip又是FCard
       └─ Three-Tier Section
            ├─ _TierBanner (Container + border)                   ← 层级横幅
            ├─ _RiskCheckSectionCard (FCard)                       ← 发现列表卡
            │    └─ Column [MedicineRiskFindingTile x N]
            ├─ (safe tier: _TierBanner + Container)               ← 安全层级
            └─ (uncovered tier: _TierBanner + Container + _RiskCheckSectionCard)
```

**问题**:
1. **三层盒子嵌套**: `_TierBanner`(Container) → `_RiskCheckSectionCard`(FCard) → `MedicineRiskFindingTile`(Padding + Row)
2. **MedicineRiskMetricChip 自己就是 FCard**: 在 `_RiskCheckSectionCard`(也是 FCard) 里套 FCard → 双重卡片
3. **Tier banner 与 section card 割裂**: 横幅和下面的卡片是两个独立元素，视觉上不连贯
4. **safe tier 毫无设计感**: 安全状态只有一个 `_TierBanner` + 一个 info `Container`，信息量极少
5. **red flag alert row 嵌套**: 在红色 banner 内部，每个 alert row 又有自己的 `Container` 背景
6. **risk_finding_tile 过于拥挤**: 右侧两个 `FBadge.raw`（severity + context）堆叠在文字旁边，布局紧张
7. **没有总体风险评分**: 页面缺乏一个一目了然的整体风险等级指示器
8. **单一检查模式**: 只有静态检查，无法利用 LLM 进行更灵活的风险分析

### 1.3 后端现状

**风险检查逻辑完全在客户端**:
- `LucentMedicineRiskCheckRepository` 逐个调用 `/medicines/:id` 获取详情，然后在客户端运行 `MedicineRiskChecker.evaluate()`
- **离线 fallback 不成立**: 客户端依赖网络拉取药品详情 JSON 后才能计算，无网络 = 无输入 = 无法检查
- **问题**: 客户端需下载全部药品详情 JSON 后才能计算，网络开销大；且检查逻辑无法被后端 suggestion/analysis 引擎复用

**后端已有基础设施（可直接复用）**:
- `DrugbankMedicineDetailDto` 包含 `drugInteractions[]` 和 `foodInteractions[]` 数据
- `CnMedicineDetailDto` 包含 `contraindications`、`precautions`、`ingredients` 文本
- `UserHealthContextService` 管理过敏史、当前用药列表，所有写操作已 `emitAsync(HEALTH_CONTEXT_CHANGED)`
- `EventEmitter2` + `@OnEvent` 事件驱动模式（`SuggestionCacheInvalidationListener` 已是此模式）
- `BaseLlmGeneratorService` 抽象基类：Zod schema 结构化输出 + circuit breaker + retry + metrics
- `LlmRuntimeService` 提供 `createChatModel(role)` 和 `requireChatModel(role)`
- `safeParseLlmJson` + `toInputJsonValue` JSON 工具函数
- `MedicinesCacheService` 药品详情缓存（Redis）
- `CACHE_MANAGER` 通用缓存层

**已有事件**:
- `HEALTH_CONTEXT_CHANGED` — 药品、过敏、慢性病变更时触发
- `REMINDER_CHANGED` — 提醒变更时触发

---

## 二、重构目标

1. **消除盒子嵌套**: 每个信息层级只保留一个容器，用色彩/间距/排版而非嵌套卡片来区分层级
2. **丰富视觉层次**: 用 `SemanticColor` + `GradientTokens` 让不同风险级别有明确的色彩语言
3. **后端化风险检查**: 客户端 `MedicineRiskChecker` 和 `RedFlagEvaluator` **删除**，全部迁移到服务端
4. **双检查模式**: 静态检查（确定性交叉验证）+ LLM 检查（语境化风险分析），两者互补
5. **事件驱动自动检查**: 静态检查由事件触发后台异步执行，用户无需手动操作
6. **DB 持久化**: 每次检查结果存入 DB，请求时返回已有记录，配合 `stale` 标记管理新鲜度
7. **风险检查页面重新设计**: 以风险评分为中心，FTabs 切换静态/LLM 两种结果
8. **保持 Forui-first**: 不引入 Material 3 组件，使用 Forui 原语 + design tokens [[memory:17849504329474592541]]

---

## 三、后端改造（Lucent）

### 3.1 Prisma 新增 Model

```prisma
model MedicineRiskCheckRecord {
  id          String   @id @default(uuid())
  userId      String   @map("user_id")
  checkType   String   @map("check_type")    // "static" | "llm"
  result      Json     @db.JsonB              // 完整检查结果 JSON
  riskScore   Int      @map("risk_score")    // 0-100
  riskLevel   String   @map("risk_level")    // "safe" | "caution" | "risk" | "danger"
  stale       Boolean  @default(false)       // 事件触发时标记 true，新检查完成后标记 false
  createdAt   DateTime @default(now()) @map("created_at") @db.Timestamptz(3)
  updatedAt   DateTime @default(now()) @updatedAt @map("updated_at") @db.Timestamptz(3)
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, checkType])  // 每种类型只保留最新一条
  @@index([userId, checkType])
  @@map("medicine_risk_check_records")
}
```

**设计说明**:
- `@@unique([userId, checkType])` — 每用户每种检查类型只保留最新一条，用 `upsert` 写入
- `result` 字段存储完整的 `MedicineRiskCheckResponseDto` JSON
- `stale` 字段用于标记数据新鲜度，事件触发时标记为 `true`
- `createdAt` / `updatedAt` 前端用于显示最后检查时间

### 3.2 API 设计

#### `GET /medicines/risk-check`

返回 DB 中两种类型的最新记录，不触发检查：

```typescript
// 响应
{
  static: MedicineRiskCheckRecordDto | null,
  llm: MedicineRiskCheckRecordDto | null
}

// MedicineRiskCheckRecordDto
{
  checkType: 'static' | 'llm',
  result: MedicineRiskCheckResponseDto,  // 完整检查结果
  riskScore: number,
  riskLevel: string,
  stale: boolean,
  createdAt: string,   // ISO 时间戳
  updatedAt: string,
}
```

#### `POST /medicines/risk-check`

手动触发指定类型的检查，执行后写入 DB：

```typescript
// 请求
{
  type: 'static' | 'llm'
}

// 响应: MedicineRiskCheckRecordDto（同 GET 返回的单条记录）
```

- `type: 'static'` — 执行静态检查，写入 DB，返回结果
- `type: 'llm'` — 执行 LLM 检查，写入 DB，返回结果。如 LLM 未配置返回 `503 Service Unavailable`

### 3.3 响应 DTO

```typescript
class MedicineRiskCheckResponseDto {
  overallRiskLevel: 'safe' | 'caution' | 'risk' | 'danger';
  overallRiskScore: number;          // 0-100
  currentMedicineCount: number;
  checkedMedicineCount: number;
  findings: MedicineRiskFindingDto[];
  coverageIssues: MedicineRiskCoverageIssueDto[];
  redFlags: MedicineRedFlagDto[];
  overallRecommendation?: string;    // LLM 检查才有
}

class MedicineRiskFindingDto {
  type: 'interaction' | 'duplicateIngredient' | 'allergy'
      | 'foodInteraction' | 'longTermUse' | 'schedulingConflict' | 'specialGroup';
  severity: 'high' | 'medium' | 'info';
  context: 'none' | 'alcohol' | 'caffeine';
  primaryMedicineName: string;
  secondaryMedicineName?: string;
  relatedLabel?: string;
  evidence?: string;
  recommendation?: string;    // LLM 检查才有
}

class MedicineRiskCoverageIssueDto {
  medicineName: string;
  reason: 'manualEntry' | 'missingSourceRef' | 'detailUnavailable';
}

class MedicineRedFlagDto {
  rule: 'severeAllergy' | 'informationGap';
  primaryMedicineName: string;
  relatedLabel?: string;
}
```

**LLM 特有 finding types**: `longTermUse`（长期使用/成瘾性风险）、`schedulingConflict`（用药计划冲突）、`specialGroup`（特殊人群禁忌）

### 3.4 静态检查 Service

**新增文件**: `src/modules/medicines/services/medicine-risk-check.service.ts`

将客户端 `MedicineRiskChecker` 的逻辑迁移到服务端：

```typescript
@Injectable()
export class MedicineRiskCheckService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly medicinesService: MedicinesService,
    private readonly healthContextService: UserHealthContextService,
    @Inject(CACHE_MANAGER) private readonly cache: Cache,
  ) {}

  // 获取已有记录（GET 请求用）
  async getRecords(userId: string): Promise<{ static: ..., llm: ... }> {
    const records = await this.prisma.medicineRiskCheckRecord.findMany({
      where: { userId },
    });
    // 按 checkType 分组返回
  }

  // 执行静态检查（POST 请求 / 事件触发）
  async runStaticCheck(userId: string): Promise<MedicineRiskCheckRecord> {
    // 1. 获取健康档案（过敏、慢性病、当前用药）
    // 2. 并行拉取药品详情（Promise.all + MedicinesService.getDetailWithCache）
    // 3. 执行检查逻辑（DrugBank 交互、成分重复、过敏匹配、食物相互作用）
    // 4. 计算 overallRiskScore 和 overallRiskLevel
    // 5. upsert 写入 DB（checkType='static', stale=false）
    // 6. 写入 Redis 缓存
    // 7. 返回记录
  }

  // 执行 LLM 检查（POST 请求）
  async runLlmCheck(userId: string): Promise<MedicineRiskCheckRecord> {
    // 1. 先执行静态检查获取 baseline
    // 2. 构建 LLM 上下文（药品详情 + 过敏 + 慢性病 + 提醒 + 静态结果）
    // 3. 调用 LLM generator
    // 4. upsert 写入 DB（checkType='llm', stale=false）
    // 5. 写入 Redis 缓存
    // 6. 返回记录
  }
}
```

**静态检查逻辑**（从客户端 `risk_checker.dart` 迁移）:
- `_allergyFindings()` — 过敏成分匹配（token + haystack）
- `_foodInteractionFindings()` — 酒精/咖啡因交互
- `_pairInteractionFinding()` — DrugBank ID 交叉验证
- `_duplicateIngredientFinding()` — 标准化成分重复检测
- `_coverageIssueFor()` — 覆盖缺口检测

**Risk Score 计算**:
```
基础分 = 0
+ findings 中每个 high severity → +30
+ findings 中每个 medium severity → +15
+ findings 中每个 info severity → +5
+ coverageIssues 每个 → +3
+ redFlags 每个 severeAllergy → +40
+ redFlags 每个 informationGap → +10
总分 = min(100, 基础分)

Risk Level:
  0-10   → safe
  11-40  → caution
  41-70  → risk
  71-100 → danger
```

### 3.5 LLM 检查 Generator

**新增文件**:
- `src/modules/medicines/services/medicine-risk-llm-generator.service.ts`
- `src/modules/medicines/prompts/risk-check.prompt.ts`
- `src/modules/medicines/schemas/risk-check.schema.ts`

继承 `BaseLlmGeneratorService`，复用已有的 circuit breaker + retry + metrics：

```typescript
@Injectable()
export class MedicineRiskLlmGeneratorService extends BaseLlmGeneratorService<
  MedicineRiskLlmContext,
  MedicineRiskLlmPromptCopy,
  MedicineRiskLlmOutput
> {
  protected readonly schema = medicineRiskLlmSchema;
  protected readonly modelRole = 'analysis';  // 复用 analysis 角色
  protected readonly options = {
    toolName: 'MedicineRiskCheck',
    streamName: 'Medicine risk LLM check',
  } as const;

  protected buildSystemPrompt(): string { ... }
  protected buildUserPrompt(context, copy): string { ... }
}
```

**LLM 输入上下文**:

```typescript
interface MedicineRiskLlmContext {
  medicines: Array<{
    name: string;
    source: 'drugbank' | 'cn';
    ingredients?: string;
    contraindications?: string;
    precautions?: string;
    foodInteractions?: string[];
    drugInteractions?: Array<{ target: string; description: string }>;
    startedAt?: string;       // 开始服用日期 — 用于判断长期用药
  }>;
  allergies: Array<{
    label: string;
    severity: string;
    reaction?: string;
  }>;
  conditions: Array<{
    label: string;
    status: string;
  }>;
  reminders: Array<{
    medicineName: string;
    scheduledHour: number;
    scheduledMinute: number;
    daysOfWeek?: number[];
    startDate?: string;
    endDate?: string;
  }>;
  staticFindings: Array<{    // 静态检查结果作为 baseline
    type: string;
    severity: string;
    description: string;
  }>;
}
```

**为什么传入 `reminders`**: 成瘾性药物（苯二氮卓类、阿片类、中枢兴奋剂等）的长期定时服用风险，只有 LLM 结合用药时长和频率才能判断。静态检查不知道用户一天吃几次、吃了多久。

**Zod 输出 Schema**:

```typescript
const medicineRiskLlmSchema = z.object({
  summary: z.string().trim().min(1).max(200),
  riskScore: z.number().min(0).max(100),
  riskLevel: z.enum(['safe', 'caution', 'risk', 'danger']),
  findings: z.array(z.object({
    type: z.enum([
      'interaction', 'duplicateIngredient', 'allergy',
      'foodInteraction', 'longTermUse', 'schedulingConflict', 'specialGroup'
    ]),
    severity: z.enum(['high', 'medium', 'info']),
    title: z.string(),
    description: z.string(),
    recommendation: z.string(),
    primaryMedicineName: z.string(),
    secondaryMedicineName: z.string().optional(),
  })),
  overallRecommendation: z.string(),
});
```

**System Prompt 要点**:
- "You are a medicine safety analyst"
- "Use the provided medicine details, allergies, conditions, and reminders"
- "Identify risks including: drug interactions, duplicate ingredients, allergy matches, food interactions, long-term use risks (addiction, tolerance), scheduling conflicts, special population contraindications"
- "The static findings are provided as baseline — expand on them, do not contradict"
- "Do not recommend starting, stopping, or changing medication doses"
- "Return only structured output matching the schema"

### 3.6 事件驱动 + 防抖

**新增文件**: `src/modules/medicines/services/medicine-risk-check.listener.ts`

```typescript
@Injectable()
export class MedicineRiskCheckListener {
  private readonly logger = new Logger(MedicineRiskCheckListener.name);
  // per-user 防抖计时器
  private readonly pendingTimers = new Map<string, NodeJS.Timeout>();
  private static readonly DEBOUNCE_MS = 5000;

  constructor(private readonly riskCheckService: MedicineRiskCheckService) {}

  @OnEvent(HEALTH_CONTEXT_CHANGED)
  async handleHealthContextChanged(payload: HealthContextChangedPayload): Promise<void> {
    // 1. 标记两种检查记录 stale=true
    await this.riskCheckService.markStale(payload.userId);
    // 2. 防抖调度静态检查
    this.scheduleStaticCheck(payload.userId);
  }

  @OnEvent(REMINDER_CHANGED)
  async handleReminderChanged(payload: ReminderChangedPayload): Promise<void> {
    // 同上 — 提醒变更影响长期用药风险判断
    await this.riskCheckService.markStale(payload.userId);
    this.scheduleStaticCheck(payload.userId);
  }

  private scheduleStaticCheck(userId: string): void {
    const existing = this.pendingTimers.get(userId);
    if (existing) clearTimeout(existing);

    const timer = setTimeout(() => {
      this.pendingTimers.delete(userId);
      this.riskCheckService.runStaticCheck(userId).catch((err) => {
        this.logger.warn(`Async static risk check failed for ${userId}`, err);
        // 失败时保留旧记录，stale 保持 true
      });
    }, MedicineRiskCheckListener.DEBOUNCE_MS);

    this.pendingTimers.set(userId, timer);
  }
}
```

**防抖原因**: 用户添加药品时，前端流程通常是 `POST /health-context/current-medicines` → `POST /reminders`，触发 `HEALTH_CONTEXT_CHANGED` + `REMINDER_CHANGED` 两个事件。5 秒防抖确保只执行一次检查。

### 3.7 缓存一致性 — 三层裁决

```
Client (Riverpod keepAlive provider)
    ↓ miss
Server Redis (CACHE_MANAGER, TTL 30min)
    ↓ miss
DB (MedicineRiskCheckRecord, source of truth)
```

| 操作 | DB | Redis | Client |
|---|---|---|---|
| POST 检查完成 | upsert 写入 | 写入 + TTL 30min | 响应触发 provider refresh |
| `HEALTH_CONTEXT_CHANGED` / `REMINDER_CHANGED` 事件 | `stale=true` | **删除** static key | 不动（下次 GET 自然刷新） |
| GET 请求 | Redis miss 时回源读取 | miss 则读 DB 并回填 | provider miss 时发请求 |

**关键决策**:
- 事件不删 DB 记录 — 保证即使事件丢失、Redis 清空，DB 仍有数据可返回
- 事件只标记 `stale=true` + 删 Redis — 下次 GET 时前端看到 `stale=true`，可显示 "数据可能已过期"
- 静态检查失败时保留旧记录，`stale` 保持 `true`，前端显示 "上次检查失败" + 重试入口

### 3.8 Controller

```typescript
@Get('risk-check')
@ApiBearerAuth('access-token')
@ApiOperation({ summary: 'Get latest risk check records' })
async getRiskCheck(@CurrentUser() user: UserPayload) {
  const records = await this.riskCheckService.getRecords(user.sub);
  return successEnvelope(records);
}

@Post('risk-check')
@ApiBearerAuth('access-token')
@ApiOperation({ summary: 'Run risk check (static or LLM)' })
async runRiskCheck(
  @CurrentUser() user: UserPayload,
  @Body() dto: RunRiskCheckDto,
) {
  const record = dto.type === 'llm'
    ? await this.riskCheckService.runLlmCheck(user.sub)
    : await this.riskCheckService.runStaticCheck(user.sub);
  return successEnvelope(record);
}
```

### 3.9 OpenAPI 同步

完成代码后:
1. `cd Lucent && pnpm export:openapi`
2. `cd Luminous && dart run tool/bootstrap_generated_sources.dart`

---

## 四、前端改造（Luminous）

### 4.1 删除客户端检查逻辑

**删除文件**:
- `lib/features/medicine/domain/services/risk_checker.dart` — 客户端检查逻辑，迁移到后端
- `lib/features/medicine/domain/services/risk_checker_utils.dart` — 工具函数，迁移到后端
- `lib/features/medicine/domain/services/red_flag_evaluator.dart` — 红旗评估，迁移到后端
- `lib/features/medicine/domain/services/ingredient_canonicalizer.dart` — 成分标准化，迁移到后端
- `lib/features/medicine/domain/services/allergy_severity_helper.dart` — 过敏严重度，迁移到后端
- `lib/features/medicine/domain/entities/risk_medicine_detail.dart` — 客户端药品详情包装，不再需要

### 4.2 数据层重构

#### 4.2.1 扩展 Entity

**修改文件**: `lib/features/medicine/domain/entities/risk_check.dart`

```dart
enum RiskLevel { safe, caution, risk, danger }

enum MedicineRiskCheckType { staticCheck, llm }

@freezed
abstract class MedicineRiskCheckResult with _$MedicineRiskCheckResult {
  const factory MedicineRiskCheckResult({
    required RiskLevel overallRiskLevel,
    required int overallRiskScore,
    required int currentMedicineCount,
    required int checkedMedicineCount,
    required List<MedicineRiskFinding> findings,
    required List<MedicineRiskCoverageIssue> coverageIssues,
    required List<RedFlagAlert> redFlags,
    String? overallRecommendation,    // LLM 检查才有
  }) = _MedicineRiskCheckResult;
}

@freezed
abstract class MedicineRiskCheckRecord with _$MedicineRiskCheckRecord {
  const factory MedicineRiskCheckRecord({
    required MedicineRiskCheckType checkType,
    required MedicineRiskCheckResult result,
    required int riskScore,
    required RiskLevel riskLevel,
    required bool stale,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MedicineRiskCheckRecord;
}

// MedicineRiskFinding 新增字段:
// - recommendation (String?) — LLM 检查的建议
// - type 枚举新增: longTermUse, schedulingConflict, specialGroup
```

#### 4.2.2 新增 Data Source

**新增文件**: `lib/features/medicine/data/datasources/risk_check_remote.dart`

```dart
class MedicineRiskCheckRemoteDataSource {
  const MedicineRiskCheckRemoteDataSource({required this.api});

  final MedicinesApi api;

  /// GET — 读取 DB 已有记录
  Future<({MedicineRiskCheckRecord? staticRecord, MedicineRiskCheckRecord? llmRecord})>
      fetchRecords() async {
    final response = await api.medicinesControllerGetRiskCheckV1();
    ensureEnvelopeSuccess(code: response.code, message: response.message);
    return _mapRecords(response.data!);
  }

  /// POST — 手动触发检查
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async {
    final response = await api.medicinesControllerRunRiskCheckV1(
      body: RunRiskCheckDto(type: type.name),
    );
    ensureEnvelopeSuccess(code: response.code, message: response.message);
    return _mapRecord(response.data!);
  }
}
```

#### 4.2.3 简化 Repository

**修改文件**: `lib/features/medicine/data/repositories/risk_check.dart`

```dart
class LucentMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  // 不再需要 MedicineSearchRemoteDataSource 和 MedicineRiskChecker
  // 只需要直接调用后端端点

  Future<({MedicineRiskCheckRecord? staticRecord, MedicineRiskCheckRecord? llmRecord})>
      fetchRecords() {
    return remoteDataSource.fetchRecords();
  }

  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) {
    return remoteDataSource.runCheck(type);
  }
}
```

#### 4.2.4 Provider 调整

**修改文件**: `lib/features/medicine/presentation/providers/risk_check.dart`

```dart
/// 读取 DB 已有的检查记录（GET）
@Riverpod(keepAlive: true)
Future<MedicineRiskCheckRecords> medicineRiskCheckRecords(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () {
      final repository = ref.watch(medicineRiskCheckRepositoryProvider);
      return repository.fetchRecords();
    },
  );
}

/// 手动触发检查（POST）
@riverpod
Future<MedicineRiskCheckRecord> runRiskCheck(Ref ref, MedicineRiskCheckType type) {
  return authGuarded(
    ref: ref,
    fetch: () {
      final repository = ref.watch(medicineRiskCheckRepositoryProvider);
      return repository.runCheck(type);
    },
  );
}
```

### 4.3 用药安全卡片重构（用药 Tab）

**目标**: 消除 FCard 嵌套，用单一容器 + 色彩分层，显示最后检查时间

#### 用药 Tab 红点逻辑

| 状态 | 条件 | 展示 |
|---|---|---|
| 正常 | 静态检查存在且 `stale=false` 且 `riskLevel=safe` | 正常显示，无标记 |
| 有风险 | 静态检查存在且 `stale=false` 且 `riskLevel≠safe` | 红点 + 风险摘要 |
| 可能过期 | 静态检查存在但 `stale=true` | 黄点 + "可能已过期" 文字 |
| 从未检查 | 静态检查不存在 | 灰色提示 + "点击查看" |

#### 新结构

```
_SafetyEngineSection (Column)
  ├─ _SafetyHeader (Row)                ← 标题 + 风险等级徽章 + 最后检查时间
  │    ├─ Text(title)
  │    ├─ _RiskLevelPill                 ← 小型等级标签 (safe/risk/danger)
  │    └─ _LastCheckedLabel              ← "上次检查: 14:30" / "可能已过期"
  │
  └─ _SafetyCard (FTappable → DecoratedBox)  ← 单一容器，整体可点击跳转
       └─ Padding
            └─ Column
                 ├─ _RiskSummary (Row)    ← 图标 + 标题 + 描述 + 箭头
                 ├─ SizedBox(height: level3)
                 ├─ _MetricRow (Row)       ← 3个指标横向排列，语义着色
                 │    ├─ _MetricItem(label, value, color)
                 │    ├─ _MetricDivider
                 │    ├─ _MetricItem(label, value, color)
                 │    ├─ _MetricDivider
                 │    └─ _MetricItem(label, value, color)
                 └─ if (alerts.isNotEmpty)
                      Column [_AlertChip x N]   ← 紧凑型 alert 条目
```

#### 设计细节

**`_SafetyCard`**: 不再使用 `FCard`，改为 `DecoratedBox`:
- 背景: `riskLevel.subtle(context)` — 极淡的语义色底
- 边框: `riskLevel.border(context)` — 语义色边框
- 圆角: `RadiusTokens.level4`
- 外层包 `FTappable`，跳转到风险检查页面

**`_RiskLevelPill`**: 右上角小型 pill:
- safe: `SemanticColor.success`
- caution: `SemanticColor.warning`
- risk: `SemanticColor.destructive`
- danger: `SemanticColor.destructive` + 呼吸效果

**`_LastCheckedLabel`**: 最后检查时间显示
- `stale=false` → "上次检查: HH:mm"（`TypographyToken.level3` + `mutedForeground`）
- `stale=true` → "可能已过期"（`SemanticColor.warning`）
- 从未检查 → "点击开始检查"（`SemanticColor.primary`）

**`_MetricRow`**: 三个指标横向排列，用竖线分隔
- 当前用药数: `SemanticColor.neutral`
- 发现数: `findings > 0 ? SemanticColor.destructive : SemanticColor.success`
- 覆盖缺口: `coverageGaps > 0 ? SemanticColor.warning : SemanticColor.success`
- 数值用 `TypographyToken.level7` + `FontWeight.w800`
- 标签用 `TypographyToken.level3` + `mutedForeground`

**`_AlertChip`**: 紧凑型 alert（非卡片）:
- 一行: 图标 + 标题（单行截断）+ severity badge
- 不再使用 `FAvatar`，改用 `Icon` + 背景圆
- 最多显示 2 条，超出显示 `+N`

**空状态**:
- 不再用 `FCard` 包裹
- 直接在 `_SafetyCard` 内展示: 盾牌图标 + "暂无风险数据" 文案

### 4.4 风险检查页面重构

**目标**: FTabs 切换静态/LLM 两种结果，以风险评分仪表盘为中心

#### 新结构

```
MedicineRiskCheckPage
  └─ _MedicineRiskCheckBody (Column)
       ├─ FTabs                                     ← Forui Tabs 切换
       │    ├─ FTabEntry("系统检查")
       │    │    └─ _CheckTabContent
       │    │         ├─ _TabHeader                  ← 最后更新时间 + 刷新按钮(仅 stale 时)
       │    │         ├─ _RiskScoreHero              ← 风险评分英雄区
       │    │         │    └─ DecoratedBox (tintFade)
       │    │         │         └─ _RiskScoreRing (CustomPaint) + level + description
       │    │         ├─ if (redFlags.isNotEmpty) _RedFlagSection
       │    │         ├─ _MetricGrid (Row x4)
       │    │         ├─ _FindingsSection
       │    │         ├─ if (hasCoverageGaps) _CoverageSection
       │    │         └─ if (isSafe) _SafeStateCard
       │    │
       │    └─ FTabEntry("AI 分析")
       │         └─ _CheckTabContent
       │              ├─ _TabHeader                  ← 最后更新时间 + "运行 AI 分析"按钮
       │              ├─ if (record == null)
       │              │    _LlmEmptyState             ← 空状态 CTA
       │              ├─ if (record != null)
       │              │    ├─ if (stale) _StaleBanner ← "数据已变更，建议重新分析"
       │              │    ├─ _RiskScoreHero
       │              │    ├─ _FindingsSection (含 recommendation)
       │              │    └─ _OverallRecommendationCard
       │              └─ if (llmNotConfigured) _LlmUnavailableState
```

#### 设计细节

**`_TabHeader`**: tab 内顶部行
- 左侧: "最后更新: 2026-07-27 14:30"（`TypographyToken.level3` + `mutedForeground`）
- 右侧:
  - 静态 tab: `stale=true` 或无记录时显示 "运行检查" 按钮（`FButton.ghost`）
  - 静态 tab: `stale=false` 时不显示按钮
  - LLM tab: 始终显示 "运行 AI 分析" 按钮（`FButton`）

**`_RiskScoreHero`**:
- 背景: `GradientTokens.tintFade(riskLevel.muted(context), theme.background)`
- 不使用 `FCard` — 用 `DecoratedBox` + `RoundedSuperellipseBorder`
- 高度: 约 200px
- 内含环形进度条（`CustomPaint` 绘制），颜色随风险级别变化

**`_RiskScoreRing`**: 环形进度条
- 直径: 120px
- 背景环: `riskLevel.subtle(context)`
- 前景环: `riskLevel.solid(context)` 或 `GradientTokens.semanticFill(palette)`
- 中心数字: `overallRiskScore` + `/100`
- 用 `CustomPaint` + `AnimationController` 实现

**`_StaleBanner`** (LLM tab 专属):
- `warning.subtle` 背景 + `warning.border` 边框
- 图标 + "药品/提醒已变更，以上结果可能已过期"
- 不自动触发检查，只提示用户点击 "运行 AI 分析"

**`_LlmEmptyState`**:
- 居中: 大图标 + "尚未进行 AI 风险分析"
- 描述: "AI 分析可以识别长期用药风险、成瘾性、特殊人群禁忌等静态检查无法发现的问题"
- CTA: "运行 AI 分析" 按钮

**`_OverallRecommendationCard`** (LLM tab 专属):
- `DecoratedBox` + `primary.subtle` 背景
- 标题: "总体建议"
- 内容: `overallRecommendation` 文本

**`_MetricGrid`**: 4 格网格，不用 FCard
- 每格: `Container` + 细右边框 (`Border(right: BorderSide(color: border))`)
- 标签 + 数值，数值用 `TypographyToken.level7` 大字
- 发现数可点击（滚动到发现区域）

**`_FindingItem`**: 替代 `MedicineRiskFindingTile`
- 不用 FCard，用 `FTappable` + `Padding`
- 左侧: 4px 宽色条（severity 对应色）+ 图标圆
- 中间: 标题 + 描述 + 证据文本（折叠/展开）
- 右侧: severity 标签（小 pill）
- LLM 结果中如有 `recommendation`，在描述下方显示 "建议: ..." 行
- 用 `AppDivider` 分隔条目

**`_RedFlagSection`**: 替代 `MedicineRiskRedFlagBanner`
- 不用外层 Container 嵌套内层 Container
- 每个 `_RedFlagItem` 是一个带左侧红色色条的 Row:
  ```
  ╔═══════════════════════════════╗
  ║█ ⚠  严重过敏：阿莫西林         ║
  ║█    建议立即停药并就诊           ║
  ╚═══════════════════════════════╝
  ```
- 左侧色条: `Container(width: 4, color: destructive.solid)`
- 背景: `destructive.subtle(context)`

**`_CoverageItem`**: 替代 `MedicineRiskCoverageIssueTile`
- 简洁: 图标 + 药品名 + 原因标签
- 不用 FCard

**`_SafeStateCard`**: 替代 safe tier 的 banner + info container
- 单个 `DecoratedBox` + `success.subtle` 背景
- 大图标 + "用药安全" + 描述

**Section 间不再使用 `_RiskCheckSectionCard`(FCard)**:
- 每个 section 用 `Padding` + section title (`TypographyToken.level6`) + 内容
- section 之间用 `SizedBox(height: Spacing.level5)` 间隔
- 折叠/展开按钮保持 `FButton.ghost`

### 4.5 Loading 状态

**修改文件**: `risk_check_loading.dart`

更新 skeleton 布局以匹配新结构:
- 一个 FTabs skeleton
- 一个 hero skeleton (高度 200)
- 一个 metric grid skeleton (高度 80)
- 两个 finding item skeleton

### 4.6 l10n 新增字符串

**修改文件**: `lib/l10n/src/medicine_zh.arb`, `lib/l10n/src/medicine_en.arb`

新增:
- `medicineRiskCheckTabStatic` — "系统检查" / "System Check"
- `medicineRiskCheckTabLlm` — "AI 分析" / "AI Analysis"
- `medicineRiskScoreTitle` — "风险评分" / "Risk Score"
- `medicineRiskLevelSafe` — "安全" / "Safe"
- `medicineRiskLevelCaution` — "需注意" / "Caution"
- `medicineRiskLevelRisk` — "有风险" / "At Risk"
- `medicineRiskLevelDanger` — "高风险" / "Danger"
- `medicineRiskScoreSafeDescription` — "当前用药组合未发现安全风险" / "No safety risks found"
- `medicineRiskScoreRiskDescription` — "发现 {count} 项风险发现，请查看详情" / "{count} risk findings detected"
- `medicineRiskScoreDangerDescription` — "检测到严重风险，请立即处理" / "Critical risks detected"
- `medicineRiskFindingRecommendation` — "建议" / "Recommendation"
- `medicineRiskOverallRecommendation` — "总体建议" / "Overall Recommendation"
- `medicineRiskCheckLastUpdated` — "最后更新: {time}" / "Last updated: {time}"
- `medicineRiskCheckStale` — "可能已过期" / "May be outdated"
- `medicineRiskCheckStaleBanner` — "药品/提醒已变更，以上结果可能已过期" / "Medicines or reminders have changed, results may be outdated"
- `medicineRiskCheckRunStatic` — "运行检查" / "Run Check"
- `medicineRiskCheckRunLlm` — "运行 AI 分析" / "Run AI Analysis"
- `medicineRiskCheckLlmEmptyTitle` — "尚未进行 AI 风险分析" / "No AI risk analysis yet"
- `medicineRiskCheckLlmEmptyBody` — "AI 分析可以识别长期用药风险、成瘾性、特殊人群禁忌等静态检查无法发现的问题" / "AI analysis can identify long-term use risks, addiction potential, and special population contraindications that static checks cannot detect"
- `medicineRiskCheckLlmUnavailable` — "AI 分析功能未配置" / "AI analysis is not configured"
- `medicineRiskCheckNeverChecked` — "点击开始检查" / "Tap to start check"

### 4.7 文件变更清单

| 操作 | 文件路径 | 说明 |
|------|----------|------|
| **Lucent 后端** | | |
| 新增 | `Lucent/prisma/schema.prisma` | 新增 `MedicineRiskCheckRecord` model |
| 新增 migration | `Lucent/prisma/migrations/` | DB migration |
| 新增 | `Lucent/src/modules/medicines/dto/risk-check-request.dto.ts` | 请求 DTO |
| 新增 | `Lucent/src/modules/medicines/dto/risk-check-response.dto.ts` | 响应 DTO |
| 新增 | `Lucent/src/modules/medicines/services/medicine-risk-check.service.ts` | 静态检查 + DB 管理 |
| 新增 | `Lucent/src/modules/medicines/services/medicine-risk-check.listener.ts` | 事件监听 + 防抖 |
| 新增 | `Lucent/src/modules/medicines/services/medicine-risk-llm-generator.service.ts` | LLM 检查 generator |
| 新增 | `Lucent/src/modules/medicines/prompts/risk-check.prompt.ts` | LLM prompt |
| 新增 | `Lucent/src/modules/medicines/schemas/risk-check.schema.ts` | Zod schema |
| 修改 | `Lucent/src/modules/medicines/medicines.controller.ts` | 新增 GET + POST 端点 |
| 修改 | `Lucent/src/modules/medicines/medicines.module.ts` | 注册 service + listener |
| **Luminous 前端** | | |
| 删除 | `Luminous/lib/features/medicine/domain/services/risk_checker.dart` | 客户端检查逻辑 |
| 删除 | `Luminous/lib/features/medicine/domain/services/risk_checker_utils.dart` | 工具函数 |
| 删除 | `Luminous/lib/features/medicine/domain/services/red_flag_evaluator.dart` | 红旗评估 |
| 删除 | `Luminous/lib/features/medicine/domain/services/ingredient_canonicalizer.dart` | 成分标准化 |
| 删除 | `Luminous/lib/features/medicine/domain/services/allergy_severity_helper.dart` | 过敏严重度 |
| 删除 | `Luminous/lib/features/medicine/domain/entities/risk_medicine_detail.dart` | 客户端药品详情包装 |
| 修改 | `Luminous/lib/features/medicine/domain/entities/risk_check.dart` | 扩展 entity |
| 修改 | `Luminous/lib/features/medicine/domain/repositories/risk_check.dart` | 简化接口 |
| 修改 | `Luminous/lib/features/medicine/data/repositories/risk_check.dart` | 简化实现 |
| 新增 | `Luminous/lib/features/medicine/data/datasources/risk_check_remote.dart` | API 调用 |
| 修改 | `Luminous/lib/features/medicine/presentation/providers/risk_check.dart` | provider 重构 |
| 重写 | `Luminous/lib/features/medicine/presentation/widgets/sections/mobile_safety.dart` | 安全卡片 |
| 重写 | `Luminous/lib/features/medicine/presentation/pages/risk_check.dart` | 风险检查页面 (FTabs) |
| 重写 | `Luminous/lib/features/medicine/presentation/widgets/risk/risk_finding_tile.dart` | 发现条目 |
| 重写 | `Luminous/lib/features/medicine/presentation/widgets/risk/risk_red_flag.dart` | 红旗条目 |
| 重写 | `Luminous/lib/features/medicine/presentation/widgets/risk/risk_coverage_issue_tile.dart` | 覆盖条目 |
| 重写 | `Luminous/lib/features/medicine/presentation/widgets/risk/risk_metric_chip.dart` | 指标格子 |
| 重写 | `Luminous/lib/features/medicine/presentation/widgets/risk/risk_check_loading.dart` | skeleton |
| 新增 | `Luminous/lib/features/medicine/presentation/widgets/risk/risk_score_ring.dart` | 环形进度条 |
| 新增 | `Luminous/lib/features/medicine/presentation/widgets/risk/check_tab_content.dart` | tab 内容容器 |
| 修改 | `Luminous/lib/features/medicine/presentation/widgets/shared/copy.dart` | copy 工具函数 |
| 修改 | `Luminous/lib/features/medicine/presentation/utils/safety_tip_style.dart` | 样式工具 |
| 修改 | `Luminous/lib/l10n/src/medicine_zh.arb` | 中文 l10n |
| 修改 | `Luminous/lib/l10n/src/medicine_en.arb` | 英文 l10n |

---

## 五、触发策略总结

### 5.1 静态检查

| 场景 | 触发方式 | 说明 |
|---|---|---|
| 添加/修改/删除药品 | `HEALTH_CONTEXT_CHANGED` → 标记 stale → 防抖 5s → 后台执行 | 药品变更可能引入新交互 |
| 添加/修改/删除过敏 | 同上 | 新过敏可能与现有药品冲突 |
| 添加/修改/删除慢性病 | 同上 | 特殊人群禁忌 |
| 创建/修改/删除提醒 | `REMINDER_CHANGED` → 标记 stale → 防抖 5s → 后台执行 | 用药频率变化影响长期风险评估 |
| 风险检查页面手动触发 | `POST /medicines/risk-check { type: "static" }` | 仅 `stale=true` 或无记录时显示按钮 |
| 用药 Tab 打开 | `GET /medicines/risk-check` 返回 DB 记录 | 不触发检查，仅读取 |

**防抖**: 5 秒 per-user，确保连续操作（如添加药品 + 创建提醒）只触发一次检查

**失败容错**: 检查失败时保留旧记录，`stale` 保持 `true`，日志 warn，下次事件/手动重试时再次尝试

### 5.2 LLM 检查

| 场景 | 触发方式 | 说明 |
|---|---|---|
| 风险检查页面手动触发 | `POST /medicines/risk-check { type: "llm" }` | 用户点击 "运行 AI 分析" |
| 事件触发 | **不触发** LLM 检查 | 仅标记 `stale=true`，前端提示 "数据已变更" |

**LLM 上下文包含**: 药品详情 + 过敏 + 慢性病 + 提醒计划 + 静态检查结果（baseline）

### 5.3 缓存失效

| 事件 | DB | Redis | 前端 |
|---|---|---|---|
| `HEALTH_CONTEXT_CHANGED` | `stale=true` (static + llm) | 删除 static key | 下次 GET 自然刷新 |
| `REMINDER_CHANGED` | `stale=true` (static + llm) | 删除 static key | 下次 GET 自然刷新 |
| POST 检查完成 | upsert, `stale=false` | 写入 + TTL 30min | provider refresh |

---

## 六、执行计划

### Phase 1: 后端 — Prisma + 静态检查（Lucent）
1. 新增 `MedicineRiskCheckRecord` model + migration
2. 创建 `risk-check-request.dto.ts` 和 `risk-check-response.dto.ts`
3. 创建 `medicine-risk-check.service.ts` — 迁移客户端检查逻辑 + DB 管理 + Redis 缓存
4. 在 `medicines.controller.ts` 添加 `GET` + `POST` 端点
5. 在 `medicines.module.ts` 注册 provider
6. 创建 `medicine-risk-check.listener.ts` — 事件监听 + 防抖
7. 运行 `pnpm lint:check && pnpm build && pnpm test`
8. 运行 `pnpm export:openapi`

### Phase 2: 后端 — LLM 检查（Lucent）
1. 创建 `risk-check.schema.ts` (Zod)
2. 创建 `risk-check.prompt.ts` (system + user prompt)
3. 创建 `medicine-risk-llm-generator.service.ts` (继承 `BaseLlmGeneratorService`)
4. 在 `MedicineRiskCheckService` 中添加 `runLlmCheck()` 方法
5. 运行 `pnpm lint:check && pnpm build && pnpm test`
6. 运行 `pnpm export:openapi`

### Phase 3: 前端 — 数据层适配（Luminous）
1. 删除客户端检查相关文件（`risk_checker.dart` 等 6 个文件）
2. 扩展 `risk_check.dart` entity
3. 新增 `risk_check_remote.dart` data source
4. 简化 `risk_check.dart` repository
5. 更新 `risk_check.dart` provider
6. 运行 `dart run tool/bootstrap_generated_sources.dart`
7. 运行 `flutter analyze`

### Phase 4: 用药安全卡片重构
1. 重写 `mobile_safety.dart` — 新结构 + 红点逻辑 + 最后检查时间
2. 更新 `copy.dart` 中安全卡片相关函数
3. 新增 l10n 字符串并 merge
4. 运行 `flutter analyze`

### Phase 5: 风险检查页面重构
1. 新增 `risk_score_ring.dart`（CustomPaint 环形进度条）
2. 新增 `check_tab_content.dart`（tab 内容容器）
3. 重写 `risk_check.dart`（页面主体 + FTabs）
4. 重写 `risk_finding_tile.dart`
5. 重写 `risk_red_flag.dart`
6. 重写 `risk_coverage_issue_tile.dart`
7. 重写 `risk_metric_chip.dart`（改为 `_MetricCell`）
8. 重写 `risk_check_loading.dart`
9. 更新 l10n 字符串并 merge
10. 运行 `flutter analyze`

### Phase 6: 文档 & 收尾
1. 运行 `dart run tool/check_doc_coverage.dart --warning-only`
2. 更新 `docs/03-logs/migration-log/2026-07-27.md`
3. 更新相关 `docs/00-current/*.md`
4. 更新 `docs/02-reference/Localization.md`

---

## 七、设计约束

1. **Forui-first**: 使用 `FTabs`, `FTabEntry`, `FCard`, `FTappable`, `FBadge`, `FButton` 等 Forui 原语，不引入 Material 组件 [[memory:17849504329474592541]]
2. **渐变色**: 允许通过 `GradientTokens.semanticFill` / `GradientTokens.tintFade` 使用，禁止内联 `LinearGradient`
3. **SemanticColor 体系**: `SemanticColor { primary, success, warning, info, destructive, neutral }` + 5 级色阶 (`solid, foreground, muted, subtle, border`)
4. **Typography**: 使用 `TypographyToken.levelN.body(context)` + `copyWith()` 调整
5. **Spacing**: 使用 `Spacing.levelN` 间距体系
6. **Radius**: 使用 `RadiusTokens.levelN` + `RadiusTokens.levelFull`（全圆）
7. **图标**: 使用 `FLucideIcons.*`，不用 Material `Icons.*`
8. **l10n**: 编辑 `lib/l10n/src/medicine_*.arb` fragment 文件，不直接编辑 `app_*.arb`
9. **不使用 CircularProgressIndicator**: loading 状态用 shimmer skeleton
10. **页面 header**: 子页面使用标准 header（返回箭头 + 居中标题），通过 `PageScaffold`
11. **LLM 复用**: 继承 `BaseLlmGeneratorService`，复用 circuit breaker / retry / metrics 基础设施
12. **事件驱动**: 使用 `@OnEvent` 装饰器 + `EventEmitter2`，不直接导入跨模块服务
