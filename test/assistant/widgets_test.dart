import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/capabilities_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_state.dart';
import 'package:luminous/features/assistant/presentation/widgets/disclaimer_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/chips.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
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

    testWidgets('long-press menu offers rename and delete and forwards ids', (
      tester,
    ) async {
      final now = DateTime.now();
      String? renamedId;
      String? deletedId;

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
                  id: 'conv-1',
                  title: 'Sleep chat',
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
            onRename: (id) => renamedId = id,
            onDelete: (id) => deletedId = id,
          ),
        ),
      );

      await tester.longPress(
        find.byKey(const Key('assistant-recent-conversation-conv-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('重命名'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('assistant-conversation-rename-conv-1')),
      );
      expect(renamedId, 'conv-1');

      await tester.longPress(
        find.byKey(const Key('assistant-recent-conversation-conv-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('assistant-conversation-delete-conv-1')),
      );
      expect(deletedId, 'conv-1');

      // Flush the Forui tappable hold timer so no timer is left pending.
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('untitled conversations show tap-to-name and route to rename', (
      tester,
    ) async {
      final now = DateTime.now();
      String? renamedId;

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
                  id: 'conv-untitled',
                  title: null,
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
            onRename: (id) => renamedId = id,
            onDelete: (_) {},
          ),
        ),
      );

      expect(find.text('点击补名'), findsOneWidget);
      expect(find.text('未命名会话'), findsNothing);

      await tester.tap(find.text('点击补名'));
      expect(renamedId, 'conv-untitled');

      // Flush the Forui tappable hold timer so no timer is left pending.
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('current conversation shows archiving label while clearing', (
      tester,
    ) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantDrawerState(
              conversationId: 'conv-1',
              isOpeningConversation: false,
              isClearingConversation: true,
              isLoadingRecentConversations: false,
              recentConversationError: null,
              recentConversations: [
                AssistantConversationSummary(
                  id: 'conv-1',
                  title: 'Sleep chat',
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

      expect(find.text('归档中…'), findsOneWidget);
      expect(find.text('当前'), findsNothing);
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

  group('AssistantSourceStrip data-as-of (F-14)', () {
    testWidgets('shows the data-as-of row from confidenceNote', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['get_today_summary_by_date'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'get_today_summary_by_date',
                confidenceNote: '截至 2026-08-17',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-source-strip')));
      await tester.pump();

      expect(find.textContaining('数据截至: 截至 2026-08-17'), findsOneWidget);
    });

    testWidgets('falls back to the source version when no note exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['get_today_summary_by_date'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'get_today_summary_by_date',
                sourceVersion: '7',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-source-strip')));
      await tester.pump();

      expect(find.textContaining('数据截至: 版本 7'), findsOneWidget);
    });

    testWidgets('prefers confidenceNote over sourceVersion', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['get_today_summary_by_date'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(
                name: 'get_today_summary_by_date',
                confidenceNote: '基于持久化摘要',
                sourceVersion: '3',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-source-strip')));
      await tester.pump();

      expect(find.textContaining('数据截至: 基于持久化摘要'), findsOneWidget);
      expect(find.textContaining('数据截至: 版本'), findsNothing);
    });

    testWidgets('hides the row when neither field exists', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantSourceStrip(
            usedTools: <String>['get_today_summary_by_date'],
            toolDetails: <AssistantToolDetail>[
              AssistantToolDetail(name: 'get_today_summary_by_date'),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('assistant-source-strip')));
      await tester.pump();

      expect(find.textContaining('数据截至'), findsNothing);
    });
  });

  group('AssistantCapabilitiesPanel (F-10)', () {
    const capabilities = AssistantCapabilities(
      phase: 'production',
      assistantEnabled: true,
      assistantMemoryEnabled: false,
      assistantContext: AssistantContextAccess(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      chatModelConfigured: true,
      interactiveChatReady: true,
      langGraphReady: true,
      streamingSupported: true,
      streamingTransport: 'sse',
      markdownRenderingRecommended: true,
      ragEnabled: true,
      tools: <AssistantToolCapability>[
        AssistantToolCapability(
          id: 'get_today_records',
          requiredContextSources: <String>[],
          permittedByUser: true,
          enabled: true,
          implemented: true,
          disabledReason: null,
        ),
        AssistantToolCapability(
          id: 'get_user_profile',
          requiredContextSources: <String>['health_profile'],
          permittedByUser: false,
          enabled: false,
          implemented: true,
          disabledReason: 'context_disabled',
        ),
        AssistantToolCapability(
          id: 'search_drugbank_passages',
          requiredContextSources: <String>[],
          permittedByUser: true,
          enabled: false,
          implemented: false,
          disabledReason: 'not_implemented',
        ),
        AssistantToolCapability(
          id: 'propose_update_daily_record',
          requiredContextSources: <String>['daily_records'],
          permittedByUser: true,
          enabled: false,
          implemented: true,
          disabledReason: 'some_future_reason',
        ),
      ],
      updatedAt: null,
    );

    testWidgets('renders summary rows and tool statuses', (tester) async {
      await tester.pumpWidget(
        _shell(
          const SizedBox(
            height: 800,
            child: AssistantCapabilitiesPanel(capabilities: capabilities),
          ),
        ),
      );

      // 摘要区:AI 对话与 RAG 已启用,持久化记忆已关闭。
      expect(find.text('能力详情'), findsOneWidget);
      expect(find.text('能力摘要'), findsOneWidget);
      expect(find.text('启用 AI 对话'), findsOneWidget);
      expect(find.text('启用持久化记忆'), findsOneWidget);
      expect(find.text('RAG 检索'), findsOneWidget);
      expect(find.text('已启用'), findsNWidgets(2));
      expect(find.text('已关闭'), findsOneWidget);

      // 工具行:enabled → 可用;disabled → disabledReason 翻译。
      expect(
        find.byKey(const Key('assistant-capability-tool-get_today_records')),
        findsOneWidget,
      );
      expect(find.text('可用'), findsOneWidget);
      expect(find.text('未开放所需健康上下文'), findsOneWidget);
      expect(find.text('尚未实现'), findsOneWidget);
      // 未知 disabledReason 显示原文,不硬造。
      expect(find.text('some_future_reason'), findsOneWidget);
      // 计数 1 / 4。
      expect(find.text('1 / 4'), findsOneWidget);
    });

    testWidgets('renders empty tools list gracefully', (tester) async {
      await tester.pumpWidget(
        _shell(
          const SizedBox(
            height: 800,
            child: AssistantCapabilitiesPanel(
              capabilities: AssistantCapabilities(
                phase: 'production',
                assistantEnabled: true,
                assistantMemoryEnabled: true,
                assistantContext: AssistantContextAccess(
                  healthProfile: true,
                  dailyRecords: true,
                  sleepRecords: true,
                  currentMedicines: true,
                ),
                chatModelConfigured: true,
                interactiveChatReady: true,
                langGraphReady: true,
                streamingSupported: true,
                streamingTransport: 'sse',
                markdownRenderingRecommended: true,
                ragEnabled: true,
                tools: <AssistantToolCapability>[],
                updatedAt: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('0 / 0'), findsOneWidget);
    });
  });
}
