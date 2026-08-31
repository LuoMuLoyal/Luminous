import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';

import '../auth/test_helpers.dart';

/// A fake repository with canned responses.
class FakeAssistantRepository implements AssistantRepository {
  FakeAssistantRepository({
    this.latestConversation,
    this.streamOverride,
    this.regenerateStream,
  });

  AssistantConversation? latestConversation;
  Stream<AssistantGenerationEvent>? streamOverride;

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
  Completer<void>? renameGate;
  final List<String> deleteCalls = <String>[];
  bool throwOnRename = false;
  bool throwOnDelete = false;

  String? lastStreamConversationId;
  List<AssistantMessage>? lastStreamMessages;
  int streamMessagesCallCount = 0;

  /// Stream returned by [regenerateLastMessage].
  Stream<AssistantGenerationEvent>? regenerateStream;
  String? lastRegenerateConversationId;
  int regenerateCallCount = 0;

  final List<
    ({String conversationId, List<String> proposalIds, String decision})
  >
  confirmCalls =
      <({String conversationId, List<String> proposalIds, String decision})>[];
  String? confirmResult;
  bool throwOnConfirm = false;

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(
      AssistantCapabilities(
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
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(latestConversation);
  }

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(recentList);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(String id) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.tryCatch(() async {
      final gate = clearGate;
      if (gate != null) {
        await gate.future;
      }
      if (throwOnClear) {
        throw Exception('clear failed');
      }
      return true;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> renameConversation({
    required String conversationId,
    required String title,
  }) {
    return TaskEither.tryCatch(() async {
      renameCalls.add((conversationId: conversationId, title: title));
      await renameGate?.future;
      if (throwOnRename) {
        throw Exception('rename failed');
      }
      // Mirror the backend: the persisted title changes, so the refreshed list
      // returns the new title.
      recentList = [
        for (final item in recentList)
          item.id == conversationId ? summaryWithTitle(item, title) : item,
      ];
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> deleteConversation(String conversationId) {
    return TaskEither.tryCatch(() async {
      deleteCalls.add(conversationId);
      if (throwOnDelete) {
        throw Exception('delete failed');
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
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
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  }) async* {
    regenerateCallCount++;
    lastRegenerateConversationId = conversationId;
    await for (final event
        in regenerateStream ?? const Stream<AssistantGenerationEvent>.empty()) {
      if (event is AssistantGenerationChunkEvent) {
        onChunk(event.content);
      }
      yield event;
    }
  }

  @override
  TaskEither<LucentFailure, String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) {
    return TaskEither.tryCatch(() async {
      confirmCalls.add((
        conversationId: conversationId,
        proposalIds: proposalIds,
        decision: decision,
      ));
      if (throwOnConfirm) {
        throw Exception('confirm failed');
      }
      return confirmResult;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }
}

AssistantProposedAction createDailyRecordProposal({
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

AssistantProposedAction updateUserSettingsProposal({required String id}) {
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
AssistantConversationSummary summaryWithTitle(
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

AssistantConversation conversationWith({
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

AssistantMessage buildAssistantMessage({
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

ProviderContainer buildContainer(FakeAssistantRepository repository) {
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
      assistantRepositoryProvider.overrideWithValue(repository),
    ],
  );
  return container;
}

class ErrorThrowingRepository implements AssistantRepository {
  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.left(
      LucentFailure.unknown(
        message: 'Network error',
        cause: Exception('Network error'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(String id) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(true);
  }

  @override
  TaskEither<LucentFailure, void> renameConversation({
    required String conversationId,
    required String title,
  }) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, void> deleteConversation(String conversationId) {
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
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  }) async* {
    // no-op
  }

  @override
  TaskEither<LucentFailure, String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) {
    throw UnimplementedError();
  }
}
