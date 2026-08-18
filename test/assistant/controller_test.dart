import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';

/// A fake repository with canned responses.
class _FakeAssistantRepository implements AssistantRepository {
  _FakeAssistantRepository({this.latestConversation, this.streamOverride});

  AssistantConversation? latestConversation;
  final Stream<AssistantGenerationEvent>? streamOverride;

  /// Conversations returned by [listRecentConversations].
  List<AssistantConversationSummary> recentList =
      const <AssistantConversationSummary>[];

  /// When set, [clearLatestConversation] waits on it (used to observe the
  /// in-flight clearing state).
  Completer<bool>? clearGate;

  /// When set, [clearLatestConversation] throws after the gate (if any).
  bool throwOnClear = false;

  final List<({String conversationId, String title})> renameCalls =
      <({String conversationId, String title})>[];
  final List<String> deleteCalls = <String>[];
  bool throwOnRename = false;
  bool throwOnDelete = false;

  String? lastStreamConversationId;
  List<AssistantMessage>? lastStreamMessages;
  int streamMessagesCallCount = 0;

  final List<
    ({String conversationId, List<String> proposalIds, String decision})
  >
  confirmCalls =
      <({String conversationId, List<String> proposalIds, String decision})>[];
  String? confirmResult;
  bool throwOnConfirm = false;

  @override
  Future<AssistantCapabilities> getCapabilities() async {
    return AssistantCapabilities(
      phase: 'production',
      assistantEnabled: true,
      assistantMemoryEnabled: true,
      assistantContext: const AssistantContextAccess(
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
      tools: const <AssistantToolCapability>[],
      updatedAt: DateTime(2026, 6, 10),
    );
  }

  @override
  Future<AssistantConversation?> getLatestConversation() async {
    return latestConversation;
  }

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    return recentList;
  }

  @override
  Future<AssistantConversation> openConversation(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async {
    final gate = clearGate;
    if (gate != null) {
      await gate.future;
    }
    if (throwOnClear) {
      throw Exception('clear failed');
    }
    return true;
  }

  @override
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    renameCalls.add((conversationId: conversationId, title: title));
    if (throwOnRename) {
      throw Exception('rename failed');
    }
    // Mirror the backend: the persisted title changes, so the refreshed list
    // returns the new title.
    recentList = [
      for (final item in recentList)
        item.id == conversationId ? _summaryWithTitle(item, title) : item,
    ];
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    deleteCalls.add(conversationId);
    if (throwOnDelete) {
      throw Exception('delete failed');
    }
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    streamMessagesCallCount++;
    lastStreamConversationId = conversationId;
    lastStreamMessages = List<AssistantMessage>.of(messages);
    return streamOverride ?? const Stream.empty();
  }

  @override
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) async {
    confirmCalls.add((
      conversationId: conversationId,
      proposalIds: proposalIds,
      decision: decision,
    ));
    if (throwOnConfirm) {
      throw Exception('confirm failed');
    }
    return confirmResult;
  }
}

AssistantProposedAction _createDailyRecordProposal({
  required String id,
  DateTime? expiresAt,
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
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 15)),
    payloadVersion: 1,
    payload: const AssistantCreateDailyRecordProposalPayload(
      draft: AssistantCreateDailyRecordDraft(
        kind: 'water',
        occurredAt: '2026-08-17',
        title: null,
        value: '300',
        unit: 'ml',
        note: null,
        payload: null,
      ),
    ),
  );
}

AssistantProposedAction _updateUserSettingsProposal({required String id}) {
  return AssistantProposedAction(
    id: id,
    type: AssistantProposedActionType.updateUserSettings,
    title: '更新助手相关设置',
    summary: '关闭持久化记忆。',
    reason: null,
    previewFields: const <AssistantProposalPreviewField>[],
    target: const AssistantProposalTarget(
      kind: 'user_settings',
      label: '助手设置',
      settingKeys: <String>['assistantMemoryEnabled'],
    ),
    constraints: const <String>[],
    expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    payloadVersion: 1,
    payload: const AssistantUpdateUserSettingsProposalPayload(
      draft: AssistantUpdateUserSettingsDraft(assistantMemoryEnabled: false),
    ),
  );
}

/// Returns a copy of [summary] with its title replaced.
AssistantConversationSummary _summaryWithTitle(
  AssistantConversationSummary summary,
  String? title,
) {
  return AssistantConversationSummary(
    id: summary.id,
    title: title,
    status: summary.status,
    lastMessageAt: summary.lastMessageAt,
    createdAt: summary.createdAt,
    updatedAt: summary.updatedAt,
  );
}

AssistantConversation _conversationWith({
  required String id,
  required List<AssistantMessage> messages,
}) {
  return AssistantConversation(
    id: id,
    title: null,
    status: 'active',
    messages: messages,
    lastMessageAt: null,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 6, 1),
  );
}

AssistantMessage _assistantMessage({
  required String content,
  List<AssistantProposedAction> proposedActions =
      const <AssistantProposedAction>[],
}) {
  return AssistantMessage(
    role: AssistantMessageRole.assistant,
    content: content,
    createdAt: DateTime(2026, 6, 1, 12),
    proposedActions: proposedActions,
  );
}

ProviderContainer _buildContainer(_FakeAssistantRepository repository) {
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
      assistantRepositoryProvider.overrideWithValue(repository),
    ],
  );
  return container;
}

void main() {
  group('AssistantController', () {
    test('build returns loading state when authenticated', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isTrue);
    });

    test('loadCapabilities populates capabilities on success', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isFalse);
      expect(state.capabilities, isNotNull);
      expect(state.capabilities!.chatModelConfigured, isTrue);
    });

    test('loadCapabilities handles error gracefully', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            _ErrorThrowingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isFalse);
      expect(state.capabilityError, isNotNull);
    });

    test('sendMessage forwards the persisted conversation id', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final fake = _FakeAssistantRepository(
        latestConversation: AssistantConversation(
          id: 'persisted-1',
          title: null,
          status: 'active',
          messages: const <AssistantMessage>[],
          lastMessageAt: null,
          createdAt: DateTime(2026, 6, 1),
          updatedAt: DateTime(2026, 6, 1),
        ),
        streamOverride: Stream.fromIterable([
          AssistantGenerationResultEvent(
            conversationId: 'persisted-1',
            message: AssistantMessage(
              role: AssistantMessageRole.assistant,
              content: 'ok',
              createdAt: DateTime(2026, 6, 1),
            ),
          ),
        ]),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadLatestConversation();
      await controller.sendMessage('hello');

      expect(fake.lastStreamConversationId, 'persisted-1');
    });

    test(
      'confirmProposedAction confirms on the backend and emits dailyRecords',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final proposal = _createDailyRecordProposal(id: 'proposal-1');
        final assistantMessage = _assistantMessage(
          content: '建议：记录喝水。',
          proposedActions: <AssistantProposedAction>[proposal],
        );
        final fake = _FakeAssistantRepository(
          latestConversation: _conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[
              AssistantMessage(
                role: AssistantMessageRole.user,
                content: '帮我记一杯水',
                createdAt: DateTime(2026, 6, 1, 11),
              ),
              assistantMessage,
            ],
          ),
        );
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final state = container.read(assistantControllerProvider);
        await controller.confirmProposedAction(
          messageId: controller.messageIdOf(state.messages.last),
          proposalId: 'proposal-1',
        );

        expect(fake.confirmCalls.single.conversationId, 'persisted-1');
        expect(fake.confirmCalls.single.proposalIds, <String>['proposal-1']);
        expect(fake.confirmCalls.single.decision, 'approved');

        final updated = container.read(assistantControllerProvider);
        final updatedProposal = updated.messages
            .expand((message) => message.proposedActions)
            .singleWhere((proposal) => proposal.id == 'proposal-1');
        expect(
          updatedProposal.executionState,
          AssistantProposalExecutionState.confirmed,
        );

        final bus = container.read(dataChangeBusProvider);
        expect(bus[DataChangeTopic.dailyRecords], 1);
        expect(bus[DataChangeTopic.userSettings], isNull);
      },
    );

    test(
      'confirmProposedAction emits userSettings for settings proposals',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final proposal = _updateUserSettingsProposal(id: 'proposal-settings-1');
        final assistantMessage = _assistantMessage(
          content: '建议：关闭记忆。',
          proposedActions: <AssistantProposedAction>[proposal],
        );
        final fake = _FakeAssistantRepository(
          latestConversation: _conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[
              AssistantMessage(
                role: AssistantMessageRole.user,
                content: '关闭记忆',
                createdAt: DateTime(2026, 6, 1, 11),
              ),
              assistantMessage,
            ],
          ),
        );
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final state = container.read(assistantControllerProvider);
        await controller.confirmProposedAction(
          messageId: controller.messageIdOf(state.messages.last),
          proposalId: 'proposal-settings-1',
        );

        expect(fake.confirmCalls.single.decision, 'approved');
        final bus = container.read(dataChangeBusProvider);
        expect(bus[DataChangeTopic.userSettings], 1);
        expect(bus[DataChangeTopic.dailyRecords], isNull);
      },
    );

    test(
      'confirmProposedAction marks the proposal failed and rethrows',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final proposal = _createDailyRecordProposal(id: 'proposal-1');
        final assistantMessage = _assistantMessage(
          content: '建议：记录喝水。',
          proposedActions: <AssistantProposedAction>[proposal],
        );
        final fake = _FakeAssistantRepository(
          latestConversation: _conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[assistantMessage],
          ),
        )..throwOnConfirm = true;
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final state = container.read(assistantControllerProvider);
        await expectLater(
          controller.confirmProposedAction(
            messageId: controller.messageIdOf(state.messages.last),
            proposalId: 'proposal-1',
          ),
          throwsA(isA<Exception>()),
        );

        final updated = container.read(assistantControllerProvider);
        final updatedProposal = updated.messages
            .expand((message) => message.proposedActions)
            .singleWhere((proposal) => proposal.id == 'proposal-1');
        expect(
          updatedProposal.executionState,
          AssistantProposalExecutionState.failed,
        );
        expect(updatedProposal.executionError, isNotNull);
      },
    );

    test(
      'confirmProposedAction throws without a persisted conversation',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final fake = _FakeAssistantRepository(
          streamOverride: Stream<AssistantGenerationEvent>.fromIterable([
            AssistantGenerationResultEvent(
              conversationId: '',
              message: _assistantMessage(
                content: '建议：记录喝水。',
                proposedActions: <AssistantProposedAction>[
                  _createDailyRecordProposal(id: 'proposal-1'),
                ],
              ),
            ),
          ]),
        );
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();
        await controller.sendMessage('帮我记一杯水');

        final state = container.read(assistantControllerProvider);
        expect(state.conversationId, isNull);

        await expectLater(
          controller.confirmProposedAction(
            messageId: controller.messageIdOf(state.messages.last),
            proposalId: 'proposal-1',
          ),
          throwsA(isA<StateError>()),
        );
        expect(fake.confirmCalls, isEmpty);
      },
    );

    test(
      'regenerateExpiredProposal resends the preceding user message',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final userMessage = AssistantMessage(
          role: AssistantMessageRole.user,
          content: '帮我记一杯水',
          createdAt: DateTime(2026, 6, 1, 11),
        );
        final assistantMessage = _assistantMessage(
          content: '建议已过期。',
          proposedActions: <AssistantProposedAction>[
            _createDailyRecordProposal(
              id: 'proposal-expired',
              expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
        );
        final fake = _FakeAssistantRepository(
          latestConversation: _conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[userMessage, assistantMessage],
          ),
          streamOverride: Stream<AssistantGenerationEvent>.fromIterable([
            AssistantGenerationResultEvent(
              conversationId: 'persisted-1',
              message: _assistantMessage(content: '这是重新生成的建议。'),
            ),
          ]),
        );
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final before = container
            .read(assistantControllerProvider)
            .messages
            .length;
        await controller.regenerateExpiredProposal(
          messageId: controller.messageIdOf(assistantMessage),
          proposalId: 'proposal-expired',
        );

        expect(fake.streamMessagesCallCount, 1);
        expect(fake.lastStreamConversationId, 'persisted-1');
        // The pipeline reuses the persisted messages without appending a new
        // user message; the user message that produced the proposal is in there.
        expect(fake.lastStreamMessages?.length, 2);
        expect(fake.lastStreamMessages?.first.content, '帮我记一杯水');
        // The pipeline reuses persisted messages without appending a new user
        // message; a fresh assistant reply is appended on the result event.
        expect(
          container.read(assistantControllerProvider).messages.length,
          before + 1,
        );
      },
    );

    test(
      'regenerateExpiredProposal throws when no user message precedes it',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final assistantMessage = _assistantMessage(
          content: '建议已过期。',
          proposedActions: <AssistantProposedAction>[
            _createDailyRecordProposal(
              id: 'proposal-expired',
              expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
        );
        final fake = _FakeAssistantRepository(
          latestConversation: _conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[assistantMessage],
          ),
        );
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        await expectLater(
          controller.regenerateExpiredProposal(
            messageId: controller.messageIdOf(assistantMessage),
            proposalId: 'proposal-expired',
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'regenerateExpiredProposal is skipped while a send is in flight',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final streamController = StreamController<AssistantGenerationEvent>();
        addTearDown(streamController.close);
        final userMessage = AssistantMessage(
          role: AssistantMessageRole.user,
          content: '帮我记一杯水',
          createdAt: DateTime(2026, 6, 1, 11),
        );
        final assistantMessage = _assistantMessage(
          content: '建议已过期。',
          proposedActions: <AssistantProposedAction>[
            _createDailyRecordProposal(
              id: 'proposal-expired',
              expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
        );
        final fake = _FakeAssistantRepository(
          latestConversation: _conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[userMessage, assistantMessage],
          ),
          streamOverride: streamController.stream,
        );
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final sendFuture = controller.sendMessage('第一条消息');
        expect(container.read(assistantControllerProvider).isSending, isTrue);

        await controller.regenerateExpiredProposal(
          messageId: controller.messageIdOf(assistantMessage),
          proposalId: 'proposal-expired',
        );

        // Only the in-flight send hit the pipeline; the regenerate call was a
        // no-op. Complete the stream and await the send to clean up.
        expect(fake.streamMessagesCallCount, 1);
        streamController.add(
          AssistantGenerationResultEvent(
            conversationId: 'persisted-1',
            message: _assistantMessage(content: 'ok'),
          ),
        );
        await sendFuture;
      },
    );

    test('renameConversation updates the title optimistically', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final now = DateTime(2026, 6, 1);
      final fake = _FakeAssistantRepository()
        ..recentList = <AssistantConversationSummary>[
          AssistantConversationSummary(
            id: 'c1',
            title: 'Old title',
            status: 'active',
            lastMessageAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        ];
      final container = _buildContainer(fake);
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadRecentConversations();

      await controller.renameConversation(
        conversationId: 'c1',
        title: '  New title  ',
      );

      expect(fake.renameCalls.single.title, 'New title');
      final updated = container
          .read(assistantControllerProvider)
          .recentConversations
          .singleWhere((item) => item.id == 'c1');
      expect(updated.title, 'New title');
    });

    test(
      'renameConversation rolls back the title and rethrows on failure',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final now = DateTime(2026, 6, 1);
        final fake = _FakeAssistantRepository()
          ..recentList = <AssistantConversationSummary>[
            AssistantConversationSummary(
              id: 'c1',
              title: 'Old title',
              status: 'active',
              lastMessageAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          ]
          ..throwOnRename = true;
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadRecentConversations();

        await expectLater(
          controller.renameConversation(
            conversationId: 'c1',
            title: 'New title',
          ),
          throwsA(isA<Exception>()),
        );

        final rolledBack = container
            .read(assistantControllerProvider)
            .recentConversations
            .singleWhere((item) => item.id == 'c1');
        expect(rolledBack.title, 'Old title');
      },
    );

    test(
      'deleteConversation clears the current conversation and falls back to latest',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final now = DateTime(2026, 6, 1);
        final fake =
            _FakeAssistantRepository(
                latestConversation: AssistantConversation(
                  id: 'current',
                  title: 'Current',
                  status: 'active',
                  messages: <AssistantMessage>[
                    AssistantMessage(
                      role: AssistantMessageRole.user,
                      content: 'hello',
                      createdAt: now,
                    ),
                  ],
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              )
              ..recentList = <AssistantConversationSummary>[
                AssistantConversationSummary(
                  id: 'current',
                  title: 'Current',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
                AssistantConversationSummary(
                  id: 'other',
                  title: 'Other',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ];
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();
        expect(
          container.read(assistantControllerProvider).conversationId,
          'current',
        );

        // Simulate the backend state after deletion: no active conversation left.
        fake.latestConversation = null;
        await controller.deleteConversation('current');

        expect(fake.deleteCalls, <String>['current']);
        final state = container.read(assistantControllerProvider);
        expect(state.conversationId, isNull);
        expect(state.messages, isEmpty);
      },
    );

    test(
      'deleteConversation loads the next latest when the deleted one was current',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final now = DateTime(2026, 6, 1);
        final fake =
            _FakeAssistantRepository(
                latestConversation: AssistantConversation(
                  id: 'current',
                  title: 'Current',
                  status: 'active',
                  messages: const <AssistantMessage>[],
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              )
              ..recentList = <AssistantConversationSummary>[
                AssistantConversationSummary(
                  id: 'current',
                  title: 'Current',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ];
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        // The next latest conversation becomes active after the delete.
        fake.latestConversation = AssistantConversation(
          id: 'next',
          title: 'Next',
          status: 'active',
          messages: <AssistantMessage>[
            AssistantMessage(
              role: AssistantMessageRole.assistant,
              content: 'next',
              createdAt: now,
            ),
          ],
          lastMessageAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await controller.deleteConversation('current');

        final state = container.read(assistantControllerProvider);
        expect(state.conversationId, 'next');
        expect(state.messages.single.content, 'next');
      },
    );

    test(
      'deleteConversation keeps the current conversation when deleting another',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final now = DateTime(2026, 6, 1);
        final message = AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'hello',
          createdAt: now,
        );
        final fake =
            _FakeAssistantRepository(
                latestConversation: AssistantConversation(
                  id: 'current',
                  title: 'Current',
                  status: 'active',
                  messages: <AssistantMessage>[message],
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              )
              ..recentList = <AssistantConversationSummary>[
                AssistantConversationSummary(
                  id: 'current',
                  title: 'Current',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
                AssistantConversationSummary(
                  id: 'other',
                  title: 'Other',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ];
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        await controller.deleteConversation('other');

        expect(fake.deleteCalls, <String>['other']);
        final state = container.read(assistantControllerProvider);
        expect(state.conversationId, 'current');
        expect(state.messages.single.content, 'hello');
      },
    );

    test(
      'clearConversation exposes isClearingConversation while archiving',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final fake = _FakeAssistantRepository();
        final gate = Completer<bool>();
        fake.clearGate = gate;
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final clearing = controller.clearConversation();
        expect(
          container.read(assistantControllerProvider).isClearingConversation,
          isTrue,
        );

        gate.complete(true);
        await clearing;

        final state = container.read(assistantControllerProvider);
        expect(state.isClearingConversation, isFalse);
        expect(state.conversationId, isNull);
      },
    );

    test(
      'clearConversation resets isClearingConversation on failure',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final fake = _FakeAssistantRepository()..throwOnClear = true;
        final container = _buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        await controller.clearConversation();

        final state = container.read(assistantControllerProvider);
        expect(state.isClearingConversation, isFalse);
        expect(state.conversationError, isNotNull);
      },
    );
  });
}

class _ErrorThrowingRepository implements AssistantRepository {
  @override
  Future<AssistantCapabilities> getCapabilities() async {
    throw Exception('Network error');
  }

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    return const <AssistantConversationSummary>[];
  }

  @override
  Future<AssistantConversation> openConversation(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => true;

  @override
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    throw UnimplementedError();
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) async* {
    // no-op
  }

  @override
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) async {
    throw UnimplementedError();
  }
}
