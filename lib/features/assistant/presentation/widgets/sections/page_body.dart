import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/controls_sheet_opener.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/status_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_stack.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The main body of the assistant page. It watches the assistant controller
/// state directly so the parent [AssistantPage] only has to manage input/scroll
/// controllers and high-level callbacks.
class AssistantPageBody extends ConsumerWidget {
  const AssistantPageBody({
    super.key,
    required this.inputController,
    required this.scrollController,
    required this.isNearBottom,
    required this.onSend,
    required this.onRetry,
    required this.onConfirmProposal,
    required this.onDismissProposal,
    required this.onStartNewConversation,
    required this.onOpenDrawer,
  });

  final TextEditingController inputController;
  final ScrollController scrollController;
  final ValueNotifier<bool> isNearBottom;
  final Future<void> Function() onSend;
  final VoidCallback? onRetry;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;
  final VoidCallback onStartNewConversation;
  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final capabilities = ref.watch(
      assistantControllerProvider.select((s) => s.capabilities),
    );
    final isLoadingCapabilities = ref.watch(
      assistantControllerProvider.select((s) => s.isLoadingCapabilities),
    );
    final isLoadingConversation = ref.watch(
      assistantControllerProvider.select((s) => s.isLoadingConversation),
    );
    final isLoadingRecentConversations = ref.watch(
      assistantControllerProvider.select((s) => s.isLoadingRecentConversations),
    );
    final isOpeningConversation = ref.watch(
      assistantControllerProvider.select((s) => s.isOpeningConversation),
    );
    final capabilityError = ref.watch(
      assistantControllerProvider.select((s) => s.capabilityError),
    );
    final conversationError = ref.watch(
      assistantControllerProvider.select((s) => s.conversationError),
    );
    final hasConversation = ref.watch(
      assistantControllerProvider.select((s) => s.hasConversation),
    );

    final width = MediaQuery.sizeOf(context).width;

    return PageScaffold(
      title: l10n.assistantPageTitle,
      actions: [
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.assistantRecentConversationsAction),
          child: FButton.icon(
            key: const Key('assistant-recent-conversations-action'),
            variant: FButtonVariant.ghost,
            onPress:
                !session.canAccessProtectedData ||
                    isLoadingRecentConversations ||
                    isOpeningConversation
                ? null
                : onOpenDrawer,
            child: const Icon(SemanticIcons.actionTimeSlot),
          ),
        ),
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.assistantNewConversationAction),
          child: FButton.icon(
            key: const Key('assistant-new-conversation-action'),
            variant: FButtonVariant.ghost,
            onPress:
                !session.canAccessProtectedData ||
                    isLoadingConversation ||
                    ref.read(assistantControllerProvider).isSending ||
                    isOpeningConversation
                ? null
                : onStartNewConversation,
            child: const Icon(SemanticIcons.actionAdd),
          ),
        ),
      ],
      child: ResponsiveContentFrame(
        padding: EdgeInsets.symmetric(
          horizontal: width < Breakpoints.mobile
              ? Spacing.level3
              : Spacing.level4,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level3
                : Spacing.level4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (session.isRestoring) ...[
                const AssistantLoadingView(),
              ] else if (!session.canAccessProtectedData) ...[
                StateMessageView(
                  maxWidth: Breakpoints.assistantContent,
                  title: l10n.authNotSignedIn,
                  description: l10n.assistantSignedOutDescription,
                  icon: SemanticIcons.statusError,
                  actionLabel: l10n.authGoLogin,
                  onAction: () =>
                      context.go(loginRouteForReturnTo('/assistant')),
                ),
              ] else if (isLoadingCapabilities &&
                  isLoadingConversation &&
                  capabilities == null &&
                  capabilityError == null) ...[
                const AssistantLoadingView(),
              ] else if (isLoadingConversation && !hasConversation) ...[
                const AssistantLoadingView(),
              ] else if (capabilities == null) ...[
                StateMessageView(
                  maxWidth: Breakpoints.assistantContent,
                  title: l10n.assistantLoadErrorTitle,
                  description:
                      capabilityError ?? l10n.assistantLoadErrorFallback,
                  icon: SemanticIcons.statusError,
                  tone: StateTone.warning,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref
                      .read(assistantControllerProvider.notifier)
                      .loadCapabilities(),
                ),
              ] else ...[
                AssistantStatusBar(
                  capabilities: capabilities,
                  onOpenSettings: () =>
                      showAssistantSettingsSheet(context, ref, capabilities),
                ),
                if (conversationError != null) ...[
                  const SizedBox(height: Spacing.level4),
                  StateMessageView(
                    title: l10n.assistantLoadErrorTitle,
                    description: conversationError,
                    icon: SemanticIcons.statusError,
                    tone: StateTone.warning,
                    actionLabel: l10n.todayRetryAction,
                    onAction: () => ref
                        .read(assistantControllerProvider.notifier)
                        .loadLatestConversation(),
                  ),
                ],
                const SizedBox(height: Spacing.level3),
                Expanded(
                  child: AssistantConversationStack(
                    inputController: inputController,
                    scrollController: scrollController,
                    isNearBottom: isNearBottom,
                    capabilities: capabilities,
                    hasConversation: hasConversation,
                    onSend: onSend,
                    onRetry: onRetry,
                    onConfirmProposal: onConfirmProposal,
                    onDismissProposal: onDismissProposal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
