# lib/core/analytics — 产品测量事件(封闭上报)

目录实现隐私最小化的客户端产品事件:`product_event.dart` 定义封闭 `sealed` union,
`product_event_service.dart` 负责 fire-and-forget 上报与离线重放
(`product_event_service.g.dart` 为生成物)。

## 职责与边界

- 管:四个客户端事件(`SuggestionImpressionEvent` / `ReviewOpenedEvent` /
  `VisitSummaryPreviewedEvent` / `VisitSummaryExportedEvent`)、suggestion rule code 白名单
  (`kAllowlistedSuggestionRuleCodes`)、`POST /user/product-events` 上报与 pending-sync
  队列重放。
- 不管:事件触发时机(由 today/review 的调用方决定)、服务端权威事件(health_event_* /
  suggestion_actioned / visit_summary_share_* 由 Lucent 发,刻意不可在本 union 表达)、
  埋点分析后台。

## 对外契约

- 导出:`product_event.dart` 的 sealed `ProductEvent` union 与白名单常量;
  `product_event_service.dart` 的 `ProductEventService`(`trackSuggestionImpression` /
  `trackReviewOpened` / `trackVisitSummaryPreviewed` / `trackVisitSummaryExported`)、
  `productEventServiceProvider`(keepAlive)、`kProductEventSyncEntityType`。
- 被依赖:features/today(建议卡 impression)、features/review(review 打开、访问小结
  preview/export)。

## 不变量

- 载荷封闭:union 无 `Map<String, dynamic>` 公共入口、无自由文本/元数据字段,结构上无法
  携带症状文本、记录值、PDF URL 等;队列 payload 即 `dto.toJson()` 的白名单键,
  `test/core/analytics/product_event_service_test.dart` 的 `_allowedKeys` 断言。
- 幂等:离线重放复用同一 `clientEventId`(服务端按 per-user 唯一键去重);impression 每
  session 每 rule code 至多一次,review_opened 每 session 至多一次;非白名单 rule code
  客户端直接丢弃,不产生注定 400 的重试堆积。
- fire-and-forget:上报失败仅记日志并入队,永不向调用方抛错、不破坏 UI。
- 重放 handler 在 `productEventService` provider 内注册,按 `kProductEventSyncEntityType`
  分发到 pending-sync worker。

## 依赖禁区

- 仅依赖 `generated/lucent_api`、`../database`(pending-sync)、`../network`(client
  providers)、`../logger`;不依赖 features(触发方 import 本目录,反向禁止)。

## 陷阱与决策

- 平台解析用 `defaultTargetPlatform` 而非 `dart:io`,web 与测试环境可编译可跑。
- 新增客户端事件需双侧同步:Lucent 的 `ProductEventName` 契约 + 本 union 加 variant;新增
  suggestion rule 需同步服务端 rule registry 与 `kAllowlistedSuggestionRuleCodes`。
- 封闭 union 是隐私决策的执行手段:字段审批在类型层面完成,而非依赖 review 约定。
