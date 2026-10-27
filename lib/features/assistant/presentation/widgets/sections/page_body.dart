import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/back_button.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/chat_surface.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/capabilities_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The main body of the assistant page. It watches the assistant controller
/// state directly so the parent [AssistantPage] only has to manage input/scroll
/// controllers and high-level callbacks.
class AssistantPageBody extends ConsumerWidget {
  const AssistantPageBody({
    super.key,
    required this.inputController,
    required this.scrollController,
    required this.onSend,
    required this.onRetry,
    required this.onConfirmProposal,
    required this.onDismissProposal,
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
    required this.onStartNewConversation,
    required this.onOpenDrawer,
  });

  final TextEditingController inputController;
  final ScrollController scrollController;
  final Future<void> Function(String text) onSend;
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
    final recentConversations = ref.watch(
      assistantControllerProvider.select((s) => s.recentConversations),
    );

    final width = MediaQuery.sizeOf(context).width;

    void handleStarterPrompt(String prompt) {
      inputController.value = TextEditingValue(
        text: prompt,
        selection: TextSelection.collapsed(offset: prompt.length),
      );
    }

    return PageScaffold(
      title: l10n.assistantPageTitle,
      leading: const AppBackButton(key: Key('assistant-back-action')),
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
            child: const Icon(SemanticIcons.actionMenu),
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
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.assistantControlsDrawerTitle),
          child: FButton.icon(
            key: const Key('assistant-status-settings-action'),
            variant: FButtonVariant.ghost,
            onPress: !session.canAccessProtectedData
                ? null
                : () => unawaited(context.push(Routes.settingsAi)),
            child: const Icon(SemanticIcons.actionSettings),
          ),
        ),
        // F-10 能力详情入口:与「助手设置」同属能力类动作,放在设置按钮旁。
        // 能力未加载时禁用。面板内容见 AssistantCapabilitiesPanel。
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.assistantCapabilitiesAction),
          child: FButton.icon(
            key: const Key('assistant-capabilities-action'),
            variant: FButtonVariant.ghost,
            onPress: !session.canAccessProtectedData || capabilities == null
                ? null
                : () => unawaited(
                    showAssistantCapabilitiesSheet(context, capabilities),
                  ),
            child: const Icon(SemanticIcons.statusInfo),
          ),
        ),
      ],
      child: ResponsiveContentFrame(
        padding: EdgeInsets.symmetric(
          horizontal: width < Breakpoints.mobile ? Spacing.md : Spacing.lg,
        ),
        child: Padding(
          // 顶部不留内边距:会话区/空态紧贴顶栏,避免顶栏与首条消息之间出现
          // 一条页面底色的空白带。底部内边距保留给 composer 与手势条。
          padding: EdgeInsets.only(
            bottom: width < Breakpoints.mobile ? Spacing.md : Spacing.lg,
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
                if (conversationError != null) ...[
                  const SizedBox(height: Spacing.lg),
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
                  const SizedBox(height: Spacing.md),
                ],
                Expanded(
                  // 会话区紧贴顶栏:页面主体已经在 FHeader 之下,若 chat surface
                  // 再消费一次顶部 inset,会在顶栏与首条消息之间留出空白带。
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: AssistantChatSurface(
                      capabilities: capabilities,
                      inputController: inputController,
                      scrollController: scrollController,
                      onSend: onSend,
                      onConfirmProposal: onConfirmProposal,
                      onDismissProposal: onDismissProposal,
                      onRegenerateProposal: onRegenerateProposal,
                      onRegenerate: onRegenerate,
                      onResend: onResend,
                      onRetry: onRetry,
                      onStarterPrompt: handleStarterPrompt,
                      showMemoryHint: capabilities.assistantMemoryEnabled,
                      showDisclaimerExpanded: recentConversations.isEmpty,
                    ),
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
