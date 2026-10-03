import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/assistant_greeting.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/empty_support.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 会话空态:欢迎区(greeting)+ 起始提示 + 记忆提示 + 免责声明。
///
/// `flow_ui` 的 `FlowChatScreen.empty` 紧凑分支把 greeting 放进
/// `Expanded(Center(...))`、把 suggestions 固定在 composer 上方;内容高于视口时
/// 外层 Column 溢出,而 `Center` 不裁剪,greeting 会画到描述文字上(键盘弹起时
/// 更严重,实测 224px 溢出)。这里不使用该分支:本组件放在它的 `thread` 槽位
/// (有界高度)内,自己滚动,composer 仍由 FlowChatScreen 停靠。键盘弹出时视口
/// 收缩只会让内容滚动,不会溢出或重叠。
class AssistantEmptyConversation extends StatelessWidget {
  const AssistantEmptyConversation({
    super.key,
    required this.onStarterPrompt,
    required this.showMemoryHint,
    required this.showDisclaimerExpanded,
  });

  final ValueChanged<String> onStarterPrompt;
  final bool showMemoryHint;
  final bool showDisclaimerExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const padding = EdgeInsets.symmetric(
      horizontal: Spacing.lg,
      vertical: Spacing.md,
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          // 内容装得下时垂直居中，装不下时可滚动 —— 两种情况下都不会溢出。
          // 减去 padding：否则即使内容装得下也总会多出 padding 高度的滚动余量。
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - padding.vertical,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: AssistantSvgGreeting(text: l10n.assistantWelcomeTitle),
              ),
              const SizedBox(height: Spacing.xl2),
              AssistantEmptySupport(
                onStarterPrompt: onStarterPrompt,
                showMemoryHint: showMemoryHint,
                showDisclaimerExpanded: showDisclaimerExpanded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
