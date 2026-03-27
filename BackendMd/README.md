# BackendMd 文档索引

`BackendMd` 是后端协议与实现映射文档目录，重点用于：

- 明确接口协议（请求/响应/场景）
- 追踪 Flutter 调用入口
- 对照 `backend/src` 的实际实现

## 与其他目录的关系

- `backend/`: 当前可部署的 App 后端服务代码
- `lib/Backend/`: 历史草稿文档（保留参考）
- `lib/docs/`: 面向部署和联调的规范文档

## 推荐阅读顺序

1. [../README.md](../README.md)
2. [../backend/README.md](../backend/README.md)
3. 本目录按“已实现接口”优先阅读

## 已实现接口文档

- [medicine-search.md](medicine-search.md)
- [medicine-detail.md](medicine-detail.md)
- [medicine-ai-detail.md](medicine-ai-detail.md)
- [medicine-ai-safety.md](medicine-ai-safety.md)
- [medicine-scan.md](medicine-scan.md)

对应实现位于：

- `backend/src/handlers/*`
- `backend/src/routes/api.ts`

## 规划中或历史协议文档

- [send-code.md](send-code.md)
- [register-user.md](register-user.md)
- [login-user.md](login-user.md)
- [my-medicine.md](my-medicine.md)
- [today-reminders.md](today-reminders.md)
- [reminder.md](reminder.md)
- [checkin-create.md](checkin-create.md)
- [scan-record.md](scan-record.md)
- [aliyun-sms-auth.md](aliyun-sms-auth.md)

这些文档可能与当前 `backend/` 实现不完全一致，新增接口时请以代码为准并同步回写文档。

## 文档维护规范

每篇接口文档建议保持以下结构：

1. 接口目的
2. 请求参数（必填/可选）
3. 响应示例（成功/失败）
4. Flutter 调用位置
5. 后端实现映射
6. 变更记录

## 快速入口

- API 规范总览: [../lib/docs/backend-api.md](../lib/docs/backend-api.md)
- 部署配置总览: [../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)
