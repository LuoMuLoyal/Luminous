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
    required this.searchField,
    this.onNewConversation,
    required this.onClose,
  });

  final String title;
  final Widget searchField;
  final VoidCallback? onNewConversation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: context.theme.typography.display.xl),
            ),
            if (onNewConversation != null) ...[
              // 图标按钮是固有宽度:给宽度上限,标题(Expanded)才不会被挤。
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 56),
                child: FTooltip(
                  tipBuilder: (context, controller) =>
                      Text(l10n.assistantNewConversationAction),
                  child: FButton.icon(
                    key: const Key('assistant-sidebar-new-conversation'),
                    variant: FButtonVariant.primary,
                    onPress: onNewConversation,
                    child: const Icon(SemanticIcons.actionAdd, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 56),
              child: FButton.icon(
                variant: FButtonVariant.ghost,
                onPress: onClose,
                child: const Icon(SemanticIcons.actionClose),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        searchField,
      ],
    );
  }
}
