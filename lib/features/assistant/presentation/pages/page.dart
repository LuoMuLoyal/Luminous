import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_state.dart';
import 'package:luminous/features/assistant/presentation/widgets/flow_theme_bridge.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/page_body.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantPage extends HookConsumerWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final inputController = useTextEditingController();
    final scrollController = useMemoized(() => ScrollController());

    useEffect(() {
      return scrollController.dispose;
    }, [scrollController]);

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

    Future<void> handleRenameConversation(
      BuildContext ctx,
      String conversationId,
    ) async {
      final l = AppLocalizations.of(ctx)!;
      final current = ref
          .read(assistantControllerProvider)
          .recentConversations
          .where((item) => item.id == conversationId)
          .map((item) => item.title)
          .firstOrNull;

      final newTitle = await showFDialog<String>(
        context: ctx,
        builder: (context, style, animation) => _RenameConversationDialog(
          initialTitle: current,
          dialogTitle: l.assistantConversationRenameDialogTitle,
          hint: l.assistantConversationRenameHint,
          confirmLabel: l.assistantConversationRenameAction,
          cancelLabel: l.commonCancel,
        ),
      );
      if (newTitle == null) {
        return;
      }

      try {
        await ref
            .read(assistantControllerProvider.notifier)
            .renameConversation(
              conversationId: conversationId,
              title: newTitle,
            );
      } catch (error) {
        if (!ctx.mounted) return;
        await Toast.show(
          ctx,
          userMessageFromError(
            error,
            fallback: l.assistantConversationRenameDialogTitle,
            l10n: l,
          ),
        );
      }
    }

    Future<void> handleDeleteConversation(
      BuildContext ctx,
      String conversationId,
    ) async {
      final l = AppLocalizations.of(ctx)!;
      final confirmed = await showDangerConfirmationDialog(
        context: ctx,
        title: l.assistantConversationDeleteConfirmTitle,
        message: l.assistantConversationDeleteConfirmDescription,
        confirmLabel: l.assistantConversationDeleteAction,
        cancelLabel: l.commonCancel,
      );
      if (!confirmed) {
        return;
      }

      try {
        await ref
            .read(assistantControllerProvider.notifier)
            .deleteConversation(conversationId);
        if (!ctx.mounted) return;
        await Toast.show(ctx, l.assistantConversationDeletedToast);
      } catch (error) {
        if (!ctx.mounted) return;
        await Toast.show(
          ctx,
          userMessageFromError(
            error,
            fallback: l.assistantConversationDeleteConfirmTitle,
            l10n: l,
          ),
        );
      }
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
        await Toast.show(ctx, l.assistantProposalConfirmedToast);
      } catch (error) {
        if (!ctx.mounted) return;
        // 用统一错误文案 helper 提取用户可见消息:message 为空或非预期
        // 类型时落到本地化兜底,不直接展示原始 message。
        await Toast.show(
          ctx,
          userMessageFromError(
            error,
            fallback: l.assistantProposalFailedState,
            l10n: l,
          ),
        );
      }
    }

    Future<void> handleRegenerateProposal(
      BuildContext ctx, {
      required String messageId,
      required String proposalId,
    }) async {
      final l = AppLocalizations.of(ctx)!;
      try {
        await ref
            .read(assistantControllerProvider.notifier)
            .regenerateExpiredProposal(
              messageId: messageId,
              proposalId: proposalId,
            );
        // 重新生成已进入流式回复,新的回复即为成功反馈,不再额外 toast。
      } catch (error) {
        if (!ctx.mounted) return;
        await Toast.show(
          ctx,
          userMessageFromError(
            error,
            fallback: l.assistantProposalFailedState,
            l10n: l,
          ),
        );
      }
    }

    Future<void> handleRegenerate(BuildContext ctx) async {
      final l = AppLocalizations.of(ctx)!;
      try {
        await ref
            .read(assistantControllerProvider.notifier)
            .regenerateLastMessage();
        // 流式回复本身就是成功反馈,不再额外 toast。
      } catch (error) {
        if (!ctx.mounted) return;
        await Toast.show(
          ctx,
          userMessageFromError(
            error,
            fallback: l.assistantRegenerateAction,
            l10n: l,
          ),
        );
      }
    }

    Future<void> handleResend(BuildContext ctx, String content) async {
      final l = AppLocalizations.of(ctx)!;
      try {
        await ref
            .read(assistantControllerProvider.notifier)
            .resendMessage(content);
      } catch (error) {
        if (!ctx.mounted) return;
        await Toast.show(
          ctx,
          userMessageFromError(
            error,
            fallback: l.assistantResendAction,
            l10n: l,
          ),
        );
      }
    }

    // Watch only the drawer-relevant fields so streaming chunks (messages /
    // streamingDraft) do not rebuild the sheet contents on every event.
    final drawerState = ref.watch(
      assistantControllerProvider.select(
        (s) => AssistantDrawerState(
          conversationId: s.conversationId,
          isOpeningConversation: s.isOpeningConversation,
          isClearingConversation: s.isClearingConversation,
          isLoadingRecentConversations: s.isLoadingRecentConversations,
          recentConversationError: s.recentConversationError,
          recentConversations: s.recentConversations,
        ),
      ),
    );

    final screenWidth = MediaQuery.sizeOf(context).width;
    // Cached: recomputed only when the available width changes, not per frame.
    final drawerWidth = useMemoized(
      () => screenWidth < Breakpoints.tablet ? screenWidth * 0.84 : 320.0,
      [screenWidth],
    );
    final isConversationDrawerOpen = useState(false);

    void openConversationDrawer() {
      isConversationDrawerOpen.value = true;
    }

    final mainContent = KeyedSubtree(
      key: const Key('assistant-main-content'),
      child: AssistantPageBody(
        inputController: inputController,
        scrollController: scrollController,
        onSend: handleSend,
        onRetry: null,
        onConfirmProposal: ({required messageId, required proposalId}) =>
            handleConfirmProposal(
              context,
              messageId: messageId,
              proposalId: proposalId,
            ),
        onDismissProposal: ({required messageId, required proposalId}) {
          unawaited(
            ref
                .read(assistantControllerProvider.notifier)
                .dismissProposedAction(
                  messageId: messageId,
                  proposalId: proposalId,
                ),
          );
        },
        onRegenerateProposal: ({required messageId, required proposalId}) {
          unawaited(
            handleRegenerateProposal(
              context,
              messageId: messageId,
              proposalId: proposalId,
            ),
          );
        },
        onRegenerate: () => unawaited(handleRegenerate(context)),
        onResend: (content) => unawaited(handleResend(context, content)),
        onStartNewConversation: handleStartNewConversation,
        onOpenDrawer: openConversationDrawer,
      ),
    );

    final assistantContent = ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              end: isConversationDrawerOpen.value ? drawerWidth : 0,
            ),
            duration: DurationTokens.widgetQuick,
            curve: MotionTokens.snappy,
            child: mainContent,
            builder: (context, offset, child) {
              final displaced = offset.abs() > 0.5;
              return IgnorePointer(
                ignoring: displaced,
                child: ExcludeSemantics(
                  excluding: displaced,
                  child: Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: isConversationDrawerOpen.value ? 0 : -drawerWidth,
            top: 0,
            bottom: 0,
            width: drawerWidth,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                end: isConversationDrawerOpen.value ? 0 : -drawerWidth,
              ),
              duration: DurationTokens.widgetQuick,
              curve: MotionTokens.snappy,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.theme.colors.background,
                ),
                child: AssistantConversationDrawer(
                  width: drawerWidth,
                  state: drawerState,
                  title: l10n.assistantConversationSidebarTitle,
                  emptyTitle: l10n.assistantRecentConversationsEmptyTitle,
                  emptyDescription:
                      l10n.assistantRecentConversationsEmptyDescription,
                  searchHint: l10n.assistantConversationSearchHint,
                  searchEmptyTitle: l10n.assistantConversationSearchEmptyTitle,
                  searchEmptyDescription:
                      l10n.assistantConversationSearchEmptyDescription,
                  onClose: () => isConversationDrawerOpen.value = false,
                  onRetry: () => ref
                      .read(assistantControllerProvider.notifier)
                      .loadRecentConversations(),
                  onNewConversation: () {
                    isConversationDrawerOpen.value = false;
                    unawaited(handleStartNewConversation());
                  },
                  onSelect: (conversationId) {
                    isConversationDrawerOpen.value = false;
                    unawaited(
                      ref
                          .read(assistantControllerProvider.notifier)
                          .openConversation(conversationId),
                    );
                  },
                  onRename: (conversationId) {
                    unawaited(
                      handleRenameConversation(context, conversationId),
                    );
                  },
                  onDelete: (conversationId) {
                    unawaited(
                      handleDeleteConversation(context, conversationId),
                    );
                  },
                ),
              ),
              builder: (context, offset, child) {
                final displaced = offset.abs() > 0.5;
                return IgnorePointer(
                  ignoring: displaced,
                  child: ExcludeSemantics(
                    excluding: displaced,
                    child: Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    return withLuminousFlowTheme(context, assistantContent);
  }
}

/// Rename dialog for one assistant conversation: a single-line title field
/// (prefilled with the current title) plus cancel / confirm actions.
class _RenameConversationDialog extends StatefulWidget {
  const _RenameConversationDialog({
    required this.initialTitle,
    required this.dialogTitle,
    required this.hint,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String? initialTitle;
  final String dialogTitle;
  final String hint;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_RenameConversationDialog> createState() =>
      _RenameConversationDialogState();
}

class _RenameConversationDialogState extends State<_RenameConversationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FDialog(
      key: const Key('assistant-conversation-rename-dialog'),
      constraints: const BoxConstraints(maxWidth: 440),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.dialogTitle, style: context.theme.typography.body.lg),
            const SizedBox(height: Spacing.level4),
            FTextField(
              key: const Key('assistant-conversation-rename-field'),
              control: FTextFieldControl.managed(controller: _controller),
              hint: widget.hint,
              autofocus: true,
              maxLength: 48,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  key: const Key('assistant-conversation-rename-confirm'),
                  onPress: () => Navigator.of(context).pop(_controller.text),
                  child: Text(widget.confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
