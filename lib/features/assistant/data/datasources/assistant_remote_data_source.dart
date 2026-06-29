import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_sse.dart';

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
  });

  final String conversationId;
  final String content;
  final List<String> usedTools;
  final DateTime generatedAt;
  final List<Map<String, dynamic>> proposedActions;
}

class AssistantRemoteDataSource {
  AssistantRemoteDataSource({required this.api, required this.dio});

  final lucent.AssistantApi api;
  final Dio dio;

  Future<lucent.AssistantCapabilitiesDataDto> getCapabilities() async {
    final response = await api.assistantControllerGetCapabilitiesV1();
    final data = response.data?.data;
    if (data == null) {
      throw const LucentApiException(message: 'AI 对话能力响应为空，请稍后再试。');
    }
    return data;
  }

  Future<lucent.AssistantConversationDataDto?> getLatestConversation() async {
    final response = await api.assistantControllerGetLatestConversationV1();
    return response.data?.data;
  }

  Future<List<lucent.AssistantConversationSummaryDto>>
  listRecentConversations() async {
    final response = await api.assistantControllerListRecentConversationsV1();
    return response.data?.data ??
        const <lucent.AssistantConversationSummaryDto>[];
  }

  Future<lucent.AssistantConversationDataDto> openConversation(
    String conversationId,
  ) async {
    final response = await api.assistantControllerOpenConversationV1(
      conversationId: conversationId,
    );
    final data = response.data?.data;
    if (data == null) {
      throw const LucentApiException(message: '会话详情响应为空，请稍后再试。');
    }
    return data;
  }

  Future<bool> clearLatestConversation() async {
    final response = await api.assistantControllerClearLatestConversationV1();
    return response.data?.data?.cleared ?? false;
  }

  Stream<AssistantRemoteEvent> streamMessages({
    required List<lucent.AssistantInputMessageDto> messages,
  }) async* {
    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      '/api/v1/user/assistant/messages/stream',
      body: <String, Object?>{
        'messages': messages.map((message) => message.toJson()).toList(),
      },
    )) {
      switch (event.event) {
        case 'chunk':
          final data = _requireMap(event.data);
          final content = data['content']?.toString() ?? '';
          if (content.isNotEmpty) {
            yield AssistantRemoteChunkEvent(content);
          }
        case 'result':
          final data = _requireMap(event.data);
          final usedTools = _readStringList(data['usedTools']);
          final generatedAtText = data['generatedAt']?.toString();
          yield AssistantRemoteResultEvent(
            conversationId: data['conversationId']?.toString() ?? '',
            content: data['content']?.toString() ?? '',
            usedTools: usedTools,
            generatedAt:
                DateTime.tryParse(generatedAtText ?? '') ?? DateTime.now(),
            proposedActions: _readMapList(data['proposedActions']),
          );
        case 'error':
          throw _mapStreamError(event.data);
        case 'done':
          return;
        default:
          break;
      }
    }
  }

  Map<String, dynamic> _requireMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const LucentApiException(message: 'Lucent SSE payload is invalid.');
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
    return raw.map((item) => _requireMap(item)).toList(growable: false);
  }

  LucentApiException _mapStreamError(Object? data) {
    final json = _requireMap(data);
    return LucentApiException(
      message: json['message']?.toString() ?? '请求失败，请稍后再试。',
      code: json['code'] is int ? json['code'] as int : null,
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
      data: json,
    );
  }
}
