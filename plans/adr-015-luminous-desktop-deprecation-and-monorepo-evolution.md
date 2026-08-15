# Luminous 多端架构重组决策记录

> **日期**: 2026-08-14  
> **参与**: LuoMuLoyal (落幕Loyal), Lumi  
> **状态**: 已决策，待执行  
> **影响范围**: Luminous (前端), Lucent (后端), 文档站, 官网

---

## 背景

Luminous 最初为大学竞赛而生，采用 Flutter 跨端方案（Android / iOS / Web / Desktop）。随着项目从竞赛 demo 向真正产品演进，Desktop 端和 Web PC 端的用户价值与维护成本出现严重倒挂。

本次讨论的核心问题：**如何给电脑端一条活路，同时不让手机端被拖垮？**

---

## 交谈摘要

### 第一轮：问题的提出

**LuoMuLoyal**:
> 我想要给电脑端和 web 端一个活路。手机端是今日、记录、用药、回顾、我的这些功能模块。电脑端这五个 tab 在电脑端没有价值，也就我的页面有保留价值。我的计划是把电脑端改成 SaaS，与手机端完全不同的发展路线。web 端手机端那边和电脑端那边顺便维护了，做一下条件导入，本地缓存难做的直接在 web 端阉割掉。

**Lumi 追问**:
> 电脑端 SaaS 的目标用户是谁？个人用户？医生/管理员？电脑端用不用 Flutter？还是彻底换 Web 技术栈？Flutter 项目要不要和 Lucent 合在一个 monorepo？

### 第二轮：目标用户的明确

**LuoMuLoyal**:
> 电脑端 SaaS 的目标用户我定义为了个人用户。电脑端用不用 Flutter 其实说真的有点难以抉择。Luminous 和 Lucent 肯定不会放在一个 monorepo 里。其实 SaaS 需要的功能我还没想好，主要是想给电脑端一条活路。作为 Luminous Desktop 肯定是活不成了，改造成 SaaS 或者说 SaaS 风格是我能想到的最好的方案了。

### 第三轮：Flutter Desktop 的死亡宣判

**Lumi**:
> Flutter Desktop 彻底不用了。生态弱（没有 AG Grid、没有 ECharts）、场景不匹配（谁坐电脑前记喝水？）、维护恶心（条件编译）、部署麻烦（打包分发）。电脑端做数据看板+分析工作台，Web 技术栈是降维打击。

**LuoMuLoyal** 确认:
> 也就是 Flutter Desktop 完全不再使用？

**Lumi**:
> 对。Flutter 只做手机 App。电脑上的一切——SaaS、官网、文档——全部走 Web 技术栈。`Platform.isWindows` / `Platform.isMacOS` / `Platform.isLinux` 相关的条件编译，后面可以慢慢清理掉。

### 第四轮：Tauri 的否决

**LuoMuLoyal**:
> 那电脑端还要不要一个 app？比如说 Tauri？

**Lumi**:
> 不需要。Tauri 能给的（桌面图标、离线运行、本地文件访问），你的 SaaS 现在都不需要。书签够了，离线看旧数据优先级不高，PWA 先够用了。现在加 Tauri 是过度设计。先让 SaaS 在浏览器里跑起来，验证有人用，再考虑要不要套壳。

### 第五轮：情感关

**LuoMuLoyal**:
> 亲手删掉已经维护了几个月的桌面端代码换成 Next 重做一遍，难免不舍。

**Lumi**:
> 先不删，冻结它。`git tag desktop-final-frozen` 打个标签。代码不删也不改，新开 `apps/saas` 做 Next.js，两边并行。等 SaaS 能用了、你自己也过了这关，再慢慢清理。不是非黑即白，可以共存。
>
> 这个决策不设 deadline，但有个底线："什么时候 Desktop 成了拖后腿的维护负担，什么时候动手。"

### 第六轮：最终架构确认

**LuoMuLoyal**:
> 那也就是总的来说，Luminous 退化为只再进行手机端维护与更新，桌面端冻结，web 端的手机端继续维护，web 端的电脑端同样冻结。然后 Lucent 进化为 Lucent 本体 + 文档站 + 宣传网站 + SaaS 的 monorepo？

**Lumi**:
> 对，完全正确。
>
> 唯一需要明确的边界：Flutter Web 的"手机浏览器"和"电脑浏览器"怎么区分？
>
> 建议：电脑浏览器打开 Flutter Web 时，检测屏幕宽度 > 768px，直接跳转到 Lucent SaaS 的登录页。这样手机浏览器 → Flutter Web（轻量版），电脑浏览器 → SaaS 后台（Next.js），不再维护"电脑浏览器跑 Flutter Web"这个尴尬的存在。

**LuoMuLoyal**:
> 不错。

---

## 决策

### 冻结（不删，停止维护）

| 项目 | 状态 | 说明 |
|---|---|---|
| Luminous Desktop (Win/Mac/Linux) | ❌ 冻结 | `git tag desktop-final-frozen`，代码不删，不再维护 |
| Luminous Web (PC 浏览器) | ❌ 冻结 | 不再维护电脑浏览器下的 Flutter Web 渲染 |

### 继续维护

| 项目 | 状态 | 说明 |
|---|---|---|
| Luminous Android/iOS | ✅ 继续 | Flutter，核心产品 |
| Luminous Web (手机浏览器) | ✅ 继续 | Flutter Web 条件编译，鸿蒙过渡用 |

### 新建/迁移

| 项目 | 状态 | 说明 |
|---|---|---|
| Lucent `apps/saas` | 🆕 新建 | Next.js，个人用户数据管理后台 |
| Lucent `apps/website` | 🔄 迁入 | 现有独立 website 仓库并入 monorepo |
| Lucent `apps/docs` | 🔄 迁入 | 现有 GitHub Pages 文档站并入 monorepo |

---

## 最终架构

```
┌─────────────────────────────────────────────────────────┐
│                     Lucent (monorepo)                    │
│  ┌─────────────┐  ┌──────────┐  ┌───────┐  ┌─────────┐ │
│  │ api/        │  │ docs/    │  │ web/  │  │ saas/   │ │
│  │ NestJS 后端 │  │ 文档站   │  │ 官网   │  │ SaaS   │ │
│  │ (现有)      │  │ (迁入)   │  │ (迁入) │  │ (新建) │ │
│  └─────────────┘  └──────────┘  └───────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼ API
┌─────────────────────────────────────────────────────────┐
│                   Luminous (独立 repo)                   │
│                                                         │
│   ┌─────────────┐    ┌─────────────┐    ┌───────────┐  │
│   │ Android/iOS │    │ Web (手机)  │    │ Web (PC)  │  │
│   │  Flutter    │    │  Flutter    │    │  冻结 ❌   │  │
│   │  ✅ 维护     │    │  条件编译    │    │           │  │
│   │             │    │  ✅ 维护     │    │           │  │
│   └─────────────┘    └─────────────┘    └───────────┘  │
│                                                         │
│   ┌─────────────┐                                       │
│   │ Desktop     │                                       │
│   │ Win/Mac/Lin │                                       │
│   │ 冻结 ❌      │                                       │
│   └─────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 实施路径

### Phase 0: 本周（立即）

1. **标记冻结点**
   ```bash
   cd Luminous
   git tag desktop-final-frozen
   git tag web-pc-final-frozen
   ```

2. **Lucent monorepo 骨架**
   ```bash
   cd Lucent
   npx create-next-app apps/saas --typescript --tailwind --eslint --app --src-dir
   ```

3. **迁移 website 和 docs**
   - 将现有独立 website 仓库代码复制到 `apps/website`
   - 将现有 GitHub Pages 文档站复制到 `apps/docs`
   - 统一 package.json / tsconfig / eslint 配置

### Phase 1: 本月（验证 SaaS 可行性）

1. **后端**: 新增 `GET /me/dashboard` 端点，返回用户聚合数据（记录数、用药依从率、活跃事件等）
2. **前端**: SaaS Dashboard 单页——顶部关键指标卡片 + 左侧时间线 + 右侧简单图表
3. **路由**: Flutter Web 检测屏幕宽度 > 768px 时，跳转到 SaaS 登录页

### Phase 2: 下月（完善 SaaS）

1. 就诊摘要管理列表（查看/下载/分享历史报告）
2. 健康事件详细复盘页
3. 数据导出（CSV/PDF）

### Phase 3: 远期（按需）

1. 高级分析（AI 洞察、趋势预测）
2. 自定义看板
3. 考虑 PWA（如果需要"安装感"）
4. 考虑 Tauri（如果有本地文件访问/离线刚需）

---

## 风险与保留意见

| 风险 | 缓解措施 |
|---|---|
| SaaS 功能没想好就动手，做成半成品 | Phase 1 只做一页 Dashboard，验证能跑通再扩展 |
| Luminous Web（手机浏览器）条件编译越来越恶心 | 明确"鸿蒙过渡用"的定位，不无限投入 |
| monorepo 工具链复杂化 | 用 pnpm workspace + Turborepo，先轻量 |
| 情感关：舍不得删 Desktop 代码 | 不删，冻结。让 SaaS 自然替代，不是亲手埋葬 |

---

## 附录：电脑端 SaaS 的核心价值主张

手机端的核心价值是**即时性+随身性**，这两点在电脑端都是 0。电脑端 SaaS 的唯一活路是**数据管理中心**——手机上看不清的东西：

| 功能 | 为什么电脑上体验更好 |
|---|---|
| **历史趋势大屏** | 12 个月血糖/体重曲线，手机屏根本展不开 |
| **就诊资料整理** | 拖拽上传 PDF、批量标注、按时间线归档 |
| **报告生成与预览** | 完整 PDF 预览、直接打印、分享给医生 |
| **批量数据导入** | Excel/CSV 导入历史数据，手机端几乎做不了 |
| **健康事件深度复盘** | 多维度筛选、交叉对比、自定义时间窗口 |

**定位一句话：手机负责"记"，电脑负责"看和分析"。**

---

## 备注

- 本次决策基于 2026-08-14 晚间的讨论，由 LuoMuLoyal 发起，Lumi 协助梳理
- 决策可回溯，冻结不等于删除，SaaS 验证失败可恢复 Desktop 维护
- 下一步行动：LuoMuLoyal 确认是否立即执行 Phase 0


