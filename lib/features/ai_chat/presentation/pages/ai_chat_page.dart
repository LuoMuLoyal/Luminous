import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/responsive_content_frame.dart';
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';
import 'package:luminous/features/ai_chat/presentation/providers/ai_chat_controller.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
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
    final effectiveContext =
        settings == null && capabilities != null
            ? UpdateAiChatContextSettingsDto(
                healthProfile: capabilities.aiChatContext.healthProfile,
                dailyRecords: capabilities.aiChatContext.dailyRecords,
                sleepRecords: capabilities.aiChatContext.sleepRecords,
                currentMedicines: capabilities.aiChatContext.currentMedicines,
              )
            : null;

    return Material(
      color: surface.canvasSoft,
      child: SafeArea(
        child: ResponsiveContentFrame(
          expand: true,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < AppBreakpoints.mobile
                  ? AppSpacingTokens.lg
                  : AppSpacingTokens.xl,
            ),
            child: Column(
              children: [
                _Header(
                  title: l10n.aiChatPageTitle,
                  onBack: () => context.pop(),
                  onClear: chatState.hasConversation
                      ? ref.read(aiChatControllerProvider.notifier).clearConversation
                      : null,
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                if (session.isRestoring) ...[
                  const Expanded(child: _AiChatLoadingView()),
                ] else if (!session.canAccessProtectedData) ...[
                  Expanded(
                    child: AppStateErrorView(
                      title: l10n.authNotSignedIn,
                      description: l10n.aiChatSignedOutDescription,
                      icon: Icons.lock_outline_rounded,
                      actionLabel: l10n.authGoLogin,
                      onAction: () =>
                          context.go(loginRouteForReturnTo('/settings/ai-chat')),
                    ),
                  ),
                ] else if (chatState.isLoadingCapabilities &&
                    capabilities == null &&
                    chatState.capabilityError == null) ...[
                  const Expanded(child: _AiChatLoadingView()),
                ] else if (capabilities == null) ...[
                  Expanded(
                    child: AppStateErrorView(
                      title: l10n.aiChatLoadErrorTitle,
                      description:
                          chatState.capabilityError ?? l10n.aiChatLoadErrorFallback,
                      icon: Icons.cloud_off_rounded,
                      actionLabel: l10n.todayRetryAction,
                      onAction: () => ref
                          .read(aiChatControllerProvider.notifier)
                          .loadCapabilities(),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compactHeight = constraints.maxHeight < 620;
                        final settingsSection = SettingsSectionSurface(
                          surface: surface,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              SettingsListRow(
                                key: const Key('ai-chat-row-enabled'),
                                title: l10n.aiChatSettingsEnableTitle,
                                subtitle: l10n.aiChatSettingsEnableSubtitle,
                                icon: Icons.auto_awesome_outlined,
                                trailing: IgnorePointer(
                                  child: Switch(
                                    value: settings?.aiChatEnabled ??
                                        capabilities.aiChatEnabled,
                                    onChanged: (_) {},
                                  ),
                                ),
                                onTap: () => _toggleAiChatEnabled(
                                  context,
                                  !(settings?.aiChatEnabled ??
                                      capabilities.aiChatEnabled),
                                ),
                                showDivider: true,
                              ),
                              SettingsListRow(
                                key: const Key('ai-chat-row-context-health-profile'),
                                title: l10n.aiChatContextHealthProfile,
                                icon: Icons.badge_outlined,
                                trailing: IgnorePointer(
                                  child: Switch(
                                    value: settings?.aiChatContext.healthProfile ??
                                        capabilities.aiChatContext.healthProfile,
                                    onChanged: (_) {},
                                  ),
                                ),
                                onTap: () => _toggleContextSetting(
                                  context,
                                  settings: settings,
                                  fallbackContext: effectiveContext,
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
                                    value: settings?.aiChatContext.dailyRecords ??
                                        capabilities.aiChatContext.dailyRecords,
                                    onChanged: (_) {},
                                  ),
                                ),
                                onTap: () => _toggleContextSetting(
                                  context,
                                  settings: settings,
                                  fallbackContext: effectiveContext,
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
                                    value: settings?.aiChatContext.sleepRecords ??
                                        capabilities.aiChatContext.sleepRecords,
                                    onChanged: (_) {},
                                  ),
                                ),
                                onTap: () => _toggleContextSetting(
                                  context,
                                  settings: settings,
                                  fallbackContext: effectiveContext,
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
                                onTap: () => _toggleContextSetting(
                                  context,
                                  settings: settings,
                                  fallbackContext: effectiveContext,
                                  currentMedicines:
                                      !(settings?.aiChatContext.currentMedicines ??
                                          capabilities.aiChatContext.currentMedicines),
                                ),
                              ),
                            ],
                          ),
                        );
                        final statusSection = SettingsSectionSurface(
                          surface: surface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.aiChatStatusSectionTitle,
                                style: typography.bodyMdStrong,
                              ),
                              const SizedBox(height: AppSpacingTokens.sm),
                              Text(
                                _statusSummaryText(l10n, capabilities),
                                style: typography.bodySm.copyWith(
                                  color: surface.body,
                                ),
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
                                    enabled:
                                        capabilities.aiChatContext.enabledCount > 0,
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
                        );
                        final conversationSection = SettingsSectionSurface(
                          surface: surface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _ConversationView(
                                  state: chatState,
                                  capabilities: capabilities,
                                  scrollController: _scrollController,
                                ),
                              ),
                              if (chatState.sendError != null) ...[
                                const SizedBox(height: AppSpacingTokens.md),
                                AppStateMessageView(
                                  title: l10n.aiChatSendErrorTitle,
                                  description: chatState.sendError!,
                                  icon: Icons.error_outline_rounded,
                                  tone: AppStateTone.warning,
                                  padding: const EdgeInsets.all(
                                    AppSpacingTokens.md,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacingTokens.md),
                              _InputComposer(
                                controller: _inputController,
                                canSend:
                                    capabilities.canSendMessages &&
                                    !chatState.isSending,
                                isSending: chatState.isSending,
                                onSend: _handleSend,
                              ),
                            ],
                          ),
                        );

                        if (compactHeight) {
                          return ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              settingsSection,
                              const SizedBox(height: AppSpacingTokens.md),
                              statusSection,
                              const SizedBox(height: AppSpacingTokens.md),
                              SizedBox(
                                height: constraints.maxHeight * 0.72,
                                child: conversationSection,
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            settingsSection,
                            const SizedBox(height: AppSpacingTokens.md),
                            statusSection,
                            const SizedBox(height: AppSpacingTokens.md),
                            Expanded(child: conversationSection),
                          ],
                        );
                      },
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

  Future<void> _toggleAiChatEnabled(BuildContext context, bool nextValue) async {
    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .setAiChatEnabled(nextValue);
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
        await ref.read(userSettingsControllerProvider.notifier).setAiChatContext(
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
      await ref.read(userSettingsControllerProvider.notifier).setAiChatContext(
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
      await AppToast.show(
        context,
        LucentErrorMapper.fromObject(error).message,
      );
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

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onBack,
    required this.onClear,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SettingsBackButton(onTap: onBack),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: _typography(context).displaySm,
          ),
        ),
        SizedBox(
          width: 48,
          child: onClear == null
              ? null
              : IconButton(
                  key: const Key('ai-chat-clear-action'),
                  tooltip: l10n.recordNlpResetAction,
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
        ),
      ],
    );
  }
}

class _AiChatLoadingView extends StatelessWidget {
  const _AiChatLoadingView();

  @override
  Widget build(BuildContext context) {
    return AppStateSkeletonView(
      blocks: const [
        AppStateSkeletonBlock(height: 160),
        AppStateSkeletonBlock(height: 88),
        AppStateSkeletonBlock(height: 320),
      ],
      padding: EdgeInsets.zero,
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

    if (!capabilities.canSendMessages) {
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
      return l10n.aiChatConversationDisabledByUser;
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
                if (usedTools.isNotEmpty || isStreaming) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    isStreaming
                        ? AppLocalizations.of(context)!.aiChatStreamingLabel
                        : usedTools.join(', '),
                    style: _typography(
                      context,
                    ).bodySm.copyWith(color: surface.mute),
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

AppTypographyScale _typography(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.sizeOf(context).width;
  return width < AppBreakpoints.mobile
      ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
      : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
}
