# Active UI — Clinic Summary

后端侧隐私保护的医疗摘要，用于医生分享。

- `POST /reports/clinic-summary/preview` — 脱敏摘要
  - 姓名 mask（张**）
  - 年龄（不是 birthDate）
  - 仅诊断年份
- `POST /reports/clinic-summary/share` — Redis 分享链接，24h TTL
- `GET /reports/clinic-summary/shared/:token` — 公开访问（无需认证），过期返回 410
- `GET /reports/clinic-summary/preview/pdf` — PDF 下载（需认证），A4 格式
  - 包含 profile / allergies / conditions / medicines / disclaimer
  - CJK 字体渲染
- `GET /reports/clinic-summary/shared/:token/pdf` — 公开 PDF 下载
- `@Public()` 装饰器 + 更新的 `JwtAuthGuard`（支持 `Reflector` 的混合认证/公开路由）
- 前端 Report 导出区的分享按钮使用 `Share.share(url)`（`share_plus`）
