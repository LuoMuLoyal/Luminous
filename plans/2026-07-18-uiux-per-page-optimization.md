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
- 严格度排序见第六节 P0/P1/P2 分批；第七节列出**不得回退的既有优点**。

---

## 二、跨页面共性问题（建议作为横向任务先行）

| # | 主题 | 问题 | 涉及面 |
|---|------|------|--------|
| C2 | 骨架屏与真实版面脱节 | 多个 tab 骨架结构对应的是旧版布局，加载完成瞬间大面积跳变 | 今日、记录、用药、报告、我的五个 tab 骨架全部需按当前真实 section 顺序/栏数重排（桌面端双栏骨架单列的问题普遍存在） |
| C3 | 硬编码文案回潮 | 局部中文/英文硬编码绕过 l10n | 通知分组标题"今天/昨天/更早"与详情类型 chip（list.dart:171-188、detail.dart:170-182）；扫码 `box_scan.dart`/`recognize_dialog.dart` 整段中文；AI 流式占位（today `providers/ai_analysis.dart:14`、report `providers/ai_summary.dart:13,79`）；QQ 登录英文硬编码；多处 `?? 'English fallback'` |
| C4 | 危险操作缺确认 | 一键触发不可逆操作 | 退出登录（mine、settings 两处）；高级页"恢复默认设置"；过敏/病史/用药表单删除；PIN 启用无二次输入；数据保留期缩短 |
| C5 | 触控目标与语义 | 裸 `GestureDetector` 小按钮、纯图标按钮缺语义 | 今日 `EvidenceToggleButton`/`_AiExpandButton`；语音 sheet 麦克风按钮；搜索框清除钮；多处顶栏 sm 图标钮；未读红点/图表无 Semantics |
| C6 | 间距/尺寸魔数 | `24/32` 垂直 padding、`EdgeInsets.all(20)`、固定宽高绕过 token | 用药 3 页、助手、设置各页（settings 内部还有响应式 vs 固定 24 两套标准并存） |
| C7 | 错误文案直拼异常 | `error.toString()`/`$e` 直接上屏 | 通知列表/详情、搜索预检、报告部分 toast |
| C8 | 日期时间格式不统一 | 手写 `yyyy-MM-dd HH:mm`、`HH:mm` 拼接 vs `intl.DateFormat` locale 感知并存 | 通知、PIN、mine 勿扰、legal 列表；assistant 已是正确范式，向其收敛 |

---

## 三、逐页面优化清单

### Tab 1 · 今日（today）

#### 3.1.1 页面骨架与状态（`pages/page.dart`、`widgets/views/dashboard_view.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | `TodayEmptyView`（dashboard_view.dart:76）是死代码，`resolvePageViewState` 未传 `isInsufficient`，新用户看到的是满屏"0/0"指标卡而非引导空态 | 接上 `isInsufficient`（可复用 `shouldShowRecordHint` 判定）启用空态，或删死代码并明确"横幅式空态"为正式方案 |
| 中 | 移动端顶栏双重水平 padding：`AppTopBar` 自带 `pageHorizontalPadding`（top_bar.dart:47）且是 ListView 首 item（dashboard_view.dart:136-141），与下方卡片左右不对齐 | 顶栏移出 ListView 或去掉一层 padding |
| 中 | 桌面端双标题：`DesktopTabShell(title:)` 与内容区 `TodayTopBar` 都是"今日"（page.dart:64、dashboard_view.dart:178） | 桌面端二选一，保留助手/通知入口 |
| 中 | dashboard 5 秒超时（providers/dashboard.dart:15-17），弱网下长时间全屏骨架 | 缩短超时或骨架上叠加"加载较慢"提示 |
| 低 | 双重 SafeArea（page.dart:70 + top_bar.dart:44）；下拉刷新失败无提示；preview 模式通知按钮未登录行为与助手按钮不一致 | 各按现状微调对齐 |

#### 3.1.2 顶栏与问候语（`shared/top_bar.dart`、`entities/dashboard.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | preview 模式问候语恒为"早上好"：`signedOut()` 硬编码 `moment: morning`（dashboard.dart:46） | 用设备当前小时计算 moment |
| 低 | 未读红点硬编码 `Positioned` 偏移且无语义；纯图标按钮无 `semanticLabel`；英文问候 `item(s)` 生硬（改 ICU plural） | 补语义与 plural |

#### 3.1.3 无记录提示横幅（`sections/record_hint.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 横幅无行动按钮，`todayRecordHintAction`（"去记录"）文案已备好但未接线 | FAlert 上加 CTA 跳 `/record/create` |

#### 3.1.4 建议卡（`sections/suggestion*.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | `SuggestionSkeleton` 是固定 180 高纯色块，实际卡常 300+，加载后跳动（suggestion_state_views.dart:60-67） | 按真实卡结构绘骨架 |
| 中 | 次级建议加载中 `SizedBox.shrink`（suggestion.dart:128），加载完成整段凭空插入顶起下方 | 加载中渲染 1-2 行骨架占位 |
| 中 | `openRoute` 对无 query 路由用 `context.go`（suggestion_primary_card.dart:355-361），点击后无返回路径，与 push 行为不一致 | 统一导航语义并注释 |
| 中 | `EvidenceToggleButton`、`_AiExpandButton` 裸 `GestureDetector` + xs 小字，触控目标远不足 44pt、无按钮语义 | 换 `FTappable`/ghost `FButton` 并扩大热区 |
| 低 | 渐变卡上图标用 `colors.primary` 压语义色渐变底（components.dart:44）；fading 态仅降透明度未禁用卡内按钮；`openRoute` 与 observation `_openRoute` 重复实现 | 图标改 on-color；fading 禁交互；合并 helper |

#### 3.1.5 今天概览 + AI 摘要（`sections/summary.dart`、`view_models.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 睡眠单位重复拼接：仓库已返回 `"7.5h"`（repositories/lucent.dart:197），UI 再拼 l10n 单位（view_models.dart:159）→ 中文"7.5h 小时"、英文"7.5h h" | 单位只保留一处 |
| 中 | 无睡眠记录时显示"未记录 小时"/"Not tracked h"（fallback 也拼单位） | fallback 不拼单位 |
| 中 | 用药指标分母是全部药品数而非今日应服（view_models.dart:135-144），"2/5" 易误导 | 分母改今日计划剂量数或改文案 |
| 中 | AI 流式占位硬编码中文（providers/ai_analysis.dart:14） | 改走已有 l10n 键 |
| 低 | "未记录"与数值同字重 w800；fallback 叙述与真实 AI 摘要同样式不可区分 | 空值降字重/muted；fallback 弱化或加标识 |

#### 3.1.6 留意事项（`sections/observation.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 置信度标签用全局最小字号 level1（约 10px），"去看看"动作提示渲染成静态小灰字 | 升字号 + `FBadge` 呈现 |
| 中 | 骨架行未包 `AppSkeletonShimmer`（observation.dart:183-224），与同页 shimmer 不一致 | 统一 shimmer |
| 低 | 条目无分隔线、整行可点但无 chevron 示能；medium/low 置信度文案同为"仅供参考"；错误图标未给色 | 加分隔/chevron；梳理文案映射；补 muted 色 |

#### 3.1.7 快捷操作（`sections/quick_actions.dart`、`view_models.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 3 个次要操作标题承诺不同目的地，实际全部 `context.go(AppRoutes.medicine)`（view_models.dart:319-330）——"用药安全"应去 `/medicine/risk-check`，"提醒设置"应去 `/medicine/reminders` | 分别指向已有二级路由 |
| 中 | 次要组整体 muted 与禁用态无法区分但仍可点 | 仅图标弱化或按注释做"更多"折叠 |
| 低 | 主操作"确认用药"用 `go`、"快速记录"用 `push`，同组导航语义不一 | 统一并注释 |

---

### Tab 2 · 记录（record）

#### 3.2.1 记录主页（`pages/page.dart`、`widgets/views/dashboard_view.dart`、`mobile_timeline.dart`、`timeline.dart`、`sidebar.dart`、`quick_entry_panel.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 时间线无空态：当日无记录/筛选无结果只渲染标题+空卡片（mobile_timeline.dart:73-85、timeline.dart:77-88） | 统一空态（图标+"这一天还没有记录"+CTA 跳 `/record/create?date=<选中日期>`）；筛选空态附"清除筛选" |
| 高 | 桌面月历标题写死 l10n 静态串 "2025年5月"/"May 2025"（sidebar.dart:53-58），切月不变 | 按当前月份 `DateFormat.yMMMM(locale)` 动态格式化 |
| 中 | 移动端标题固定"今日记录 · N 条"，浏览其他日期时文案错误（mobile_timeline.dart:50） | 按选中日期动态文案 |
| 中 | 全页无刷新手段：`DesktopTabShell.onRefresh` 支持但未传，移动端无下拉刷新 | 两端接刷新 invalidate dashboard provider |
| 中 | 占位条目跳创建页日期写死 `DateTime.now()`（timeline.dart:216、mobile_timeline.dart:166），浏览历史日期时预填错误 | 传 `selectedRecordDateProvider` 日期 |
| 中 | 桌面端"语音记录（按住说话）"按钮实际打开普通创建表单（dashboard_view.dart:206-211、new_entry_panel.dart:76-92），文案与行为严重不符；桌面无 AI 录入入口 | 接入同一 NLP/语音弹层，或按钮改文案"新建记录" |
| 中 | 桌面月历"切月即选日"（sidebar.dart:24-28），无法只浏览月份 | 月份导航与日期选中解耦 |
| 中 | 桌面筛选用复选框图标暗示多选，实际单选且不可取消（sidebar.dart:299-307） | 改单选语义样式，已选项再点取消 |
| 中 | "动态排序"开关无文字标签只有 16px "?" tooltip；编辑顺序按钮用 Opacity 0.4 假装禁用（quick_entry_panel.dart:322-347） | 加文字标签；动态排序开启时真正禁用并 tooltip 说明 |
| 低 | 快捷网格 `.take(6)` 静默丢第 7 项；骨架含死代码 guide 占位、桌面骨架 2 列实际 3 列；移动端缺"回到今天"；`date_bar.dart` fontSize 11/14 等硬编码；平板档（600–1200）内容全宽拉伸；两端 locked 筛选项策略不一致；provider 超时文案硬编码中文 | 逐项打磨 |

#### 3.2.2 新建记录 `/record/create`（`pages/create.dart`、`widgets/forms/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 除睡眠外无必填校验，饮水可不填数值保存空记录；唯一反馈是 toast，无字段级内联错误（create.dart:233-287） | 按类型定义必填规则，`FTextField` error 内联提示并聚焦首个错误 |
| 中 | 睡眠校验 toast"请输入有效的睡眠时长"与实际表单（选就寝+起床时间）不符 | 改文案"请选择就寝和起床时间" |
| 中 | 保存中按钮仅置灰无进度，表单字段不整体禁用（create.dart:380-384） | 按钮内嵌 `FCircularProgress` + 禁用表单 |
| 中 | 创建表单选不到"心情"（`activeDailyRecordKinds` 不含 mood），但主页快捷面板有心境快记 | 两端类型集合对齐 |
| 低 | 饮水数值字段未设数字键盘；图片附件无拍照入口；字段无分区；页面标题复用"记录"过泛；切类型已填内容静默保留；脏状态返回无确认；成功 toast 复用"已保存" | 逐项打磨 |

#### 3.2.3 记录详情 `/record/:id`（`pages/detail.dart`、`widgets/meal/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 删除失败 toast 复用"记录未保存"（detail.dart:394） | 增"删除失败"专用文案 |
| 中 | "分析中"纯静态展示，无轮询/刷新，只能退出重进（detail.dart:194-214） | 定时 invalidate 或加"刷新状态"按钮 |
| 中 | "来源"行直接显示后端原始串如 `local`（detail.dart:177-181） | source→文案映射，未知值隐藏 |
| 中 | 营养热量无单位 `热量: 500`（analysis_summary_card.dart:86-90） | 补 kcal，数值本地化 |
| 低 | 编辑入口头尾重复；删除确认标题仅"删除"二字；字段行标签固定宽 88；食材匹配用 ASCII `->` | 逐项打磨 |

#### 3.2.4 编辑记录 `/record/:id/edit`（`pages/edit.dart`、`widgets/meal/dish_editor.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 删除确认弹窗标题是"解绑身份"（张冠李戴的 l10n 键，edit.dart:351） | 换"删除记录"键 |
| 高 | 删除成功 toast 显示"已保存"（edit.dart:375） | 换 `mineEditDeletedToast` |
| 中 | 编辑页删除后只 pop 一级，回到已失效的详情页"加载失败"（edit.dart:377） | pop 两级回列表 |
| 中 | 允许改记录类型，切型静默丢弃睡眠 payload/菜品（edit.dart:269-289） | 编辑页锁定类型或弹丢失确认 |
| 中 | `loadRecord` 失败直接 toast+pop，页面一闪而过（edit.dart:153-158） | 页内 `AppStateErrorView` + 重试 |
| 中 | "保存时确认当前菜品结果"按钮选中无样式、不可取消（edit.dart:571-586）；保存按钮无进度而删除按钮有 | 改 `FCheckbox` 可切换态；统一加载表现 |
| 低 | 菜品删除裸图标无 tooltip/语义；无离开确认 | 补语义与确认 |

#### 3.2.5 四个录入弹层（`widgets/dialogs/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 快捷记录饮水选项硬编码英文 "250 ml"/"1 cup"（fast_entry_choices.dart:45-50），中文界面混杂 | 单位走 l10n（键已存在） |
| 中 | 语音 sheet 麦克风主按钮裸 `GestureDetector`（voice_entry_dialog.dart:233）；`errorMessage` 只存不显；初始化失败统一报"麦克风权限未授权"误导；识别结果只读不能改；文案"按住说话"与实际点按不符 | 换可及性组件；渲染错误行；区分三类失败文案；结果可编辑；对齐文案 |
| 中 | NLP 弹层 `scrollable: false` 候选多时有溢出风险（nlp_dialog.dart:123）；语音/OCR 预生成阶段的失败可能无提示（错误监听挂在弹窗内） | 候选区可滚动；预生成错误显式 toast |
| 中 | OCR 选图后无"重新选择"入口；识别文本只读 | 加"重拍/重选"；结果可编辑 |
| 低 | 取消按钮混用 `MaterialLocalizations.cancelButtonLabel`；快捷弹窗保存中无指示；NLP 候选睡眠用分钟输入与主表单两套心智；"重置"清空草稿无确认；OCR 空结果复用牵强文案 | 逐项打磨 |

---

### Tab 3 · 用药（medicine）+ 搜索 + 扫码

#### 3.3.1 用药主页（`pages/page.dart`、`widgets/sections/mobile_*.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 铃铛入口红点**无条件常显**（page.dart:331-344），点击却直接进新建提醒页而非列表 | 红点按活跃提醒/今日未服驱动或移除；落点改提醒相关列表 |
| 高 | "按时服用率"指标 detail 固定显示"待服用"（mobile_drugbox.dart:310-316），语义不通 | detail 改统计周期或动态待服文案 |
| 中 | 药箱计数用未过滤集合、列表用过滤集合，"共 N 种"对不上（mobile_drugbox.dart:16-55） | 统一集合口径 |
| 中 | 窄屏"安全守护" pill 挤压标题 | 窄屏降级纯图标 |
| 中 | 骨架含已删除区块占位、顺序与真实不符（skeleton_view.dart:31-47）；桌面端搜索栏在不同状态间位置跳动 | 重排骨架；搜索栏固定进 `DesktopTabShell` |
| 低 | "已服/跳过"同为主色仅填充区分，跳过是负向动作；告警行 chevron 与"查看"按钮目标重复；图标 size 16 等硬编码 | 逐项打磨 |

#### 3.3.2 药品搜索 `/medicine/search`（`features/search/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 移动端结果卡整卡 `FTappable` 可点但点击无任何可见结果——预览面板仅桌面渲染（view.dart:274、result_widgets.dart:30-31） | 移动端点击弹详情 bottom sheet 或移除整卡 tappable |
| 高 | "最近搜索"永远传空列表仍渲染标题+"清除"（不可点纯 Text）；“分类”区块空壳（view.dart:185-198、329-339） | 数据未接入前整段隐藏 |
| 中 | 桌面 `QuickActions` 传空列表仍渲染空 `FCard`；`DesktopTabs` 两个 tab `onPress: () {}` 假导航 | 空则不渲染；删除或接通 |
| 中 | 每击键即搜且无防抖，`isSearching` 整页换 shimmer，输入过程反复闪烁 | 加 300-500ms 防抖；搜索中保留旧结果+局部加载 |
| 中 | 搜索框清除钮裸 `GestureDetector` 约 20px；无结果区 `NoResultTools` 两个建议动作纯展示不可点（result_widgets.dart:270-299） | 换图标按钮+语义；接上换源/清空行为 |
| 中 | "加入药箱"成功仅 toast"已保存"，无设提醒引导；按钮无已添加态可重复添加 | toast 带"去设提醒"action 或跳 `/medicine/reminders/new?medicineId=`；已添加变禁用/对勾 |
| 低 | 全角冒号中英混杂；预检失败 toast 直拼 `$e`；超时文案硬编码中文；桌面预览空态仅一行小字 | 逐项打磨 |

#### 3.3.3 风险检查 `/medicine/risk-check`（`pages/risk_check.dart`、`widgets/risk/*`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 三级体系视觉坍塌：`warning → destructive`（risk_check.dart:116-121），"确认风险"与"未覆盖/不确定"同为红色 | warning 档用 `SemanticColor.warning`，三级 = 红/绿/黄 |
| 高 | 风险等级仅靠颜色+小徽章文字：高=红、中=灰（像"不可用"）、info=品牌绿，红/绿对色弱不友好 | 徽章加级别图标或左侧色条；中风险改 warning 黄；统一"图标+文字+颜色"三通道 |
| 中 | 红旗横幅（最严重警告）用品牌色 primary（risk_red_flag.dart:23-46），与"确认风险"层级倒挂 | 改 destructive 色系 |
| 中 | findings/coverageIssues 无上限平铺，数据多时页面极长 | 超 N 条折叠+"展开全部"，或按 severity 分组 |
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
| 高 | 无 medicineId 进入时流程断裂：只显示"去搜索"卡，药箱已有药也无法用表单内 FSelect 直选；搜索添加后无回填跳回（reminder_edit.dart:121-124） | 无 medicineId 时直接渲染表单+FSelect 列出药箱药品，搜索添加成功后带 id 返回 |
| 高 | 时间选择 sheet 简陋：无标题/无取消/无当前选择回显，确认按钮用 `MaterialLocalizations.okButtonLabel`（reminder_edit.dart:225） | 加标题+取消/确认（走 l10n）+选中回显 |
| 中 | 星期/时间用 Material 原生 `FilterChip`/`InputChip`（form_fields.dart:73-127），破坏 forui 一致性 | 换 forui 风格 chip |
| 中 | 可添加重复时间不去重（reminder_edit.dart:234-243） | 添加前去重+toast |
| 中 | 保存按钮顶栏+底部两处重复、状态不同步；保存中无 spinner | 保留底部主按钮；保存中内嵌进度 |
| 低 | 短信不可用行整行权重未降；提示音下拉固定宽 140；频率切换清空星期无提示；编辑态错误页 description 为空串 | 逐项打磨 |

#### 3.3.6 扫码与拍照识别（`scan/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 扫码页零引导：只有细线框，无提示文案/暗角遮罩/识别中进度；权限被拒黑屏无处理（barcode_scanner.dart:172-184） | 四角括号+暗化遮罩+底部提示；识别中 loading 遮罩；权限拒绝引导页 |
| 高 | `box_scan.dart`/`recognize_dialog.dart` 整段硬编码中文（"OCR 文字识别"、"批准文号"、"置信度"等），英文枚举名 `matchType.name` 直接暴露 | 全部迁 AppLocalizations |
| 中 | 手电按钮状态不刷新（build 时读值无 listen），图标色可能近隐形（barcode_scanner.dart:158-163） | `ValueListenableBuilder`；图标色改 foreground |
| 中 | 识别失败/未找到仅 toast，无"手动搜索"兜底 | toast 带 action 跳搜索页或常驻"手动输入" |
| 中 | 多结果候选 sheet 无标题/分隔/取消；处理遮罩用 rootNavigator pop 脆弱；结果对话框 `barrierDismissible: false` 且无关闭按钮，无结果时只能重拍死循环 | sheet 规范化；遮罩用可控 dialog；结果框加关闭 |
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
| 高 | "报告预览评分/预览"文案对**已登录数据就绪**用户也显示（score_hero.dart:38、80） | 就绪态用"健康评分"，预览仅 preview 态 |
| 中 | readiness 三态徽章/图标恒为 neutral+primary，"数据不足"无 warning 色 | insufficient 用 warning、ready 用 success |
| 中 | ready 标题写死"近 7 天"，选 30 天/自定义不变 | 按范围参数化 |
| 低 | `circleHelp` 图标不可点无 tooltip；分数字号 token 外覆盖 40-54；装饰图标未 `ExcludeSemantics`；"生成总结"顶部入口无 loading | 逐项打磨 |

#### 3.4.3 趋势图表（`sections/trend.dart`）——本 tab 最高优先

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | Y 轴完全无标签，读不到数值；`currentValue` 未展示（trend.dart:182-184） | 图例项带当前值+单位，或恢复精简左轴 |
| 高 | 序列配色撞车：water/sleep 同为 info、medication/general 同为 primary（lucent.dart:149-156），图例无法区分 | 四个 kind 定义互异序列色 |
| 中 | 依从性(%)/饮水(ml)/睡眠(h) 不同量纲共用一个 Y 轴，未归一化则压成平线 | 确认后端归一化；否则按序列归一并注明或拆小图 |
| 中 | `lineTouchData` 禁用，图表完全不可触（trend.dart:216） | 开 touch tooltip（日期+各序列值+单位） |
| 中 | 整个图表无 `Semantics`，读屏获取不到趋势信息 | 容器加语义摘要 |
| 低 | X 轴手写 `M/d` 未走 locale；30 天末标签间距不均；图例色点 8px 偏小 | 逐项打磨 |

#### 3.4.4 其余区块

| 级别 | 位置 | 问题 | 建议 |
|------|------|------|------|
| 中 | metrics_grid | 指标卡**仅桌面渲染**，移动端无分项指标也无跳记录筛选入口；骨架里却有占位 | 移动端补指标区或明确"桌面独占"并修骨架 |
| 中 | metrics_grid | 状态徽章误用"未开通"（用药提醒文案）、unknown 显示"稳定"（section_models.dart:58-59） | report 专用状态键 |
| 中 | findings / patterns | 卡片 chevronRight 纯装饰不可点，导航暗示误导；桌面端仍横向滚动 Row 无滚动指示 | 去 chevron 或加跳转；桌面改网格/Wrap |
| 高 | ai_summary | 流式占位与错误文案硬编码中文（providers/ai_summary.dart:13、79），英文界面显示中文 | 走 l10n |
| 中 | ai_summary | 范围可选"自定义"但无日期选择入口，可能以空日期请求（providers/ai_summary.dart:54-60） | 选自定义联动日期选择，或移除该项 |
| 中 | export | 任一导出进行中全部卡片置 null 但仍显示 chevron 看似可点（export.dart:108-115）；"分享给医生"等接口期间无 loading | inFlight 卡片灰化；clinicShare 加进行中态 |
| 中 | reference_notice | 医疗免责声明**仅桌面端渲染**，移动端缺失（合规属性内容） | 移动端列表末尾补同一声明 |
| 中 | range_picker_dialog | 移动端弹窗上再弹弹窗；日历弹窗无取消按钮、确认用 `MaterialLocalizations.okButtonLabel`；桌面端范围 pill 重复出现两处（page.dart:470 + dashboard_view.dart:225） | 移动端改底部动作单；日历加取消；桌面趋势区 `showRangePill: false` |
| 低 | suggestion_history | 整列表不可点无"查看全部"（dead-end，可不阻塞）；徽章手写 DecoratedBox 与 FBadge 并存 | 统一徽章写法 |

---

### Tab 5 · 我的（mine）

#### 3.5.0 全局（先于逐页）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | **三个编辑路由是死路由**：`/mine/allergy/:id/edit`、`/mine/condition/:id/edit`、`/mine/medicine/:id/edit` 已声明但零导航入口；`/mine/condition/new` 同样不可达。已有健康档案无法查看列表/编辑/删除，病史功能从 UI 根本进不去 | 打通"档案行 → 列表页（或页内展开）→ `/:id/edit`"链路（见 3.5.3） |
| 中 | `IconActionButton` 同名两套实现（core/shared_widgets.dart:170 vs mine/top_bar.dart:47） | 合并为 core 版本扩展 badge 参数 |
| 低 | 骨架含 `MineStatusOverview`/"校园服务"遗留占位，与真实 6 section 不符 | 重排骨架并改名 |

#### 3.5.1 页面框架与 Hero 卡（`pages/page.dart`、`sections/account_hero.dart`、`sync_failed_banner.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 同步失败横幅自带水平 padding，比下方卡片左右各窄 8pt（sync_failed_banner.dart:51）；点击重试无任何反馈 | 去自带 padding；点击给一次性反馈 |
| 中 | Hero 卡整卡 `FTappable` 跳账号页与内部"补全资料"按钮嵌套（account_hero.dart:47-49、167-177），触摸/读屏语义混乱 | 取消整卡可点，保留主按钮 |
| 中 | 头像固定灰占位、无编辑 affordance | 头像角加编辑小徽标入口 |
| 低 | mine 移动端灰底 vs today 纯白底，跨 tab 底色跳变；角色文案固定"大学生"；缺口徽章只展示前 2 个无 "+N" | 逐项打磨 |

#### 3.5.2 各分组（`sections/archive_section.dart`、`ai_privacy.dart`、`notifications_reminders.dart`、`account_security.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 过敏/用药档案行点击写死进"新建"页（lucent.dart:170、177），已有 N 条记录时落点是空白表单，与"已完善"状态矛盾 | 有记录时先进列表/展开，再进 `/:id/edit` |
| 高 | 缺病史（condition）档案行——`conditionCount` 已在 snapshot 里但无展示无入口 | 补病史档案行 |
| 高 | 退出登录无二次确认（account_security.dart:89-97），健康类 App 误触代价高 | 加确认对话框 |
| 中 | "待补充"用 destructive 红色渲染中性状态（archive_section.dart:88-90） | 改 muted/warning |
| 中 | "隐私报告"入口跳通用设置页（ai_privacy.dart:57），承诺与落地不符 | 指向真正隐私/数据页或改名 |
| 中 | 未登录"去登录"用错误红（account_security.dart:80-85，settings 主页同病） | 按 signedIn 区分颜色 |
| 低 | 勿扰时间手拼 `HH:mm` 不走系统格式；未登录 inbox 副标题"暂无数据"在加载中也显示；紧急联系人残留 settings 兜底路由 | 逐项打磨 |

#### 3.5.3 资料编辑 `/mine/profile/edit`（`profile_edit.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 身高静默丢失：预填 `"170.0"`（double），保存 `int.tryParse` 失败变 null，老用户直接保存就丢数据（profile_edit.dart:41、52） | `num.tryParse` 接受小数 |
| 高 | 保存失败零界面反馈——错误只进 state 不进 UI（health_edit_forms.dart:39-43 + :86-91） | 失败 toast 或表单内错误条（三个健康表单页同病） |
| 中 | 保存按钮无 loading/禁用态可重复提交 | 接 `isSaving` |
| 中 | 出生日期裸文本框无日期选择器无校验；血型自由文本；单位制下拉显示原始英文 "metric"/"imperial"（:189） | 日期选择器；血型下拉；l10n 映射 |
| 中 | 暴露"已完成引导"内部流程开关给用户拨（:141-145） | 移出表单 |

#### 3.5.4 过敏 / 病史 / 用药三个健康表单页（`allergy_edit.dart`、`condition_edit.dart`、`current_medicine_edit.dart`）

三页同构，共性问题合并（行号以 allergy 为例）：

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 必填校验复用验证码文案 `authCodeRequiredToast` → 不填名称提示"请先填写验证码。"（:70-73） | 新增"请填写名称"类 l10n 键 |
| 高 | 删除无确认弹窗，且删除成功 toast 显示"已保存"（:112-116） | 确认对话框 + "已删除"专用文案 |
| 高 | 类型/严重程度/状态/来源下拉直接显示英文枚举 wire 值（`drug/food/...`、`mild/severe`、`active/resolved`、`drugbank/cn/manual`） | 全部 l10n 映射 |
| 中 | 保存/删除失败静默（同 profile 页）；"记录不存在"态复用错误文案+按钮写"重试"实为返回 | 失败反馈；专用文案+返回按钮 |
| 中 | 用药表单 8 字段无分组平铺；"来源"字段暴露内部数据血缘概念；日期裸文本框；"途径/剂量"自由文本无引导 | 分组+条件显示；来源隐藏或默认 manual；日期选择器；常用值选择+示例 hint |
| 低 | 严重程度/病史状态各档无解释文案；用药预填骨架块数与字段数不符 | 逐项打磨 |

---

### 设置（settings，15 页）

#### 3.6.0 跨页共性

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 垂直 padding 两套标准并存（响应式 24/32 vs 固定 24） | 统一为一种 |
| 中 | 分组标题两套样式：主页 `_SettingsGroup` vs 子页 `SettingsSectionLabel` | 统一为 `SettingsSectionLabel` |
| 中 | 选中勾选图标两套实现：`SettingsSelectionIcon` vs advanced/feature_flags 内联写法（未选中无占位行宽跳变） | 统一复用 `SettingsSelectionIcon` |
| 低 | `AppSettingsMasterTogglePage` 模板死代码，sleep/dnd 两页手写同模式 | 两页改用模板或删模板 |

#### 3.6.1 设置主页（`pages/page.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 未登录"去登录"用错误红色（:556-562），引导登录被渲染成危险操作 | 改 primary/普通样式 |
| 中 | 退出登录无二次确认（:119-127） | 确认对话框（可参考同页数据共享确认弹窗） |
| 中 | "健康档案"入口在"通用"组却 push tab 根页面 `/mine`（:355-361），返回栈混乱 | 移到"账号与安全"组或深链具体子页 |
| 中 | `_SettingsSwitchTile` 与全 App 标准 `FTile+suffix FSwitch` 两种实现并存，开关不可键盘聚焦（:648-705） | 删除自定义实现，统一标准模式 |
| 低 | 两个单 tile 分组碎片化；" /account" 路径硬编码未用常量；通知摘要加载期 value 空串跳变 | 逐项打磨 |

#### 3.6.2 各子页要点

| 级别 | 页面 | 问题 | 建议 |
|------|------|------|------|
| 高 | 高级 | "恢复默认设置"无确认、与导航行无视觉区分（advanced.dart:63-119） | 确认对话框 + destructive 样式；操作行与导航行视觉区分 |
| 高 | 通知 | 权限被永久拒绝后点卡片仍 `requestPermission()`，系统不再弹窗 = 死交互（notification.dart:44-50） | denied 态改 `openAppSettings()`，CTA 改"去系统设置开启" |
| 高 | 安全 PIN | 启用 PIN 只输一次无二次确认，手误即锁死（security_pin.dart:104-151） | 加"再次输入确认" |
| 中 | 主题 | 10 个色系只有文字名无颜色预览（theme.dart:87-95） | 行 prefix 加色点预览 |
| 中 | 无障碍 | 字号四档选项无效果预览 | 各行 label 按对应字号渲染 |
| 中 | AI | 上下文开关 build 时取反写入，快速连点用旧值覆盖，且失败无 toast（ai.dart:166-170） | 点击时读最新值+失败反馈 |
| 中 | 数据导出 | idle 状态 label 与 value 文案相同重复显示（data_export.dart:48、144）；请求中按钮区塌陷为 18px spinner | idle 用"尚未申请"；loading 进按钮内部 |
| 中 | 数据存储 | 缩短保留期可能清理旧数据但无影响确认 | 从"永久"改短时弹确认 |
| 中 | 免打扰/睡眠提醒 | 未设时间时列表显示"未设置"、子页却显示默认 22:00 等，两端不一致 | 默认值首次开启时持久化，或子页显示占位 |
| 中 | 安全 PIN | hint 复用报错文案"PIN 码必须为 6 位数字"；校验只有 toast 无行内 error 无数字过滤 | 专用 hint；行内 error+`digitsOnly` |
| 中 | 帮助 | 空态/错误态同一个纯文本 `_EmptyState`，无图标无重试，未复用 `AppStateErrorView`（help.dart:102-122） | 换统一状态组件 |
| 低 | 语言 | "跟随系统"不显示当前生效语言 | subtitle 补"当前：中文" |
| 低 | 通知 | 权限卡片裸 `FTile` 未包卡片容器；摘要信息 details/subtitle 位置不一 | 包 `FCard.raw`；统一 details |
| 低 | 高级 | 切 endpoint 强制登出但 toast 不提示；"开源许可"与关于页重复 | toast 说明；入口留一处 |
| 低 | 关于 | 应用内跳转与外链共用 chevronRight；支持 URL 硬编码 | 外链换 `arrowUpRight`；URL 进配置 |
| 低 | 免打扰/睡眠 | 跨天时段无"跨天生效"说明 | 加提示文案 |

---

### 其他二级页面

#### 3.7.1 AI 助手对话（`assistant/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 流式期间每个 chunk 无条件 `scrollToBottom`（page.dart:64-66），用户上翻阅读被强制拉回底部，无"回到底部"按钮 | 仅在近底部/自己发消息时自动滚底，上翻后显示悬浮回底按钮 |
| 高 | 6 个设置开关控制面板固定在输入区**下方**常驻占屏（page.dart:378-402），键盘弹出后消息列表几乎不可见 | 开关面板移入抽屉/弹层，对话页只保留 hero 摘要入口 |
| 中 | 流式每个 chunk 整页 rebuild + `MarkdownBody` 重复解析完整 markdown，长消息掉帧风险 | 流式气泡单独 watch 草稿；流式期间纯文本、结束后切 Markdown |
| 中 | 输入区无 Enter/Ctrl+Enter 发送路径（桌面端）；助手禁用时输入框仍可输入仅按钮禁用 | 桌面快捷键；禁用态同步禁输入框并在输入区附近说明原因 |
| 中 | hero 头卡常驻不可折叠，进一步压缩对话区 | 对话开始后折叠为单行状态条 |
| 低 | 用户消息不可选择复制、无时间戳无长按菜单；"正在打开…"/"生成中"纯静态文本；垂直 padding 24/32 魔数；上下文 chip 硬编码 `/4` | 逐项打磨 |

#### 3.7.2 通知列表与详情（`notification/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 分组标题"今天/昨天/更早"硬编码中文（list.dart:171-188）；详情类型 chip 全硬编码中文（detail.dart:170-182） | 新增 l10n 键 |
| 高 | 已读链路断裂：点列表项不标已读；详情"标为已读"按钮 handler 永远调 `markAsUnread`（detail.dart:121-132 vs 240-249）文案与行为相反；返回列表不刷新未读圆点 | 打通"进详情即标读"或修正按钮行为，返回时刷新列表 |
| 中 | `SingleChildScrollView`+for 循环全量渲染，无懒加载；无下拉刷新；滑动操作只有删除；桌面端 Slidable 只能鼠标拖 | `ListView.builder`/sliver 分组；加刷新；滑出加已读切换；桌面 hover 操作钮 |
| 中 | 未读卡片整条 primary 底色+边框+8px 圆点视觉过重，圆点用 `FAvatar.raw(size:8)` 凑数无语义 | 弱化为圆点+加粗标题；补 Semantics |
| 中 | 时间格式硬编码 `yyyy-MM-dd HH:mm`（detail.dart:148、list_item.dart:123） | 走 locale 感知 DateFormat |
| 低 | 详情三等宽 Expanded 按钮窄屏易溢出；错误直拼 `error.toString()`；字符串拼路由未用 typed route；"全部已读"无未读时仍可点 | 逐项打磨 |

#### 3.7.3 法律文档（`legal/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 详情正文 14px 无行高设置，长文偏小；`Markdown` 未开 selectable 无法复制条款（detail.dart:51-69） | 正文升字号+`height: 1.6-1.8`；开 selectable |
| 中 | 详情未包 `ResponsiveContentFrame`，宽屏通栏行长过长 | 限最大内容宽（如 720） |
| 中 | 标题栏固定"文档详情"，正文不显示文档名与更新时间 | 标题栏用文档名，正文顶部补更新时间 |
| 低 | h1/h2/h3 级差小；列表 updatedAt 未格式化 | 逐项打磨 |

#### 3.7.4 认证与账号（`auth/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 高 | 登录/注册/忘记密码/改邮箱**主提交按钮全是 sm 小按钮右对齐**（login.dart:373-403 等四处），主 CTA 权重低、触控目标小，与同页全宽 OAuth 按钮层级倒挂 | 主操作改全宽 primary 标准尺寸 |
| 高 | QQ 登录文案全硬编码英文；四个表单页遍布 `?? 'English fallback'` 兜底，key 缺失时中文界面露英文 | 补齐 l10n 键，收敛兜底 |
| 中 | 登录密码框 hint 复用注册向"至少 8 位…"，登录场景误导（login.dart:307-309） | 登录换中性 hint |
| 中 | 提交错误用内嵌常驻 FToast 不可关闭，与 overlay AppToast 双通道并存 | 统一错误反馈通道 |
| 中 | 注册未勾选条款时按钮直接禁用且无原因提示 | 条款行提示色/点击 toast 说明 |
| 中 | 账号设置改密/注销字段无 validator 靠 toast 报错；注销区与改密同卡无 danger-zone 分区；改密成功直接跳登录无预期 | 字段级校验；注销独立警示卡；toast 说明需重新登录 |
| 中 | 验证码发送按钮固定宽 148+魔数对齐；冷却期行为各页不一（有的可点有的禁用） | token 化；统一冷却期禁用 |
| 低 | "邮箱未验证"无"去验证"入口；改邮箱页按钮 label 误用 `todayHeroTitle`（"今日"）；头像仅 URL 输入无预览无校验；辅助链接 sm 小字触控目标小 | 逐项打磨 |

---

## 四、优先级分批

### P1 —— 体验缺口补全（约 30 项）

1. 空态体系：今日 `TodayEmptyView` 接通（3.1.1）；记录时间线空态+筛选空态（3.2.1）。
2. 骨架对齐：五个 tab 骨架按真实版面重排（C2）。
3. 危险操作确认链：退出登录×2、恢复默认、表单删除×3、PIN 二次输入、保留期缩短（C4）。
4. 表单反馈体系：记录创建/编辑必填校验+内联错误+保存进度（3.2.2/3.2.4）；健康表单失败反馈+删除确认+"已删除"文案（3.5.4）；PIN 行内 error+数字过滤（3.6.2）。
5. 用药导航断层：新建提醒无 medicineId 流程（3.3.5）；时间 sheet 规范化+去重（3.3.5）；扫码引导/权限/手动兜底（3.3.6）；搜索移动端点击死端+防抖（3.3.2）。
6. 报告图表：Y 轴数值+序列撞色+touch tooltip+Semantics（3.4.3）。
7. 我的档案链路：档案行→列表→编辑入口打通+病史行（3.5.0/3.5.2）。
8. 刷新能力：记录主页/详情下拉刷新（3.2.1/3.2.3）；报告切范围保留旧值（3.4.1）；通知下拉刷新（3.7.2）。
9. 设置统一：分组标题/开关 tile/勾选图标/垂直 padding 双实现归一（3.6.0/3.6.1）；主题色系预览、字号预览（3.6.2）。
10. 认证：主 CTA 全宽化+错误通道统一+条款禁用提示（3.7.4）；扫码硬编码中文化（3.3.6）。
11. 助手：控制面板移位+hero 折叠+输入区快捷键（3.7.1）。

### P2 —— 一致性打磨（约 50 项）

- 色弱友好三通道（风险等级、剂量状态、红旗横幅色）（3.3.3/3.3.4）。
- C3-C8 横向收尾：剩余硬编码文案、错误文案 mapper、日期格式收敛、间距魔数 token 化。
- 触控目标与语义补齐（C5）；Material 组件混入清理（提醒表单 chips、各处 `MaterialLocalizations`）。
- 桌面/移动一致性：指标卡移动端补齐（3.4.4）、findings/patterns 假 chevron（3.4.4）、桌面月历交互解耦（3.2.1）、平板中间档限宽。
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
