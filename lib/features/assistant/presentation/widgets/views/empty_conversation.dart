import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/assistant_greeting.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/empty_support.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 会话空态:欢迎区(greeting)+ 起始提示 + 记忆提示 + 免责声明。
///
/// 该组件作为 gen_ai 的 `WelcomeMessageConfig.builder` 内容渲染。gen_ai 在
/// `centerVertically: true` 时已经用 `SingleChildScrollView` + `Center` 包裹
/// 该 builder,所以这里只做自适应收缩高度的内容排布,不再自己滚动或居中,避免
/// 嵌套滚动和无界高度约束(滚动/居中由包负责)。
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: AssistantSvgGreeting(text: l10n.assistantWelcomeTitle)),
        const SizedBox(height: Spacing.xl2),
        AssistantEmptySupport(
          onStarterPrompt: onStarterPrompt,
          showMemoryHint: showMemoryHint,
          showDisclaimerExpanded: showDisclaimerExpanded,
        ),
      ],
    );
  }
}
