import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';
import 'package:luminous/features/assistant/presentation/widgets/disclaimer_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/flowui_adapter.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/proposal_card.dart';
import 'package:luminous/features/assistant/presentation/widgets/source_strip.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_message_list.dart';

import '../helpers/test_forui_app.dart';

void main() {
  group('AssistantFlowUiAdapter mapping', () {
    test('creates stable Flow ids without changing AssistantMessage', () {
      final message = _message(content: 'same message');
      const adapter = AssistantFlowUiAdapter();

      final first = adapter.mapMessage(
        message,
        conversationId: 'conversation-1',
        index: 2,
      );
      final second = adapter.mapMessage(
        message,
        conversationId: 'conversation-1',
        index: 2,
      );
      final changedIdentity = adapter.mapMessage(
        message,
        conversationId: 'conversation-1',
        index: 3,
      );
      final changedCanonicalMessage = adapter.mapMessage(
        message.copyWith(content: 'changed message'),
        conversationId: 'conversation-1',
        index: 2,
      );

      expect(first.id, second.id);
      expect(first.id, 'conversation-1:2:${messageIdFor(message)}');
      expect(changedIdentity.id, isNot(first.id));
      expect(changedCanonicalMessage.id, isNot(first.id));
      expect(message.content, 'same message');
    });

    test('maps completed, user, and streaming parts to their Flow types', () {
      const adapter = AssistantFlowUiAdapter();
      final assistant = adapter.mapMessage(
        _message(content: '**answer**'),
        conversationId: 'conversation-1',
        index: 0,
      );
      final user = adapter.mapMessage(
        _message(role: AssistantMessageRole.user, content: 'question'),
        conversationId: 'conversation-1',
        index: 1,
      );
      final streaming = adapter.mapStreamingDraft('partial answer');

      final markdown = assistant.parts.single as FlowCustomPart;
      expect(markdown.type, 'markdown');
      expect((markdown.data! as AssistantMarkdownPart).content, '**answer**');
      expect(user.parts.single, isA<FlowTextPart>());
      expect((user.parts.single as FlowTextPart).text, 'question');
      expect(streaming.status, FlowMessageStatus.streaming);
      expect(streaming.parts.single, isA<FlowTextPart>());
      expect((streaming.parts.single as FlowTextPart).text, 'partial answer');
    });

    test(
      'maps an empty streaming draft to a pending message with no parts',
      () {
        const adapter = AssistantFlowUiAdapter();
        final pending = adapter.mapStreamingDraft('');

        expect(pending.parts, isEmpty);
        expect(pending.status, FlowMessageStatus.pending);
      },
    );

    test('mapMessages explicitly maps pending and streaming send states', () {
      const adapter = AssistantFlowUiAdapter();

      final pending = adapter
          .mapMessages(
            conversationId: 'conversation-1',
            messages: const <AssistantMessage>[],
            isSending: true,
            pending: true,
          )
          .single;
      final streaming = adapter
          .mapMessages(
            conversationId: 'conversation-1',
            messages: const <AssistantMessage>[],
            streamingDraft: 'partial answer',
            isSending: true,
            pending: false,
          )
          .single;

      expect(pending.parts, isEmpty);
      expect(pending.status, FlowMessageStatus.pending);
      expect(streaming.parts.single, isA<FlowTextPart>());
      expect((streaming.parts.single as FlowTextPart).text, 'partial answer');
      expect(streaming.status, FlowMessageStatus.streaming);
    });

    test('visible proposal part carries the canonical message id', () {
      final message = _message(
        content: 'proposal answer',
        proposedActions: <AssistantProposedAction>[_proposal(id: 'proposal-1')],
      );
      const adapter = AssistantFlowUiAdapter();
      final mapped = adapter.mapMessage(
        message,
        conversationId: 'conversation-1',
        index: 0,
      );

      final proposalPart = mapped.parts.whereType<FlowCustomPart>().singleWhere(
        (part) => part.type == 'proposal',
      );
      final data = proposalPart.data! as AssistantProposalPart;

      expect(data.messageId, messageIdFor(message));
      expect(data.proposal.id, 'proposal-1');
    });
  });

  testWidgets('proposal custom builder renders the card and forwards confirm', (
    tester,
  ) async {
    String? confirmedMessageId;
    String? confirmedProposalId;
    final message = _message(
      content: 'proposal answer',
      proposedActions: <AssistantProposedAction>[_proposal(id: 'proposal-1')],
    );
    final adapter = AssistantFlowUiAdapter(
      onConfirmProposal: ({required messageId, required proposalId}) async {
        confirmedMessageId = messageId;
        confirmedProposalId = proposalId;
      },
      onDismissProposal: ({required messageId, required proposalId}) {},
    );

    await tester.pumpWidget(
      TestForuiApp(
        home: SizedBox(
          height: 600,
          child: FlowThread(
            messages: [
              adapter.mapMessage(
                message,
                conversationId: 'conversation-1',
                index: 0,
              ),
            ],
            messageBuilder: adapter.buildMessage,
          ),
        ),
      ),
    );

    expect(find.byType(AssistantProposalCard), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('assistant-proposal-confirm-proposal-1')),
    );
    await tester.pump();

    expect(confirmedMessageId, messageIdFor(message));
    expect(confirmedProposalId, 'proposal-1');

    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('pending FlowMessage renders thinking without message actions', (
    tester,
  ) async {
    const adapter = AssistantFlowUiAdapter(thinkingLabel: '思考中…');
    final pending = adapter.mapStreamingDraft('');

    await tester.pumpWidget(
      TestForuiApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SizedBox(
            height: 200,
            child: Builder(
              builder: (context) => adapter.buildMessage(context, pending),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(FlowThinkingIndicator), findsOneWidget);
    expect(find.text('思考中…'), findsOneWidget);
    expect(find.byType(FlowMessageActions), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('streaming FlowMessage keeps animated text without actions', (
    tester,
  ) async {
    const adapter = AssistantFlowUiAdapter();
    final streaming = adapter.mapStreamingDraft('partial answer');

    await tester.pumpWidget(
      TestForuiApp(
        home: SizedBox(
          height: 200,
          child: Builder(
            builder: (context) => adapter.buildMessage(context, streaming),
          ),
        ),
      ),
    );

    expect(find.byType(FlowStreamingText), findsOneWidget);
    expect(find.byType(FlowMessageActions), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'sending with empty draft renders localized thinking without empty state',
    (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        TestForuiApp(
          home: SizedBox(
            height: 300,
            child: ProviderScope(
              overrides: [
                assistantControllerProvider.overrideWith(
                  () => _TestAssistantController(
                    const AssistantState(
                      conversationId: 'conversation-1',
                      capabilities: _capabilities,
                      isSending: true,
                    ),
                  ),
                ),
              ],
              child: AssistantConversationMessageList(
                capabilities: _capabilities,
                scrollController: scrollController,
                onConfirmProposal:
                    ({required messageId, required proposalId}) async {},
                onDismissProposal:
                    ({required messageId, required proposalId}) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FlowThread), findsOneWidget);
      expect(find.byType(FlowThinkingIndicator), findsOneWidget);
      expect(find.text('思考中…'), findsOneWidget);
      expect(find.byType(StateMessageView), findsNothing);
      expect(find.byType(FlowMessageActions), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'sending with empty draft keeps thinking when capability is disabled but history exists',
    (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      final capabilities = _capabilitiesWithAssistantEnabled(false);

      await tester.pumpWidget(
        TestForuiApp(
          home: SizedBox(
            height: 400,
            child: ProviderScope(
              overrides: [
                assistantControllerProvider.overrideWith(
                  () => _TestAssistantController(
                    AssistantState(
                      conversationId: 'conversation-1',
                      capabilities: capabilities,
                      isSending: true,
                      messages: <AssistantMessage>[
                        _message(content: 'previous answer'),
                      ],
                    ),
                  ),
                ),
              ],
              child: AssistantConversationMessageList(
                capabilities: capabilities,
                scrollController: scrollController,
                onConfirmProposal:
                    ({required messageId, required proposalId}) async {},
                onDismissProposal:
                    ({required messageId, required proposalId}) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FlowThinkingIndicator), findsOneWidget);
      expect(find.byType(StateMessageView), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'streaming draft in the real message list has no streaming actions',
    (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        TestForuiApp(
          home: SizedBox(
            height: 400,
            child: ProviderScope(
              overrides: [
                assistantControllerProvider.overrideWith(
                  () => _TestAssistantController(
                    AssistantState(
                      conversationId: 'conversation-1',
                      capabilities: _capabilities,
                      isSending: true,
                      streamingDraft: 'partial answer',
                      messages: <AssistantMessage>[
                        _message(content: 'previous answer'),
                      ],
                    ),
                  ),
                ),
              ],
              child: AssistantConversationMessageList(
                capabilities: _capabilities,
                scrollController: scrollController,
                onConfirmProposal:
                    ({required messageId, required proposalId}) async {},
                onDismissProposal:
                    ({required messageId, required proposalId}) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final streamingMessage = find.byWidgetPredicate(
        (widget) =>
            widget is FlowMessage &&
            widget.message.status == FlowMessageStatus.streaming,
      );
      expect(find.byType(FlowStreamingText), findsOneWidget);
      expect(
        find.descendant(
          of: streamingMessage,
          matching: find.byType(FlowMessageActions),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('production message list renders through FlowThread', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      TestForuiApp(
        home: ProviderScope(
          overrides: [
            assistantControllerProvider.overrideWith(
              () => _TestAssistantController(
                AssistantState(
                  conversationId: 'conversation-1',
                  capabilities: _capabilities,
                  messages: <AssistantMessage>[
                    _message(
                      content: '**assistant reply**',
                      usedTools: const <String>['search_medicine_leaflets'],
                      replaced: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: AssistantConversationMessageList(
            capabilities: _capabilities,
            scrollController: scrollController,
            onConfirmProposal:
                ({required messageId, required proposalId}) async {},
            onDismissProposal: ({required messageId, required proposalId}) {},
          ),
        ),
      ),
    );

    expect(find.byType(FlowThread), findsOneWidget);
    expect(find.byType(FlowMessage), findsOneWidget);
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.byType(AssistantSourceStrip), findsOneWidget);
    expect(find.byType(AssistantDisclaimerBar), findsOneWidget);
    expect(find.byKey(const Key('assistant-replaced-label')), findsOneWidget);
  });

  testWidgets(
    'message actions preserve copy, regenerate, and resend callbacks',
    (tester) async {
      var regenerateCalls = 0;
      String? resentContent;
      String clipboardText = '';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText =
                (call.arguments as Map<Object?, Object?>)['text']?.toString() ??
                '';
          }
          if (call.method == 'Clipboard.getData') {
            return <String, String>{'text': clipboardText};
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final adapter = AssistantFlowUiAdapter(
        onRegenerate: () => regenerateCalls++,
        onResend: (content) => resentContent = content,
      );

      await tester.pumpWidget(
        TestForuiApp(
          showToaster: true,
          home: FAccessibilityScope(
            data: const FAccessibility(
              accessibleNavigation: true,
              motion: FAccessibilityMotion.all,
              focusHighlight: false,
            ),
            child: FToaster(
              child: SizedBox(
                height: 600,
                child: FlowThread(
                  messages: [
                    adapter.mapMessage(
                      _message(content: 'assistant'),
                      conversationId: 'conversation-1',
                      index: 0,
                    ),
                    adapter.mapMessage(
                      _message(
                        role: AssistantMessageRole.user,
                        content: 'resend me',
                      ),
                      conversationId: 'conversation-1',
                      index: 1,
                    ),
                  ],
                  messageBuilder: adapter.buildMessage,
                ),
              ),
            ),
          ),
        ),
      );

      final actionRows = tester
          .widgetList<FlowMessageActions>(find.byType(FlowMessageActions))
          .toList();
      expect(actionRows, hasLength(2));
      expect(actionRows[0].actions.first.onPressed, isNotNull);
      actionRows[1].actions.first.onPressed!.call();
      await tester.pump();
      expect((await Clipboard.getData('text/plain'))?.text, 'assistant');
      actionRows[0].actions[1].onPressed!.call();
      actionRows[1].actions[1].onPressed!.call();

      expect(regenerateCalls, 1);
      expect(resentContent, 'resend me');

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('markdown links require confirmation and only open http(s)', (
    tester,
  ) async {
    final opened = <Uri>[];
    final adapter = AssistantFlowUiAdapter(
      onOpenLink: (uri) async {
        opened.add(uri);
        return true;
      },
    );

    await tester.pumpWidget(
      TestForuiApp(
        home: SizedBox(
          height: 300,
          child: FlowThread(
            messages: [
              adapter.mapMessage(
                _message(content: '[资料](https://example.com/doc)'),
                conversationId: 'conversation-1',
                index: 0,
              ),
            ],
            messageBuilder: adapter.buildMessage,
          ),
        ),
      ),
    );

    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    markdown.onTapLink!('资料', 'https://example.com/doc', '');
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.text('打开外部链接？'), findsOneWidget);
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(opened, <Uri>[Uri.parse('https://example.com/doc')]);

    final inertAdapter = AssistantFlowUiAdapter(
      onOpenLink: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    await tester.pumpWidget(
      TestForuiApp(
        home: SizedBox(
          height: 300,
          child: FlowThread(
            messages: [
              inertAdapter.mapMessage(
                _message(content: '[邮件](mailto:test@example.com)'),
                conversationId: 'conversation-1',
                index: 0,
              ),
            ],
            messageBuilder: inertAdapter.buildMessage,
          ),
        ),
      ),
    );
    final inertMarkdown = tester.widget<MarkdownBody>(
      find.byType(MarkdownBody),
    );
    inertMarkdown.onTapLink!('邮件', 'mailto:test@example.com', '');
    await tester.pumpAndSettle();

    expect(find.text('打开外部链接？'), findsNothing);
    expect(opened, <Uri>[Uri.parse('https://example.com/doc')]);
  });
}

AssistantMessage _message({
  AssistantMessageRole role = AssistantMessageRole.assistant,
  required String content,
  List<String> usedTools = const <String>[],
  List<AssistantToolDetail> toolDetails = const <AssistantToolDetail>[],
  List<AssistantProposedAction> proposedActions =
      const <AssistantProposedAction>[],
  bool replaced = false,
}) {
  return AssistantMessage(
    role: role,
    content: content,
    createdAt: DateTime(2026, 8, 21, 12, 30),
    usedTools: usedTools,
    toolDetails: toolDetails,
    proposedActions: proposedActions,
    replaced: replaced,
  );
}

AssistantProposedAction _proposal({required String id}) {
  return AssistantProposedAction(
    id: id,
    type: AssistantProposedActionType.createDailyRecord,
    title: '保存这条记录',
    summary: '准备保存一条记录。',
    reason: null,
    previewFields: const <AssistantProposalPreviewField>[],
    target: const AssistantProposalTarget(kind: 'daily_record', label: '记录'),
    constraints: const <String>[],
    expiresAt: null,
    payloadVersion: 1,
    payload: const AssistantCreateDailyRecordProposalPayload(
      draft: AssistantCreateDailyRecordDraft(
        kind: 'water',
        occurredAt: '2026-08-21',
        title: null,
        value: '300',
        unit: 'ml',
        note: null,
        payload: null,
      ),
    ),
  );
}

const _capabilities = AssistantCapabilities(
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
  tools: <AssistantToolCapability>[],
  updatedAt: null,
);

AssistantCapabilities _capabilitiesWithAssistantEnabled(bool enabled) {
  return AssistantCapabilities(
    phase: _capabilities.phase,
    assistantEnabled: enabled,
    assistantMemoryEnabled: _capabilities.assistantMemoryEnabled,
    assistantContext: _capabilities.assistantContext,
    chatModelConfigured: _capabilities.chatModelConfigured,
    interactiveChatReady: _capabilities.interactiveChatReady,
    langGraphReady: _capabilities.langGraphReady,
    streamingSupported: _capabilities.streamingSupported,
    streamingTransport: _capabilities.streamingTransport,
    markdownRenderingRecommended: _capabilities.markdownRenderingRecommended,
    ragEnabled: _capabilities.ragEnabled,
    tools: _capabilities.tools,
    updatedAt: _capabilities.updatedAt,
  );
}

class _TestAssistantController extends AssistantController {
  _TestAssistantController(this.initialState);

  final AssistantState initialState;

  @override
  AssistantState build() => initialState;
}
