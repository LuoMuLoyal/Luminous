import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Header for the assistant conversation drawer: title + new conversation
/// button + close button.
class AssistantConversationDrawerHeader extends StatelessWidget {
  const AssistantConversationDrawerHeader({
    super.key,
    required this.title,
    this.onNewConversation,
    required this.onClose,
  });

  final String title;
  final VoidCallback? onNewConversation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: TypographyToken.level7.display(context)),
        ),
        if (onNewConversation != null) ...[
          FTooltip(
            tipBuilder: (context, controller) =>
                Text(l10n.assistantNewConversationAction),
            child: FButton.icon(
              key: const Key('assistant-sidebar-new-conversation'),
              variant: FButtonVariant.primary,
              onPress: onNewConversation,
              child: const Icon(SemanticIcons.actionAdd, size: 18),
            ),
          ),
          const SizedBox(width: Spacing.level2),
        ],
        FButton.icon(
          variant: FButtonVariant.ghost,
          onPress: onClose,
          child: const Icon(SemanticIcons.actionClose),
        ),
      ],
    );
  }
}
