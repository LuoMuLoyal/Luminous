import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/sse.dart';

sealed class AssistantRemoteEvent {
  const AssistantRemoteEvent();
}

class AssistantRemoteChunkEvent extends AssistantRemoteEvent {
  const AssistantRemoteChunkEvent(this.content);

  final String content;
}

class AssistantRemoteResultEvent extends AssistantRemoteEvent {
  const AssistantRemoteResultEvent({
    required this.conversationId,
    required this.content,
    required this.usedTools,
    required this.generatedAt,
    required this.proposedActions,
    this.toolDetails = const <Map<String, dynamic>>[],
  });

  final String conversationId;
  final String content;
  final List<String> usedTools;
  final DateTime generatedAt;
  final List<Map<String, dynamic>> proposedActions;

  /// Raw per-tool result envelopes; mapped to domain models by the repository.
  final List<Map<String, dynamic>> toolDetails;
}

class AssistantRemoteDataSource {
  AssistantRemoteDataSource({required this.api, required this.dio});

  final lucent.AssistantApi api;
  final Dio dio;

  Future<lucent.AssistantCapabilitiesDataDto> getCapabilities() async {
    final response = await api.assistantControllerGetCapabilitiesV1();
    return requireData(response.data, operation: 'getCapabilities').data;
  }

  Future<lucent.AssistantConversationDataDto?> getLatestConversation() async {
    final response = await api.assistantControllerGetLatestConversationV1();
    return requireData(response.data, operation: 'getLatestConversation').data;
  }

  Future<List<lucent.AssistantConversationSummaryDto>>
  listRecentConversations() async {
    final response = await api.assistantControllerListRecentConversationsV1();
    return requireData(
      response.data,
      operation: 'listRecentConversations',
    ).data;
  }

  Future<lucent.AssistantConversationDataDto> openConversation(
    String conversationId,
  ) async {
    final response = await api.assistantControllerOpenConversationV1(
      conversationId: conversationId,
    );
    // The DTO's `data` field is nullable; guard both layers so a
    // payload-less success response is reported instead of a `!` crash.
    return requireData(
      requireData(response.data, operation: 'openConversation').data,
      operation: 'openConversation',
    );
  }

  Future<bool> clearLatestConversation() async {
    // Use the generated OpenAPI client (no manual path or body workaround).
    // The backend treats an empty JSON body as absent, so a no-body POST is
    // accepted by this endpoint.
    final response = await api.assistantControllerClearLatestConversationV1();
    return response.data?.data.cleared ?? false;
  }

  /// Renames one persisted conversation (title only) and returns the updated
  /// conversation payload.
  Future<lucent.AssistantConversationDataDto> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    final response = await api.assistantControllerRenameConversationV1(
      conversationId: conversationId,
      renameConversationDto: lucent.RenameConversationDto(title: title),
    );
    return requireData(
      requireData(response.data, operation: 'renameConversation').data,
      operation: 'renameConversation',
    );
  }

  /// Soft-deletes one persisted conversation on the backend.
  Future<void> deleteConversation(String conversationId) async {
    await api.assistantControllerDeleteConversationV1(
      conversationId: conversationId,
    );
  }

  /// Confirms or rejects pending assistant write proposals on the backend and
  /// resumes the suspended graph thread. Returns the final assistant content
  /// produced after the decision is applied, or null when unavailable.
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) async {
    final response = await api.assistantControllerConfirmProposalV1(
      conversationId: conversationId,
      confirmAssistantProposalDto: lucent.ConfirmAssistantProposalDto(
        proposalIds: proposalIds,
        decision: decision == 'approved'
            ? lucent.ConfirmAssistantProposalDtoDecisionEnum.approved
            : lucent.ConfirmAssistantProposalDtoDecisionEnum.rejected,
        note: note,
      ),
    );
    return response.data?.data.finalContent;
  }

  Stream<AssistantRemoteEvent> streamMessages({
    required List<lucent.AssistantInputMessageDto> messages,
    String? conversationId,
  }) async* {
    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      '/api/v1/user/assistant/messages/stream',
      body: <String, Object?>{
        'messages': messages.map((message) => message.toJson()).toList(),
        if (conversationId != null && conversationId.isNotEmpty)
          'conversationId': conversationId,
      },
    )) {
      switch (event.event) {
        case 'chunk':
          final data = requireMap(event.data);
          final content = data['content']?.toString() ?? '';
          if (content.isNotEmpty) {
            yield AssistantRemoteChunkEvent(content);
          }
        case 'result':
          final data = requireMap(event.data);
          final usedTools = _readStringList(data['usedTools']);
          final generatedAtText = data['generatedAt']?.toString();
          yield AssistantRemoteResultEvent(
            conversationId: data['conversationId']?.toString() ?? '',
            content: data['content']?.toString() ?? '',
            usedTools: usedTools,
            generatedAt:
                DateTime.tryParse(generatedAtText ?? '') ?? clock.now(),
            proposedActions: _readMapList(data['proposedActions']),
            toolDetails: _readMapList(data['toolDetails']),
          );
        case 'error':
          throw mapSseStreamError(event.data);
        case 'done':
          return;
        default:
          break;
      }
    }
  }

  List<String> _readStringList(Object? raw) {
    if (raw is List) {
      return raw.map((value) => value.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  List<Map<String, dynamic>> _readMapList(Object? raw) {
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw.map((item) => requireMap(item)).toList(growable: false);
  }
}
