import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';
import 'package:luminous/features/ai_chat/presentation/providers/ai_chat_controller.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.listenManual<AiChatState>(aiChatControllerProvider, (_, __) {
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
    final chatState = ref.watch(aiChatControllerProvider);
    final settingsAsync = session.canAccessProtectedData
        ? ref.watch(userSettingsControllerProvider)
        : null;
    final settings = settingsAsync?.asData?.value;
    final capabilities = chatState.capabilities;
    final effectiveContext = settings == null && capabilities != null
        ? UpdateAiChatContextSettingsDto(
            healthProfile: capabilities.aiChatContext.healthProfile,
            dailyRecords: capabilities.aiChatContext.dailyRecords,
            sleepRecords: capabilities.aiChatContext.sleepRecords,
            currentMedicines: capabilities.aiChatContext.currentMedicines,
          )
        : null;

    return Material(
      color: surface.canvasSoft,
      child: PageScaffoldShell(
        title: l10n.aiChatPageTitle,
        centerTitle: true,
        leading: SettingsBackButton(onTap: () => context.pop()),
        actions: [
          IconButton(
            key: const Key('ai-chat-new-conversation-action'),
            tooltip: l10n.aiChatNewConversationAction,
            onPressed: chatState.isLoadingConversation || chatState.isSending
                ? null
                : _handleStartNewConversation,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
        children: [
          if (session.isRestoring) ...[
            const _AiChatLoadingView(),
          ] else if (!session.canAccessProtectedData) ...[
            _AssistantStateCard(
              title: l10n.authNotSignedIn,
              description: l10n.aiChatSignedOutDescription,
              icon: Icons.lock_outline_rounded,
              actionLabel: l10n.authGoLogin,
              onAction: () => context.go(loginRouteForReturnTo('/assistant')),
            ),
          ] else if (chatState.isLoadingCapabilities &&
              chatState.isLoadingConversation &&
              capabilities == null &&
              chatState.capabilityError == null) ...[
            const _AiChatLoadingView(),
          ] else if (chatState.isLoadingConversation &&
              !chatState.hasConversation) ...[
            const _AiChatLoadingView(),
          ] else if (capabilities == null) ...[
            _AssistantStateCard(
              title: l10n.aiChatLoadErrorTitle,
              description:
                  chatState.capabilityError ?? l10n.aiChatLoadErrorFallback,
              icon: Icons.cloud_off_rounded,
              tone: AppStateTone.warning,
              actionLabel: l10n.todayRetryAction,
              onAction: () => ref
                  .read(aiChatControllerProvider.notifier)
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
                title: l10n.aiChatLoadErrorTitle,
                description: chatState.conversationError!,
                icon: Icons.history_toggle_off_rounded,
                tone: AppStateTone.warning,
                actionLabel: l10n.todayRetryAction,
                onAction: () => ref
                    .read(aiChatControllerProvider.notifier)
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
                          .read(aiChatControllerProvider.notifier)
                          .retryLastMessage()
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            _AssistantControlsPanel(
              surface: surface,
              typography: typography,
              settings: settings,
              fallbackContext: effectiveContext,
              capabilities: capabilities,
              onToggleEnabled: (nextValue) =>
                  _toggleAiChatEnabled(context, nextValue),
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

  Future<void> _toggleAiChatEnabled(
    BuildContext context,
    bool nextValue,
  ) async {
    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .setAiChatEnabled(nextValue);
      await ref.read(aiChatControllerProvider.notifier).loadCapabilities();
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
    required UpdateAiChatContextSettingsDto? fallbackContext,
    bool? healthProfile,
    bool? dailyRecords,
    bool? sleepRecords,
    bool? currentMedicines,
  }) async {
    final current = settings?.aiChatContext;
    if (current == null) {
      if (fallbackContext == null) {
        return;
      }

      try {
        await ref
            .read(userSettingsControllerProvider.notifier)
            .setAiChatContext(
              UpdateAiChatContextSettingsDto(
                healthProfile: healthProfile ?? fallbackContext.healthProfile,
                dailyRecords: dailyRecords ?? fallbackContext.dailyRecords,
                sleepRecords: sleepRecords ?? fallbackContext.sleepRecords,
                currentMedicines:
                    currentMedicines ?? fallbackContext.currentMedicines,
              ),
            );
        await ref.read(aiChatControllerProvider.notifier).loadCapabilities();
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
          .setAiChatContext(
            UpdateAiChatContextSettingsDto(
              healthProfile: healthProfile ?? current.healthProfile,
              dailyRecords: dailyRecords ?? current.dailyRecords,
              sleepRecords: sleepRecords ?? current.sleepRecords,
              currentMedicines: currentMedicines ?? current.currentMedicines,
            ),
          );
      await ref.read(aiChatControllerProvider.notifier).loadCapabilities();
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
    await ref.read(aiChatControllerProvider.notifier).sendMessage(input);
  }

  Future<void> _handleStartNewConversation() async {
    _inputController.clear();
    await ref.read(aiChatControllerProvider.notifier).clearConversation();
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
    AiChatCapabilities capabilities,
  ) {
    if (!capabilities.aiChatEnabled) {
      return l10n.aiChatStatusDisabled;
    }
    if (!capabilities.chatModelConfigured) {
      return l10n.aiChatStatusModelMissing;
    }
    if (!capabilities.interactiveChatReady) {
      return l10n.aiChatStatusNotReady;
    }
    return l10n.aiChatStatusReady;
  }
}

class _AiChatLoadingView extends StatelessWidget {
  const _AiChatLoadingView();

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

  final AiChatCapabilities capabilities;
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
            Text(l10n.aiChatPageTitle, style: _typography(context).displayMd),
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
                      '${l10n.aiChatStatusToolsLabel} ${capabilities.enabledToolCount}/${capabilities.tools.length}',
                  enabled: capabilities.enabledToolCount > 0,
                ),
                _StatusChip(
                  label:
                      '${l10n.aiChatStatusContextLabel} ${capabilities.aiChatContext.enabledCount}/4',
                  enabled: capabilities.aiChatContext.enabledCount > 0,
                ),
                _StatusChip(
                  label: l10n.aiChatStatusStreamingLabel,
                  enabled: capabilities.streamingSupported,
                ),
                _StatusChip(
                  label: l10n.aiChatStatusRagLabel,
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
  });

  final AiChatState state;
  final AiChatCapabilities capabilities;
  final ScrollController scrollController;
  final TextEditingController controller;
  final Future<void> Function() onSend;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return SettingsSectionSurface(
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ConversationView(
              state: state,
              capabilities: capabilities,
              scrollController: scrollController,
            ),
          ),
          if (state.sendError != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AppStateMessageView(
              title: l10n.aiChatSendErrorTitle,
              description: _sendErrorDescription(
                l10n,
                state.sendErrorType,
                state.sendError!,
              ),
              icon: _sendErrorIcon(state.sendErrorType),
              tone: AppStateTone.warning,
              actionLabel: onRetry != null ? l10n.aiChatRetryAction : null,
              onAction: onRetry,
              actionKey: const Key('ai-chat-retry-action'),
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
    required this.onToggleContext,
  });

  final AppThemeSurface surface;
  final AppTypographyScale typography;
  final UserSettingsDataDto? settings;
  final UpdateAiChatContextSettingsDto? fallbackContext;
  final AiChatCapabilities capabilities;
  final ValueChanged<bool> onToggleEnabled;
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
          Text(l10n.aiChatStatusSectionTitle, style: typography.bodyMdStrong),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.aiChatEntrySubtitle,
            style: typography.bodySm.copyWith(color: surface.body),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          SettingsListRow(
            key: const Key('ai-chat-row-enabled'),
            title: l10n.aiChatSettingsEnableTitle,
            subtitle: l10n.aiChatSettingsEnableSubtitle,
            icon: Icons.auto_awesome_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value: settings?.aiChatEnabled ?? capabilities.aiChatEnabled,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleEnabled(
              !(settings?.aiChatEnabled ?? capabilities.aiChatEnabled),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('ai-chat-row-context-health-profile'),
            title: l10n.aiChatContextHealthProfile,
            icon: Icons.badge_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.aiChatContext.healthProfile ??
                    capabilities.aiChatContext.healthProfile,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              healthProfile:
                  !(settings?.aiChatContext.healthProfile ??
                      capabilities.aiChatContext.healthProfile),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('ai-chat-row-context-daily-records'),
            title: l10n.aiChatContextDailyRecords,
            icon: Icons.event_note_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.aiChatContext.dailyRecords ??
                    capabilities.aiChatContext.dailyRecords,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              dailyRecords:
                  !(settings?.aiChatContext.dailyRecords ??
                      capabilities.aiChatContext.dailyRecords),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('ai-chat-row-context-sleep-records'),
            title: l10n.aiChatContextSleepRecords,
            icon: Icons.bedtime_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.aiChatContext.sleepRecords ??
                    capabilities.aiChatContext.sleepRecords,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              sleepRecords:
                  !(settings?.aiChatContext.sleepRecords ??
                      capabilities.aiChatContext.sleepRecords),
            ),
            showDivider: true,
          ),
          SettingsListRow(
            key: const Key('ai-chat-row-context-current-medicines'),
            title: l10n.aiChatContextCurrentMedicines,
            icon: Icons.medication_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.aiChatContext.currentMedicines ??
                    capabilities.aiChatContext.currentMedicines,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              currentMedicines:
                  !(settings?.aiChatContext.currentMedicines ??
                      capabilities.aiChatContext.currentMedicines),
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
  });

  final AiChatState state;
  final AiChatCapabilities capabilities;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!capabilities.canSendMessages &&
        state.messages.isEmpty &&
        state.streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.aiChatConversationDisabledTitle,
        description: _disabledDescription(l10n, capabilities),
        icon: Icons.pause_circle_outline_rounded,
        tone: AppStateTone.warning,
      );
    }

    if (state.messages.isEmpty && state.streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.aiChatConversationEmptyTitle,
        description: l10n.aiChatConversationEmptyDescription,
        icon: Icons.chat_bubble_outline_rounded,
      );
    }

    final items = <_ConversationItem>[
      ...state.messages.map(_ConversationItem.message),
      if (state.streamingDraft.isNotEmpty)
        _ConversationItem.streaming(state.streamingDraft),
    ];

    return ListView.separated(
      key: const Key('ai-chat-message-list'),
      controller: scrollController,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.streamingDraft != null) {
          return _MessageBubble(
            role: AiChatMessageRole.assistant,
            content: item.streamingDraft!,
            isStreaming: true,
            usedTools: const <String>[],
          );
        }

        final message = item.message!;
        return _MessageBubble(
          role: message.role,
          content: message.content,
          usedTools: message.usedTools,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacingTokens.md),
      itemCount: items.length,
    );
  }

  String _disabledDescription(
    AppLocalizations l10n,
    AiChatCapabilities capabilities,
  ) {
    if (!capabilities.aiChatEnabled) {
      return l10n.aiChatConversationDisabledByUserHint;
    }
    if (!capabilities.chatModelConfigured) {
      return l10n.aiChatConversationModelMissing;
    }
    return l10n.aiChatConversationNotReady;
  }
}

class _ConversationItem {
  const _ConversationItem._({this.message, this.streamingDraft});

  const _ConversationItem.message(AiChatMessage message)
    : this._(message: message);

  const _ConversationItem.streaming(String draft)
    : this._(streamingDraft: draft);

  final AiChatMessage? message;
  final String? streamingDraft;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.role,
    required this.content,
    required this.usedTools,
    this.isStreaming = false,
  });

  final AiChatMessageRole role;
  final String content;
  final List<String> usedTools;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final isUser = role == AiChatMessageRole.user;
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
                    AppLocalizations.of(context)!.aiChatStreamingLabel,
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
              ],
            ),
          ),
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
            key: const Key('ai-chat-input'),
            controller: controller,
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l10n.aiChatInputHint,
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
          key: const Key('ai-chat-send-action'),
          onPressed: canSend ? onSend : null,
          child: Text(
            isSending ? l10n.aiChatSendingAction : l10n.aiChatSendAction,
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

String _localizeToolName(String toolId, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return switch (toolId) {
    'health_context_snapshot' => l10n.aiChatToolHealthContext,
    'recent_daily_records' => l10n.aiChatToolRecentDailyRecords,
    'recent_sleep_summary' => l10n.aiChatToolRecentSleepSummary,
    'current_medicines' => l10n.aiChatToolCurrentMedicines,
    _ => toolId,
  };
}

String _sendErrorDescription(
  AppLocalizations l10n,
  AiChatSendErrorType? errorType,
  String fallback,
) {
  return switch (errorType) {
    AiChatSendErrorType.streamInterrupted => l10n.aiChatErrorStreamInterrupted,
    AiChatSendErrorType.emptyResult => l10n.aiChatErrorEmptyResult,
    AiChatSendErrorType.server => l10n.aiChatErrorServer,
    AiChatSendErrorType.unknown || null => fallback,
  };
}

IconData _sendErrorIcon(AiChatSendErrorType? errorType) {
  return switch (errorType) {
    AiChatSendErrorType.streamInterrupted => Icons.wifi_off_rounded,
    AiChatSendErrorType.emptyResult => Icons.hourglass_empty_rounded,
    AiChatSendErrorType.server => Icons.cloud_off_rounded,
    AiChatSendErrorType.unknown || null => Icons.error_outline_rounded,
  };
}

AppTypographyScale _typography(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.sizeOf(context).width;
  return width < AppBreakpoints.mobile
      ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
      : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
}
