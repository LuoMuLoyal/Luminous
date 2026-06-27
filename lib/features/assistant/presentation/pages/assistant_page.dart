import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_controls_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_conversation_surface.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_hero.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_state_card.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _drawerScaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    ref.listenManual<AssistantState>(assistantControllerProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
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

    return Material(
      color: surface.canvasSoft,
      child: PageScaffoldShell(
        scaffoldKey: _drawerScaffoldKey,
        title: l10n.assistantPageTitle,
        centerTitle: true,
        scrollable: false,
        leading: SettingsBackButton(onTap: () => context.pop()),
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
                : _openRecentConversationsDrawer,
            icon: const Icon(Icons.history_rounded),
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
                : _handleStartNewConversation,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
        children: [
          if (session.isRestoring) ...[
            const AssistantLoadingView(),
          ] else if (!session.canAccessProtectedData) ...[
            AssistantStateCard(
              title: l10n.authNotSignedIn,
              description: l10n.assistantSignedOutDescription,
              icon: Icons.lock_outline_rounded,
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
              icon: Icons.cloud_off_rounded,
              tone: AppStateTone.warning,
              actionLabel: l10n.todayRetryAction,
              onAction: () => ref
                  .read(assistantControllerProvider.notifier)
                  .loadCapabilities(),
            ),
          ] else ...[
            AssistantHero(
              capabilities: capabilities,
              statusSummary: _statusSummaryText(l10n, capabilities),
            ),
            if (chatState.conversationError != null) ...[
              const SizedBox(height: AppSpacingTokens.md),
              AppStateMessageView(
                title: l10n.assistantLoadErrorTitle,
                description: chatState.conversationError!,
                icon: Icons.history_toggle_off_rounded,
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
                scrollController: _scrollController,
                controller: _inputController,
                onSend: _handleSend,
                onRetry: chatState.lastFailedInput != null
                    ? () => ref
                          .read(assistantControllerProvider.notifier)
                          .retryLastMessage()
                    : null,
                onConfirmProposal:
                    ({required messageId, required proposalId}) =>
                        _handleConfirmProposal(
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
                icon: Icons.history_toggle_off_rounded,
                tone: AppStateTone.warning,
                actionLabel: l10n.todayRetryAction,
                onAction: () => ref
                    .read(assistantControllerProvider.notifier)
                    .loadRecentConversations(),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.md),
            AssistantControlsPanel(
              surface: surface,
              typography: typography,
              settings: settings,
              fallbackContext: effectiveContext,
              capabilities: capabilities,
              onToggleEnabled: (nextValue) =>
                  _toggleAssistantEnabled(context, nextValue),
              onToggleMemoryEnabled: (nextValue) =>
                  _toggleAssistantMemoryEnabled(context, nextValue),
              onToggleContext:
                  ({
                    bool? healthProfile,
                    bool? dailyRecords,
                    bool? sleepRecords,
                    bool? currentMedicines,
                  }) => _toggleContextSetting(
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
      ),
    );
  }

  Future<void> _toggleAssistantEnabled(
    BuildContext context,
    bool nextValue,
  ) async {
    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .setAssistantEnabled(nextValue);
      await ref.read(assistantControllerProvider.notifier).loadCapabilities();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await AppToast.show(context, LucentErrorMapper.fromObject(error).message);
    }
  }

  Future<void> _toggleContextSetting(
    BuildContext context, {
    required UserSettingsDataDto? settings,
    required UpdateAssistantContextSettingsDto? fallbackContext,
    bool? healthProfile,
    bool? dailyRecords,
    bool? sleepRecords,
    bool? currentMedicines,
  }) async {
    final current = settings?.assistantContext;
    if (current == null) {
      if (fallbackContext == null) {
        return;
      }

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
        await ref.read(assistantControllerProvider.notifier).loadCapabilities();
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        await AppToast.show(
          context,
          LucentErrorMapper.fromObject(error).message,
        );
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
      if (!context.mounted) {
        return;
      }
      await AppToast.show(context, LucentErrorMapper.fromObject(error).message);
    }
  }

  Future<void> _toggleAssistantMemoryEnabled(
    BuildContext context,
    bool nextValue,
  ) async {
    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .setAssistantMemoryEnabled(nextValue);
      await ref.read(assistantControllerProvider.notifier).loadCapabilities();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await AppToast.show(context, LucentErrorMapper.fromObject(error).message);
    }
  }

  Future<void> _handleSend() async {
    final input = _inputController.text;
    if (input.trim().isEmpty) {
      return;
    }
    _inputController.clear();
    await ref.read(assistantControllerProvider.notifier).sendMessage(input);
  }

  Future<void> _handleStartNewConversation() async {
    _inputController.clear();
    await ref.read(assistantControllerProvider.notifier).clearConversation();
  }

  Future<void> _handleConfirmProposal(
    BuildContext context, {
    required String messageId,
    required String proposalId,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .confirmProposedAction(messageId: messageId, proposalId: proposalId);
      if (!context.mounted) {
        return;
      }
      await AppToast.show(context, l10n.assistantProposalConfirmedToast);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await AppToast.show(context, LucentErrorMapper.fromObject(error).message);
    }
  }

  void _openRecentConversationsDrawer() {
    _drawerScaffoldKey.currentState?.openEndDrawer();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  String _statusSummaryText(
    AppLocalizations l10n,
    AssistantCapabilities capabilities,
  ) {
    if (!capabilities.assistantEnabled) {
      return l10n.assistantStatusDisabled;
    }
    if (!capabilities.chatModelConfigured) {
      return l10n.assistantStatusModelMissing;
    }
    if (!capabilities.interactiveChatReady) {
      return l10n.assistantStatusNotReady;
    }
    return l10n.assistantStatusReady;
  }
}
