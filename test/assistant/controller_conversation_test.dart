import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller_test_helpers.dart';

void main() {
  group('AssistantController', () {
    test(
      'confirmProposedAction confirms on the backend and emits dailyRecords',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final proposal = createDailyRecordProposal(id: 'proposal-1');
        final assistantMessage = buildAssistantMessage(
          content: '建议：记录喝水。',
          proposedActions: <AssistantProposedAction>[proposal],
        );
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
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
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final state = container.read(assistantControllerProvider);
        await controller.confirmProposedAction(
          messageId: messageIdFor(state.messages.last),
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
        final proposal = updateUserSettingsProposal(id: 'proposal-settings-1');
        final assistantMessage = buildAssistantMessage(
          content: '建议：关闭记忆。',
          proposedActions: <AssistantProposedAction>[proposal],
        );
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
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
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final state = container.read(assistantControllerProvider);
        await controller.confirmProposedAction(
          messageId: messageIdFor(state.messages.last),
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
        final proposal = createDailyRecordProposal(id: 'proposal-1');
        final assistantMessage = buildAssistantMessage(
          content: '建议：记录喝水。',
          proposedActions: <AssistantProposedAction>[proposal],
        );
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[assistantMessage],
          ),
        )..throwOnConfirm = true;
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final state = container.read(assistantControllerProvider);
        await expectLater(
          controller.confirmProposedAction(
            messageId: messageIdFor(state.messages.last),
            proposalId: 'proposal-1',
          ),
          throwsA(isA<LucentFailure>()),
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
        final fake = FakeAssistantRepository(
          streamOverride: Stream<AssistantGenerationEvent>.fromIterable([
            AssistantGenerationResultEvent(
              conversationId: '',
              message: buildAssistantMessage(
                content: '建议：记录喝水。',
                proposedActions: <AssistantProposedAction>[
                  createDailyRecordProposal(id: 'proposal-1'),
                ],
              ),
            ),
          ]),
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();
        await controller.sendMessage('帮我记一杯水');

        final state = container.read(assistantControllerProvider);
        expect(state.conversationId, isNull);

        await expectLater(
          controller.confirmProposedAction(
            messageId: messageIdFor(state.messages.last),
            proposalId: 'proposal-1',
          ),
          throwsA(isA<StateError>()),
        );
        expect(fake.confirmCalls, isEmpty);
      },
    );

    test('renameConversation updates the title optimistically', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final now = DateTime(2026, 6, 1);
      final fake = FakeAssistantRepository()
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
      final container = buildContainer(fake);
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
      'renameConversation ignores a concurrent rename for the same conversation',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final now = DateTime(2026, 6, 1);
        final fake = FakeAssistantRepository()
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
          ..renameGate = Completer<void>();
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadRecentConversations();

        final first = controller.renameConversation(
          conversationId: 'c1',
          title: 'First title',
        );
        await Future<void>.delayed(Duration.zero);

        final second = controller.renameConversation(
          conversationId: 'c1',
          title: 'Second title',
        );
        await second;

        expect(fake.renameCalls, hasLength(1));
        expect(fake.renameCalls.single.title, 'First title');
        expect(
          container
              .read(assistantControllerProvider)
              .recentConversations
              .single
              .title,
          'First title',
        );

        fake.renameGate!.complete();
        await first;
      },
    );

    test(
      'renameConversation rolls back the title and rethrows on failure',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final now = DateTime(2026, 6, 1);
        final fake = FakeAssistantRepository()
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
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadRecentConversations();

        await expectLater(
          controller.renameConversation(
            conversationId: 'c1',
            title: 'New title',
          ),
          throwsA(isA<LucentFailure>()),
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
            FakeAssistantRepository(
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
        final container = buildContainer(fake);
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
            FakeAssistantRepository(
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
        final container = buildContainer(fake);
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
            FakeAssistantRepository(
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
        final container = buildContainer(fake);
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
        final fake = FakeAssistantRepository();
        final gate = Completer<bool>();
        fake.clearGate = gate;
        final container = buildContainer(fake);
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
        final fake = FakeAssistantRepository()..throwOnClear = true;
        final container = buildContainer(fake);
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
