---
status: frozen
owner: frontend
updated: 2026-10-29
---

# 前端架构治理：严格 Clean Architecture + DDD-lite

Created: 2026-10-21（2026-10-29 重写为严格 Clean + DDD-lite；原「标准 DDD 全套」与本轮的「基线对账版」均已作废）

> **口径已经裁定，不再讨论**：
>
> 1. **严格 Clean**：`presentation` 只能依赖 `application` + `domain`，**永不 import `data/`**
>    ——包括 `presentation/providers/`。现在的「providers 作组合根」是 MVVM，不是 Clean。
> 2. **DDD-lite**：`application/` 不是可选层，**16 个 feature 全部建立**，use case 按用户意图切。
> 3. **无白名单**：不划 sanctioned seam、不设目录豁免、不做基线对账。规则一律 error。
> 4. **目录硬约束**：任一目录直接源文件 **≤ 8**（不含 `.g.dart` / `.freezed.dart`）。
> 5. **不移植 Lucent 的 `arch-check-with-baseline`**：门禁直接是 error；清理是大规模改动，不是增量容忍。

## 0. 目标形态

```text
lib/features/<feature>/
  domain/          最内层，零外部框架依赖。
                   允许：dart:*、fpdart、freezed_annotation、meta、clock
                   禁止：flutter / flutter_riverpod / dio / drift / lucent_api /
                         flutter_local_notifications / paddle_ocr_native /
                         path_provider / permission_handler / units_converter / crypto
                   以及任何 features/*/ 的其他层
  application/     use case + ports。只依赖 domain。
                   禁止：flutter / flutter_riverpod / dio / data/ / presentation/
                   （Ref 不进 use case；use case 收纯参数、返回纯结果）
  data/            domain 仓储接口的实现 + datasource + mapper。
                   禁止：presentation/ / application/ / 其他 feature 的任何层
  presentation/    pages / widgets / controllers / providers。
                   只依赖 application + domain。禁止 import data/
  infrastructure/  ← 新增：组合根
                   唯一同时知道 data 与 providers 的层：把 data 实现注入 providers
```

**依赖方向**（Clean 的唯一判据，箭头 = 可以依赖）：

```text
presentation ──▶ application ──▶ domain ◀── data
       ▲                                      │
       └────────── infrastructure ◀───────────┘
```

`infrastructure/` 在 `lib/app/` 与 `core/` 里，不在 feature 内部：feature 内的 `main`/`app` 装配统一由 `lib/app/bootstrap` 注入。

## 1. 全量实测（2026-10-29，743 个非生成 Dart 文件，3329 条 import 边）

### 1.1 违规全表（严格 Clean + 无白名单口径）

| # | 违规 | 边数 | 源文件 | 说明 |
| --- | --- | --- | --- | --- |
| C1 | `presentation → data`（**含 providers**） | **114** | **94** | 其中 providers 内 51 边 / 40 文件，providers 外 63 边 / 54 文件 |
| C2 | `application → presentation` | 21 | 9 | 现存 `application/` 本身就是坏的 |
| C3 | `data → presentation` | 4 | 3 | 方向倒置 |
| C4 | `data → 其他 feature`（任意层） | 72 | 39 | 无白名单，全部要断；现有规则只禁 data→data，漏了 data→domain/provider |
| C5 | `domain → 禁止依赖` | 0 | 0 | 按 `package:` 统计为 0；但需用 1.3 的按文件口径复核 |
| C6 | `core → feature` | 11 | 6 | 现有 `core/auth`、`core/push` 白名单**取消** |

### 1.2 `presentation → data` 按 feature（94 文件，含 providers）

| feature | providers 内 | providers 外 | 合计 |
| --- | --- | --- | --- |
| record | — | 18 | 18 |
| medicine | — | 8 | 8 |
| mine | — | 7 | 7 |
| settings | — | 6 | 6 |
| scan | （无 providers） | 4 | 4 |
| today / review / auth / search | — | 2 / 2 / 2 / 2 | 8 |
| notification / health_data / shell | — | 1 / 1 / 1 | 3 |

（精确到文件的清单在 C1 阶段用门禁扫描生成，不在计划里手抄——手抄会漂。）

### 1.3 `domain/` 的外部依赖（15 个文件）

| 包 | 文件数 | 是否允许 |
| --- | --- | --- |
| `fpdart` | 24 | ✅ 允许 |
| `freezed_annotation` | 20 | ✅ 允许 |
| `clock` | 2 | ✅ 允许 |
| `meta`（经 `flutter/foundation` 间接） | 8 | ✅ 允许，但**必须改直接 import `package:meta`** |
| `flutter/material` | 5 | ❌ 迁出 |
| `flutter/services` | 2 | ❌ 迁出 |
| `flutter_riverpod` | 2 | ❌ 迁出 |
| `dio` | 1 | ❌ 迁出 |
| `lucent_api` | 1 | ❌ 迁出 |
| `flutter_local_notifications` | 1 | ❌ 迁出 |
| `paddle_ocr_native` | 1 | ❌ 迁出 |
| `path_provider` | 1 | ❌ 迁出 |
| `permission_handler` | 1 | ❌ 迁出 |
| `units_converter` | 1 | ❌ 迁出 |
| `crypto` | 1 | ❌ 迁出 |

### 1.4 `application/` 覆盖度（16 个 feature 的现状）

| feature | 现状 | 目标 |
| --- | --- | --- |
| record | 9 个文件，其中 7 个 import `presentation/` | 重写为 use case |
| today | 2 个，含 `quick_entry_water.dart` import record 的 presentation | 重写 |
| settings | 1 个，import `presentation/providers/` | 重写 |
| **其余 13 个 feature** | **0** | **新建** |

### 1.5 目录超限（裸文件 > 8 的 12 个目录，合计多出 49 个文件）

| 目录 | 裸文件 | 超 | 拆分方向 |
| --- | --- | --- | --- |
| `features/auth/presentation/pages` | 16 | 8 | `login/` `register/` `account/` `oauth/` |
| `features/settings/presentation/pages` | 16 | 8 | `notification/` `data/` `advanced/` `about/` |
| `core/database/daos` | 14 | 6 | `records/` `medicine/` `review/` `sync/` |
| `core/database/tables` | 14 | 6 | 同 daos 分组（表与 DAO 一一对应，必须同步分） |
| `features/review/presentation/widgets/sections` | 13 | 5 | `overview/` `history/` `preview/` |
| `features/medicine/presentation/widgets/risk` | 12 | 4 | `overview/` `findings/` `coverage/` `shared/` |
| `features/record/presentation/widgets/sections` | 12 | 4 | `dashboard/` `quick_entry/` `detail/` |
| `features/mine/presentation/widgets/sections` | 11 | 3 | `account/` `archive/` `sync/` |
| `features/settings/presentation/providers` | 10 | 2 | `notification/` 子目录（已有 6 个 notification_* 文件） |
| `core/widgets/common/control` | 9 | 1 | `desktop/` 子目录（3 个 desktop_* 文件） |
| `features/auth/data/datasources/wechat` | 9 | 1 | 已接近，按 `client/` `callback/` 分 |
| `features/medicine/presentation/widgets/reminder` | 9 | 1 | `form/` `detail/` |

> 拆分规则与仓库既有命名规则一致：目录已表达类型就不加后缀；`domain/<聚合>/` 与
> `presentation/<子域>/` 是**目录语义**，不是类型后缀。

## 2. 分层契约（唯一事实源，全部为 error）

| # | 规则 | 违规 | 阶段 |
| --- | --- | --- | --- |
| R1 | `domain/**` 只允许 `dart:*`、`fpdart`、`freezed_annotation`、`meta`、`clock`、以及**同层 `domain/` 内**文件 | §1.3 | C1 |
| R2 | `domain/**` 不得 import 任何 `package:flutter*`、`dio`、`drift`、`lucent_api` 及 §1.3 其余包 | 15 文件 | C1 |
| R3 | `application/**` 只允许 `domain/**` + `dart:*` + `fpdart` + `meta` + `clock` | 22 文件（新增后） | C2 |
| R4 | `data/**` 只允许 `domain/**` + 本层 + `dart:*` + 第三方包 + `core/network`、`core/database`、`core/storage` | 43 文件（C3+C4） | C3 |
| R5 | `presentation/**` 只允许 `application/**` + `domain/**` + 本层 + `core/design`、`core/widgets`、`core/i18n`、`core/feedback` 等纯 UI 包 | **114 边 / 94 文件** | C4 |
| R6 | 任何 feature **不得 import 其他 feature 的 `data/` 或 `presentation/`**；跨 feature 只经 `domain/` 或 `application/ports/` | 见 2.1 | C5 |
| R7 | `core/**` 不得 import `features/**`（**无白名单**） | 11 边 / 6 文件 | C6 |
| R8 | 任一目录直接源文件 ≤ 8（排除生成文件） | 12 目录 / 49 文件 | C7 |
| R9 | 不出现 `presentation/services/`（5 个文件）与 `data/providers/`（20 个文件）两个既非层也非职责的目录 | 25 文件 | C3/C4 |

### 2.1 R6 的现实：跨 feature presentation 耦合 219 个文件

实测跨 feature 的 `presentation → presentation` 边有 **666 条、219 个源文件**。
严格执行 R6 等于重写整个 UI 层——**这一条不是 C1–C7 同批交付的**，见 §4 的 C5 与 §5 并行策略。

R6 的落地路径是：先用 `domain/` + `application/ports/` 建出跨 feature 的正式接缝，
把「跨 feature 的显示组件复用」降级为「跨 feature 的数据复用」，UI 组件本身不跨 feature 暴露。

## 3. feature 目标结构

```text
lib/features/<feature>/
  domain/
    <aggregate>/
      <aggregate>.dart          # 聚合根/实体
      <entity>.dart
      <value_object>.dart
    repositories/<aggregate>.dart   # 仓储接口
    services/<policy>.dart          # 跨聚合的纯规则
  application/
    use_cases/<intent>.dart         # 用户意图命名的单一操作
    ports/<outbound>.dart           # 平台/网络出站接口（domain 实现不了的能力）
    read_models/<view>.dart         # 查询侧投影（CQRS 的读）
  data/
    repositories/<impl>.dart        # 实现 domain 仓储接口
    datasources/<source>.dart
    mappers/<aggregate>.dart
  presentation/
    pages/<subdomain>/page.dart
    widgets/<subdomain>/*.dart
    providers/<subdomain>/*.dart
    controllers/<flow>.dart
```

`data/providers/` 取消（20 个文件）：datasource 的 provider 归 `infrastructure` 层装配，
或直接在 `data/repositories/` 的构造函数里收参数、由 app 层注入。

`presentation/services/` 取消（5 个文件）：纯逻辑下沉 `domain/services/`，
平台适配器归 `data/datasources/`，UI 流程归 `presentation/controllers/`。

## 4. 阶段

每个阶段一个 PR 批次，可独立发布；批次内不改 UI 行为、路由、l10n、公开契约。

### C0 门禁落地（第一个开工）

把 `tool/luminous_lints` 的 R1–R9 全部以 **error** 生效，**不做基线、不做白名单**：

- `layered_import` 拆成 R1–R7 七条独立规则，各带独立 lint code
- 新增 `directory_file_cap` 规则（R8），阈值 8，排除 `*.g.dart` / `*.freezed.dart`
- 新增 `forbidden_directory` 规则（R9）
- 接入 `dart run scripts/workflows/daily.dart` 与 `.github/workflows/ci.yml`；pre-push 加 `--fatal`

**C0 期间 CI 必然红灯**——这是预期的：规则先上线、违规后清理。做法是
`--fatal` 只进 pre-push，CI 用 `--report` 出违规数，每个阶段结束违规数必须下降。
**不允许**为了让 CI 变绿而恢复 warn 模式。

估：2–3 天。

### C1 domain 纯净（R1 + R2）

15 个文件，按依赖类型分：

| 类型 | 文件 | 动作 |
| --- | --- | --- |
| `@immutable` | 8 个 | 改 `package:meta/meta.dart`（机械） |
| `IconData` | 3 个（`medicine/workspace`、`record/dashboard`、`review/dashboard`） | 域实体改存 Lucide 名称 `String`，presentation 用 `LucideIconBridge.resolve` |
| `Material`/`services` 死导入或平台能力 | 3 个（`record/sleep_entry`、`settings/notification_permission`、`record/fast_entry_choices`） | 迁出到 `data/datasources/` 或 `application/ports/` |
| 平台插件（dio/riverpod/notifications/paddle_ocr/path_provider/permission_handler/units_converter/crypto） | `scan/ocr_model_manager`、`scan/paddle_ocr_provider`、`medicine/reminder_notification_planner`、`auth/repositories/auth`（`lucent_api`） | 拆成 `domain` 纯规则 + `application/ports/` + `data/` 适配器 |

估：8–10 天（`scan` 的 OCR 与 `medicine` 的提醒计划是两个独立子任务，可并行）。

### C2 application 层建立（R3）—— **暂缓（3/16 完成）**

- 先把 3 个现存 `application/`（`record` 9、`today` 2、`settings` 1）重写成真 use case：
  去掉 `presentation/` 依赖，`Ref`/`BuildContext` 不进 use case
- 给 13 个 0 文件 feature 按**用户意图**建 use case（不是按 repository 方法）：
  - `auth`：`sign_in` / `sign_out` / `refresh_session` / `link_identity` …
  - `medicine`：`add_medicine` / `mark_dose` / `schedule_reminder` / `run_risk_check` …
  - `record`：`log_water` / `log_meal` / `log_sleep` / `change_date` …
  - `settings`：`change_theme` / `change_locale` / `toggle_notification` …
  - 只读 feature（`review` / `today` / `health_context` / `legal` / `support`）：
    只建 `read_models/` 与查询 use case，不建写 use case（CQRS 读侧）
- `presentation/providers/` 改为只 watch use case / read model，不 watch repository

估：20–25 天（16 个 feature，按意图切粒度，是整份计划最大的一块）。

### C3 data 层归位（R4 + 部分 R9）

- 去掉 `data → presentation` 的 4 条倒置边（格式化函数下沉 `domain/` 或 `core/utils/`）
- 去掉 `data → 其他 feature` 的 72 条边（39 文件）：跨 feature 读写改走对方 `domain/` 仓储接口
- 取消 `data/providers/`（20 文件）：装配移 `lib/app/infrastructure/`
- `presentation/services/` 的纯逻辑并入 `domain/services/`

估：15–18 天（跨 feature 的 72 条边里，`today` 与 `health_data` 占一半，见 §1.1 注）。

### C4 presentation 去 data（R5）

94 个文件 / 114 条边。前面 C2/C3 完成后，providers 里的 51 条边会自动消失
（改为 watch use case），实际要改的是 providers 外的 54 个文件：

`scan`(4) → `record`(18) → `medicine`(8) → `mine`(7) → `settings`(6) →
`today`(2) → `review`(2) → `auth`(2) → `search`(2) → `notification`(1) → `health_data`(1) → `shell`(1)

估：10–14 天。

### C5 跨 feature 接缝（R6 的实质部分）—— **暂缓（剩 51 条）**

666 条边 / 219 个文件。**不与 C1–C4 同批**：先建 `application/ports/` 与跨 feature 的
domain 接口，再按 feature 对逐个替换。按 feature 对分批，每个 PR 只处理一对
（如 `today ← record`、`search ↔ medicine`），逐对下降。

估：独立计划（本计划只建立规则与接缝模式，不承诺清理完 219 个文件）。

### C6 core 去 feature（R7）

11 条边 / 6 文件。`core/auth`、`core/push` 的白名单**取消**：

- `core/auth/session_*` → 依赖方向反转，session 快照经 `lib/app/infrastructure/` 注入
- `core/push/message_handler` → 目标改为事件/命令回调注入，不直接 import feature provider
- `core/database/sync/handlers` → 抽 `SyncHandler` 接口，由各 feature 在 app 层注册

估：5–7 天。

### C7 目录收敛（R8）

12 个目录 / 49 个文件，按 §1.5 的拆分方向执行。纯移动 + import 改路径，无逻辑改动。

估：5–7 天。

### 依赖

```text
C0 ──┬─→ C1 ┐
     ├─→ C2 ┼─→ C3 ──→ C4 ──┬─→ C7
     ├─→ C6 ┘                │
     └─→ C5（独立，按 feature 对分批，可长期进行）
```

## 5. worktree 并行划分

六个 worktree + 六个 `arch/*` 分支（W1 domain / W2 application / W3 data / W4 presentation /
W5 core / W6 dirs，按层切而非按 feature 切）已于 2026-10-29 全部合入 `develop` 并回收，
独立引导脚本保留在 `scripts/arch/bootstrap-worktree.ps1`。

## 6. 不在本计划

- **组件化**（`plans/2026-10-28-composable-tabs.md`）：本计划定「组件从哪取数据」，不做组件目录。
- **DDD 全套**：聚合根、领域事件、上下文映射、ADR-0010、ubiquitous-language——仍不做（DDD-lite）。
- **C5 的 219 个文件全部清理**：只建规则与接缝模式。
- **`fast_entry_choices.dart` 领域建模**（domain 里存了 `RecordFastChoice.label` 本地化文案）：
  C1 迁出后记入 `docs/TODO.md`。
- **UI / 路由 / l10n / 生成契约**：零变化。

## 7. 验收

- R1–R9 全部 error，`luminous_lints --fatal` 在 pre-push 通过，违规数 0
- `domain/` 只有 `dart:*`、`fpdart`、`freezed_annotation`、`meta`、`clock`
- `application/` 只有 `domain/`，16 个 feature 全部有 `application/use_cases/`
- `presentation/` 对 `data/` 引用 0（含 providers）
- 跨 feature import 只经 `domain/` 或 `application/ports/`
- `core/` 对 `features/` 引用 0
- `lib/` 下裸文件 > 8 的目录 0 个
- 现有 widget / golden 测试断言不变

## 8. 风险

| 风险 | 应对 |
| --- | --- |
| C2 最大（20–25 天），阻塞 C3/C4 | C2 按 feature 拆 16 个独立 PR；`record`/`medicine`/`auth`/`settings` 先做，其余并行 |
| 规则先上线导致 CI 长期红灯 | `--fatal` 只进 pre-push；CI 用 `--report`；每阶段结束违规数必须下降 |
| C5 的 219 个文件无法限期完成 | 明确不进验收；只建接缝，按 feature 对长期递减 |
| `scan`/`medicine` 的 domain 迁出改变调用面 | 两个 feature 各拆独立 PR，先建 `application/ports/` 再改调用点 |
| 目录拆分与 C4 改同一批文件 | C7 排在 C4 之后；只移动不改内容，冲突时以 C4 为准 |
| 16 个 feature 建 application 后 use case 变成 repository 转发 | 按用户意图命名（`log_water` 而非 `create_record`），一个意图可以对多个 repository 调用 |

## 9. 收口状态（2026-10-29）

本计划**冻结**：规则部分已全部落地，剩下的 C2（application 层推广到其余 13 个 feature）与
C5（跨 feature 接缝收敛）暂缓，等组件化计划推进到编排层再决定是否重启。

已完成并合入 `develop`：

| 阶段 | 结果 |
| --- | --- |
| C0 门禁落地 | `--clean-layers` 模式 R1–R9 生效，违规即 exit 1；接入 pre-push、`daily.dart`、CI（CI 暂带 `continue-on-error`） |
| C1 domain 纯净 | 清零（`lib/shared/domain/` 作为共享内核被显式允许） |
| C3 data 层归位 | 清零；`data/providers/` 目录删除并纳入 `forbidden_directory`；provider 装配上移 `lib/app/composition/` |
| C4 presentation 去 data | 清零；取数统一走各 feature 的 `presentation/providers/data_access.dart` 接缝 |
| C6 core 去 feature | 清零（`core/auth`、`core/push` 的旧豁免一并取消） |
| C7 目录收敛 | 清零；阈值 8 与 `AGENTS.md` 对齐 |

未完成、暂缓：

| 阶段 | 现状 | 暂缓原因 |
| --- | --- | --- |
| C2 application 层 | 3/16（`record`、`settings`、`today`）；其余 13 个 feature 的编排仍在 `presentation/providers/` | 与组件化计划的「表面挂载 + 组件取数」共用同一批 provider 装配，先定组件模型再回填，避免两次搬迁 |
| C5 跨 feature 接缝 | 剩 51 条（`presentation/providers/` 19、widgets 12、`shell` 9、其余零散） | 组件化计划 A0 会把 `cross_feature_import` 口径对齐到既有的 providers 接缝与 `shell` 豁免，届时多数条目不再算违规 |

验收项因此只达成一半：R1–R9 除 `cross_feature_import` 外全部为 0，
`presentation → data` 为 0，`core → features` 为 0，目录超限为 0；
`cross_feature_import` 与 16 个 feature 的 application 覆盖两项随 C2/C5 一起挂起。

重启时的入口：先读 `plans/2026-10-28-composable-tabs.md` 的 A0/A4，那里定义了新的编排层形态，
C2/C5 的剩余工作应在其之后按新形态执行，不再按本计划原文推进。
