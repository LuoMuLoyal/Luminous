# 联调修正与接入实施计划

> **日期**: 2026-07-20
> **范围**: SSE 超时修复 + 诊所摘要全链路接入 + 建议历史详情面板
> **前置审计**: `plans/2026-07-20-frontend-backend-integration-audit.md`

---

## 任务总览

| # | 任务 | 难度 | 预计工时 | 涉及项目 |
|---|---|---|---|---|
| 3 | 诊所摘要预览弹窗 | ⭐⭐ | 4-6h | Luminous |
| 4 | 诊所摘要 PDF 下载 | ⭐⭐⭐ | 4-6h | Luminous |
| 5 | 诊所摘要分享链路改造（先预览再分享） | ⭐⭐ | 2h | Luminous |
| 6 | 诊所摘要公开分享页（深链接） | ⭐⭐⭐ | 4-6h | Luminous |
| 7 | i18n 字符串补充 | ⭐ | 1h | Luminous |
| 8 | 生成客户端确认 + 测试 | ⭐ | 1-2h | Luminous |

> UserDevices 暂不接入（用户决定）。

---

## 文件变更清单

### 新增文件（5 个）

| 文件路径 | 说明 |
|---|---|
| `lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart` | 预览弹窗 + PDF 下载 + 分享按钮 |
| `lib/features/report/presentation/providers/clinic_summary.dart` | Riverpod providers（preview + shared） |
| `lib/features/report/presentation/pages/clinic_summary_shared.dart` | 公开分享页 |
| `lib/features/report/presentation/widgets/shared/clinic_summary_content.dart` | 共享的摘要内容组件 |

### 修改文件（4 个）

| 文件路径 | 改动 |
|---|---|
| `lib/core/network/api_paths.dart` | 新增 2 个 PDF 路径常量 |
| `lib/features/report/presentation/pages/page.dart` | `clinicShare` 入口改为先弹出预览弹窗 |
| `lib/app/router.dart` | 新增公开路由 + `_publicRoutePrefixes` |
| `lib/l10n/src/report_zh.arb` + `report_en.arb` | 新增诊所摘要 i18n 字符串 |
