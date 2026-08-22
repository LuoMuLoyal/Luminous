import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
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
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
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
