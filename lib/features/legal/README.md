# lib/features/legal — 法律与合规文档

一句话:7 类合规文档(terms/privacy/disclaimer/minor-protection/sdk-list/permissions/account-cancellation)的列表与详情页,未登录可访问。

## 职责与边界
- 管:`LegalDocType` 文档的远程拉取(remote-first)与内置 assets/legal/*.md 回退、Markdown 列表/详情渲染。
- 不管:注册/登录页的条款勾选与账号注销流程(auth;本目录只提供 account-cancellation 文档页)。

## 对外契约
- 路由(presentation/routes.dart):`Routes.legal`(/legal)、`Routes.legalDetail`(/legal/:docType,docType 为嵌套子路径)。
- 导出:domain/entities/doc_type.dart(`LegalDocType` 枚举 + `fromPathSegment`)。
- 被依赖:auth 的 login/register/account_settings_sections 直链 `${Routes.legal}/terms|privacy|account-cancellation`;router 将 /legal 列入公开前缀(未登录可看)。

## 不变量
- 404 → assets 回退是文档化产品合同:服务端未发布时合规页必须仍可查看;回退视为 Right,findAll 缺失资产跳过、findOne 缺失资产才是 Left。
- 未知 docType 由 `fromPathSegment` 返回 null,详情页以错误态处理并提供回列表入口;空文档列表是合法 Right;服务端未知 docType 在 findAll 兜底映射为 terms。

## 依赖禁区
- 零跨 feature 依赖;仅经 lib/core/network 的 `lucentClientProvider` 取 LegalDocumentsApi,不直用 Dio。

## 陷阱与决策
- 文档语言经 localeResolver(core/i18n locale)以 zh/en 传给后端;回退资产按 `_zh`/`_en` 后缀选择,新增文档类型需同时补 assets 与枚举。
- 测试在 test/features/legal/(比多数 feature 多一层 features/),镜像测试时注意路径。
