import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/ai_chat/data/datasources/ai_chat_remote_data_source.dart';
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';

sealed class AiChatGenerationEvent {
  const AiChatGenerationEvent();
}

class AiChatGenerationChunkEvent extends AiChatGenerationEvent {
  const AiChatGenerationChunkEvent(this.content);

  final String content;
}

class AiChatGenerationResultEvent extends AiChatGenerationEvent {
  const AiChatGenerationResultEvent({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final AiChatMessage message;
}

abstract interface class AiChatRepository {
  Future<AiChatCapabilities> getCapabilities();

  Future<List<AiChatConversationSummary>> listRecentConversations();

  Future<AiChatConversation?> getLatestConversation();

  Future<AiChatConversation> openConversation(String conversationId);

  Future<bool> clearLatestConversation();

  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages);
}

final aiChatRemoteDataSourceProvider = Provider<AiChatRemoteDataSource>((ref) {
  final api = ref.watch(lucentAiChatApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return AiChatRemoteDataSource(api: api, dio: dio);
});

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final dataSource = ref.watch(aiChatRemoteDataSourceProvider);
  return LucentAiChatRepository(dataSource: dataSource);
});

class LucentAiChatRepository implements AiChatRepository {
  LucentAiChatRepository({required this.dataSource});

  final AiChatRemoteDataSource dataSource;

  @override
  Future<AiChatCapabilities> getCapabilities() async {
    final dto = await dataSource.getCapabilities();
    return _mapCapabilities(dto);
  }

  @override
  Future<AiChatConversation?> getLatestConversation() async {
    final dto = await dataSource.getLatestConversation();
    if (dto == null) {
      return null;
    }
    return _mapConversation(dto);
  }

  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async {
    final items = await dataSource.listRecentConversations();
    return items.map(_mapConversationSummary).toList(growable: false);
  }

  @override
  Future<AiChatConversation> openConversation(String conversationId) async {
    final dto = await dataSource.openConversation(conversationId);
    return _mapConversation(dto);
  }

  @override
  Future<bool> clearLatestConversation() {
    return dataSource.clearLatestConversation();
  }

  @override
  Stream<AiChatGenerationEvent> streamMessages(
    List<AiChatMessage> messages,
  ) async* {
    final requestMessages = messages
        .map(
          (message) => lucent.AiChatInputMessageDto(
            role: switch (message.role) {
              AiChatMessageRole.user =>
                lucent.AiChatInputMessageDtoRoleEnum.user,
              AiChatMessageRole.assistant =>
                lucent.AiChatInputMessageDtoRoleEnum.assistant,
            },
            content: message.content,
          ),
        )
        .toList(growable: false);

    await for (final event in dataSource.streamMessages(
      messages: requestMessages,
    )) {
      switch (event) {
        case AiChatRemoteChunkEvent():
          yield AiChatGenerationChunkEvent(event.content);
        case AiChatRemoteResultEvent():
          yield AiChatGenerationResultEvent(
            conversationId: event.conversationId,
            message: AiChatMessage(
              role: AiChatMessageRole.assistant,
              content: event.content,
              usedTools: event.usedTools,
              createdAt: event.generatedAt,
              proposedActions: event.proposedActions
                  .map(_mapProposedActionFromJson)
                  .whereType<AiChatProposedAction>()
                  .toList(growable: false),
            ),
          );
      }
    }
  }

  AiChatCapabilities _mapCapabilities(lucent.AiChatCapabilitiesDataDto dto) {
    return AiChatCapabilities(
      phase: dto.phase,
      aiChatEnabled: dto.aiChatEnabled,
      aiChatMemoryEnabled: dto.aiChatMemoryEnabled,
      aiChatContext: AiChatContextPermissions(
        healthProfile: dto.aiChatContext.healthProfile,
        dailyRecords: dto.aiChatContext.dailyRecords,
        sleepRecords: dto.aiChatContext.sleepRecords,
        currentMedicines: dto.aiChatContext.currentMedicines,
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
            (tool) => AiChatToolCapability(
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

  AiChatConversation _mapConversation(lucent.AiChatConversationDataDto dto) {
    return AiChatConversation(
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

  AiChatConversationSummary _mapConversationSummary(
    lucent.AiChatConversationSummaryDto dto,
  ) {
    return AiChatConversationSummary(
      id: dto.id,
      title: dto.title?.toString(),
      status: dto.status.value,
      lastMessageAt: _parseDateTime(dto.lastMessageAt),
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? DateTime.now(),
    );
  }

  AiChatMessage _mapConversationMessage(
    lucent.AiChatConversationMessageDto dto,
  ) {
    return AiChatMessage(
      role: switch (dto.role) {
        lucent.AiChatConversationMessageDtoRoleEnum.user =>
          AiChatMessageRole.user,
        lucent.AiChatConversationMessageDtoRoleEnum.assistant =>
          AiChatMessageRole.assistant,
        lucent.AiChatConversationMessageDtoRoleEnum.unknownDefaultOpenApi =>
          AiChatMessageRole.assistant,
      },
      content: dto.content,
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      usedTools: dto.usedTools,
    );
  }

  AiChatProposedAction? _mapProposedActionFromJson(Map<String, dynamic> json) {
    final type = AiChatProposedActionType.fromValue(
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
              (item) => AiChatProposalPreviewField(
                label: item['label']?.toString() ?? '',
                value: item['value']?.toString() ?? '',
              ),
            )
            .toList(growable: false),
      _ => const <AiChatProposalPreviewField>[],
    };

    final payloadVersion = switch (json['payloadVersion']) {
      final int value => value,
      final num value => value.toInt(),
      _ => 1,
    };

    return AiChatProposedAction(
      id: json['id']?.toString() ?? '',
      type: type,
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      reason: json['reason']?.toString(),
      previewFields: previewFields,
      payloadVersion: payloadVersion,
      payload: payload,
      confirmationRequired: json['confirmationRequired'] != false,
      backendStatus: json['status']?.toString() ?? 'proposed',
    );
  }

  AiChatProposalPayload? _mapProposalPayload(
    AiChatProposedActionType type,
    Object? rawPayload,
  ) {
    final payload = _mapStringKeyedMap(rawPayload);
    if (payload == null) {
      return null;
    }

    switch (type) {
      case AiChatProposedActionType.createDailyRecord:
        final draft = _mapStringKeyedMap(payload['draft']);
        final kind = draft?['kind']?.toString();
        final occurredAt = draft?['occurredAt']?.toString();
        if (draft == null || kind == null || occurredAt == null) {
          return null;
        }
        return AiChatCreateDailyRecordProposalPayload(
          draft: AiChatCreateDailyRecordDraft(
            kind: kind,
            occurredAt: occurredAt,
            title: draft['title']?.toString(),
            value: draft['value']?.toString(),
            unit: draft['unit']?.toString(),
            note: draft['note']?.toString(),
            payload: _mapStringKeyedMap(draft['payload']),
          ),
        );
      case AiChatProposedActionType.updateDailyRecord:
        final recordId = payload['recordId']?.toString();
        final draft = _mapStringKeyedMap(payload['draft']);
        if (recordId == null || draft == null) {
          return null;
        }
        return AiChatUpdateDailyRecordProposalPayload(
          recordId: recordId,
          draft: draft,
        );
      case AiChatProposedActionType.deleteDailyRecord:
        final recordId = payload['recordId']?.toString();
        if (recordId == null) {
          return null;
        }
        return AiChatDeleteDailyRecordProposalPayload(recordId: recordId);
      case AiChatProposedActionType.updateUserSettings:
        final draft = _mapStringKeyedMap(payload['draft']);
        if (draft == null) {
          return null;
        }
        final context = _mapStringKeyedMap(draft['aiChatContext']);
        return AiChatUpdateUserSettingsProposalPayload(
          draft: AiChatUpdateUserSettingsDraft(
            aiChatEnabled: draft['aiChatEnabled'] as bool?,
            aiChatMemoryEnabled: draft['aiChatMemoryEnabled'] as bool?,
            aiChatContext: context == null
                ? null
                : AiChatContextPermissions(
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
