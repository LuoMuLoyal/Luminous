# Lucent Contract Snapshot

- API base：`/api/v1`
- 响应包络：`{ code, message, data }`
- 生成合同：`Lucent/docs/openapi.json`
- 当前生成客户端基线：84 paths / 188 schemas
- Luminous 已使用的后端领域：
  - auth / account
  - user-scoped health context
  - medicine search / detail
  - current medicines
  - dose logs
  - medicine reminders
  - daily records（含单图附件元数据）
  - environment snapshot
  - user settings
  - support resources
  - app info
  - data export requests
- 用户业务数据在 `/api/v1/user/*` 下；账户资料/安全操作在 `/api/v1/account/*` 下。
