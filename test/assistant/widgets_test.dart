import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_state.dart';
import 'package:luminous/features/assistant/presentation/widgets/disclaimer_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/welcome_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/chips.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/message_bubble.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/proposal_card.dart';
import 'package:luminous/features/assistant/presentation/widgets/source_strip.dart';

import '../helpers/test_forui_app.dart';

Widget _shell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

const _disclaimerText = 'AI 回答仅供健康参考，不构成医疗诊断或用药建议；用药调整请咨询医生或药师。';

void main() {
  group('AssistantToolChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _shell(const AssistantToolChip(label: 'Today Records')),
      );
      expect(find.text('Today Records'), findsOneWidget);
    });
  });

  group('AssistantDisclaimerBar', () {
    testWidgets('renders nothing for empty text', (tester) async {
      await tester.pumpWidget(_shell(const AssistantDisclaimerBar(text: '')));
      expect(find.byType(AssistantDisclaimerBar), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('renders single-line disclaimer text', (tester) async {
      await tester.pumpWidget(
        _shell(const AssistantDisclaimerBar(text: _disclaimerText)),
      );
      final text = tester.widget<Text>(find.text(_disclaimerText));
      expect(text.maxLines, 1);
    });
  });

  group('AssistantLoadingView', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(
        _shell(
          const SizedBox(
            height: 800,
            child: SingleChildScrollView(child: AssistantLoadingView()),
          ),
        ),
      );
      expect(find.byType(AssistantLoadingView), findsOneWidget);
    });
  });

  group('AssistantWelcomePanel', () {
    testWidgets('renders welcome copy and forwards starter prompt', (
      tester,
    ) async {
      String? selectedPrompt;

      await tester.pumpWidget(
        _shell(
          AssistantWelcomePanel(
            onStarterPrompt: (prompt) => selectedPrompt = prompt,
          ),
        ),
      );

      expect(find.text('开始和 Luminous 聊天'), findsOneWidget);
      expect(find.text('可以问我最近的睡眠、记录和用药情况。'), findsOneWidget);

      await tester.tap(find.text('总结我今天的记录'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(selectedPrompt, '总结我今天的记录');
    });

    testWidgets('shows full disclaimer when showDisclaimerExpanded is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          AssistantWelcomePanel(
            onStarterPrompt: (_) {},
            showDisclaimerExpanded: true,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(_disclaimerText));
      expect(text.maxLines, isNull);
      expect(find.byIcon(SemanticIcons.actionCollapse), findsOneWidget);
    });

    testWidgets('collapses the disclaimer on tap', (tester) async {
      await tester.pumpWidget(
        _shell(
          AssistantWelcomePanel(
            onStarterPrompt: (_) {},
            showDisclaimerExpanded: true,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-welcome-disclaimer')));
      await tester.pump();

      final text = tester.widget<Text>(find.text(_disclaimerText));
      expect(text.maxLines, 1);
      expect(find.byIcon(SemanticIcons.actionExpand), findsOneWidget);
    });

    testWidgets('starts collapsed when showDisclaimerExpanded is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          AssistantWelcomePanel(
            onStarterPrompt: (_) {},
            showDisclaimerExpanded: false,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(_disclaimerText));
      expect(text.maxLines, 1);
      expect(find.byIcon(SemanticIcons.actionExpand), findsOneWidget);
    });
  });

  group('AssistantMessageBubble', () {
    testWidgets('renders user message content', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-user',
            role: AssistantMessageRole.user,
            content: 'User message',
            usedTools: <String>[],
          ),
        ),
      );
      expect(find.text('User message'), findsOneWidget);
    });

    testWidgets('uses a readable accent color for user message text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-user-color',
            role: AssistantMessageRole.user,
            content: 'Readable user message',
            usedTools: <String>[],
          ),
        ),
      );

      final messageContext = tester.element(
        find.byType(AssistantMessageBubble),
      );
      final text = tester.widget<SelectableText>(find.byType(SelectableText));

      expect(text.style?.color, SemanticColor.primary.solid(messageContext));
    });

    testWidgets('renders assistant message with context menu', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-assistant',
            role: AssistantMessageRole.assistant,
            content: 'Assistant reply',
            usedTools: <String>[],
          ),
        ),
      );
      expect(find.text('Assistant reply'), findsOneWidget);
      expect(find.byType(FContextMenu), findsOneWidget);
    });

    testWidgets('renders source strip for assistant messages with tools', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-source',
            role: AssistantMessageRole.assistant,
            content: 'Reply with sources',
            usedTools: <String>['search_medicine_leaflets'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'search_medicine_leaflets',
                coverageStatus: 'complete',
              ),
            ],
          ),
        ),
      );

      expect(find.byType(AssistantSourceStrip), findsOneWidget);
      expect(find.textContaining('参考来源:'), findsOneWidget);
      expect(find.textContaining('中文说明书检索'), findsOneWidget);
    });

    testWidgets('does not render source strip for user messages', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-user-source',
            role: AssistantMessageRole.user,
            content: 'User message',
            usedTools: <String>['search_medicine_leaflets'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(name: 'search_medicine_leaflets'),
            ],
          ),
        ),
      );

      expect(find.byType(AssistantSourceStrip), findsNothing);
    });

    testWidgets(
      'renders fixed disclaimer for assistant message without tools',
      (tester) async {
        await tester.pumpWidget(
          _shell(
            const AssistantMessageBubble(
              messageId: 'msg-disclaimer',
              role: AssistantMessageRole.assistant,
              content: 'Reply',
              usedTools: <String>[],
            ),
          ),
        );

        expect(find.byType(AssistantDisclaimerBar), findsOneWidget);
        expect(find.text(_disclaimerText), findsOneWidget);
      },
    );

    testWidgets('prefers tool disclaimer over the fixed text', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-disclaimer-tool',
            role: AssistantMessageRole.assistant,
            content: 'Reply',
            usedTools: <String>['search_medical_qa_corpus'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'search_medical_qa_corpus',
                disclaimer: '仅供参考，不构成诊疗建议。',
              ),
            ],
          ),
        ),
      );

      expect(find.text('仅供参考，不构成诊疗建议。'), findsOneWidget);
      expect(find.text(_disclaimerText), findsNothing);
    });

    testWidgets('does not render disclaimer for user messages', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-user-disclaimer',
            role: AssistantMessageRole.user,
            content: 'User message',
            usedTools: <String>[],
          ),
        ),
      );

      expect(find.byType(AssistantDisclaimerBar), findsNothing);
    });

    testWidgets('does not render disclaimer while streaming', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-streaming-disclaimer',
            role: AssistantMessageRole.assistant,
            content: 'Streaming',
            usedTools: <String>[],
            isStreaming: true,
          ),
        ),
      );

      expect(find.byType(AssistantDisclaimerBar), findsNothing);

      // Dispose the streaming bubble so the typing-indicator animation's
      // pending timer is cancelled before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });

  group('AssistantProposalCard', () {
    AssistantProposedAction proposal({
      required String id,
      required DateTime? expiresAt,
    }) {
      return AssistantProposedAction(
        id: id,
        type: AssistantProposedActionType.createDailyRecord,
        title: '保存这条记录',
        summary: '准备保存一条 water 记录。',
        reason: null,
        previewFields: const <AssistantProposalPreviewField>[],
        target: const AssistantProposalTarget(
          kind: 'daily_record_draft',
          label: 'water',
        ),
        constraints: const <String>[],
        expiresAt: expiresAt,
        payloadVersion: 1,
        payload: const AssistantCreateDailyRecordProposalPayload(
          draft: AssistantCreateDailyRecordDraft(
            kind: 'water',
            occurredAt: '2026-06-18',
            title: null,
            value: '300',
            unit: 'ml',
            note: null,
            payload: null,
          ),
        ),
      );
    }

    testWidgets(
      'expired proposal shows a regenerate button that forwards ids',
      (tester) async {
        final expired = proposal(
          id: 'proposal-expired',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        );
        String? capturedMessageId;
        String? capturedProposalId;

        await tester.pumpWidget(
          _shell(
            AssistantProposalCard(
              messageId: 'msg-1',
              proposal: expired,
              onConfirmProposal: null,
              onDismissProposal: null,
              onRegenerateProposal:
                  ({required messageId, required proposalId}) {
                    capturedMessageId = messageId;
                    capturedProposalId = proposalId;
                  },
            ),
          ),
        );

        final button = find.byKey(
          const Key('assistant-proposal-regenerate-proposal-expired'),
        );
        expect(button, findsOneWidget);
        expect(find.text('重新生成'), findsOneWidget);

        await tester.tap(button);
        await tester.pump(const Duration(milliseconds: 200));

        expect(capturedMessageId, 'msg-1');
        expect(capturedProposalId, 'proposal-expired');
      },
    );

    testWidgets('non-expired proposal does not show a regenerate button', (
      tester,
    ) async {
      final active = proposal(
        id: 'proposal-active',
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      await tester.pumpWidget(
        _shell(
          AssistantProposalCard(
            messageId: 'msg-2',
            proposal: active,
            onConfirmProposal: null,
            onDismissProposal: null,
            onRegenerateProposal:
                ({required messageId, required proposalId}) {},
          ),
        ),
      );

      expect(
        find.byKey(const Key('assistant-proposal-regenerate-proposal-active')),
        findsNothing,
      );
      expect(find.text('重新生成'), findsNothing);
    });
  });

  group('AssistantSourceStrip', () {
    testWidgets('renders nothing when usedTools is empty', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>[],
            toolDetails: <AssistantToolDetail>[],
          ),
        ),
      );

      expect(find.byKey(const Key('assistant-source-strip')), findsNothing);
      expect(find.textContaining('参考来源:'), findsNothing);
    });

    testWidgets('collapsed state lists localized tool names', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>[
              'search_medicine_leaflets',
              'resolve_drugbank_entity',
            ],
            toolDetails: <AssistantToolDetail>[],
          ),
        ),
      );

      expect(find.textContaining('参考来源:'), findsOneWidget);
      expect(find.textContaining('中文说明书检索'), findsOneWidget);
      expect(find.textContaining('DrugBank 实体定位'), findsOneWidget);
      expect(find.byKey(const Key('assistant-source-tool-')), findsNothing);
    });

    testWidgets('appends label to tool name when present', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['search_medicine_leaflets'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'search_medicine_leaflets',
                label: '布洛芬缓释胶囊',
              ),
            ],
          ),
        ),
      );

      expect(find.textContaining('参考来源: 中文说明书检索(布洛芬缓释胶囊)'), findsOneWidget);
    });

    testWidgets('expands to show envelope fields', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['search_medicine_leaflets'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'search_medicine_leaflets',
                label: '布洛芬缓释胶囊',
                coverageStatus: 'complete',
                coverageReason: null,
                confidenceLevel: 'high',
                confidenceReason: '向量检索命中',
                ambiguities: <String>['候选A', '候选B'],
                sourceTool: 'search_medicine_leaflets',
                sourceGeneratedAt: '2026-08-17T10:00:00.000Z',
                sourceTables: <String>['cn_medicine_leaflets'],
                disclaimer: '仅供参考，不构成诊疗建议。',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-source-strip')));
      await tester.pump();

      expect(find.textContaining('覆盖: 完整'), findsOneWidget);
      expect(find.textContaining('置信: 高 向量检索命中'), findsOneWidget);
      expect(find.textContaining('不确定项: 候选A, 候选B'), findsOneWidget);
      expect(find.textContaining('来源: cn_medicine_leaflets'), findsOneWidget);
      expect(find.textContaining('生成时间: '), findsOneWidget);
      expect(find.text('仅供参考，不构成诊疗建议。'), findsOneWidget);
    });

    testWidgets('shows placeholder when tool has no details', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['get_user_profile'],
            toolDetails: <AssistantToolDetail>[],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-source-strip')));
      await tester.pump();

      expect(find.text('该消息的工具详情暂不可用'), findsOneWidget);
    });

    testWidgets('shows badges for the three knowledge tiers', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>[
              'search_medicine_leaflets',
              'resolve_drugbank_entity',
              'search_medical_qa_corpus',
            ],
            toolDetails: <AssistantToolDetail>[],
          ),
        ),
      );

      expect(find.text('说明书'), findsOneWidget);
      expect(find.text('DrugBank'), findsOneWidget);
      expect(find.text('医疗问答'), findsOneWidget);
    });

    testWidgets('shows low-trust hint in collapsed state for medical QA tool', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['search_medical_qa_corpus'],
            toolDetails: <AssistantToolDetail>[],
          ),
        ),
      );

      expect(find.text('低可信教育参考'), findsOneWidget);
    });

    testWidgets('shows no badges or hint for non-knowledge tools', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['get_user_profile'],
            toolDetails: <AssistantToolDetail>[],
          ),
        ),
      );

      expect(find.text('说明书'), findsNothing);
      expect(find.text('DrugBank'), findsNothing);
      expect(find.text('医疗问答'), findsNothing);
      expect(find.text('低可信教育参考'), findsNothing);
    });
  });

  group('AssistantConversationDrawer', () {
    testWidgets('renders with empty state', (tester) async {
      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: const AssistantDrawerState(
              conversationId: null,
              isOpeningConversation: false,
              isLoadingRecentConversations: false,
              recentConversationError: null,
              recentConversations: [],
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );
      expect(find.text('No conversations'), findsOneWidget);
    });

    testWidgets('groups conversations and highlights current', (tester) async {
      final now = DateTime.now();
      final today = AssistantConversationSummary(
        id: 'today',
        title: 'Today chat',
        status: 'active',
        lastMessageAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final thisWeek = AssistantConversationSummary(
        id: 'this-week',
        title: 'This week chat',
        status: 'active',
        lastMessageAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      );
      final older = AssistantConversationSummary(
        id: 'older',
        title: 'Older chat',
        status: 'active',
        lastMessageAt: now.subtract(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      );

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantDrawerState(
              conversationId: 'today',
              isOpeningConversation: false,
              isLoadingRecentConversations: false,
              recentConversationError: null,
              recentConversations: [today, thisWeek, older],
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );

      expect(find.text('今天'), findsOneWidget);
      expect(find.text('最近 7 天'), findsOneWidget);
      expect(find.text('更早'), findsOneWidget);
      expect(find.text('当前'), findsOneWidget);
      expect(find.text('Today chat'), findsOneWidget);
      expect(find.text('This week chat'), findsOneWidget);
      expect(find.text('Older chat'), findsOneWidget);
    });

    testWidgets('new conversation button is shown when callback is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: const AssistantDrawerState(
              conversationId: null,
              isOpeningConversation: false,
              isLoadingRecentConversations: false,
              recentConversationError: null,
              recentConversations: [],
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
            onNewConversation: () {},
          ),
        ),
      );
      expect(
        find.byKey(const Key('assistant-sidebar-new-conversation')),
        findsOneWidget,
      );
    });

    testWidgets('filters conversations by title in the drawer search', (
      tester,
    ) async {
      final now = DateTime.now();
      final conversations = <AssistantConversationSummary>[
        AssistantConversationSummary(
          id: 'today',
          title: 'Today chat',
          status: 'active',
          lastMessageAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        AssistantConversationSummary(
          id: 'this-week',
          title: 'This week chat',
          status: 'active',
          lastMessageAt: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        AssistantConversationSummary(
          id: 'older',
          title: 'Older chat',
          status: 'active',
          lastMessageAt: now.subtract(const Duration(days: 8)),
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
      ];

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantDrawerState(
              conversationId: null,
              isOpeningConversation: false,
              isLoadingRecentConversations: false,
              recentConversationError: null,
              recentConversations: conversations,
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('assistant-conversation-search')),
        'Older',
      );
      await tester.pump();

      expect(find.text('Older chat'), findsOneWidget);
      expect(find.text('Today chat'), findsNothing);
      expect(find.text('This week chat'), findsNothing);
      expect(find.text('今天'), findsNothing);
      expect(find.text('最近 7 天'), findsNothing);
    });

    testWidgets('shows an empty state when the search has no matches', (
      tester,
    ) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantDrawerState(
              conversationId: null,
              isOpeningConversation: false,
              isLoadingRecentConversations: false,
              recentConversationError: null,
              recentConversations: [
                AssistantConversationSummary(
                  id: 'today',
                  title: 'Today chat',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ],
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('assistant-conversation-search')),
        'missing',
      );
      await tester.pump();

      expect(find.text('No matching chats'), findsOneWidget);
      expect(find.text('Today chat'), findsNothing);
    });
  });

  group('Assistant state message', () {
    testWidgets('renders title and description with maxWidth', (tester) async {
      await tester.pumpWidget(
        _shell(
          const StateMessageView(
            maxWidth: 560,
            title: 'Ready',
            description: 'Assistant is active',
            icon: SemanticIcons.statusDone,
          ),
        ),
      );
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Assistant is active'), findsOneWidget);
    });

    testWidgets('renders action button', (tester) async {
      await tester.pumpWidget(
        _shell(
          StateMessageView(
            maxWidth: 560,
            title: 'Error',
            description: 'Something went wrong',
            icon: SemanticIcons.statusError,
            actionLabel: 'Retry',
            onAction: () {},
            tone: StateTone.danger,
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
