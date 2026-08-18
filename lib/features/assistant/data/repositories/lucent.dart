import 'package:clock/clock.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/features/assistant/data/datasources/assistant.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent.g.dart';

@riverpod
AssistantRemoteDataSource assistantRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).assistant;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return AssistantRemoteDataSource(api: api, dio: dio);
}

@riverpod
AssistantRepository assistantRepository(Ref ref) {
  final dataSource = ref.watch(assistantRemoteDataSourceProvider);
  return LucentAssistantRepository(dataSource: dataSource);
}

class LucentAssistantRepository implements AssistantRepository {
  LucentAssistantRepository({required this.dataSource});

  final AssistantRemoteDataSource dataSource;

  @override
  Future<AssistantCapabilities> getCapabilities() async {
    final dto = await dataSource.getCapabilities();
    return _mapCapabilities(dto);
  }

  @override
  Future<AssistantConversation?> getLatestConversation() async {
    final dto = await dataSource.getLatestConversation();
    if (dto == null) {
      return null;
    }
    return _mapConversation(dto);
  }

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    final items = await dataSource.listRecentConversations();
    return items.map(_mapConversationSummary).toList(growable: false);
  }

  @override
  Future<AssistantConversation> openConversation(String conversationId) async {
    final dto = await dataSource.openConversation(conversationId);
    return _mapConversation(dto);
  }

  @override
  Future<bool> clearLatestConversation() {
    return dataSource.clearLatestConversation();
  }

  @override
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    await dataSource.renameConversation(
      conversationId: conversationId,
      title: title,
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await dataSource.deleteConversation(conversationId);
  }

  @override
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) {
    return dataSource.confirmProposals(
      conversationId: conversationId,
      proposalIds: proposalIds,
      decision: decision,
      note: note,
    );
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) async* {
    final requestMessages = messages
        .map(
          (message) => lucent.AssistantInputMessageDto(
            role: switch (message.role) {
              AssistantMessageRole.user =>
                lucent.AssistantInputMessageDtoRoleEnum.user,
              AssistantMessageRole.assistant =>
                lucent.AssistantInputMessageDtoRoleEnum.assistant,
            },
            content: message.content,
          ),
        )
        .toList(growable: false);

    await for (final event in dataSource.streamMessages(
      messages: requestMessages,
      conversationId: conversationId,
    )) {
      switch (event) {
        case AssistantRemoteChunkEvent():
          yield AssistantGenerationChunkEvent(event.content);
        case AssistantRemoteResultEvent():
          yield AssistantGenerationResultEvent(
            conversationId: event.conversationId,
            message: AssistantMessage(
              role: AssistantMessageRole.assistant,
              content: event.content,
              usedTools: event.usedTools,
              createdAt: event.generatedAt,
              toolDetails: event.toolDetails
                  .map(_mapToolDetail)
                  .toList(growable: false),
              proposedActions: event.proposedActions
                  .map(_mapProposedActionFromJson)
                  .whereType<AssistantProposedAction>()
                  .toList(growable: false),
            ),
          );
      }
    }
  }

  @override
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  }) async* {
    await for (final event in dataSource.regenerateLastMessage(
      conversationId: conversationId,
    )) {
      switch (event) {
        case AssistantRemoteChunkEvent():
          onChunk(event.content);
          yield AssistantGenerationChunkEvent(event.content);
        case AssistantRemoteResultEvent():
          yield AssistantGenerationResultEvent(
            conversationId: event.conversationId,
            message: AssistantMessage(
              role: AssistantMessageRole.assistant,
              content: event.content,
              usedTools: event.usedTools,
              createdAt: event.generatedAt,
              toolDetails: event.toolDetails
                  .map(_mapToolDetail)
                  .toList(growable: false),
              proposedActions: event.proposedActions
                  .map(_mapProposedActionFromJson)
                  .whereType<AssistantProposedAction>()
                  .toList(growable: false),
            ),
          );
      }
    }
  }

  AssistantCapabilities _mapCapabilities(
    lucent.AssistantCapabilitiesDataDto dto,
  ) {
    return AssistantCapabilities(
      phase: dto.phase,
      assistantEnabled: dto.assistantEnabled,
      assistantMemoryEnabled: dto.assistantMemoryEnabled,
      assistantContext: AssistantContextAccess(
        healthProfile: dto.assistantContext.healthProfile,
        dailyRecords: dto.assistantContext.dailyRecords,
        sleepRecords: dto.assistantContext.sleepRecords,
        currentMedicines: dto.assistantContext.currentMedicines,
      ),
      chatModelConfigured: dto.chatModelConfigured,
      interactiveChatReady: dto.interactiveChatReady,
      langGraphReady: dto.langGraphReady,
      streamingSupported: dto.streamingSupported,
      streamingTransport: dto.streamingTransport,
      markdownRenderingRecommended: dto.markdownRenderingRecommended,
      ragEnabled: dto.ragEnabled,
      tools: dto.tools
          .map(
            (tool) => AssistantToolCapability(
              id:
                  tool.name ==
                      lucent
                          .AssistantToolCapabilityDtoNameEnum
                          .unknownDefaultOpenApi
                  ? ''
                  : tool.name.value,
              requiredContextSources: tool.requiredContextSources,
              permittedByUser: tool.permittedByUser,
              enabled: tool.enabled,
              implemented: tool.implemented,
              disabledReason: tool.disabledReason?.value,
            ),
          )
          .toList(growable: false),
      updatedAt: DateTime.tryParse(dto.updatedAt ?? ''),
    );
  }

  AssistantConversation _mapConversation(
    lucent.AssistantConversationDataDto dto,
  ) {
    return AssistantConversation(
      id: dto.id,
      title: dto.title?.toString(),
      status: dto.status.value,
      messages: dto.messages
          .map(_mapConversationMessage)
          .toList(growable: false),
      lastMessageAt: _parseDateTime(dto.lastMessageAt),
      createdAt: _parseDateTime(dto.createdAt) ?? clock.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? clock.now(),
    );
  }

  AssistantConversationSummary _mapConversationSummary(
    lucent.AssistantConversationSummaryDto dto,
  ) {
    return AssistantConversationSummary(
      id: dto.id,
      title: dto.title?.toString(),
      status: dto.status.value,
      lastMessageAt: _parseDateTime(dto.lastMessageAt),
      createdAt: _parseDateTime(dto.createdAt) ?? clock.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? clock.now(),
    );
  }

  AssistantMessage _mapConversationMessage(
    lucent.AssistantConversationMessageDto dto,
  ) {
    return AssistantMessage(
      role: switch (dto.role) {
        lucent.AssistantConversationMessageDtoRoleEnum.user =>
          AssistantMessageRole.user,
        lucent.AssistantConversationMessageDtoRoleEnum.assistant =>
          AssistantMessageRole.assistant,
        lucent.AssistantConversationMessageDtoRoleEnum.unknownDefaultOpenApi =>
          AssistantMessageRole.assistant,
      },
      content: dto.content,
      createdAt: _parseDateTime(dto.createdAt) ?? clock.now(),
      usedTools: dto.usedTools,
      // Persisted conversations predate the SSE toolDetails field and never
      // carry it; history messages have no source strip details.
      toolDetails: const <AssistantToolDetail>[],
    );
  }

  AssistantToolDetail _mapToolDetail(Map<String, dynamic> json) {
    final coverage = _mapStringKeyedMap(json['coverage']);
    final confidence = _mapStringKeyedMap(json['confidence']);
    final source = _mapStringKeyedMap(json['source']);
    return AssistantToolDetail(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString(),
      coverageStatus: coverage?['status']?.toString(),
      coverageReason: coverage?['reason']?.toString(),
      confidenceLevel: confidence?['level']?.toString(),
      confidenceReason: confidence?['reason']?.toString(),
      ambiguities: switch (json['ambiguities']) {
        final List<Object?> items =>
          items.map((item) => item.toString()).toList(growable: false),
        _ => const <String>[],
      },
      sourceTool: source?['tool']?.toString(),
      sourceGeneratedAt: source?['generatedAt']?.toString(),
      sourceTables: switch (source?['tables']) {
        final List<Object?> items =>
          items.map((item) => item.toString()).toList(growable: false),
        _ => const <String>[],
      },
      // F-14:摘要工具(如 get_today_summary_by_date)的置信度说明与数据源版本,
      // 后端 buildToolDetails 可选透传;缺失时保持 null,来源条不渲染。
      confidenceNote: json['confidenceNote']?.toString(),
      sourceVersion: json['sourceVersion']?.toString(),
      disclaimer: json['disclaimer']?.toString(),
    );
  }

  AssistantProposedAction? _mapProposedActionFromJson(
    Map<String, dynamic> json,
  ) {
    final type = AssistantProposedActionType.fromValue(
      json['type']?.toString() ?? '',
    );
    if (type == null) {
      return null;
    }

    final payload = _mapProposalPayload(type, json['payload']);
    if (payload == null) {
      return null;
    }

    final previewFields = switch (json['previewFields']) {
      final List<Object?> items =>
        items
            .whereType<Map>()
            .map(
              (item) => AssistantProposalPreviewField(
                label: item['label']?.toString() ?? '',
                value: item['value']?.toString() ?? '',
              ),
            )
            .toList(growable: false),
      _ => const <AssistantProposalPreviewField>[],
    };

    final targetJson = _mapStringKeyedMap(json['target']);
    final target = AssistantProposalTarget(
      kind: targetJson?['kind']?.toString() ?? 'unknown',
      label: targetJson?['label']?.toString() ?? '',
      recordId: targetJson?['recordId']?.toString(),
      settingKeys: switch (targetJson?['settingKeys']) {
        final List<Object?> items =>
          items.map((item) => item.toString()).toList(growable: false),
        _ => const <String>[],
      },
      matchedBy: switch (targetJson?['matchedBy']) {
        final List<Object?> items =>
          items.map((item) => item.toString()).toList(growable: false),
        _ => const <String>[],
      },
      snapshot: _mapStringKeyedMap(targetJson?['snapshot']),
    );

    final constraints = switch (json['constraints']) {
      final List<Object?> items =>
        items.map((item) => item.toString()).toList(growable: false),
      _ => const <String>[],
    };

    final payloadVersion = switch (json['payloadVersion']) {
      final int value => value,
      final num value => value.toInt(),
      _ => 1,
    };

    return AssistantProposedAction(
      id: json['id']?.toString() ?? '',
      type: type,
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      reason: json['reason']?.toString(),
      previewFields: previewFields,
      target: target,
      constraints: constraints,
      expiresAt: _parseDateTime(json['expiresAt']),
      payloadVersion: payloadVersion,
      payload: payload,
      confirmationRequired: json['confirmationRequired'] != false,
      backendStatus: json['status']?.toString() ?? 'proposed',
    );
  }

  AssistantProposalPayload? _mapProposalPayload(
    AssistantProposedActionType type,
    Object? rawPayload,
  ) {
    final payload = _mapStringKeyedMap(rawPayload);
    if (payload == null) {
      return null;
    }

    switch (type) {
      case AssistantProposedActionType.createDailyRecord:
        final draft = _mapStringKeyedMap(payload['draft']);
        final kind = draft?['kind']?.toString();
        final occurredAt = draft?['occurredAt']?.toString();
        if (draft == null || kind == null || occurredAt == null) {
          return null;
        }
        return AssistantCreateDailyRecordProposalPayload(
          draft: AssistantCreateDailyRecordDraft(
            kind: kind,
            occurredAt: occurredAt,
            title: draft['title']?.toString(),
            value: draft['value']?.toString(),
            unit: draft['unit']?.toString(),
            note: draft['note']?.toString(),
            payload: _mapStringKeyedMap(draft['payload']),
          ),
        );
      case AssistantProposedActionType.updateDailyRecord:
        final recordId = payload['recordId']?.toString();
        final draft = _mapStringKeyedMap(payload['draft']);
        if (recordId == null || draft == null) {
          return null;
        }
        return AssistantUpdateDailyRecordProposalPayload(
          recordId: recordId,
          draft: draft,
        );
      case AssistantProposedActionType.deleteDailyRecord:
        final recordId = payload['recordId']?.toString();
        if (recordId == null) {
          return null;
        }
        return AssistantDeleteDailyRecordProposalPayload(recordId: recordId);
      case AssistantProposedActionType.updateUserSettings:
        final draft = _mapStringKeyedMap(payload['draft']);
        if (draft == null) {
          return null;
        }
        final context = _mapStringKeyedMap(draft['assistantContext']);
        return AssistantUpdateUserSettingsProposalPayload(
          draft: AssistantUpdateUserSettingsDraft(
            assistantEnabled: draft['assistantEnabled'] as bool?,
            assistantMemoryEnabled: draft['assistantMemoryEnabled'] as bool?,
            assistantContext: context == null
                ? null
                : AssistantContextAccess(
                    healthProfile: context['healthProfile'] as bool? ?? false,
                    dailyRecords: context['dailyRecords'] as bool? ?? false,
                    sleepRecords: context['sleepRecords'] as bool? ?? false,
                    currentMedicines:
                        context['currentMedicines'] as bool? ?? false,
                  ),
          ),
        );
    }
  }

  Map<String, dynamic>? _mapStringKeyedMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  DateTime? _parseDateTime(Object? raw) {
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw.toString());
  }
}
