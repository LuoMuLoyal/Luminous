# Luminous 合规/法律页面补全计划（未完成部分）

> 创建日期：2026-07-10
> 最后修订：2026-08-03
> 状态：P2-1 待实施（ICP 备案 + About 增强）
> 涉及仓库：Luminous（主）

> 进度说明（2026-08-03 更新）：原计划 **P2-2「后端管理法律文档（远程优先 +
> assets fallback）」已完成**——`lib/features/legal/data/repositories/lucent.dart`
> 已实现 remote-first（`GET /api/v1/legal-documents` 列表/详情），API 404 时回退
> `assets/legal/` 本地 Markdown。本文件仅保留**未实施**的 P2-1。

---

## 剩余工作

### P2-1: ICP 备案信息 + About 页增强

**About 页面** (`about_settings_page.dart`) 需增加：
- ICP 备案号展示（需取得备案号后实施）
- 公司信息（名称、联系方式）

当前 About 页已有：App 图标/版本/tagline、法律文档入口（7 项）、开源许可、检查更新、帮助与反馈。

---

## P2-1 验证清单

- [ ] About 页展示 ICP 备案号 + 公司信息
