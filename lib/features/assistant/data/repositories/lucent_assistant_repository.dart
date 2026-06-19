import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';

sealed class AssistantGenerationEvent {
  const AssistantGenerationEvent();
}

class AssistantGenerationChunkEvent extends AssistantGenerationEvent {
  const AssistantGenerationChunkEvent(this.content);

  final String content;
}

class AssistantGenerationResultEvent extends AssistantGenerationEvent {
  const AssistantGenerationResultEvent({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final AssistantMessage message;
}

abstract interface class AssistantRepository {
  Future<AssistantCapabilities> getCapabilities();

  Future<List<AssistantConversationSummary>> listRecentConversations();

  Future<AssistantConversation?> getLatestConversation();

  Future<AssistantConversation> openConversation(String conversationId);

  Future<bool> clearLatestConversation();

  Stream<AssistantGenerationEvent> streamMessages(List<AssistantMessage> messages);
}

final assistantRemoteDataSourceProvider = Provider<AssistantRemoteDataSource>((ref) {
  final api = ref.watch(lucentAssistantApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return AssistantRemoteDataSource(api: api, dio: dio);
});

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final dataSource = ref.watch(assistantRemoteDataSourceProvider);
  return LucentAssistantRepository(dataSource: dataSource);
});

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
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) async* {
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
              proposedActions: event.proposedActions
                  .map(_mapProposedActionFromJson)
                  .whereType<AssistantProposedAction>()
                  .toList(growable: false),
            ),
          );
      }
    }
  }

  AssistantCapabilities _mapCapabilities(lucent.AssistantCapabilitiesDataDto dto) {
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
              id: tool.name.value,
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

  AssistantConversation _mapConversation(lucent.AssistantConversationDataDto dto) {
    return AssistantConversation(
      id: dto.id,
      title: dto.title?.toString(),
      status: dto.status.value,
      messages: dto.messages
          .map(_mapConversationMessage)
          .toList(growable: false),
      lastMessageAt: _parseDateTime(dto.lastMessageAt),
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? DateTime.now(),
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
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? DateTime.now(),
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
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      usedTools: dto.usedTools,
    );
  }

  AssistantProposedAction? _mapProposedActionFromJson(Map<String, dynamic> json) {
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
