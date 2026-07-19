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

### 设置（settings，15 页）

#### 3.6.0 跨页共性

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | `AppSettingsMasterTogglePage` 模板死代码，sleep/dnd 两页手写同模式 | 两页改用模板或删模板 |

#### 3.6.1 设置主页（`pages/page.dart`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 低 | 两个单 tile 分组碎片化 | 逐项打磨 |

#### 3.6.2 各子页要点

| 级别 | 页面 | 问题 | 建议 |
|------|------|------|------|
| 中 | AI | 上下文开关 build 时取反写入，快速连点用旧值覆盖，且失败无 toast（ai.dart:166-170） | 点击时读最新值+失败反馈 |
| 中 | 免打扰/睡眠提醒 | 未设时间时列表显示"未设置"、子页却显示默认 22:00 等，两端不一致 | 默认值首次开启时持久化，或子页显示占位 |
| 低 | 通知 | 权限卡片裸 `FTile` 未包卡片容器；摘要信息 details/subtitle 位置不一 | 包 `FCard.raw`；统一 details |
| 低 | 高级 | 切 endpoint 强制登出但 toast 不提示；"开源许可"与关于页重复 | toast 说明；入口留一处 |
| 低 | 关于 | 应用内跳转与外链共用 chevronRight；支持 URL 硬编码 | 外链换 `arrowUpRight`；URL 进配置 |

---

### 其他二级页面

#### 3.7.1 AI 助手对话（`assistant/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | 流式每个 chunk 整页 rebuild + `MarkdownBody` 重复解析完整 markdown，长消息掉帧风险 | 流式气泡单独 watch 草稿；流式期间纯文本、结束后切 Markdown |
| 中 | 输入区无 Enter/Ctrl+Enter 发送路径（桌面端）；助手禁用时输入框仍可输入仅按钮禁用 | 桌面快捷键；禁用态同步禁输入框并在输入区附近说明原因 |
| 中 | hero 头卡常驻不可折叠，进一步压缩对话区 | 对话开始后折叠为单行状态条 |
| 低 | 用户消息不可选择复制、无时间戳无长按菜单；"正在打开…"/"生成中"纯静态文本；垂直 padding 24/32 魔数；上下文 chip 硬编码 `/4` | 逐项打磨 |

#### 3.7.2 通知列表与详情（`notification/presentation/`）

| 级别 | 问题 | 建议 |
|------|------|------|
| 中 | `SingleChildScrollView`+for 循环全量渲染，无懒加载；无下拉刷新；桌面端 Slidable 只能鼠标拖 | `ListView.builder`/sliver 分组；加刷新；桌面 hover 操作钮 |
| 中 | 未读卡片整条 primary 底色+边框+8px 圆点视觉过重 | 弱化为圆点+加粗标题 |
| 中 | 时间格式硬编码 `yyyy-MM-dd HH:mm`（detail.dart:148、list_item.dart:123） | 走 locale 感知 DateFormat |
| 低 | 详情三等宽 Expanded 按钮窄屏易溢出；错误直拼 `error.toString()`；字符串拼路由未用 typed route | 逐项打磨 |

---

## 四、优先级分批

### P1 —— 体验缺口补全（剩余项）

1. 空态体系：今日 `TodayEmptyView` 接通（3.1.1）；记录时间线空态+筛选空态（3.2.1）。
2. 刷新能力：通知下拉刷新（3.7.2）。
3. 助手剩余项：hero 折叠+输入区快捷键（3.7.1）。
4. 设置剩余项：AI 上下文开关写入时序、免打扰/睡眠提醒默认值不一致（3.6.2）。
5. 通知剩余项：列表懒加载+时间格式 locale 化（3.7.2）。

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
