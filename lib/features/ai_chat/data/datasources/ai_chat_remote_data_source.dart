import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_sse.dart';

sealed class AiChatRemoteEvent {
  const AiChatRemoteEvent();
}

class AiChatRemoteChunkEvent extends AiChatRemoteEvent {
  const AiChatRemoteChunkEvent(this.content);

  final String content;
}

class AiChatRemoteResultEvent extends AiChatRemoteEvent {
  const AiChatRemoteResultEvent({
    required this.conversationId,
    required this.content,
    required this.usedTools,
    required this.generatedAt,
  });

  final String conversationId;
  final String content;
  final List<String> usedTools;
  final DateTime generatedAt;
}

class AiChatRemoteDataSource {
  AiChatRemoteDataSource({required this.api, required this.dio});

  final lucent.AIChatApi api;
  final Dio dio;

  Future<lucent.AiChatCapabilitiesDataDto> getCapabilities() async {
    final response = await api.aiChatControllerGetCapabilitiesV1();
    final data = response.data?.data;
    if (data == null) {
      throw const LucentApiException(message: 'AI 对话能力响应为空，请稍后再试。');
    }
    return data;
  }

  Future<lucent.AiChatConversationDataDto?> getLatestConversation() async {
    final response = await api.aiChatControllerGetLatestConversationV1();
    return response.data?.data;
  }

  Future<bool> clearLatestConversation() async {
    final response = await api.aiChatControllerClearLatestConversationV1();
    return response.data?.data?.cleared ?? false;
  }

  Stream<AiChatRemoteEvent> streamMessages({
    required List<lucent.AiChatInputMessageDto> messages,
  }) async* {
    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      '/api/v1/user/ai-chat/messages/stream',
      body: <String, Object?>{
        'messages': messages.map((message) => message.toJson()).toList(),
      },
    )) {
      switch (event.event) {
        case 'chunk':
          final data = _requireMap(event.data);
          final content = data['content']?.toString() ?? '';
          if (content.isNotEmpty) {
            yield AiChatRemoteChunkEvent(content);
          }
        case 'result':
          final data = _requireMap(event.data);
          final usedTools = _readStringList(data['usedTools']);
          final generatedAtText = data['generatedAt']?.toString();
          yield AiChatRemoteResultEvent(
            conversationId: data['conversationId']?.toString() ?? '',
            content: data['content']?.toString() ?? '',
            usedTools: usedTools,
            generatedAt:
                DateTime.tryParse(generatedAtText ?? '') ?? DateTime.now(),
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
