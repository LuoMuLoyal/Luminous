# 目录结构整理:文件命名与裸文件治理

> 创建于 2026-08-30。背景:对 `lib/` 全量审计后发现一批与 `AGENTS.md`「File Naming Rules」
> (文件名 = 职责,而非位置)不符的文件名,以及多个裸文件过多的目录。本计划给出逐条清单、
> 执行批次与风险对策。范围仅限 `lib/` 与对应 `test/` 镜像;不改任何运行时行为。

## 一、审计范围与方法

- 扫描 `lib/` 全部 718 个 dart 文件(排除 `generated/`),对照 AGENTS.md 八条命名规则逐条核查。
- 按目录统计裸文件数(源文件,不含 `.g.dart` / `.freezed.dart`),阈值:>10 触发分组,8–10 观察。
- 用 grep 核实可疑文件的引用链,确认改名冲突与死代码候选。
- 结论:**import 全部为 `package:luminous/...` 绝对导入**(无跨 feature 相对导入),重命名只需
  字符串级替换,迁移成本低。

## 二、违规清单

### 2.1 P1 — 机械改名(规则明确违反,低风险)

**A. 目录名 = 文件名 / 纯类型词(规则 2、3)**

| 现状                                                   | 目标                                                                                  | 依据       |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------- | ---------- |
| `core/logger/logger.dart`                              | 候选`log_level.dart`(内容:LogLevel 枚举 + Talker 日志 provider)                       | 规则 3、2  |
| `core/theme/theme.dart`                                | 候选`family.dart`(内容:AppThemeFamily + 主题数据)                                     | 规则 3     |
| `core/shortcuts/shortcuts.dart`                        | 候选`bindings.dart`(内容:AppShortcuts 全局快捷键装配)                                 | 规则 3     |
| `core/design/icon_tokens.dart`                         | `semantic_icons.dart`(与类名 `SemanticIcons` 一致,现名不达意)                         | 职责可达性 |
| `features/search/presentation/widgets/views/view.dart` | 候选`content.dart`(纯类型词 `view`,内容:搜索主视图组合各 section)                     | 规则 2     |
| `features/record/presentation/constants.dart`          | 候选`ui_defaults.dart`(纯类型词 `constants`,内容:UI 默认值——日历年份边界、对话框尺寸) | 规则 2     |

> 标注「候选」的名字需在执行时按文件实际内容最终确认,见第 3 节决策点 D2。

**B. 目录已传达类型的类型后缀(规则 1)**

| 现状                                                                                                                                                                    | 目标                                                                |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `core/database/daos/*_dao.dart` × 8(current_medicine / daily_record / health_context / medicine_dose_log / pending_sync / review / review_dashboard / today_suggestion) | 去掉`_dao`:如 `current_medicine_dao.dart` → `current_medicine.dart` |
| `core/utils/date_format_utils.dart`                                                                                                                                     | `date_format.dart`                                                  |
| `core/utils/string_utils.dart`                                                                                                                                          | `string.dart`                                                       |
| `core/utils/type_conversion_utils.dart`                                                                                                                                 | `type_conversion.dart`                                              |

> 注意:去后缀后 `daos/review.dart` 与 `tables/reviews.dart` 形成单复数对(DAO vs Drift 表定义),
> 跨目录、可接受;执行时留意不要互相导错。

**C. feature 名前缀(规则 3)**

| 现状                                                                       | 目标                                                           |
| -------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `features/medicine/presentation/pages/medicine_detail.dart`                | `detail.dart`(与 `pages/reminder/detail.dart` 不同目录,不冲突) |
| `features/review/presentation/pages/review_detail.dart`                    | `detail.dart`                                                  |
| `features/mine/presentation/widgets/shared/mine_edit_form_loading.dart`    | `edit_form_loading.dart`                                       |
| `features/review/presentation/widgets/sections/review_preview_locked.dart` | `preview_locked.dart`                                          |
| `features/review/presentation/widgets/sections/review_history.dart`        | `history.dart`                                                 |

**D. 单文件子目录扁平化(结构坏味道)**

| 现状                                                | 目标                                                  |
| --------------------------------------------------- | ----------------------------------------------------- |
| `app/router/helpers.dart`(router/ 下唯一文件)       | `app/router_helpers.dart`,删除空目录                  |
| `core/widgets/command_palette/command_palette.dart` | `core/widgets/common/command_palette.dart`,删除空目录 |

### 2.2 P1 — review 新旧视图链(前置决策后执行)

`review` 存在新旧两条视图链并存,四组文件两两同名类,禁止直接改名:

- 旧链:`pages/legacy_dashboard_compat.dart`(挂在路由 `/review/legacy`)→ `views/dashboard_view.dart`
  → 旧 sections:`ai_summary.dart`、`suggestion_history.dart`(类名与新版完全相同)。
- 新链:`views/review_view.dart` → 新 sections:`review_ai_summary.dart`(注释:从旧
  ReviewAiSummarySection 改名而来)、`review_suggestion_history.dart`、`review_history.dart`、
  `review_preview_locked.dart`(另被 `views/dashboard_preview.dart` 引用)。

因此 `review_ai_summary.dart → ai_summary.dart`、`review_suggestion_history.dart → suggestion_history.dart` 的去前缀**必须等 D1 决策落地后执行**。

### 2.3 P2 — 裸文件过多的目录分组

| 目录                                             | 裸源文件数 | 处置                                                                                                                                                                                                     |
| ------------------------------------------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `core/design/`                                   | 17         | 分`tokens/`、`color/`、`layout/` 子目录;barrel `design.dart` **留在根**,外部 import 不变                                                                                                                 |
| `core/widgets/common/`                           | 16         | 分`dialog/`、`feedback/`、`control/`;barrel `state_views.dart` **留在根**                                                                                                                                |
| `core/network/`                                  | 15         | 分`client/`(dio_client、client_providers、interceptors/、session_store、sse)、`contract/`(response_body、problem_details、error_code、result_code、error_mapper、api_paths);barrel `api.dart` **留在根** |
| `features/review/presentation/widgets/sections/` | 16         | 随 2.2 旧链处置后,按 detail/history 等页面归组                                                                                                                                                           |
| `features/settings/presentation/pages/`          | 14         | 列入 P3 观察(设置子页面为叶子页,平铺可辩护)                                                                                                                                                              |

> barrel 留根是本节的关键设计:`design.dart` / `api.dart` / `state_views.dart` 的外部消费者
> import 路径不变,分组只影响 barrel 内部 export 与少数直接深引用。

**core/design 分组时的三胞胎改名**(单复数仅一 s 之差,极高误导率):

| 现状                                                  | 目标                                  |
| ----------------------------------------------------- | ------------------------------------- |
| `semantic_color.dart`(enum SemanticColor + 解析扩展)  | `color/semantic_color.dart`(名字保留) |
| `semantic_color_palette.dart`(SemanticColorPalette)   | `color/palette.dart`                  |
| `semantic_colors.dart`(ThemeExtension SemanticColors) | `color/theme_extension.dart`          |

### 2.4 P2 — 错层文件归位

| 现状                                                | 目标                                                            | 理由                                                       |
| --------------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------- |
| `features/settings/utils/version_check.dart`        | `features/settings/domain/services/version_check.dart`          | feature 根的`utils/` 破坏四层结构;内容是纯函数 semver 比较 |
| `features/record/data/quick_entry_preferences.dart` | `features/record/data/datasources/quick_entry_preferences.dart` | `data/` 下唯一裸文件;内容是 SharedPreferences 数据源       |

### 2.5 P3 — 观察项与后续任务(本次不改)

- `settings/presentation/pages` × 14:若分组,按 about / appearance / data / notification 归组;暂缓。
- 8–10 文件目录(`record/widgets/sections`、`medicine/widgets/risk`、`auth/pages`、
  `mine/widgets/sections`、`medicine/widgets/reminder`、`auth/data/datasources/wechat`):
  阈值内,仅观察;`auth/pages` 的 account_settings 三件套可在下次触碰时归入
  `account_settings/` 子目录。
- `_view` 后缀(`views/skeleton_view.dart` 等四个 feature):规则 1 未列 `_view`;
  若要治理,先在 AGENTS.md 补约定再执行。
- `health_data` / `health_context` 的 `health_` 前缀:业务词(规则 5),保留。
- **test/ 全面镜像化**:307 个测试文件中大量平铺在 feature 根且带旧类型后缀
  (`*_page_test`、`*_provider_test`、`*_repository_test`),并存在滞后样例
  (`core/feedback/app_toast_test.dart`,源文件已改名 `toast.dart`)。工作量与风险自成一体,
  作为独立任务排期;本计划只承诺「改哪个源文件就同步其对应 test」。

## 三、前置决策点

- **D1 — review 旧链退役**:旧链是有意保留的兼容路由(路由 `/review/legacy` 仍注册,
  `pages/page.dart` 注释明确标注 legacy)。执行 1d 前选择:
  - 旧链文件整体移入 `sections/legacy/`、`views/legacy/` 物理隔离,新旧并存,
  - 新链照常去前缀。

- **D2 — 候选名确认**:`logger.dart`、`theme.dart`、`shortcuts.dart`、`view.dart`、
  `constants.dart` 的新名以文件实际内容为准(2.1-A 给出候选)。
- **D3 — AGENTS 补充**:建议在 File Naming Rules 追加第 8 条「目录直下源文件
  (不含生成文件)>10 应分子目录」,把本次审计阈值固化为规则。

## 四、执行批次

每批固定流程:`git mv` 改名 → 全局替换 `package:luminous/...` import → 涉及
`part`/freezed/drift 的重跑 `dart run build_runner build` → `flutter analyze` →
`flutter test`(全量)→ 单独提交(`refactor(scope): 中文摘要`,禁止与其他改动混合)→
追加迁移日志 `docs/03-logs/migration-log/2026-08-30.md` → grep `docs/` `plans/` 同步旧路径文字
(例:`2026-08-30-doc-governance-evolution.md` 引用了 `core/design/{spacing,icon_size,semantic_color*}.dart`)。

- [x] **0. 决策** — 确认 D1 / D2 / D3。
- [ ] **1a. core 数据与工具改名** — 2.1-B 全部(daos × 8、utils × 3),同步 `test/core/...` 对应改名。
- [ ] **1b. core 命名重复与扁平化** — 2.1-A(logger / theme / shortcuts / icon_tokens)+ 2.1-D
      (router/helpers、command_palette)。
- [ ] **1c. features 去前缀** — 2.1-C(medicine_detail、review_detail、mine_edit_form_loading、
      review_preview_locked、review_history)+ search `view.dart` + record `constants.dart`。
- [ ] **1d. review 新旧链** — 按 D1 结论执行,新链去前缀,sections 按 detail/history 归组。
- [ ] **2. core/design 分组** — 2.3 含三胞胎改名;`design.dart` 留根更新 export。
- [ ] **3. core/widgets/common 分组** — 2.3;`state_views.dart` 留根。
- [ ] **4. core/network 分组** — 2.3;`api.dart` 留根。
- [ ] **5. 错层归位** — 2.4 两处。
- [ ] **6. 收尾验证** — 见第五节 DoD;本计划完成段落删除(AGENTS: Finishing a plan)。

## 五、完成定义(DoD)

1. `lib/` 内不再存在:目录已传达类型的 `_dao` / `_utils` 后缀、feature 名前缀文件、
   目录名 = 文件名、纯类型词文件名、单文件子目录。
2. 裸文件 >10 的目录全部分组完毕(豁免项在迁移日志登记理由)。
3. `flutter analyze` 0 issue;`flutter test` 全绿;`build_runner` 重生成后无悬空 part 引用。
4. `git grep` 全库无指向旧路径的 `package:luminous/` import;`docs/`、`plans/` 无失效路径文字。
5. 迁移日志含每批记录;`dart run scripts/check_doc_coverage.dart --warning-only` 通过。
6. 每批独立 commit,可单独 revert。

## 六、风险与对策

- **同名类冲突**(如两个 `detail.dart` 的页面类):全库 import 均为绝对路径,仅当同一文件同时
  import 两个同名导出才冲突;`flutter analyze` 逐批兜底,必要时 `import ... as`。
- **生成文件断链**:`.g.dart` / `.freezed.dart` 随源文件 `git mv`,但 `part 'xxx.g.dart'` 声明
  与内部引用需重跑 `build_runner` 校正;drift DAO 改名后确认 `database.dart` 的 part 引用。
- **barrel 之外的深引用**:`core/widgets/common/*` 无 barrel 保护,分组后直接 import 全量替换;
  按批全库 `git grep` 旧路径清零后再提交。
- **文档路径失同步**:doc-governance-evolution 等 plans/docs 文字引用旧路径,每批末尾 grep 同步。
- **回滚**:批内多文件、批间隔离;任一批出问题 revert 该批 commit 即可,不影响其余批次。

## 七、明确不做(范围外)

- 不改类名(AGENTS 规则 6),不改 `page.dart` 根页面模式(AGENTS 规则 3 认可)、
  合法 barrel(`design.dart`、`api.dart`、`state_views.dart`)、Drift `tables/` 复数命名、
  medicine 的 `part` 拆分结构。
- 不动目录不传达类型的类型词文件(`runtime_providers`、`connection_providers`、
  `client_providers`、`core/auth/session_provider`、`settings/widgets/*_section`)——
  这些名字的 provider/section 是职责的一部分,不属规则 1 违规。
- 不动实现限定词:`lucent`、`remote`、`mock`、`mobile`、`desktop`(规则 5)。
- 不做 test/ 全量镜像化(独立任务)、不做大文件拆分(见
  `2026-08-22-medium-to-large-migration-inventory.md`)。不碰归档与旧参考:`docs/04-archive/`、
  根下 `Luminous/backend/`(legacy 后端参考)、`docs-archive/`(1d 处置的 review 旧链除外)。
