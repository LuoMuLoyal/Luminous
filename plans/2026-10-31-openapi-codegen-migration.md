---
status: active
owner: frontend
updated: 2026-10-31
---

# OpenAPI 生成器迁移：dart-dio → degenerate（OAS 3.2 + 类型安全 SSE）

Created: 2026-10-31

> 状态：**未开工**。本计划记录一次实测评估的结论，并给出分阶段迁移路径。
> 触发背景：user 提出「OpenAPI 3.2 已提供 SSE 支持，可以生成类型安全的客户端，是否该换了」。

- 范围：`Luminous`（生成器与客户端）、`Lucent`（spec 版本与 SSE 帧协议）
- 结论先行：生成器可换且质量过关，但**换生成器本身不产生收益**，真正的前置条件是
  改掉「SSE 语义藏在 `event:` 名里」这一协议形状。按 P0 → P4 顺序推进。

---

## 0. 背景

当前链路（`AGENTS.md`「Cross-Project Contract」）：

```
Lucent controller/DTO + zod
  → pnpm export:openapi            （openapi.json，OAS 3.0.0 直出）
  → Luminous: dart run scripts/contract/bootstrap.dart
      → openapi-generator-cli 7.25.0 + dart-dio   → generated/lucent_api/
      → build_runner（json_serializable + copy_with_extension）
```

2025-09-05 曾评估 OAS 3.1/3.2 升级并**放弃**，理由记录在
`Lucent/docs/archive/2026-09-05/2026-09-05.md`、`Luminous/docs/archive/2026-09-05/2026-09-05.md`，
结论固化在 `Lucent/AGENTS.md`「Working Rules」：*"OpenAPI spec stays OAS 3.0 direct output —
3.1/3.2 upgrade is deferred (upstream dart-dio bugs + validator gaps)"*。

本次重新评估发现：**当初的否决对 openapi-generator/dart-dio 成立，但对整个 Dart 生态不成立**。
存在另一条技术路线（`degenerate`）已经支持 3.2 + 类型安全 SSE。**旧结论需要修正。**

---

## 1. 实测结论

以下全部为本机实跑结果（Dart SDK 3.13.5 / Flutter 3.47.7 / Windows），非文档引用。

### 1.1 旧结论的两处修正

**(a) openapi-generator 至今仍读不了 `openapi: 3.2.0` —— 旧结论正确，且已 13 个月未变**

实测 `openapi-generator-cli 7.26.0`（当前最新，2026-10-06 发布；我们 pin 的是 7.25.0）：

```
$ java -jar openapi-generator-cli-7.26.0.jar validate -i probe32.yaml
- attribute openapi is unexpected
- attribute paths.'/stream'(post).responses.200.content is unexpected
- attribute components is unexpected
[error] Spec has 4 errors.
```

更危险的是 `generate --skip-validate-spec`：**exit 0，但产出零文件**（静默失败）。
根因是上游 `swagger-parser` 没有 3.2 对象模型，与我们的配置无关。

**(b) dart-dio 的 nullable bug 爆炸半径被高估了 —— 旧结论需要收窄**

旧记录称 *"任一表达（`anyOf [T,null]`、`nullable:true`、数组 type）都会把可空字段生成成非空
Dart 类型，影响面达全量模型"*。在 7.26.0 上复测两种典型形态，**Dart 类型均正确**：

| 形态 | 生成结果 |
| --- | --- |
| `required` + `$ref` + `anyOf [Nested, null]`（#21510 场景） | `final Nested? nested;` ✅ |
| `required` + `type: [object,'null']` + inline `properties`（#23866 场景） | `final ThingInline? inline;` ✅ |
| 顶层 `type: [string,'null']` / `[array,'null']` | `String?` / `List<String>?` ✅ |

上游两个 issue（#21510、#23866）在 GitHub 上**仍是 open 状态、无 assignee、无近期活动**，
所以不能据此宣称「bug 已修」；但「影响全量模型」这一判断不成立，`Lucent` 侧
`export-openapi.ts` 的 3.0 兼容过滤不必再以此为由继续扩大。

> 该修正本身**不构成本次迁移的理由**，只是把历史决策的依据校准到事实。

### 1.2 `degenerate` 生成器评估

候选：[`degenerate`](https://pub.dev/packages/degenerate) v0.5.0，MIT，pub.dev 验证发布者
`blopker.com`。自述「Strives for full OpenAPI 3.0, 3.1, and 3.2 compatibility」，
并提供 SSE/JSONL 的 `Stream<T>` 类型化流式。

**用我们真实的 `Lucent/docs/reference/generated/openapi.json` 直接生成**（OAS 3.0.0，
161 paths / 396 schemas）：

```
$ dart run degenerate -i our.json -n lucent
Generated 440 files
$ dart analyze lib/lucent
No issues found!                                      ← 440 文件零告警
```

运行时行为抽测（真实模型 `AccountResponse`）：

| 检查 | 结果 |
| --- | --- |
| `fromJson` → `toJson` 键保留 | 10/10 ✅ |
| nullable 字段往返（`email: null`） | 保持 `null` ✅ |
| 缺 key 容错 | 不抛异常，返回 `null` ✅ |
| `==` / `hashCode` 值语义 | 正确 ✅ |
| 现有 snake/camel 命名 | 正确归一 ✅ |
| DTO 字段注释（JSDoc）透传 | ✅ |

工程质量观察：走规范化 IR + `code_builder` 构建 AST，不是字符串模板拼接。有专门的安全加固
（[PR #18](https://github.com/blopker/degenerate/pull/18) 把 spec 可控字符串包成 `SpecString`
类型，从类型层面阻止描述字段注入 Dart 源码）。

### 1.3 SSE 能力：有类型，但**丢弃 `event:` 名**

| 输入 | 生成签名 |
| --- | --- |
| 我们当前的 3.0 spec（`schema: {type: string}`） | `Stream<String>` |
| 3.2 + `itemSchema: Chunk` | `Stream<Chunk>` |
| 3.2 + `itemSchema: oneOf[Chunk, Result, Error]` | `Stream<StreamMessagesEvent>`（`OneOf3<...>`），`dart analyze` 零问题 |

但对**我们真实的四帧协议**做线上探针，发现决定性缺陷：

```
event: chunk  data: {"content":"hi"}          → 解析成功
event: result data: {"conversationId":"c1"}   → 解析成功
event: done   data: {}                        → PARSE FAILED
    ArgumentError: No variant matched for value ({}):
      ChunkEvent: type 'Null' is not a subtype of type 'String' in cast
      ResultEvent: ...
      ErrorEvent: ...
```

根因在 `degenerate_runtime-0.5.0/lib/src/api_executor.dart` 的 `executeStreaming`：

```dart
parseStream: (bytes) => parseSseStream(bytes).map((event) => event.data),
//                                            ^^^^^ 只取 data，丢弃 event.name
```

runtime 内部其实解析出了 `SseEvent.event`（`sse.dart` 有该字段），但生成器的回调契约只传
`data`。于是**类型判别退化为「按 payload 结构试解析」**（`OneOfN.parse` 逐个 `fromJson` 试错），
而不是按帧名分派。

这与我们的协议直接冲突：`Lucent` 三个流式端点的语义**相当一部分编码在 `event:` 名上**——

- `done` 帧 data 是 `{}`（无判别信息）
- `error` 帧走 Problem Details，与 `result` 帧可能结构重叠
- 帧序语义（`chunk → result → done`）本身就是协议的一部分
  （`Lucent/docs/archive/01-reference/toolchain.md` 明确记录事件名与顺序是 runtime 语义）

**因此：换生成器前必须先把协议改成「每帧 data 自带判别字段」。** 这是本计划 P0。

---

## 2. 决策

**换，但收益来自「协议自描述化 + 类型化流」，而不是「换个生成器」。** 分阶段推进，每阶段可独立回退。

### 2.1 为什么值得换（正面）

1. **SSE 从手写解析变成生成代码**：目标形态是删掉
   `lib/core/network/client/sse.dart` 的手写分帧/解析，改由生成器直接产出
   `Stream<T>`。当前 doc 明确记录 SSE 不走生成客户端（`docs/reference/openapi-client.md:107`），
   这是长期的技术债。
2. **移除 build_runner 链路**：`degenerate` 产出纯 Dart，不需要 `json_serializable` +
   `copy_with_extension` 的 `.g.dart`。少一层代码生成、少一类漂移。
3. **枚举未知值原生保留**：当前靠 `openapi_gen_config.json` 的 `enumUnknownDefaultCase: true`
   打补丁，`degenerate` 内建（`$Unknown` 变体 + raw value 往返）。
4. **响应按 status/media type 生成 sealed 变体**，与 ADR-0012（无 envelope + Problem Details）
   形态契合，可类型化消费错误。
5. **`Omittable<T?>` 能表达 PATCH 三态**，有望删掉「用裸 Dio JSON 绕过生成 DTO」那批 workaround
   （见 `docs/reference/openapi-client.md` 的 PATCH 约定）。

### 2.2 为什么不能现在直接换（阻力清单）

| 阻力 | 说明 |
| --- | --- |
| 协议冲突 | 生成器丢弃 `event:` 名，我们的帧语义靠名字表达 → 必须先改协议（P0） |
| 发出端产不出 `itemSchema` | `@nestjs/swagger` 硬编码 `openapi: '3.0.0'`（无 `itemSchema` 发射能力）→ 必须在 `export-openapi.ts` 手工注入 |
| 迁移面 | `package:lucent_api/` 被 **119 个文件**引用；客户端形状全变（模型名、`ApiResult`、`Omittable`、枚举 class 化） |
| 无增量路径 | 新旧生成物不能共存，是一次性替换 |

---

## 3. 风险登记

按「会不会伤到线上」排序。

### R1 — 单人项目，bus factor = 1（高）

实测数据（GitHub API，2026-10-31）：

| 指标 | 值 |
| --- | --- |
| 仓库创建 | 2026-03-09（**7 个月**） |
| 最后 push | **2026-09-10**（约 7 周前） |
| Stars / Watchers / Forks | 5 / **1** / 4 |
| 贡献者 | **2 人**：`blopker` 153 commits、`josher8a` 4 commits（**97% 单人**） |
| 版本 | **0.5.0（未到 1.0）** |
| 周下载 | 683 |
| CI | 有（`.github/workflows/ci.yml`） |

**对冲手段（必须做）**：生成产物入库 + 版本精确 pin + 快照 diff。
产物是纯 Dart、运行时仅依赖 `meta`，最坏情况可 vendor 一份产物继续用，不会像
openapi-generator 那样被 Java 生态锁死。

### R2 — 0.x 破坏性变更频繁（高）

0.4 → 0.5 已有 7 项 breaking change（README 迁移表），其中影响我们的：

- optional nullable 由 `T?` → `Omittable<T?>`
- `copyWith` 可选字段改 **thunk 形态**（实测 `copyWith(nickname: "x")` 编译失败，
  须写 `copyWith(nickname: () => "x")`）

**对策**：精确 pin `0.5.0`（不用 `^`）；升级前先跑快照 diff 再决定。

### R3 — 认证链路冲突（高，须专门验证）

`degenerate_dio` 自带 `AuthInterceptor`（含 `refreshToken` 回调）。**我们的架构禁止走它**：
按 `AGENTS.md`「Lumine/lumine 约束」与 `Luminous/AGENTS.md`，refresh 是**一次性轮换 +
重放检测撤销整族**，必须走单飞 `refreshSession()`。绕过单飞可能让服务端判定盗用并撤销整条会话链。

**对策**：只把 `degenerate` 当**传输层**，认证继续用我们自己的 Dio interceptor；
**不得**启用生成器的 `AuthInterceptor`。P2 必须有一条「access token 过期 → 单飞续期 →
重试」的端到端用例。

另：开放 issue [#25](https://github.com/blopker/degenerate/issues/25)（per-path servers）、
[#26](https://github.com/blopker/degenerate/pull/26)（cookie/query 型 securityScheme）
至今未见回应，两者都碰认证。我们不走生成器的 security 机制可绕开，但需确认。

### R4 — Web 端流式可能仍然不逐字（中，须验证）

已知遗留：`docs/TODO.md` 记录 **dio Web 适配器用 XHR + arraybuffer 整流缓冲**，
Flutter Web 上助手回答无逐字流式（三条 SSE 共用同一客户端）。

`degenerate_http` 基于 `package:http`，Web 端同样是 XHR。**不能假设换生成器能解决这个问题**，
甚至可能维持现状。P2 必须实测 Web 端帧到达时序，再决定是否维持原有 TODO。

### R5 — 生态用户极少，bug 由我们先发现（中）

683 周下载、5 stars 意味着真实世界覆盖有限，我们 396 个 schema 的契约很可能踩到别人没踩的路径。
已知它在 0.4.x 修过一批「生成代码根本编译不过 / URL 拼错」级 bug：

- [#7](https://github.com/blopker/degenerate/issues/7) `$ref` 字符串枚举进 URL 变 `Color(red)`
- [#8](https://github.com/blopker/degenerate/issues/8) apiKey 缺 `in` 时引用未生成的方法，**包无法编译**
- [#9](https://github.com/blopker/degenerate/issues/9) 空 security 列表推断成 `List<dynamic>`

**对策**：`dart analyze` + 全量测试作为切换门禁；不靠「看代码没问题」判断。

### R6 — 手工契约维护点（中）

`itemSchema` 无法由 NestJS 产出，需在 `Lucent/scripts/contract/export-openapi.ts` 注入。
这与「不手写端点文档」原则有摩擦，属可控但需记账的技术债。

### R7 — 生成器 CLI 的平台要求（低，已满足）

- 生成器本体：需 Dart **3.11.1+**（桌面 CLI）→ 本机 3.13.5 ✅
- 生成产物 + runtime：需 Dart **3.8.0+** → ✅
- 产物跨平台（iOS/Android/Web/桌面），仅 CLI 限桌面 → CI 需能跑 `dart run degenerate`

---

## 4. 迁移步骤

### P0 —— SSE 帧协议自描述化（前置，独立价值）

**目标**：每帧 `data` 自带判别字段，让「按结构判别」成为可靠手段。

- 新增字段建议：`type: 'chunk' | 'result' | 'error' | 'done'`，与 `event:` 名保持一致
  （双写过渡期，向后兼容）。
- `done` 帧由 `{}` 改为 `{"type":"done"}`。
- 覆盖 4 个当前 SSE operation：
  - `POST /api/v1/user/assistant/messages/stream`
  - `POST /api/v1/user/assistant/conversations/{conversationId}/regenerate`
  - `POST /api/v1/user/today-analysis/generate/stream`
  - `POST /api/v1/layouts/{surface}/generate`
- 涉及 `Lucent/src/common/api/sse/sse.ts` 与四个 controller；同步更新
  `Luminous/lib/core/network/client/sse.dart` 消费侧与既有 SSE 测试。
- **此阶段不换生成器**，价值独立：现有手写解析也会因此简化，且为 P2 铺路。

### P1 —— spec 升 3.2 + 注入 `itemSchema`

- `export-openapi.ts:582` 的 `openapi: '3.0.0'` → `'3.2.0'`；
  zod 侧 `target: 'openapi-3.0'`（`:671`）需评估是否有 3.1/3.2 target，
  否则保持 3.0 语义后再手工提升文档版本。
- 为 4 个流式端点注入 `content['text/event-stream'].itemSchema`，
  指向「帧判别 + payload」的 `oneOf` schema。
- 校验：`openapi.json` 能被 `degenerate` 解析且 4 个 SSE 端点都生成精确类型
  （不应再出现 `Stream<String>`）。

### P2 —— 生成器切换（分支内，带基线）

1. 记录基线：当前 `generated/lucent_api/` 全量快照 + `dart analyze` / `flutter test` 结果。
2. 新增 `degenerate` 到 dev_dependencies，**精确 pin `0.5.0`**。
3. 在 `Luminous/scripts/contract/` 下新增生成入口（与现有 `bootstrap.dart` 并列，
   不直接改写，便于回退）。约定：
   - `--omittable=off` 起步（与 dart-dio 输出行为对齐，降低 churn）；
     P3 之后再评估是否对 PATCH 端点切到 `nullable`
   - `enumUnknownDefaultCase` 概念由生成器内建承接，无需额外配置
   - 输出到新目录（如 `generated/lucent_api_next/`）与旧产物并行，便于 A/B
4. 跑 `dart analyze`，要求**零 issues**；有任何 issue 即视为阻塞，先上报。
5. 用真实 3.2 spec 做流式端到端验证：四帧全部正确分派。

### P3 —— 消费侧迁移（119 文件）

按 feature 分批，每批一个提交：

1. 机械替换：`package:lucent_api/...` 路径与模型名。
2. 语义替换：
   - `Future<Response<T>>` → `ApiResult<T, E>` + `dataOrThrow` / sealed 变体
   - 枚举 `.name` → `.value`（未知值保留语义）
   - nullable 读写点按 `--omittable` 选择调整
3. 优先删掉因既有缺陷存在的 workaround（裸 Dio JSON 写 PATCH、手写分帧）。
4. 每批跑 `flutter analyze` + 该 feature 测试。

### P4 —— 收尾

- 删除 `lib/core/network/client/sse.dart` 的手写解析（若 P2 端到端验证通过）。
- 删除 `bootstrap.dart` 的 `_filteredClients` 过滤生成机制与 `openapi_gen_config.json`
  （`degenerate` 有 `--tag` / `--path` 过滤，需评估能否等价替代；其「未用类型自动 tree-shake」
   可能让整套 `_filteredClients` 清单直接消失）。
- 移除 `json_serializable` / `copy_with_extension` / `build_runner` 在生成客户端链路上的配置。
- 更新 `docs/reference/openapi-client.md`（SSE 边界那一节必改）、
  `Luminous/AGENTS.md`「OpenAPI Client」、`Lucent/docs/howto/sync-openapi-client.md`、
  `Lucent/AGENTS.md`「Working Rules」里那条 3.0 冻结声明。
- 追加双方 migration log；本计划执行完毕后删除。

---

## 5. 需要注意的点（硬约束）

1. **不得启用生成器的 `AuthInterceptor`**。refresh 只能走单飞 `refreshSession()`（见 R3）。
2. **不得手改生成物**。需要新字段就改 `Lucent` 契约再生成。
3. **不得用 `--skip-validate-spec` 之类手段绕过校验**——实测那会静默产出零文件。
4. **版本精确 pin，不用 `^`**。0.x 破坏性变更频繁（见 R2）。
5. **审计 `event:` 名的剩余用途**。P0 之后 `event:` 应降级为传输冗余，
   业务语义必须能从 `data` 单独推出；否则 P2 会再次撞墙。
6. **`Omittable` 不要一步到位**。先 `off` 保 parity，再针对 PATCH 端点单独开。
7. **失败即停**：`dart analyze` 非零 issues、或四帧探针有任一帧解析失败，
   都视为阻塞而非「后续再修」。

---

## 6. 回退方案

| 阶段 | 回退动作 |
| --- | --- |
| P0 | 新增判别字段是向后兼容的，旧客户端无需同步改 |
| P1 | `itemSchema` 是纯增量；回退只需把 `openapi` 版本改回 3.0.0 并移除注入 |
| P2/P3 | 新旧产物并行目录；未删除旧生成器前，`bootstrap.dart` 原路径随时可用 |
| P4 | 只有在 P2/P3 全绿且观察期过后才删旧链路 |

最坏情况（上游弃坑）：产物为纯 Dart，可 vendor 入库继续维护，不阻塞交付。

---

## 7. 待确认项（尚未实测，不得当作已知）

- [ ] `@nestjs/swagger` 是否支持 `setOpenAPIVersion('3.2.0')` 且不与现有导出校验冲突
- [ ] zod 4 `toJSONSchema` 有无 3.1/3.2 target；没有时手工提升版本的副作用面
- [ ] `degenerate --tag` / `--path` 能否等价替代 `_filteredClients` 的按需切分
- [ ] Web 端（`degenerate_http` + XHR）SSE 是否逐字流式（见 R4）
- [ ] 生成产物对 `flutter test` / `integration_test` 的全量回归影响面
- [ ] `degenerate` 对 RFC 9457 Problem Details（`application/problem+json`）的映射质量
- [ ] `pubspec.yaml` 的 `sdk` 约束是否已满足产物要求的 Dart 3.8+

---

## 8. 验收标准

1. `dart analyze`：全仓零 issues（含生成物）。
2. 四帧探针：`chunk / result / error / done` 全部按判别字段正确反序列化。
3. 三条既有流式链路（assistant / today / reports-or-layouts）端到端跑通。
4. access token 过期 → 单飞续期 → 重试成功，且无重复 refresh 请求。
5. `flutter test` 全绿；`--clean-layers` 门禁不新增违规（生成物在 `generated/` 下需确认
   是否落在 `directory_file_cap` 等规则扫描范围内）。
6. 生成物快照入库，`verify` 脚本可检出非预期漂移。

---

## 9. 附：本次实测复现方法

```bash
# 1. 生成器能力
dart pub add dev:degenerate degenerate_runtime degenerate_http   # 0.5.0
dart run degenerate -i ../../../Lucent/docs/reference/generated/openapi.json -n lucent
dart analyze lib/lucent

# 2. 四帧协议探针（构造 3.2 spec + itemSchema: oneOf，喂真实帧文本）
#    见 §1.3 输出

# 3. openapi-generator 对照（证明 3.2 输入仍不可用）
java -jar openapi-generator-cli-7.26.0.jar validate -i probe32.yaml
```

> 上述临时探针目录已在 2026-10-31 清理（移到回收站），未留在工作区。
