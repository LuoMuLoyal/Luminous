import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The floating-scroll-to-bottom button + conversation surface stack.
/// Extracted from [AssistantPageBody] so the parent only orchestrates page-level
/// state without owning the scroll-to-bottom interaction details.
class AssistantConversationStack extends ConsumerWidget {
  const AssistantConversationStack({
    super.key,
    required this.inputController,
    required this.scrollController,
    required this.isNearBottom,
    required this.capabilities,
    required this.hasConversation,
    required this.onStarterPrompt,
    required this.onSend,
    this.onRetry,
    required this.onConfirmProposal,
    required this.onDismissProposal,
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
  });

  final TextEditingController inputController;
  final ScrollController scrollController;
  final ValueNotifier<bool> isNearBottom;
  final AssistantCapabilities capabilities;
  final bool hasConversation;
  final ValueChanged<String> onStarterPrompt;
  final Future<void> Function() onSend;
  final VoidCallback? onRetry;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;

  /// Regenerates the last assistant message (F-5b).
  final VoidCallback? onRegenerate;

  /// Re-sends an existing user message (「重新发送」).
  final void Function(String content)? onResend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lastFailedInput = ref.watch(
      assistantControllerProvider.select((s) => s.lastFailedInput),
    );

    return Stack(
      children: [
        AssistantConversationSurface(
          capabilities: capabilities,
          scrollController: scrollController,
          controller: inputController,
          showStarterPrompts: !hasConversation,
          onStarterPrompt: onStarterPrompt,
          onSend: onSend,
          onRetry: lastFailedInput != null
              ? () => ref
                    .read(assistantControllerProvider.notifier)
                    .retryLastMessage()
              : onRetry,
          onConfirmProposal: onConfirmProposal,
          onDismissProposal: onDismissProposal,
          onRegenerateProposal: onRegenerateProposal,
          onRegenerate: onRegenerate,
          onResend: onResend,
        ),
        if (!isNearBottom.value)
          Positioned(
            right: Spacing.level4,
            bottom: Spacing.level4,
            child: FButton(
              variant: .secondary,
              mainAxisSize: .min,
              onPress: () async {
                isNearBottom.value = true;
                await _scrollToBottom(scrollController);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(SemanticIcons.actionExpand, size: 16),
                  const SizedBox(width: Spacing.level2),
                  Text(l10n.assistantScrollToBottom),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _scrollToBottom(ScrollController controller) async {
    if (!controller.hasClients) return;
    await controller.animateTo(
      controller.position.maxScrollExtent,
      duration: DurationTokens.widgetQuick,
      curve: MotionTokens.snappy,
    );
  }
}
