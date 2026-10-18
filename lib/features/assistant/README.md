# assistant

一句话:全屏 AI 助手工作区(`Routes.assistant`):基于 Lucent 后端的流式对话(chat + 工具调用 + 写操作 proposal 确认),渲染经 `flutter_gen_ai_chat_ui`,五 tab 之外的全屏路由。

## 职责与边界
- 管:capabilities 读取与发送门控、会话列表/打开/重命名/删除/清空 latest、SSE 流式问答与重新生成、写 proposal 的确认/拒绝(`domain/repositories/assistant.dart` 为全量合同);gen_ai 适配与消息流 UI(`presentation/widgets/chat_adapter.dart`、`chat_surface.dart`)。
- 不管:模型/工具执行/会话持久化全在 Lucent 后端;本地 on-device AI 实验归 `lib/core/ai`(本 feature 不引用);proposal 落地后的业务写由对应 feature 完成(本 feature 只 emit DataChangeBus);today/review 的建议与摘要类 AI 不走本 feature。

## 对外契约
- 路由:`Routes.assistant` = `/assistant`,顶层全屏 `AssistantRoute`(`presentation/routes.dart`);未登录可进预览(`lib/app/router.dart` `_publicRootRoutes`)。
- 导出:无——`assistantControllerProvider` 等仅 feature 内消费;外界只经路由进入,无 provider 级依赖。
- 被依赖(仅路由入口):`today/presentation/widgets/shared/top_bar.dart`、`shell/presentation/page.dart`、`core/shortcuts/bindings.dart`(Ctrl/Cmd+Shift+A)、`core/widgets/common/dialog/command_palette.dart`、`core/router/action_route_mapper.dart`('assistant' action)。

## 不变量
- 生产链路 = Lucent 后端:generated `AssistantApi` + `LucentSseClient`(`core/network/client/sse.dart`)POST `/api/v1/user/assistant/messages/stream`(regenerate 走 `/conversations/{id}/regenerate`),事件 chunk/result/error/done;流语义不包 `TaskEither`,失败以 stream error 上抛(`domain/repositories/assistant.dart` 注释;`test/assistant/remote_data_source_stream_test.dart`)。
- `lib/core/ai` 是实验 seam(文件头 "not part of the shipping assistant path"),assistant 不得 import 它。
- 发送门控以后端 capabilities 为准:`AssistantCapabilities.canSendMessages`;未登录(`canAccessProtectedData == false`)直接空态,不发请求(`presentation/providers/conversation.dart`)。
- 消息 canonical id 由 `presentation/utils/message_id.dart` 决定,gen_ai 列表身份与之解耦(gen_ai 列表 id = `$conversationId:$index:$canonical`,`chat_adapter.dart` 头注释;`test/assistant/chat_adapter_test.dart`)。
- proposal 决策必须经后端 `confirmProposals` 恢复挂起的 graph thread,成功后 emit 对应 `DataChangeTopic`(dailyRecords/userSettings)驱动其他 feature 刷新。

## 依赖禁区
- 不 import 任何其他 feature;跨 feature 感知只经 `dataChangeBusProvider` emit。
- 不 import `lib/core/ai`;网络只走 `core/network`(SSE client + error contract),不自行建 Dio。

## 陷阱与决策
- 渲染经 `flutter_gen_ai_chat_ui`(gen_ai,建在 framework `package:flutter/material.dart` 上,尚未迁 `material_ui`)的 `AiChatWidget`:`chat_adapter.dart` 只做 domain→view-model 映射且不持有状态;Forui/SemanticColor 主题经 `chat_theme_bridge.dart` 桥成一层 framework `ThemeData`(+ `CustomThemeExtension`)。**主题桥必须显式设 `brightness`/`colorScheme`**:app 根是 `material_ui` 的 `MaterialApp`,framework `Theme.of` 在根下恒为 M3 默认浅色,继承会串色/丢深浅(`chat_theme_bridge.dart` 头注释;`test/assistant/page_test.dart` 的 `AssistantPage scopes one chat theme bridge below MaterialApp`)。
- 流式草稿 `streamingDraft` 与已落库 `messages` 分离;发送失败保留 `lastFailedInput` 供重发(`presentation/providers/conversation.dart`)。SSE 生命周期经 `ref.listen` 镜像到 `ChatMessagesController.setStreamingMessage`/`stopStreamingMessage`(稳定 id `assistant:streaming`),驱动 gen_ai 的流式 caret;**不在 build 内调用**(会 build 期 notify)。
- SSE 复用 dio 实例(`LucentSseClient(dio: dio)`),`error` 事件经 `mapSseStreamError` 直接 throw,勿吞掉。
- 会话持久化全在后端(latest/rename/delete/clear 均为 API 调用),客户端不写本地库。
- AI 回复用 gen_ai 自带气泡(markdown/流式 caret),底色取主题桥的 `CustomThemeExtension.messageBubbleColor`(= Forui `colors.secondary`);来源条/免责声明/proposal 卡/copy-regen-动作行经 `MessageOptions.bubbleBuilder`(`chat_adapter.dart` 的 `buildBubble` + `_AssistantMessageChrome`)**追加在气泡下方**,不再包进一块面板。gen_ai 自带的 action row 关闭(`showCopyButton:false`/`showTime:false`),改由自研 `_ActionRow` 渲染以保留 l10n 文案。
- 欢迎区 greeting 用 `AssistantSvgGreeting`(`sections/assistant_greeting.dart`,iconMind SVG AI 图标 `SemanticIconSvg.aiGenerated`),作为 gen_ai `WelcomeMessageConfig.builder` 的内容(`empty_conversation.dart`)渲染;gen_ai 在 `centerVertically:true` 时已用 `SingleChildScrollView`+`Center` 包裹 builder,故空态**不再自己滚动/居中**(避免嵌套滚动与无界高度约束)。
- AI 语义图标(入口/生成中/记忆/RAG/工具)统一走 `SemanticIconSvg`(`core/design/tokens/semantic_icon_svg.dart`,iconMind SVG);通用操作/状态图标仍走 `SemanticIcons`(Lucide)。能力面板摘要行/工具行即为此分工的例子。
