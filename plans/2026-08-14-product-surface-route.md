# 产品表面路线:手机核心 + 桌面 SaaS 差异化 + Web 第三客户端

Created: 2026-08-14
Updated: 2026-08-15

> 状态:方向提案待决策(ADR-0012),未执行。背景源于产品定位讨论:项目从大学竞赛产物转向正式产品。
> 权威决策:`docs/02-reference/adr/0012-desktop-independent-web-product-route.md`(proposed);仅在 ADR 通过后转为执行计划。
> 相关讨论草稿见 `plans/adr-015-luminous-desktop-deprecation-and-monorepo-evolution.md`(临时草稿,非正式 ADR,2026-08-14 讨论记录);
> 配套后端计划见 `Lucent/plans/2026-08-14-saas-modules-and-node-monorepo.md`。
> 本文档为方向性计划;具体执行细节在执行前按任务拆分子计划。

## 一、目标

1. 0.1.0 移动端发布验证**不阻塞、零重构**——本计划的所有动作都不得挡住发布门禁。
2. 把「桌面端冻结」决策升级为「桌面端 SaaS 差异化独立路线」:不再追求与手机端功能对等,
   桌面工作台走**独立 web 客户端(Next.js)**形态,不复刻五大 Tab。
3. Web 端承担两个形态:移动 web(Flutter,鸿蒙过渡)与桌面 web(SaaS 工作台,Next.js),
   由各自技术栈维护,不做「电脑浏览器跑 Flutter Web」的尴尬形态。

## 二、候选方案(2026-08-15 修订,待 ADR-0012 决策)

- **Flutter 只做手机 App + 移动 web**:Android/iOS 与 Flutter Web(手机浏览器,鸿蒙过渡)继续维护;
  **Flutter Desktop 与 Flutter Web(PC)冻结**(`git tag desktop-final-frozen` / `web-pc-final-frozen`),
  代码不删、不再维护。
- **桌面工作台 = 独立 Next.js web 客户端**(Lucent monorepo 的 `apps/saas`),与营销站同生态;
  技术选型依据:桌面端核心能力是复杂数据表/筛选/趋势图表,web 生态(TanStack Table/AG Grid + ECharts)
  对此碾压 Flutter;WebView 性能顾虑经调研澄清(WebView2=Chromium,瓶颈在数据层工程,不在引擎);
  升级路径不对称(web→Tauri 加壳 UI 零重写,Flutter→web 全量重写)。
- 手机端是**当前核心产品表面**:当前发布结构仍为今日 / 记录 / 用药 / 回顾 / 我的;长期 Tab 结构由 ADR-0012 另行决策。
- 工作台定位一句话:**手机负责「记」,电脑负责「看和分析」**——历史趋势大屏、就诊资料整理、
  报告生成与预览、批量导入、健康事件深度复盘。
- 路由边界:Flutter Web 检测屏幕宽度 > 768px 时跳转 SaaS 登录页,手机浏览器 → Flutter Web,
  电脑浏览器 → SaaS(Next.js),不再维护桌面形态的 Flutter Web。
- 平台门控路由(条件导入)仅服务于**移动 web 的能力降级**,不再承载桌面 SaaS 表面。

## 三、Web 端能力边界

### 移动 web(Flutter,继续维护)

- [ ] 保留 drift 本地库(`web/drift_worker.js` + `sqlite3.wasm` 已可用),不破坏随手记离线体验
- [ ] 保留账号体系与云端同步(微信登录需替换,见下)
- [ ] 保留核心记录/今日/回顾的只读与基础录入流程

### 移动 web 阉割 / 替换清单

- [ ] 微信登录:fluwx 为原生 SDK,web 改为扫码 OAuth 流程(需 Lucent 支持,后端计划第一优先)
- [ ] 推送与本地通知:JPush、flutter_local_notifications 在 web 端不可用,隐藏相关入口
- [ ] 扫码 / OCR:mobile_scanner、paddle_ocr 不上 web
- [ ] 健康数据桥接:Apple Health / Health Connect 与 web 无关,隐藏入口
- [ ] 图像压缩等依赖原生能力的功能按需降级
- [ ] 每次移动端新增功能,需过「web 端如何降级」检查(持续成本,非一次性)

### 桌面 web(SaaS 工作台,Next.js,新建)

- [ ] 登录(微信扫码 OAuth + 账号体系)与账号/安全设置
- [ ] 工作台 Dashboard(Phase 1):关键指标卡 + 时间线 + 图表,验证可行再扩展
- [ ] 就诊摘要管理列表(查看/下载/分享历史报告,复用现有可撤销分享 API)
- [ ] 健康事件详细复盘页(多维度筛选、对比、自定义时间窗口)
- [ ] 数据导出(CSV/PDF,复用 data-export API)
- [ ] Tauri 加壳按触发条件评估(本地目录导出 / 托盘 / 通知 / 自动更新),UI 零重写

## 四、架构动作

- [ ] Flutter 侧:冻结 Desktop / Web(PC)目标,标记冻结点;清理 `Platform.isWindows` 等条件编译
      作为长期事项(不设 deadline,「什么时候成了拖后腿的维护负担,什么时候动手」)
- [ ] Flutter Web(手机)保留响应式层现状(`breakpoints.dart` / `responsive_sizing.dart` 不重构),
      新增 >768px 跳转 SaaS 登录页的边界逻辑
- [ ] 移动端独占插件抽象层维持现状(fluwx、mobile_scanner、paddle_ocr 已有 stub/条件导入,不推倒)
- [ ] SaaS 工作台代码位于 Lucent monorepo `apps/saas`(Next.js),与后端同仓同 CI

## 五、文档同步(发布前完成)

- [ ] `docs/00-current/Project_Governance.md` 产品表面一节:桌面端由「冻结」改写为「SaaS 差异化定位」
- [ ] `docs/00-current/Desktop_UI.md`:状态由 `frozen` 改为记录桌面端新定位与工作台方向
- [ ] `docs/00-current/Next_Plan.md`:「不要现在开始」清单更新,标注 SaaS/web 路线与依赖
- [ ] 迁移日志:追加本计划修订条目(范围:方向计划,无代码变更)

## 六、执行顺序

1. [ ] 0.1.0 移动端发布验证(当前门禁,零重构,只修阻断项)
2. [ ] 文档同步 + 冻结点标记(Phase 0)
3. [ ] 依赖 Lucent `apps/saas` 与 web 扫码登录落地后,开始工作台 MVP(Phase 1 单页 Dashboard)
4. [ ] 工作台完善(Phase 2:就诊摘要管理 / 事件复盘 / 导出)
5. [ ] 移动 web 按第三节清单做能力降级与 >768px 跳转边界
6. [ ] SaaS 表面长大、共享代码占比下降后,再评估是否抽取独立应用(现阶段工作台独立于 Flutter,无需再拆)

## 七、待定问题

- 鸿蒙扩展路径:移动 web 直跑浏览器 vs 打包为鸿蒙 WebView 容器(需鸿蒙设备验证)
- 工作台 MVP 最小功能集与页面结构(Phase 1 启动前定)
- web 微信扫码登录的 Lucent 侧工作量(后端计划已排为第一优先)
- Tauri 加壳触发条件的观测方式(用户反馈渠道 / 功能请求统计)
