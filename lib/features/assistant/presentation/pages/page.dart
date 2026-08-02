import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/page_body.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantPage extends HookConsumerWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldKey = useMemoized(GlobalKey<ScaffoldState>.new);

    final inputController = useTextEditingController();
    final scrollController = useMemoized(() => ScrollController());
    final isNearBottom = useState<bool>(true);

    void scrollToBottom() {
      if (!scrollController.hasClients) return;
      unawaited(
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: DurationTokens.widgetQuick,
          curve: MotionTokens.snappy,
        ),
      );
    }

    void onUserScroll() {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;
      final nearBottom =
          (pos.pixels - pos.maxScrollExtent).abs() <= 96 ||
          pos.pixels >= pos.maxScrollExtent - 1;
      if (isNearBottom.value != nearBottom) {
        isNearBottom.value = nearBottom;
      }
    }

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
      return () {
        scrollController.removeListener(onUserScroll);
        scrollController.dispose();
      };
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

    // Watch only the drawer-relevant fields so streaming chunks (messages /
    // streamingDraft) do not rebuild the Scaffold + drawer on every event.
    final conversationDrawer = AssistantConversationDrawer(
      state: ref.watch(
        assistantControllerProvider.select(
          (s) => AssistantState(
            conversationId: s.conversationId,
            isOpeningConversation: s.isOpeningConversation,
            isLoadingRecentConversations: s.isLoadingRecentConversations,
            recentConversationError: s.recentConversationError,
            recentConversations: s.recentConversations,
          ),
        ),
      ),
      title: l10n.assistantConversationSidebarTitle,
      emptyTitle: l10n.assistantRecentConversationsEmptyTitle,
      emptyDescription: l10n.assistantRecentConversationsEmptyDescription,
      onRetry: () => ref
          .read(assistantControllerProvider.notifier)
          .loadRecentConversations(),
      onNewConversation: () async {
        scaffoldKey.currentState?.closeEndDrawer();
        await handleStartNewConversation();
      },
      onSelect: (conversationId) async {
        scaffoldKey.currentState?.closeEndDrawer();
        await ref
            .read(assistantControllerProvider.notifier)
            .openConversation(conversationId);
      },
    );

    return Scaffold(
      key: scaffoldKey,
      endDrawer: conversationDrawer,
      body: AssistantPageBody(
        inputController: inputController,
        scrollController: scrollController,
        isNearBottom: isNearBottom,
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
        onStartNewConversation: handleStartNewConversation,
        onOpenDrawer: () => scaffoldKey.currentState?.openEndDrawer(),
      ),
    );
  }
}
