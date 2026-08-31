# lib/features/support — 应用元数据

一句话:从后端公开端点拉取 app 元数据(最低/最新版本、下载链接、支持邮箱),供 About/Help 页消费。

## 职责与边界
- 管:`GET /api/v1/public/app-info` 的读取与 `AppInfo` 模型。
- 不管:semver 比较、About/Help 页 UI、本地包版本号——均属 lib/features/settings。

## 对外契约
- 路由:无——纯 data/domain feature,无 presentation、无路由。
- 导出:data/providers/resources.dart(`appInfoProvider`)、domain/entities/app_info.dart(`AppInfo` + `kFallbackSupportUrl`)。
- 被依赖:settings 的 presentation/pages/about.dart 与 help.dart 消费 `appInfoProvider`。

## 不变量
- 端点公开免登录;字段全部未配置(env 驱动)仍是 Right(`AppInfo` 全空字段),由消费方回退本地值;空成功响应体是 Left(emptyResponse)。
- `null` 语义仅表示"无元数据可用",消费方已守护,不得改动。

## 依赖禁区
- 仅经 lib/core/network 的 `lucentClientProvider` 取 AppInfoApi;无跨 feature 依赖,不直用 Dio。

## 陷阱与决策
- 刻意保持最小面:无 UI 无路由;`kFallbackSupportUrl` 仅作 About 页最后回退。
- TaskEither 仓库边界依据 ../../../docs/reference/adr/0005-result-type-and-error-handling.md;测试在 test/support/。
