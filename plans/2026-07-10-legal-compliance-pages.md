# Luminous 合规/法律页面补全计划

> 创建日期：2026-07-10
> 最后修订：2026-07-28
> 状态：P2 待实施（ICP 备案 + About 增强 + 远程优先 fallback）
> 涉及仓库：Luminous（主）、Luminous-website（辅）、Lucent（后端）

---

## 一、剩余工作

### P2-1: ICP 备案信息 + About 页增强

**About 页面** (`about_settings_page.dart`) 需增加：
- ICP 备案号展示（需取得备案号后实施）
- 公司信息（名称、联系方式）

当前 About 页已有：App 图标/版本/tagline、法律文档入口（7 项）、开源许可、检查更新、帮助与反馈。

### P2-2: 后端管理法律文档（远程优先 + assets fallback）

将法律文档内容从纯本地 assets 升级为后端管理 + 本地 fallback：

- 在 Lucent 新建 `legal-documents` 模块或扩展 `support-resources`
- `GET /api/v1/legal-documents` — 列表
- `GET /api/v1/legal-documents/:type` — 详情
- 返回 Markdown 内容 + 更新时间戳
- App 端 data source 改为远程优先 + 本地 assets fallback
- 按照跨项目契约流程：`pnpm export:openapi` → `dart run build_runner build`

---

## 二、P2 验证清单

- [ ] About 页展示 ICP 备案号 + 公司信息
- [ ] `pnpm export:openapi` 成功
- [ ] `dart run build_runner build`（generated client）成功
- [ ] App 端远程优先 + assets fallback 逻辑正确（断网时 fallback 到本地）
