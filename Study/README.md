# Study 文档中心

`Study` 目录用于代码学习、架构回顾和问题定位，不是对外宣传文档。

## 目标

- 让你快速定位某个功能的实现链路
- 在重构或修复问题时有稳定的“先看哪里”路径

## 建议阅读顺序

1. [00-Review-Summary.md](00-Review-Summary.md)
2. [01-App-Startup-and-Architecture.md](01-App-Startup-and-Architecture.md)
3. [02-Navigation-and-Main-Tabs.md](02-Navigation-and-Main-Tabs.md)
4. 按业务主题阅读 03-11

## 文件索引

- [00-Review-Summary.md](00-Review-Summary.md): 已知风险、review 结论与状态
- [01-App-Startup-and-Architecture.md](01-App-Startup-and-Architecture.md): 启动流程、依赖注入、全局分层
- [02-Navigation-and-Main-Tabs.md](02-Navigation-and-Main-Tabs.md): 路由与主 Tab 结构
- [03-Authentication.md](03-Authentication.md): 认证链路、token、用户态
- [04-Home-and-Today-Reminders.md](04-Home-and-Today-Reminders.md): 首页与今日提醒
- [05-Medicine-Search-and-Detail.md](05-Medicine-Search-and-Detail.md): 搜索、详情、AI 解读
- [06-Scan-Album-and-Safety.md](06-Scan-Album-and-Safety.md): 识别、相册、安全辅助
- [07-Reminders-and-CheckIn.md](07-Reminders-and-CheckIn.md): 提醒、打卡、通知
- [08-Local-Storage-and-Sync.md](08-Local-Storage-and-Sync.md): SQLite 与本地同步边界
- [09-Mine-Profile-and-User-State.md](09-Mine-Profile-and-User-State.md): 我的页与设置状态
- [10-Backend-and-Sealos.md](10-Backend-and-Sealos.md): 后端结构与部署映射
- [11-Android-Native-Startup.md](11-Android-Native-Startup.md): Android 原生启动与平台侧能力

## 按问题类型定位

- 登录、用户状态问题: 先看 `03`、`09`
- 首页样式与提醒问题: 先看 `04`、`07`
- 药品识别/详情问题: 先看 `05`、`06`
- 本地数据残留/同步问题: 先看 `08`
- 接口联调问题: 先看 `10`，再看 `backend/src/handlers`

## 与其他文档的关系

- 项目总览: [../README.md](../README.md)
- 后端文档入口: [../BackendMd/README.md](../BackendMd/README.md)
- 后端运行说明: [../backend/README.md](../backend/README.md)
- 部署配置清单: [../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)

## 维护建议

- 代码结构变更后，优先更新本 README 的索引与入口顺序。
- 新增重大功能时，新增对应专题文档，避免把信息散落到多篇旧文档。
- 关键结论变更时，同步更新 `00-Review-Summary.md`。
