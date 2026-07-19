# Luminous 逐页面 UI/UX 优化计划

> 创建日期：2026-07-18
> 状态：待实施
> 范围：Luminous 五个主 tab（今日 / 记录 / 用药 / 报告 / 我的）+ 全部二级页面（记录、用药、我的、设置、通知、助手、扫码、法律、认证、搜索）
> 依据：对 `lib/features/*/presentation/` 全部页面代码的逐页审查（2026-07-18），所有问题均附文件:行号定位。

---

## 一、目标与方法

逐页提升 UI/UX 质量，聚焦六类问题：布局与视觉层级、加载/空态/错误态、交互反馈、设计系统一致性、文案与 l10n、无障碍与宽屏适配。**只做 UI/UX 优化，不引入新功能、不动后端与架构**，除非缺口直接破坏界面体验（如死路由导致页面不可达）。

执行原则：

- 复用现有范式（`PageStateSwitch`、`AppStateMessageView`/`AppStateErrorView`、`AppSkeleton*`、`FTileGroup`、`SemanticColor`/`Spacing`/`TypographyToken`），不新造体系。
- 每个改动同步补/改 l10n 键（zh + en），禁止新增硬编码用户可见字符串。
- 严格度排序见第四节 P0/P1/P2 分批；第五节列出**不得回退的既有优点**。

---

## 二、跨页面共性问题（建议作为横向任务先行）

| # | 主题 | 问题 | 涉及面 |
|---|------|------|--------|
| C2 | 骨架屏与真实版面脱节 | 多个 tab 骨架结构对应的是旧版布局，加载完成瞬间大面积跳变 | 今日、记录、用药、报告、我的五个 tab 骨架全部需按当前真实 section 顺序/栏数重排（桌面端双栏骨架单列的问题普遍存在） |
| C4 | 危险操作缺确认 | 一键触发不可逆操作 | 退出登录（mine、settings 两处）；高级页"恢复默认设置"；过敏/病史/用药表单删除；PIN 启用无二次输入；数据保留期缩短 |
| C5 | 触控目标与语义 | 纯图标按钮缺语义 | 多处顶栏 sm 图标钮缺 `semanticLabel`；未读红点无 Semantics |
| C6 | 间距/尺寸魔数 | `24/32` 垂直 padding、`EdgeInsets.all(20)`、固定宽高绕过 token | 用药 3 页、助手、设置各页（settings 内部还有响应式 vs 固定 24 两套标准并存） |
| C7 | 错误文案直拼异常 | `error.toString()`/`$e` 直接上屏 | 搜索预检 toast |
| C8 | 日期时间格式不统一 | 手写 `yyyy-MM-dd HH:mm`、`HH:mm` 拼接 vs `intl.DateFormat` locale 感知并存 | PIN、mine 勿扰、legal 列表；assistant 已是正确范式，向其收敛 |

---

## 三、逐页面优化清单

### Tab 1 · 今日（today）

#### 3.1.1 页面骨架与状态（`pages/page.dart`、`widgets/views/dashboard_view.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | dashboard 5 秒超时（providers/dashboard.dart:15-17），弱网下长时间全屏骨架 | 缩短超时或骨架上叠加"加载较慢"提示 |
| 低 | 下拉刷新失败无提示；preview 模式通知按钮未登录行为与助手按钮不一致 | 各按现状微调对齐 |

#### 3.1.2 顶栏与问候语（`shared/top_bar.dart`、`entities/dashboard.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 未读红点硬编码 `Positioned` 偏移且无语义；纯图标按钮无 `semanticLabel`；英文问候 `item(s)` 生硬（改 ICU plural） | 补语义与 plural |

#### 3.1.4 建议卡（`sections/suggestion*.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 渐变卡上图标用 `colors.primary` 压语义色渐变底（components.dart:44）；fading 态仅降透明度未禁用卡内按钮；`openRoute` 与 observation `_openRoute` 重复实现 | 图标改 on-color；fading 禁交互；合并 helper |

#### 3.1.5 今天概览 + AI 摘要（`sections/summary.dart`、`view_models.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 用药指标分母是全部药品数而非今日应服（view_models.dart:135-144），"2/5" 易误导 | 分母改今日计划剂量数或改文案 |

#### 3.1.6 留意事项（`sections/observation.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 置信度标签用全局最小字号 level1（约 10px），"去看看"动作提示渲染成静态小灰字 | 升字号 + `FBadge` 呈现 |
| 低 | 条目无分隔线、整行可点但无 chevron 示能；medium/low 置信度文案同为"仅供参考"；错误图标未给色 | 加分隔/chevron；梳理文案映射；补 muted 色 |

#### 3.1.7 快捷操作（`sections/quick_actions.dart`、`view_models.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 主操作"确认用药"用 `go`、"快速记录"用 `push`，同组导航语义不一 | 统一并注释 |

---

### Tab 2 · 记录（record）

#### 3.2.1 记录主页（`pages/page.dart`、`widgets/views/dashboard_view.dart`、`mobile_timeline.dart`、`timeline.dart`、`sidebar.dart`、`quick_entry_panel.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 全页无刷新手段：`DesktopTabShell.onRefresh` 支持但未传，移动端无下拉刷新 | 两端接刷新 invalidate dashboard provider |
| 低 | 快捷网格 `.take(6)` 静默丢第 7 项；骨架含死代码 guide 占位、桌面骨架 2 列实际 3 列；移动端缺"回到今天"；`date_bar.dart` fontSize 11/14 等硬编码；平板档（600–1200）内容全宽拉伸；两端 locked 筛选项策略不一致；provider 超时文案硬编码中文 | 逐项打磨 |

#### 3.2.2 新建记录 `/record/create`（`pages/create.dart`、`widgets/forms/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 饮水数值字段未设数字键盘；图片附件无拍照入口；字段无分区；页面标题复用"记录"过泛；切类型已填内容静默保留；脏状态返回无确认；成功 toast 复用"已保存" | 逐项打磨 |

#### 3.2.3 记录详情 `/record/:id`（`pages/detail.dart`、`widgets/meal/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | "分析中"纯静态展示，无轮询/刷新，只能退出重进（detail.dart:194-214） | 定时 invalidate 或加"刷新状态"按钮 |

#### 3.2.4 编辑记录 `/record/:id/edit`（`pages/edit.dart`、`widgets/meal/dish_editor.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 允许改记录类型，切型静默丢弃睡眠 payload/菜品（edit.dart:269-289） | 编辑页锁定类型或弹丢失确认 |
| 中 | "保存时确认当前菜品结果"按钮选中无样式、不可取消（edit.dart:571-586） | 改 `FCheckbox` 可切换态 |

#### 3.2.5 四个录入弹层（`widgets/dialogs/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | NLP 弹层 `scrollable: false` 候选多时有溢出风险（nlp_dialog.dart:123）；语音/OCR 预生成阶段的失败可能无提示（错误监听挂在弹窗内） | 候选区可滚动；预生成错误显式 toast |
| 中 | OCR 选图后无"重新选择"入口；识别文本只读 | 加"重拍/重选"；结果可编辑 |
| 低 | 取消按钮混用 `MaterialLocalizations.cancelButtonLabel`；快捷弹窗保存中无指示；NLP 候选睡眠用分钟输入与主表单两套心智；"重置"清空草稿无确认；OCR 空结果复用牵强文案 | 逐项打磨 |

---

### Tab 3 · 用药（medicine）+ 搜索 + 扫码

#### 3.3.1 用药主页（`pages/page.dart`、`widgets/sections/mobile_*.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 骨架含已删除区块占位、顺序与真实不符（skeleton_view.dart:31-47）；桌面端搜索栏在不同状态间位置跳动 | 重排骨架；搜索栏固定进 `DesktopTabShell` |
| 低 | "已服/跳过"同为主色仅填充区分，跳过是负向动作；告警行 chevron 与"查看"按钮目标重复；图标 size 16 等硬编码 | 逐项打磨 |

#### 3.3.2 药品搜索 `/medicine/search`（`features/search/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 每击键即搜且无防抖（搜索中保留旧结果已实现，但防抖未确认） | 加 300-500ms 防抖 |
| 中 | "加入药箱"成功仅 toast"已保存"，无设提醒引导；按钮无已添加态可重复添加 | toast 带"去设提醒"action 或跳 `/medicine/reminders/new?medicineId=`；已添加变禁用/对勾 |
| 中 | `DesktopTabs` 两个 tab `onPress: () {}` 假导航 | 删除或接通 |
| 低 | 全角冒号中英混杂；预检失败 toast 直拼 `$e`；超时文案硬编码中文；桌面预览空态仅一行小字 | 逐项打磨 |

#### 3.3.3 风险检查 `/medicine/risk-check`（`pages/risk_check.dart`、`widgets/risk/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | `EdgeInsets.all(20)`、padding 24/32 魔数；coverage 图标 secondary 色语义含糊；指标 chip 不能与列表联动；红旗 action 文案像链接不可点 | 逐项打磨 |

#### 3.3.4 提醒详情 `/medicine/reminders/:medicineId`（`pages/reminder/reminder_detail.dart`、`widgets/reminder/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 启用/停用徽标视觉无差异，且详情页不能直接切换启停，必须进编辑页 | 详情页加启停 switch；停用态灰化 |
| 中 | 时间列表 value 无 maxLines，多时间 join 后挤压溢出（rows.dart:31-35） | 改 Wrap 芯片或限 2 行 |
| 中 | 提醒方式行拼接"通知开启 · 短信关闭 · 默认提示音"，不可用项同权重 | 拆行或不可用项置灰 |
| 低 | `0.12 > 0.5` 恒假死代码；日志面板无"查看全部"；missed 状态仅靠红色区分（色弱不友好）；删除失败 toast 复用 `settingsSyncFailed` | 逐项打磨 |

#### 3.3.5 新建/编辑提醒（`pages/reminder/reminder_edit.dart`、`widgets/reminder/form_*.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 保存按钮顶栏+底部两处重复、状态不同步；保存中无 spinner | 保留底部主按钮；保存中内嵌进度 |
| 低 | 短信不可用行整行权重未降；提示音下拉固定宽 140；频率切换清空星期无提示；编辑态错误页 description 为空串 | 逐项打磨 |

#### 3.3.6 扫码与拍照识别（`scan/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 置信度裸数字无解释；线框 280×120 硬编码；结果头图无占位；OCR/AI 方式卡缺隐私差异说明（设备端 vs 上传） | 逐项打磨 |

---

### Tab 4 · 报告（report，单页多区块）

#### 3.4.1 外壳与状态（`pages/page.dart`、`widgets/views/skeleton_view.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 桌面 loading 外壳 `scrollable: false` 矮窗溢出风险；`ReportActionBar` 传空回调看似可点（page.dart:357-358） | 可滚动+按钮禁用 |
| 中 | 移动端错误态出现 `AppBackButton`（tab 根页面有返回键），错误/空/就绪三种 chrome 各异（page.dart:277-318） | 统一复用同款顶栏，去掉返回钮 |
| 中 | 同步按钮 `isSyncing` 三处全硬编码 `false`（page.dart:491-532） | 接 provider refreshing 态 |
| 中 | 切时间范围整页退回全屏骨架，无旧值兜底 | 保留旧内容+局部加载指示 |
| 低 | loading 副标题写死"暂无数据"误导；页面级空态 `isInsufficient: (_) => false` 不可达死代码 | 微调 |

#### 3.4.2 就绪卡 / 评分 Hero（`sections/readiness.dart`、`score_hero.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | `circleHelp` 图标不可点无 tooltip；分数字号 token 外覆盖 40-54；装饰图标未 `ExcludeSemantics`；"生成总结"顶部入口无 loading | 逐项打磨 |

#### 3.4.3 趋势图表（`sections/trend.dart`）——本 tab 最高优先

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 依从性(%)/饮水(ml)/睡眠(h) 不同量纲共用一个 Y 轴，未归一化则压成平线 | 确认后端归一化；否则按序列归一并注明或拆小图 |
| 低 | X 轴手写 `M/d` 未走 locale；30 天末标签间距不均；图例色点 8px 偏小 | 逐项打磨 |

#### 3.4.4 其余区块

| 级别 | 位置 | 问题 | 建议 |
|------|------|------|------|
| 中 | findings / patterns | 桌面端 findings 仍横向滚动 Row 无滚动指示（chevron 已移除、patterns 已改网格） | 桌面改网格/Wrap |
| 中 | range_picker_dialog | 移动端弹窗上再弹弹窗；日历弹窗无取消按钮、确认用 `MaterialLocalizations.okButtonLabel`；桌面端范围 pill 重复出现两处（page.dart:470 + dashboard_view.dart:225） | 移动端改底部动作单；日历加取消；桌面趋势区 `showRangePill: false` |
| 低 | suggestion_history | 整列表不可点无"查看全部"（dead-end，可不阻塞）；徽章手写 DecoratedBox 与 FBadge 并存 | 统一徽章写法 |

---

### 设置（settings，15 页）

#### 3.6.1 设置主页（`pages/page.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 两个单 tile 分组碎片化 | 逐项打磨 |

#### 3.6.2 各子页要点

| 级别 | 页面 | 问题 | 建议 |
|------|------|------|------|
| 中 | AI | 上下文开关 build 时取反写入，快速连点用旧值覆盖，且失败无 toast（ai.dart:166-170） | 点击时读最新值+失败反馈 |
| 中 | 免打扰/睡眠提醒 | 未设时间时列表显示"未设置"、子页却显示默认 22:00 等，两端不一致 | 默认值首次开启时持久化，或子页显示占位 |
| 低 | 通知 | 摘要信息 details/subtitle 位置不一（权限卡片已包 FCard.raw） | 统一 details |
| 低 | 高级 | "开源许可"与关于页重复（切 endpoint toast 已加） | 入口留一处 |
| 低 | 关于 | 支持 URL 硬编码（外链已改 arrowUpRight） | URL 进配置 |

---

### 其他二级页面

#### 3.7.1 AI 助手对话（`assistant/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 用户消息不可选择复制、无时间戳无长按菜单；"正在打开…"/"生成中"纯静态文本；垂直 padding 24/32 魔数；上下文 chip 硬编码 `/4` | 逐项打磨 |

#### 3.7.2 通知列表与详情（`notification/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | `SingleChildScrollView`+for 循环全量渲染，无懒加载；桌面端 Slidable 只能鼠标拖（下拉刷新已加） | `ListView.builder`/sliver 分组；桌面 hover 操作钮 |
| 低 | 详情三等宽 Expanded 按钮窄屏易溢出（已改 Wrap）；错误直拼 `error.toString()`（已改 userMessageFromError）；字符串拼路由未用 typed route | 逐项打磨 |

---

## 四、优先级分批

### P2 —— 一致性打磨（约 50 项）

- 各页低级别项（导航语义统一、图标语义、死路由常量、预览态细节等）。

---

## 五、不得回退的既有优点（执行时勿误改）

- 状态架构：`PageStateSwitch`/`resolvePageViewState` 刷新保留旧数据不闪骨架；未登录 preview 数据 + `SignInHintBanner` + `AuthRequiredDialogGate`（带 returnTo）是全 App 统一且成熟的模式。
- 骨架基建：`AppSkeletonScope/Slot/Text` 细粒度行内骨架、刻意不造假数据的原则保留（要改的是骨架**结构**与真实版面对齐）。
- 今日：建议卡反馈行/AI 解释的重试上限/提交态是其他模块样板；`todayCardStyle` 五档语义色体系。
- 记录：`dailyRecordFormRules` 类型显隐规则、附件变更 diff、快捷入口偏好持久化、筛选"已筛选：X · 清除"可见性。
- 用药：加药前风险预检对话框（安全闭环亮点）；风险三级信息架构（改色不改结构）；`TintedStatusBadge` 文字+浅底不依赖纯颜色。
- 报告：AI 总结状态机与降级文案；导出的六态状态机；骨架不造假分数。
- 我的：档案"年龄 · 身高"实时合成副标题、通知摘要合成等信息密度范式。
- 设置：全部子页 `PageScaffold`+`AppBackButton` 统一头部、`ResponsiveContentFrame` 限宽、开关 loading 禁用规范。
- 助手：proposal 卡片状态机、错误/空态分支完整度、抽屉三态。
- 认证：`AuthShell` 统一布局动画、字段级 `AutovalidateMode` 校验器体系。
- 搜索：数据源切换选中态、预检对话框信息层级。

## 六、验收方式

- 每批完成后：`flutter analyze` + `flutter test` 全绿；改动页面人工过一遍 zh/en 双语与 1.2 倍文字缩放。
- 每个 P0 项修复后在 `docs/03-logs/migration-log/YYYY-MM-DD.md` 追加记录；UI 可见变化同步 `docs/00-current/Current_State.md`。
- 本计划的完成条目按 plans 规范**整节删除**，全部完成后删除本文件。
