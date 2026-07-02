import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/assistant_controls_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/assistant_conversation_surface.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/assistant_hero.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/assistant_loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/assistant_conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/assistant_state_card.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantPage extends HookConsumerWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final chatState = ref.watch(assistantControllerProvider);
    final settingsAsync = session.canAccessProtectedData
        ? ref.watch(userSettingsControllerProvider)
        : null;
    final settings = settingsAsync?.asData?.value;
    final capabilities = chatState.capabilities;
    final effectiveContext = settings == null && capabilities != null
        ? UpdateAssistantContextSettingsDto(
            healthProfile: capabilities.assistantContext.healthProfile,
            dailyRecords: capabilities.assistantContext.dailyRecords,
            sleepRecords: capabilities.assistantContext.sleepRecords,
            currentMedicines: capabilities.assistantContext.currentMedicines,
          )
        : null;

    final inputController = useTextEditingController();
    final scrollController = useMemoized(() => ScrollController());
    final drawerScaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    void scrollToBottom() {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }

    // Auto-scroll to bottom on new messages
    ref.listen<AssistantState>(assistantControllerProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    });

    String statusSummaryText(AppLocalizations l, AssistantCapabilities caps) {
      if (!caps.assistantEnabled) return l.assistantStatusDisabled;
      if (!caps.chatModelConfigured) return l.assistantStatusModelMissing;
      if (!caps.interactiveChatReady) return l.assistantStatusNotReady;
      return l.assistantStatusReady;
    }

    Future<void> toggleAssistantEnabled(
      BuildContext ctx,
      bool nextValue,
    ) async {
      try {
        await ref
            .read(userSettingsControllerProvider.notifier)
            .setAssistantEnabled(nextValue);
        await ref.read(assistantControllerProvider.notifier).loadCapabilities();
      } catch (error) {
        if (!ctx.mounted) return;
        await AppToast.show(ctx, LucentErrorMapper.fromObject(error).message);
      }
    }

    Future<void> toggleAssistantMemoryEnabled(
      BuildContext ctx,
      bool nextValue,
    ) async {
      try {
        await ref
            .read(userSettingsControllerProvider.notifier)
            .setAssistantMemoryEnabled(nextValue);
        await ref.read(assistantControllerProvider.notifier).loadCapabilities();
      } catch (error) {
        if (!ctx.mounted) return;
        await AppToast.show(ctx, LucentErrorMapper.fromObject(error).message);
      }
    }

    Future<void> toggleContextSetting(
      BuildContext ctx, {
      required UserSettingsDataDto? settings,
      required UpdateAssistantContextSettingsDto? fallbackContext,
      bool? healthProfile,
      bool? dailyRecords,
      bool? sleepRecords,
      bool? currentMedicines,
    }) async {
      final current = settings?.assistantContext;
      if (current == null) {
        if (fallbackContext == null) return;
        try {
          await ref
              .read(userSettingsControllerProvider.notifier)
              .setAssistantContext(
                UpdateAssistantContextSettingsDto(
                  healthProfile: healthProfile ?? fallbackContext.healthProfile,
                  dailyRecords: dailyRecords ?? fallbackContext.dailyRecords,
                  sleepRecords: sleepRecords ?? fallbackContext.sleepRecords,
                  currentMedicines:
                      currentMedicines ?? fallbackContext.currentMedicines,
                ),
              );
          await ref
              .read(assistantControllerProvider.notifier)
              .loadCapabilities();
        } catch (error) {
          if (!ctx.mounted) return;
          await AppToast.show(ctx, LucentErrorMapper.fromObject(error).message);
        }
        return;
      }
      try {
        await ref
            .read(userSettingsControllerProvider.notifier)
            .setAssistantContext(
              UpdateAssistantContextSettingsDto(
                healthProfile: healthProfile ?? current.healthProfile,
                dailyRecords: dailyRecords ?? current.dailyRecords,
                sleepRecords: sleepRecords ?? current.sleepRecords,
                currentMedicines: currentMedicines ?? current.currentMedicines,
              ),
            );
        await ref.read(assistantControllerProvider.notifier).loadCapabilities();
      } catch (error) {
        if (!ctx.mounted) return;
        await AppToast.show(ctx, LucentErrorMapper.fromObject(error).message);
      }
    }

    Future<void> handleSend() async {
      final input = inputController.text;
      if (input.trim().isEmpty) return;
      inputController.clear();
      await ref.read(assistantControllerProvider.notifier).sendMessage(input);
    }

    Future<void> handleStartNewConversation() async {
      inputController.clear();
      await ref.read(assistantControllerProvider.notifier).clearConversation();
    }

    Future<void> handleConfirmProposal(
      BuildContext ctx, {
      required String messageId,
      required String proposalId,
    }) async {
      final l = AppLocalizations.of(ctx)!;
      try {
        await ref
            .read(assistantControllerProvider.notifier)
            .confirmProposedAction(
              messageId: messageId,
              proposalId: proposalId,
            );
        if (!ctx.mounted) return;
        await AppToast.show(ctx, l.assistantProposalConfirmedToast);
      } catch (error) {
        if (!ctx.mounted) return;
        await AppToast.show(ctx, LucentErrorMapper.fromObject(error).message);
      }
    }

    void openRecentConversationsDrawer() {
      drawerScaffoldKey.currentState?.openEndDrawer();
    }

    return PageScaffoldShell(
      scaffoldKey: drawerScaffoldKey,
      title: l10n.assistantPageTitle,
      centerTitle: true,
      scrollable: false,
      leading: AppBackButton(onPressed: () => context.pop()),
      endDrawer: Drawer(
        child: AssistantConversationDrawer(
          state: chatState,
          title: l10n.assistantRecentConversationsTitle,
          emptyTitle: l10n.assistantRecentConversationsEmptyTitle,
          emptyDescription: l10n.assistantRecentConversationsEmptyDescription,
          onRetry: () => ref
              .read(assistantControllerProvider.notifier)
              .loadRecentConversations(),
          onSelect: (conversationId) async {
            Navigator.of(context).pop();
            await ref
                .read(assistantControllerProvider.notifier)
                .openConversation(conversationId);
          },
        ),
      ),
      actions: [
        IconButton(
          key: const Key('assistant-recent-conversations-action'),
          tooltip: l10n.assistantRecentConversationsAction,
          onPressed:
              !session.canAccessProtectedData ||
                  chatState.isLoadingRecentConversations ||
                  chatState.isOpeningConversation
              ? null
              : openRecentConversationsDrawer,
          icon: const Icon(FLucideIcons.clock4),
        ),
        IconButton(
          key: const Key('assistant-new-conversation-action'),
          tooltip: l10n.assistantNewConversationAction,
          onPressed:
              !session.canAccessProtectedData ||
                  chatState.isLoadingConversation ||
                  chatState.isSending ||
                  chatState.isOpeningConversation
              ? null
              : handleStartNewConversation,
          icon: const Icon(FLucideIcons.plus),
        ),
      ],
      children: [
        if (session.isRestoring) ...[
          const AssistantLoadingView(),
        ] else if (!session.canAccessProtectedData) ...[
          AssistantStateCard(
            title: l10n.authNotSignedIn,
            description: l10n.assistantSignedOutDescription,
            icon: FLucideIcons.circleAlert,
            actionLabel: l10n.authGoLogin,
            onAction: () => context.go(loginRouteForReturnTo('/assistant')),
          ),
        ] else if (chatState.isLoadingCapabilities &&
            chatState.isLoadingConversation &&
            capabilities == null &&
            chatState.capabilityError == null) ...[
          const AssistantLoadingView(),
        ] else if (chatState.isLoadingConversation &&
            !chatState.hasConversation) ...[
          const AssistantLoadingView(),
        ] else if (capabilities == null) ...[
          AssistantStateCard(
            title: l10n.assistantLoadErrorTitle,
            description:
                chatState.capabilityError ?? l10n.assistantLoadErrorFallback,
            icon: FLucideIcons.circleAlert,
            tone: AppStateTone.warning,
            actionLabel: l10n.todayRetryAction,
            onAction: () => ref
                .read(assistantControllerProvider.notifier)
                .loadCapabilities(),
          ),
        ] else ...[
          AssistantHero(
            capabilities: capabilities,
            statusSummary: statusSummaryText(l10n, capabilities),
          ),
          if (chatState.conversationError != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AppStateMessageView(
              title: l10n.assistantLoadErrorTitle,
              description: chatState.conversationError!,
              icon: FLucideIcons.circleAlert,
              tone: AppStateTone.warning,
              actionLabel: l10n.todayRetryAction,
              onAction: () => ref
                  .read(assistantControllerProvider.notifier)
                  .loadLatestConversation(),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.md),
          Expanded(
            child: AssistantConversationSurface(
              state: chatState,
              capabilities: capabilities,
              scrollController: scrollController,
              controller: inputController,
              onSend: handleSend,
              onRetry: chatState.lastFailedInput != null
                  ? () => ref
                        .read(assistantControllerProvider.notifier)
                        .retryLastMessage()
                  : null,
              onConfirmProposal: ({required messageId, required proposalId}) =>
                  handleConfirmProposal(
                    context,
                    messageId: messageId,
                    proposalId: proposalId,
                  ),
              onDismissProposal: ({required messageId, required proposalId}) {
                ref
                    .read(assistantControllerProvider.notifier)
                    .dismissProposedAction(
                      messageId: messageId,
                      proposalId: proposalId,
                    );
              },
            ),
          ),
          if (chatState.recentConversationError != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AppStateMessageView(
              title: l10n.assistantRecentConversationsTitle,
              description: chatState.recentConversationError!,
              icon: FLucideIcons.circleAlert,
              tone: AppStateTone.warning,
              actionLabel: l10n.todayRetryAction,
              onAction: () => ref
                  .read(assistantControllerProvider.notifier)
                  .loadRecentConversations(),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.md),
          AssistantControlsPanel(
            settings: settings,
            fallbackContext: effectiveContext,
            capabilities: capabilities,
            onToggleEnabled: (nextValue) =>
                toggleAssistantEnabled(context, nextValue),
            onToggleMemoryEnabled: (nextValue) =>
                toggleAssistantMemoryEnabled(context, nextValue),
            onToggleContext:
                ({
                  bool? healthProfile,
                  bool? dailyRecords,
                  bool? sleepRecords,
                  bool? currentMedicines,
                }) => toggleContextSetting(
                  context,
                  settings: settings,
                  fallbackContext: effectiveContext,
                  healthProfile: healthProfile,
                  dailyRecords: dailyRecords,
                  sleepRecords: sleepRecords,
                  currentMedicines: currentMedicines,
                ),
          ),
        ],
      ],
    );
  }
}
