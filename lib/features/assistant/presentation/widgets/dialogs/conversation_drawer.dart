import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_header.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_list.dart';

/// A compact conversation manager shown as a side sheet on mobile and tablet
/// and as a sidebar on desktop.
///
/// Conversations are grouped by recency (today / last 7 days / older) and the
/// currently active conversation is visually highlighted. Rename and delete
/// actions are currently disabled because the backend does not expose
/// `PATCH /conversations/:id` or `DELETE /conversations/:id` yet.
class AssistantConversationDrawer extends StatelessWidget {
  const AssistantConversationDrawer({
    super.key,
    required this.state,
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onRetry,
    required this.onSelect,
    this.onNewConversation,
  });

  final AssistantState state;
  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNewConversation;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width < Breakpoints.tablet
        ? MediaQuery.sizeOf(context).width * 0.85
        : 320.0;

    return SizedBox(
      width: width,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AssistantConversationDrawerHeader(
                title: title,
                onNewConversation: onNewConversation,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: Spacing.level4),
              Expanded(
                child: AssistantConversationDrawerList(
                  state: state,
                  emptyTitle: emptyTitle,
                  emptyDescription: emptyDescription,
                  onRetry: onRetry,
                  onSelect: onSelect,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
