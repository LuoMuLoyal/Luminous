import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/sse.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';

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

  Future<lucent.AssistantCapabilitiesResponse> getCapabilities() async {
    final response = await api.getCapabilities();
    return _requireData(response.data, operation: 'getCapabilities');
  }

  Future<lucent.AssistantConversationData?> getLatestConversation() async {
    final response = await api.getLatestConversation();
    return _requireData(response.data, operation: 'getLatestConversation');
  }

  Future<List<lucent.AssistantConversationSummaryItem>>
  listRecentConversations() async {
    final response = await api.listRecentConversations();
    return _requireData(response.data, operation: 'listRecentConversations');
  }

  Future<lucent.AssistantConversationData> openConversation(
    String conversationId,
  ) async {
    final response = await api.openConversation(conversationId: conversationId);
    // The DTO's `data` field is nullable; guard both layers so a
    // payload-less success response is reported instead of a `!` crash.
    final responseDto = _requireData(
      response.data,
      operation: 'openConversation',
    );
    return lucent.AssistantConversationData.fromJson(responseDto.toJson());
  }

  Future<bool> clearLatestConversation() async {
    // Use the generated OpenAPI client (no manual path or body workaround).
    // The backend treats an empty JSON body as absent, so a no-body POST is
    // accepted by this endpoint.
    final response = await api.clearLatestConversation();
    return response.data?.cleared ?? false;
  }

  /// Renames one persisted conversation (title only) and returns the updated
  /// conversation payload.
  Future<lucent.AssistantConversationData> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    final response = await api.renameConversation(
      conversationId: conversationId,
      renameConversationRequest: lucent.RenameConversationRequest(title: title),
    );
    final responseDto = _requireData(
      response.data,
      operation: 'renameConversation',
    );
    return lucent.AssistantConversationData.fromJson(responseDto.toJson());
  }

  /// Soft-deletes one persisted conversation on the backend.
  Future<void> deleteConversation(String conversationId) async {
    await api.deleteConversation(conversationId: conversationId);
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
    final response = await api.confirmProposal(
      conversationId: conversationId,
      confirmProposalRequest: lucent.ConfirmProposalRequest(
        proposalIds: proposalIds,
        decision: decision == 'approved'
            ? lucent.ConfirmProposalRequestDecisionEnum.approved
            : lucent.ConfirmProposalRequestDecisionEnum.rejected,
        note: note,
      ),
    );
    return response.data?.finalContent;
  }

  Stream<AssistantRemoteEvent> streamMessages({
    required List<lucent.StreamMessagesRequestMessages> messages,
    String? conversationId,
  }) async* {
    final sse = LucentSseClient(dio: dio);

    yield* _readEvents(
      sse.postJson(
        '/api/v1/user/assistant/messages/stream',
        body: <String, Object?>{
          'messages': messages.map((message) => message.toJson()).toList(),
          if (conversationId != null && conversationId.isNotEmpty)
            'conversationId': conversationId,
        },
      ),
    );
  }

  /// Regenerates the last assistant message of a persisted conversation
  /// (F-5b) via the SSE endpoint, yielding the same chunk/result events as
  /// [streamMessages].
  Stream<AssistantRemoteEvent> regenerateLastMessage({
    required String conversationId,
  }) async* {
    final sse = LucentSseClient(dio: dio);

    yield* _readEvents(
      sse.postJson(
        '/api/v1/user/assistant/conversations/$conversationId/regenerate',
        body: const <String, Object?>{},
      ),
    );
  }

  Stream<AssistantRemoteEvent> _readEvents(
    Stream<LucentSseEvent> events,
  ) async* {
    await for (final event in events) {
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

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (today `ai_remote` / record `record.dart` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }
}
