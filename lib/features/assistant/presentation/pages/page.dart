import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/controls_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_surface.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/hero.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';

import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantPage extends HookConsumerWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    // Subscribe to capability-related state slices. These never change during
    // streaming, so the parent stays stable while chunks arrive.
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
    final lastFailedInput = ref.watch(
      assistantControllerProvider.select((s) => s.lastFailedInput),
    );
    final hasConversation = ref.watch(
      assistantControllerProvider.select((s) => s.hasConversation),
    );

    final settingsAsync = session.canAccessProtectedData
        ? ref.watch(userSettingsControllerProvider)
        : null;
    final settings = settingsAsync?.asData?.value;
    final effectiveContext = settings == null && capabilities != null
        ? AssistantContextPatch(
            healthProfile: capabilities.assistantContext.healthProfile,
            dailyRecords: capabilities.assistantContext.dailyRecords,
            sleepRecords: capabilities.assistantContext.sleepRecords,
            currentMedicines: capabilities.assistantContext.currentMedicines,
          )
        : null;

    final inputController = useTextEditingController();
    final scrollController = useMemoized(() => ScrollController());
    // Tracks whether the user is currently near the bottom of the conversation.
    // Only then do we auto-scroll on new streamed chunks; otherwise we show a
    // floating "scroll to bottom" button so users can read history undisturbed.
    final isNearBottom = useState<bool>(true);
    // Hero collapses once a conversation has content, but the user can expand
    // it again to inspect the full status summary at any time.
    final heroExpanded = useState<bool>(false);

    void scrollToBottom() {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: DurationTokens.widgetQuick,
        curve: Curves.easeOut,
      );
    }

    void onUserScroll() {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;
      // Consider "near bottom" if within 96 logical px of the max extent.
      final nearBottom =
          (pos.pixels - pos.maxScrollExtent).abs() <= 96 ||
          pos.pixels >= pos.maxScrollExtent - 1;
      if (isNearBottom.value != nearBottom) {
        isNearBottom.value = nearBottom;
      }
    }

    // Auto-scroll to bottom only when the user is already near the bottom.
    // This avoids yanking the view back during streaming while the user is
    // reading earlier messages. We only watch message-count deltas here (not
    // streamingDraft) so the parent does not rebuild on every chunk.
    ref.listen<int>(
      assistantControllerProvider.select(
        (s) => s.messages.length + (s.streamingDraft.isNotEmpty ? 1 : 0),
      ),
      (prev, next) {
        final grew = (prev ?? 0) < next;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isNearBottom.value || grew) {
            scrollToBottom();
          }
        });
      },
    );

    useEffect(() {
      scrollController.addListener(onUserScroll);
      return () => scrollController.removeListener(onUserScroll);
    }, [scrollController]);

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
      final result = await runGuarded(
        ref: ref,
        tag: 'AssistantPage.toggleAssistantEnabled',
        action: () async {
          await ref
              .read(userSettingsControllerProvider.notifier)
              .setAssistantEnabled(nextValue);
          await ref
              .read(assistantControllerProvider.notifier)
              .loadCapabilities();
        },
      );
      if (result case Failure(:final error)) {
        if (!ctx.mounted) return;
        await Toast.show(ctx, error.message);
      }
    }

    Future<void> toggleAssistantMemoryEnabled(
      BuildContext ctx,
      bool nextValue,
    ) async {
      final result = await runGuarded(
        ref: ref,
        tag: 'AssistantPage.toggleAssistantMemoryEnabled',
        action: () async {
          await ref
              .read(userSettingsControllerProvider.notifier)
              .setAssistantMemoryEnabled(nextValue);
          await ref
              .read(assistantControllerProvider.notifier)
              .loadCapabilities();
        },
      );
      if (result case Failure(:final error)) {
        if (!ctx.mounted) return;
        await Toast.show(ctx, error.message);
      }
    }

    Future<void> toggleContextSetting(
      BuildContext ctx, {
      required UserSettings? settings,
      required AssistantContextPatch? fallbackContext,
      bool? healthProfile,
      bool? dailyRecords,
      bool? sleepRecords,
      bool? currentMedicines,
    }) async {
      final current = settings?.assistantContext;
      if (current == null) {
        if (fallbackContext == null) return;
        final result = await runGuarded(
          ref: ref,
          tag: 'AssistantPage.toggleContextSetting',
          action: () async {
            await ref
                .read(userSettingsControllerProvider.notifier)
                .setAssistantContext(
                  AssistantContextPatch(
                    healthProfile:
                        healthProfile ?? fallbackContext.healthProfile,
                    dailyRecords: dailyRecords ?? fallbackContext.dailyRecords,
                    sleepRecords: sleepRecords ?? fallbackContext.sleepRecords,
                    currentMedicines:
                        currentMedicines ?? fallbackContext.currentMedicines,
                  ),
                );
            await ref
                .read(assistantControllerProvider.notifier)
                .loadCapabilities();
          },
        );
        if (result case Failure(:final error)) {
          if (!ctx.mounted) return;
          await Toast.show(ctx, error.message);
        }
        return;
      }
      final result = await runGuarded(
        ref: ref,
        tag: 'AssistantPage.toggleContextSetting',
        action: () async {
          await ref
              .read(userSettingsControllerProvider.notifier)
              .setAssistantContext(
                AssistantContextPatch(
                  healthProfile: healthProfile ?? current.healthProfile,
                  dailyRecords: dailyRecords ?? current.dailyRecords,
                  sleepRecords: sleepRecords ?? current.sleepRecords,
                  currentMedicines:
                      currentMedicines ?? current.currentMedicines,
                ),
              );
          await ref
              .read(assistantControllerProvider.notifier)
              .loadCapabilities();
        },
      );
      if (result case Failure(:final error)) {
        if (!ctx.mounted) return;
        await Toast.show(ctx, error.message);
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
      final result = await runGuarded(
        ref: ref,
        tag: 'AssistantPage.handleConfirmProposal',
        action: () => ref
            .read(assistantControllerProvider.notifier)
            .confirmProposedAction(
              messageId: messageId,
              proposalId: proposalId,
            ),
      );
      switch (result) {
        case Success():
          if (!ctx.mounted) return;
          await Toast.show(ctx, l.assistantProposalConfirmedToast);
        case Failure(:final error):
          if (!ctx.mounted) return;
          await Toast.show(ctx, error.message);
      }
    }

    void openRecentConversationsDrawer() {
      unawaited(
        showFSheet<void>(
          context: context,
          side: FLayout.rtl,
          builder: (sheetContext) => AssistantConversationDrawer(
            // The drawer needs full state; pull a fresh snapshot here so it
            // always reflects the latest even though the parent used select.
            state: ref.read(assistantControllerProvider),
            title: l10n.assistantRecentConversationsTitle,
            emptyTitle: l10n.assistantRecentConversationsEmptyTitle,
            emptyDescription: l10n.assistantRecentConversationsEmptyDescription,
            onRetry: () => ref
                .read(assistantControllerProvider.notifier)
                .loadRecentConversations(),
            onSelect: (conversationId) async {
              Navigator.of(sheetContext).pop();
              await ref
                  .read(assistantControllerProvider.notifier)
                  .openConversation(conversationId);
            },
          ),
        ),
      );
    }

    void openControlsDrawer() {
      unawaited(
        showFSheet<void>(
          context: context,
          side: FLayout.rtl,
          builder: (sheetContext) => _AssistantControlsSheet(
            title: l10n.assistantControlsDrawerTitle,
            controls: AssistantControlsPanel(
              settings: settings,
              fallbackContext: effectiveContext,
              capabilities: capabilities!,
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
          ),
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final scaffoldBody = PageScaffold(
      title: l10n.assistantPageTitle,
      actions: [
        FButton.icon(
          key: const Key('assistant-recent-conversations-action'),
          variant: FButtonVariant.ghost,
          onPress:
              !session.canAccessProtectedData ||
                  isLoadingRecentConversations ||
                  isOpeningConversation
              ? null
              : openRecentConversationsDrawer,
          child: const Icon(FLucideIcons.clock4),
        ),
        FButton.icon(
          key: const Key('assistant-new-conversation-action'),
          variant: FButtonVariant.ghost,
          onPress:
              !session.canAccessProtectedData ||
                  isLoadingConversation ||
                  // `isSending` is read via provider so we don't resubscribe
                  // here; we intentionally keep this single bool slice.
                  ref.read(assistantControllerProvider).isSending ||
                  isOpeningConversation
              ? null
              : handleStartNewConversation,
          child: const Icon(FLucideIcons.plus),
        ),
        if (session.canAccessProtectedData && capabilities != null)
          FButton.icon(
            key: const Key('assistant-controls-action'),
            variant: FButtonVariant.ghost,
            onPress: openControlsDrawer,
            child: const Icon(FLucideIcons.settings2),
          ),
      ],
      child: ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
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
                  icon: FLucideIcons.circleAlert,
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
                  icon: FLucideIcons.circleAlert,
                  tone: StateTone.warning,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref
                      .read(assistantControllerProvider.notifier)
                      .loadCapabilities(),
                ),
              ] else ...[
                AnimatedSize(
                  duration: DurationTokens.widgetStandard,
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: AssistantHero(
                    capabilities: capabilities,
                    statusSummary: statusSummaryText(l10n, capabilities),
                    compact: hasConversation && !heroExpanded.value,
                    onToggleCompact: hasConversation
                        ? () => heroExpanded.value = !heroExpanded.value
                        : null,
                  ),
                ),
                if (conversationError != null) ...[
                  const SizedBox(height: Spacing.level4),
                  StateMessageView(
                    title: l10n.assistantLoadErrorTitle,
                    description: conversationError,
                    icon: FLucideIcons.circleAlert,
                    tone: StateTone.warning,
                    actionLabel: l10n.todayRetryAction,
                    onAction: () => ref
                        .read(assistantControllerProvider.notifier)
                        .loadLatestConversation(),
                  ),
                ],
                const SizedBox(height: Spacing.level4),
                Expanded(
                  child: Stack(
                    children: [
                      AssistantConversationSurface(
                        capabilities: capabilities,
                        scrollController: scrollController,
                        controller: inputController,
                        onSend: handleSend,
                        onRetry: lastFailedInput != null
                            ? () => ref
                                  .read(assistantControllerProvider.notifier)
                                  .retryLastMessage()
                            : null,
                        onConfirmProposal:
                            ({required messageId, required proposalId}) =>
                                handleConfirmProposal(
                                  context,
                                  messageId: messageId,
                                  proposalId: proposalId,
                                ),
                        onDismissProposal:
                            ({required messageId, required proposalId}) {
                              ref
                                  .read(assistantControllerProvider.notifier)
                                  .dismissProposedAction(
                                    messageId: messageId,
                                    proposalId: proposalId,
                                  );
                            },
                      ),
                      if (!isNearBottom.value)
                        Positioned(
                          right: Spacing.level4,
                          bottom: Spacing.level4,
                          child: FButton(
                            variant: .secondary,
                            mainAxisSize: .min,
                            onPress: () {
                              isNearBottom.value = true;
                              scrollToBottom();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FLucideIcons.chevronDown, size: 16),
                                const SizedBox(width: Spacing.level2),
                                Text(l10n.assistantScrollToBottom),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return scaffoldBody;
  }
}

class _AssistantControlsSheet extends StatelessWidget {
  const _AssistantControlsSheet({required this.title, required this.controls});

  final String title;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width < 600
        ? MediaQuery.sizeOf(context).width * 0.85
        : 400.0;

    return SizedBox(
      width: width,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TypographyToken.level7.display(context),
                    ),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(context).pop(),
                    child: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level4),
              Expanded(child: SingleChildScrollView(child: controls)),
            ],
          ),
        ),
      ),
    );
  }
}
