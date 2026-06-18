import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
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
        title: l10n.assistantPageTitle,
        centerTitle: true,
        leading: SettingsBackButton(onTap: () => context.pop()),
        actions: [
          IconButton(
            key: const Key('assistant-recent-conversations-action'),
            tooltip: l10n.assistantRecentConversationsAction,
            onPressed:
                !session.canAccessProtectedData ||
                    chatState.isLoadingRecentConversations ||
                    chatState.isOpeningConversation
                ? null
                : () => _showRecentConversationsSheet(context),
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
            const _AssistantLoadingView(),
          ] else if (!session.canAccessProtectedData) ...[
            _AssistantStateCard(
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
            const _AssistantLoadingView(),
          ] else if (chatState.isLoadingConversation &&
              !chatState.hasConversation) ...[
            const _AssistantLoadingView(),
          ] else if (capabilities == null) ...[
            _AssistantStateCard(
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
            _AssistantHero(
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
            SizedBox(
              height: width < AppBreakpoints.mobile ? 460 : 520,
              child: _ConversationSurface(
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
            _AssistantControlsPanel(
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

  Future<void> _showRecentConversationsSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Consumer(
              builder: (context, ref, _) {
                final latestState = ref.watch(assistantControllerProvider);
                return _RecentConversationSheet(
                  state: latestState,
                  title: l10n.assistantRecentConversationsTitle,
                  emptyTitle: l10n.assistantRecentConversationsEmptyTitle,
                  emptyDescription:
                      l10n.assistantRecentConversationsEmptyDescription,
                  onRetry: () => ref
                      .read(assistantControllerProvider.notifier)
                      .loadRecentConversations(),
                  onSelect: (conversationId) async {
                    Navigator.of(sheetContext).pop();
                    await ref
                        .read(assistantControllerProvider.notifier)
                        .openConversation(conversationId);
                  },
                );
              },
            ),
          ),
        );
      },
    );
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

class _AssistantLoadingView extends StatelessWidget {
  const _AssistantLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 28, widthFactor: 0.3),
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.52),
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.74),
          ],
        ),
        SizedBox(height: AppSpacingTokens.md),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 240),
            AppInlineSkeletonBlock(height: 56),
          ],
        ),
        SizedBox(height: AppSpacingTokens.md),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 56),
            AppInlineSkeletonBlock(height: 56),
            AppInlineSkeletonBlock(height: 56),
          ],
        ),
      ],
    );
  }
}

class _AssistantStateCard extends StatelessWidget {
  const _AssistantStateCard({
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.tone = AppStateTone.neutral,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppStateTone tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: AppStateMessageView(
          title: title,
          description: description,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          tone: tone,
        ),
      ),
    );
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero({
    required this.capabilities,
    required this.statusSummary,
  });

  final AssistantCapabilities capabilities;
  final String statusSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            surface.canvas,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.assistantPageTitle, style: _typography(context).displayMd),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              statusSummary,
              style: _typography(context).bodyMd.copyWith(color: surface.body),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Wrap(
              spacing: AppSpacingTokens.sm,
              runSpacing: AppSpacingTokens.sm,
              children: [
                _StatusChip(
                  label:
                      '${l10n.assistantStatusToolsLabel} ${capabilities.enabledToolCount}/${capabilities.tools.length}',
                  enabled: capabilities.enabledToolCount > 0,
                ),
                _StatusChip(
                  label:
                      '${l10n.assistantStatusContextLabel} ${capabilities.assistantContext.enabledCount}/4',
                  enabled: capabilities.assistantContext.enabledCount > 0,
                ),
                _StatusChip(
                  label: l10n.assistantStatusStreamingLabel,
                  enabled: capabilities.streamingSupported,
                ),
                _StatusChip(
                  label: l10n.assistantStatusRagLabel,
                  enabled: capabilities.ragEnabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationSurface extends StatelessWidget {
  const _ConversationSurface({
    required this.state,
    required this.capabilities,
    required this.scrollController,
    required this.controller,
    required this.onSend,
    this.onRetry,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final AssistantState state;
  final AssistantCapabilities capabilities;
  final ScrollController scrollController;
  final TextEditingController controller;
  final Future<void> Function() onSend;
  final VoidCallback? onRetry;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return SettingsSectionSurface(
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isOpeningConversation) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
              child: Text(
                l10n.assistantOpeningConversationLabel,
                style: _typography(
                  context,
                ).bodySm.copyWith(color: surface.mute),
              ),
            ),
          ],
          Expanded(
            child: _ConversationView(
              state: state,
              capabilities: capabilities,
              scrollController: scrollController,
              onConfirmProposal: onConfirmProposal,
              onDismissProposal: onDismissProposal,
            ),
          ),
          if (state.sendError != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AppStateMessageView(
              title: l10n.assistantSendErrorTitle,
              description: _sendErrorDescription(
                l10n,
                state.sendErrorType,
                state.sendError!,
              ),
              icon: _sendErrorIcon(state.sendErrorType),
              tone: AppStateTone.warning,
              actionLabel: onRetry != null ? l10n.assistantRetryAction : null,
              onAction: onRetry,
              actionKey: const Key('assistant-retry-action'),
              padding: const EdgeInsets.all(AppSpacingTokens.md),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.md),
          _InputComposer(
            controller: controller,
            canSend: capabilities.canSendMessages && !state.isSending,
            isSending: state.isSending,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}

class _AssistantControlsPanel extends StatelessWidget {
  const _AssistantControlsPanel({
    required this.surface,
    required this.typography,
    required this.settings,
    required this.fallbackContext,
    required this.capabilities,
    required this.onToggleEnabled,
    required this.onToggleMemoryEnabled,
    required this.onToggleContext,
  });

  final AppThemeSurface surface;
  final AppTypographyScale typography;
  final UserSettingsDataDto? settings;
  final UpdateAssistantContextSettingsDto? fallbackContext;
  final AssistantCapabilities capabilities;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<bool> onToggleMemoryEnabled;
  final Future<void> Function({
    bool? healthProfile,
    bool? dailyRecords,
    bool? sleepRecords,
    bool? currentMedicines,
  })
  onToggleContext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSectionSurface(
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.assistantStatusSectionTitle, style: typography.bodyMdStrong),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.assistantEntrySubtitle,
            style: typography.bodySm.copyWith(color: surface.body),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          SettingsListRow(
            key: const Key('assistant-row-enabled'),
            title: l10n.assistantSettingsEnableTitle,
            subtitle: l10n.assistantSettingsEnableSubtitle,
            icon: Icons.auto_awesome_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value: settings?.assistantEnabled ?? capabilities.assistantEnabled,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleEnabled(
              !(settings?.assistantEnabled ?? capabilities.assistantEnabled),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('assistant-row-memory-enabled'),
            title: l10n.assistantSettingsMemoryTitle,
            subtitle: l10n.assistantSettingsMemorySubtitle,
            icon: Icons.psychology_alt_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantMemoryEnabled ??
                    capabilities.assistantMemoryEnabled,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleMemoryEnabled(
              !(settings?.assistantMemoryEnabled ??
                  capabilities.assistantMemoryEnabled),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('assistant-row-context-health-profile'),
            title: l10n.assistantContextHealthProfile,
            icon: Icons.badge_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.healthProfile ??
                    capabilities.assistantContext.healthProfile,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              healthProfile:
                  !(settings?.assistantContext.healthProfile ??
                      capabilities.assistantContext.healthProfile),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('assistant-row-context-daily-records'),
            title: l10n.assistantContextDailyRecords,
            icon: Icons.event_note_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.dailyRecords ??
                    capabilities.assistantContext.dailyRecords,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              dailyRecords:
                  !(settings?.assistantContext.dailyRecords ??
                      capabilities.assistantContext.dailyRecords),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('assistant-row-context-sleep-records'),
            title: l10n.assistantContextSleepRecords,
            icon: Icons.bedtime_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.sleepRecords ??
                    capabilities.assistantContext.sleepRecords,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              sleepRecords:
                  !(settings?.assistantContext.sleepRecords ??
                      capabilities.assistantContext.sleepRecords),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('assistant-row-context-current-medicines'),
            title: l10n.assistantContextCurrentMedicines,
            icon: Icons.medication_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.currentMedicines ??
                    capabilities.assistantContext.currentMedicines,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              currentMedicines:
                  !(settings?.assistantContext.currentMedicines ??
                      capabilities.assistantContext.currentMedicines),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView({
    required this.state,
    required this.capabilities,
    required this.scrollController,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final AssistantState state;
  final AssistantCapabilities capabilities;
  final ScrollController scrollController;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!capabilities.canSendMessages &&
        state.messages.isEmpty &&
        state.streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.assistantConversationDisabledTitle,
        description: _disabledDescription(l10n, capabilities),
        icon: Icons.pause_circle_outline_rounded,
        tone: AppStateTone.warning,
      );
    }

    if (state.messages.isEmpty && state.streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.assistantConversationEmptyTitle,
        description: l10n.assistantConversationEmptyDescription,
        icon: Icons.chat_bubble_outline_rounded,
      );
    }

    final items = <_ConversationItem>[
      ...state.messages.map(_ConversationItem.message),
      if (state.streamingDraft.isNotEmpty)
        _ConversationItem.streaming(state.streamingDraft),
    ];

    return ListView.separated(
      key: const Key('assistant-message-list'),
      controller: scrollController,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.streamingDraft != null) {
          return _MessageBubble(
            messageId: 'streaming-draft',
            role: AssistantMessageRole.assistant,
            content: item.streamingDraft!,
            isStreaming: true,
            usedTools: const <String>[],
          );
        }

        final message = item.message!;
        return _MessageBubble(
          messageId: _messageIdFor(message),
          role: message.role,
          content: message.content,
          usedTools: message.usedTools,
          proposedActions: message.proposedActions,
          onConfirmProposal: onConfirmProposal,
          onDismissProposal: onDismissProposal,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacingTokens.md),
      itemCount: items.length,
    );
  }

  String _disabledDescription(
    AppLocalizations l10n,
    AssistantCapabilities capabilities,
  ) {
    if (!capabilities.assistantEnabled) {
      return l10n.assistantConversationDisabledByUserHint;
    }
    if (!capabilities.chatModelConfigured) {
      return l10n.assistantConversationModelMissing;
    }
    return l10n.assistantConversationNotReady;
  }
}

class _ConversationItem {
  const _ConversationItem._({this.message, this.streamingDraft});

  const _ConversationItem.message(AssistantMessage message)
    : this._(message: message);

  const _ConversationItem.streaming(String draft)
    : this._(streamingDraft: draft);

  final AssistantMessage? message;
  final String? streamingDraft;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.messageId,
    required this.role,
    required this.content,
    required this.usedTools,
    this.proposedActions = const <AssistantProposedAction>[],
    this.isStreaming = false,
    this.onConfirmProposal,
    this.onDismissProposal,
  });

  final String messageId;
  final AssistantMessageRole role;
  final String content;
  final List<String> usedTools;
  final List<AssistantProposedAction> proposedActions;
  final bool isStreaming;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })?
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})?
  onDismissProposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final isUser = role == AssistantMessageRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? theme.colorScheme.primary.withValues(alpha: 0.14)
        : surface.canvasSoft2;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUser)
                  Text(content, style: _typography(context).bodyMd)
                else
                  MarkdownBody(
                    data: content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: _typography(context).bodyMd,
                      blockquote: _typography(
                        context,
                      ).bodySm.copyWith(color: surface.body),
                    ),
                  ),
                if (isStreaming) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    AppLocalizations.of(context)!.assistantStreamingLabel,
                    style: _typography(
                      context,
                    ).bodySm.copyWith(color: surface.mute),
                  ),
                ],
                if (!isStreaming && usedTools.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Wrap(
                    spacing: AppSpacingTokens.xs,
                    runSpacing: AppSpacingTokens.xs,
                    children: [
                      for (final tool in usedTools)
                        _ToolChip(label: _localizeToolName(tool, context)),
                    ],
                  ),
                ],
                if (!isStreaming &&
                    !isUser &&
                    proposedActions.any((proposal) => proposal.isVisible)) ...[
                  const SizedBox(height: AppSpacingTokens.md),
                  for (final proposal in proposedActions.where(
                    (proposal) => proposal.isVisible,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.sm,
                      ),
                      child: _ProposalCard(
                        messageId: messageId,
                        proposal: proposal,
                        onConfirmProposal: onConfirmProposal,
                        onDismissProposal: onDismissProposal,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.messageId,
    required this.proposal,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final String messageId;
  final AssistantProposedAction proposal;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })?
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})?
  onDismissProposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _proposalIcon(proposal.type),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacingTokens.xs),
                Expanded(
                  child: Text(
                    proposal.title,
                    style: _typography(context).bodyMdStrong,
                  ),
                ),
                Text(
                  _proposalStateText(l10n, proposal),
                  style: _typography(context).bodySm.copyWith(
                    color: _proposalStateColor(theme, proposal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(proposal.summary, style: _typography(context).bodySm),
            if (proposal.reason case final reason?) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                reason,
                style: _typography(
                  context,
                ).bodySm.copyWith(color: surface.body),
              ),
            ],
            if (proposal.previewFields.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Wrap(
                spacing: AppSpacingTokens.xs,
                runSpacing: AppSpacingTokens.xs,
                children: [
                  for (final field in proposal.previewFields)
                    _ToolChip(label: '${field.label}: ${field.value}'),
                ],
              ),
            ],
            if (proposal.executionError case final error?) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                error,
                style: _typography(
                  context,
                ).bodySm.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              children: [
                FilledButton(
                  key: Key('assistant-proposal-confirm-${proposal.id}'),
                  onPressed:
                      proposal.executionState ==
                              AssistantProposalExecutionState.executing ||
                          onConfirmProposal == null
                      ? null
                      : () => onConfirmProposal!(
                          messageId: messageId,
                          proposalId: proposal.id,
                        ),
                  child: Text(_proposalConfirmLabel(l10n, proposal.type)),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                TextButton(
                  key: Key('assistant-proposal-dismiss-${proposal.id}'),
                  onPressed:
                      proposal.executionState ==
                          AssistantProposalExecutionState.executing
                      ? null
                      : () => onDismissProposal?.call(
                          messageId: messageId,
                          proposalId: proposal.id,
                        ),
                  child: Text(l10n.assistantProposalDismissAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputComposer extends StatelessWidget {
  const _InputComposer({
    required this.controller,
    required this.canSend,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final bool isSending;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            key: const Key('assistant-input'),
            controller: controller,
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l10n.assistantInputHint,
              filled: true,
              fillColor: surface.canvasSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        FilledButton(
          key: const Key('assistant-send-action'),
          onPressed: canSend ? onSend : null,
          child: Text(
            isSending ? l10n.assistantSendingAction : l10n.assistantSendAction,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(label, style: _typography(context).bodySm),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: 2,
        ),
        child: Text(
          label,
          style: _typography(context).bodySm.copyWith(color: surface.body),
        ),
      ),
    );
  }
}

class _RecentConversationSheet extends StatelessWidget {
  const _RecentConversationSheet({
    required this.state,
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onRetry,
    required this.onSelect,
  });

  final AssistantState state;
  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final items = state.recentConversations;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _typography(context).displaySm),
          const SizedBox(height: AppSpacingTokens.md),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoadingRecentConversations && items.isEmpty) {
                  return const AppStateSkeletonView(
                    blocks: <AppStateSkeletonBlock>[
                      AppStateSkeletonBlock(height: 72),
                      AppStateSkeletonBlock(height: 72),
                      AppStateSkeletonBlock(height: 72),
                    ],
                  );
                }
                if (state.recentConversationError != null && items.isEmpty) {
                  return AppStateMessageView(
                    title: title,
                    description: state.recentConversationError!,
                    icon: Icons.history_toggle_off_rounded,
                    tone: AppStateTone.warning,
                    actionLabel: AppLocalizations.of(context)!.todayRetryAction,
                    onAction: onRetry,
                  );
                }
                if (items.isEmpty) {
                  return AppStateMessageView(
                    title: emptyTitle,
                    description: emptyDescription,
                    icon: Icons.chat_bubble_outline_rounded,
                  );
                }

                return ListView.separated(
                  key: const Key('assistant-recent-conversation-list'),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item.id == state.conversationId;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: Key('assistant-recent-conversation-${item.id}'),
                        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                        onTap: state.isOpeningConversation
                            ? null
                            : () => onSelect(item.id),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  )
                                : surface.canvas,
                            borderRadius: BorderRadius.circular(
                              AppRadiusTokens.lg,
                            ),
                            border: Border.all(color: surface.hairline),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacingTokens.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _conversationTitle(context, item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _typography(context).bodyMdStrong,
                                ),
                                const SizedBox(height: AppSpacingTokens.xs),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _conversationTimestampLabel(
                                          context,
                                          item,
                                        ),
                                        style: _typography(
                                          context,
                                        ).bodySm.copyWith(color: surface.body),
                                      ),
                                    ),
                                    if (selected)
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.assistantRecentConversationCurrentLabel,
                                        style: _typography(context).bodySm
                                            .copyWith(
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacingTokens.sm),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _localizeToolName(String toolId, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return switch (toolId) {
    'get_today_records' => l10n.assistantToolTodayRecords,
    'get_records_by_date' => l10n.assistantToolRecordsByDate,
    'get_records_by_range' => l10n.assistantToolRecordsByRange,
    'get_today_summary_by_date' => l10n.assistantToolTodaySummaryByDate,
    'get_report_summary_by_range' => l10n.assistantToolReportSummaryByRange,
    'get_recent_today_summaries' => l10n.assistantToolRecentTodaySummaries,
    'get_recent_report_summaries' => l10n.assistantToolRecentReportSummaries,
    'get_user_profile' => l10n.assistantToolUserProfile,
    'get_user_settings' => l10n.assistantToolUserSettings,
    'get_current_medicines' => l10n.assistantToolCurrentMedicines,
    'get_sleep_summary_by_range' => l10n.assistantToolSleepByRange,
    'propose_create_daily_record' => l10n.assistantToolProposeCreateRecord,
    'propose_update_daily_record' => l10n.assistantToolProposeUpdateRecord,
    'propose_delete_daily_record' => l10n.assistantToolProposeDeleteRecord,
    'propose_update_user_settings' => l10n.assistantToolProposeUpdateSettings,
    _ => toolId,
  };
}

String _messageIdFor(AssistantMessage message) {
  return '${message.role.name}-${message.createdAt.toIso8601String()}-${message.content.hashCode}';
}

IconData _proposalIcon(AssistantProposedActionType type) {
  return switch (type) {
    AssistantProposedActionType.createDailyRecord => Icons.add_task_rounded,
    AssistantProposedActionType.updateDailyRecord => Icons.edit_note_rounded,
    AssistantProposedActionType.deleteDailyRecord => Icons.delete_outline_rounded,
    AssistantProposedActionType.updateUserSettings => Icons.tune_rounded,
  };
}

String _proposalConfirmLabel(
  AppLocalizations l10n,
  AssistantProposedActionType type,
) {
  return switch (type) {
    AssistantProposedActionType.createDailyRecord =>
      l10n.assistantProposalConfirmCreateAction,
    AssistantProposedActionType.updateDailyRecord =>
      l10n.assistantProposalConfirmUpdateAction,
    AssistantProposedActionType.deleteDailyRecord =>
      l10n.assistantProposalConfirmDeleteAction,
    AssistantProposedActionType.updateUserSettings =>
      l10n.assistantProposalConfirmSettingsAction,
  };
}

String _proposalStateText(
  AppLocalizations l10n,
  AssistantProposedAction proposal,
) {
  return switch (proposal.executionState) {
    AssistantProposalExecutionState.pending => l10n.assistantProposalPendingState,
    AssistantProposalExecutionState.executing => l10n.assistantProposalExecutingState,
    AssistantProposalExecutionState.confirmed => l10n.assistantProposalConfirmedState,
    AssistantProposalExecutionState.dismissed => l10n.assistantProposalDismissedState,
    AssistantProposalExecutionState.failed => l10n.assistantProposalFailedState,
  };
}

Color _proposalStateColor(ThemeData theme, AssistantProposedAction proposal) {
  return switch (proposal.executionState) {
    AssistantProposalExecutionState.pending => theme.colorScheme.primary,
    AssistantProposalExecutionState.executing => theme.colorScheme.primary,
    AssistantProposalExecutionState.confirmed => const Color(0xFF159B55),
    AssistantProposalExecutionState.dismissed => theme.colorScheme.outline,
    AssistantProposalExecutionState.failed => theme.colorScheme.error,
  };
}

String _sendErrorDescription(
  AppLocalizations l10n,
  AssistantSendErrorType? errorType,
  String fallback,
) {
  return switch (errorType) {
    AssistantSendErrorType.streamInterrupted => l10n.assistantErrorStreamInterrupted,
    AssistantSendErrorType.emptyResult => l10n.assistantErrorEmptyResult,
    AssistantSendErrorType.server => l10n.assistantErrorServer,
    AssistantSendErrorType.unknown || null => fallback,
  };
}

IconData _sendErrorIcon(AssistantSendErrorType? errorType) {
  return switch (errorType) {
    AssistantSendErrorType.streamInterrupted => Icons.wifi_off_rounded,
    AssistantSendErrorType.emptyResult => Icons.hourglass_empty_rounded,
    AssistantSendErrorType.server => Icons.cloud_off_rounded,
    AssistantSendErrorType.unknown || null => Icons.error_outline_rounded,
  };
}

AppTypographyScale _typography(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.sizeOf(context).width;
  return width < AppBreakpoints.mobile
      ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
      : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
}

String _conversationTitle(
  BuildContext context,
  AssistantConversationSummary summary,
) {
  final title = summary.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return AppLocalizations.of(context)!.assistantUntitledConversation;
}

String _conversationTimestampLabel(
  BuildContext context,
  AssistantConversationSummary summary,
) {
  final locale = Localizations.localeOf(context).toString();
  final value = summary.lastMessageAt ?? summary.updatedAt;
  final local = value.toLocal();
  final pattern = locale.startsWith('zh') ? 'M月d日 HH:mm' : 'MMM d, HH:mm';
  return intl.DateFormat(pattern, locale).format(local);
}
