import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/capabilities_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_message_list.dart';
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
    final isSending = ref.watch(
      assistantControllerProvider.select((s) => s.isSending),
    );
    final sendError = ref.watch(
      assistantControllerProvider.select((s) => s.sendError),
    );
    final sendErrorType = ref.watch(
      assistantControllerProvider.select((s) => s.sendErrorType),
    );
    final lastFailedInput = ref.watch(
      assistantControllerProvider.select((s) => s.lastFailedInput),
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
            child: const Icon(FLucideIcons.menu),
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
                  child: FlowChatScreen(
                    key: const Key('assistant-flow-chat-screen'),
                    empty:
                        !hasConversation &&
                        capabilities.canSendMessages &&
                        !isSending,
                    greeting: FlowGreeting(
                      text: l10n.assistantWelcomeTitle,
                      icon: SemanticIcons.aiGenerated,
                    ),
                    suggestions: _AssistantEmptySupport(
                      onStarterPrompt: handleStarterPrompt,
                      showMemoryHint: capabilities.assistantMemoryEnabled,
                      showDisclaimerExpanded: recentConversations.isEmpty,
                    ),
                    thread: AssistantConversationMessageList(
                      capabilities: capabilities,
                      scrollController: scrollController,
                      onConfirmProposal: onConfirmProposal,
                      onDismissProposal: onDismissProposal,
                      onRegenerateProposal: onRegenerateProposal,
                      onRegenerate: onRegenerate,
                      onResend: onResend,
                    ),
                    composer: _AssistantComposerHost(
                      controller: inputController,
                      isSending: isSending,
                      canSendMessages: capabilities.canSendMessages,
                      onSend: onSend,
                    ),
                    aboveComposer: isOpeningConversation || sendError != null
                        ? _AssistantAboveComposer(
                            isOpeningConversation: isOpeningConversation,
                            sendError: sendError,
                            sendErrorType: sendErrorType,
                            onRetry: lastFailedInput != null
                                ? () => ref
                                      .read(
                                        assistantControllerProvider.notifier,
                                      )
                                      .retryLastMessage()
                                : onRetry,
                          )
                        : null,
                    threadController: scrollController,
                    jumpToLatestTooltip: l10n.assistantJumpToLatestTooltip,
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

class _AssistantAboveComposer extends StatelessWidget {
  const _AssistantAboveComposer({
    required this.isOpeningConversation,
    required this.sendError,
    required this.sendErrorType,
    required this.onRetry,
  });

  final bool isOpeningConversation;
  final String? sendError;
  final AssistantSendErrorType? sendErrorType;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOpeningConversation)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.level3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                      width: 16,
                      height: 16,
                      child: FCircularProgress(),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 800.ms),
                const SizedBox(width: Spacing.level2),
                Text(
                  l10n.assistantOpeningConversationLabel,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        if (sendError != null) ...[
          if (isOpeningConversation) const SizedBox(height: Spacing.level4),
          StateMessageView(
            title: l10n.assistantSendErrorTitle,
            description: sendErrorDescription(l10n, sendErrorType, sendError!),
            icon: sendErrorIcon(sendErrorType),
            tone: StateTone.warning,
            actionLabel: onRetry != null
                ? l10n.assistantContinueGeneratingAction
                : null,
            onAction: onRetry,
            actionKey: const Key('assistant-retry-action'),
            padding: const EdgeInsets.all(Spacing.level4),
          ),
        ],
      ],
    );
  }
}

/// Direct assistant host for FlowUI's multiline composer.
///
/// The page owns the shared controller and the no-argument send callback;
/// FlowComposer continues to own text editing, multiline behavior, and the
/// send action.
class _AssistantComposerHost extends StatelessWidget {
  const _AssistantComposerHost({
    required this.controller,
    required this.isSending,
    required this.canSendMessages,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool canSendMessages;
  final Future<void> Function() onSend;

  void _handleSend(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    controller.value = TextEditingValue(
      text: trimmedText,
      selection: TextSelection.collapsed(offset: trimmedText.length),
    );
    unawaited(onSend());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!canSendMessages)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.level3),
            child: Row(
              children: [
                Icon(
                  SemanticIcons.statusPaused,
                  size: 14,
                  color: SemanticColor.neutral.solid(context),
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Text(
                    l10n.assistantInputDisabledHint,
                    style: context.theme.typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Material(
          type: MaterialType.transparency,
          child: FlowComposer(
            key: const Key('assistant-input'),
            controller: controller,
            placeholder: l10n.assistantComposerPlaceholder,
            maxLines: 5,
            submitOnEnter: false,
            enabled: canSendMessages && !isSending,
            isStreaming: false,
            clearOnSend: true,
            onSend: _handleSend,
          ),
        ),
      ],
    );
  }
}

/// Assistant-specific support rendered inside FlowChatScreen's empty state.
///
/// FlowChatScreen owns the greeting and composer layout. This host retains the
/// existing assistant description, starter prompts, memory hint, and
/// collapsible health disclaimer without introducing new localization.
class _AssistantEmptySupport extends StatefulWidget {
  const _AssistantEmptySupport({
    required this.onStarterPrompt,
    this.showMemoryHint = false,
    this.showDisclaimerExpanded = true,
  });

  final ValueChanged<String> onStarterPrompt;
  final bool showMemoryHint;
  final bool showDisclaimerExpanded;

  @override
  State<_AssistantEmptySupport> createState() => _AssistantEmptySupportState();
}

class _AssistantEmptySupportState extends State<_AssistantEmptySupport> {
  late bool _disclaimerExpanded;

  @override
  void initState() {
    super.initState();
    _disclaimerExpanded = widget.showDisclaimerExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prompts = <String>[
      l10n.assistantStarterPromptTodaySummary,
      l10n.assistantStarterPromptSleep,
      l10n.assistantStarterPromptMedicines,
      l10n.assistantStarterPromptWhatToWatch,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.assistantWelcomeDescription,
          textAlign: TextAlign.center,
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.level6),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.assistantStarterPromptTitle,
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              const SizedBox(height: Spacing.level2),
              FlowSuggestionGroup(
                layout: FlowSuggestionLayout.column,
                suggestions: [
                  for (final prompt in prompts)
                    FlowSuggestion(
                      label: prompt,
                      onTap: () => widget.onStarterPrompt(prompt),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (widget.showMemoryHint) ...[
          const SizedBox(height: Spacing.level5),
          const _AssistantMemoryHintSection(),
        ],
        const SizedBox(height: Spacing.level3),
        _AssistantDisclaimerSection(
          expanded: _disclaimerExpanded,
          onToggle: () =>
              setState(() => _disclaimerExpanded = !_disclaimerExpanded),
        ),
      ],
    );
  }
}

class _AssistantMemoryHintSection extends StatelessWidget {
  const _AssistantMemoryHintSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            SemanticIcons.statusInfo,
            size: 14,
            color: SemanticColor.neutral.solid(context),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assistantMemoryHintTitle,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.assistantMemoryHintDescription,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantDisclaimerSection extends StatelessWidget {
  const _AssistantDisclaimerSection({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: expanded
          ? l10n.assistantDisclaimerCollapseAction
          : l10n.assistantDisclaimerShowAction,
      child: GestureDetector(
        key: const Key('assistant-welcome-disclaimer'),
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                SemanticIcons.statusInfo,
                size: 14,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.level2),
              Expanded(
                child: Text(
                  l10n.assistantDisclaimerText,
                  maxLines: expanded ? null : 1,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.level2),
              Icon(
                expanded
                    ? SemanticIcons.actionCollapse
                    : SemanticIcons.actionExpand,
                size: 14,
                color: SemanticColor.neutral.solid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
