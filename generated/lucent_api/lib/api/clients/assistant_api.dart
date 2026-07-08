// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/assistant_capabilities_response_dto.dart';
import '../models/assistant_clear_result_response_dto.dart';
import '../models/assistant_conversation_list_response_dto.dart';
import '../models/assistant_conversation_response_dto.dart';
import '../models/stream_assistant_messages_dto.dart';

part 'assistant_api.g.dart';

@RestApi()
abstract class AssistantApi {
  factory AssistantApi(Dio dio, {String? baseUrl}) = _AssistantApi;

  /// Get authenticated user assistant capabilities and permissions
  @GET('/api/v1/user/assistant/capabilities')
  Future<AssistantCapabilitiesResponseDto>
  assistantControllerGetCapabilitiesV1();

  /// List recent persisted assistant conversations for the user
  @GET('/api/v1/user/assistant/conversations')
  Future<AssistantConversationListResponseDto>
  assistantControllerListRecentConversationsV1();

  /// Get the authenticated user latest persisted assistant conversation
  @GET('/api/v1/user/assistant/latest')
  Future<AssistantConversationResponseDto>
  assistantControllerGetLatestConversationV1();

  /// Activate one persisted assistant conversation and return its full history
  @POST('/api/v1/user/assistant/conversations/{conversationId}/open')
  Future<AssistantConversationResponseDto>
  assistantControllerOpenConversationV1({
    @Path('conversationId') required String conversationId,
  });

  /// Archive the authenticated user latest active assistant conversation
  @POST('/api/v1/user/assistant/latest/clear')
  Future<AssistantClearResultResponseDto>
  assistantControllerClearLatestConversationV1();

  /// Stream authenticated user assistant response.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/assistant/messages/stream')
  Future<String> assistantControllerStreamMessagesV1({
    @Body() required StreamAssistantMessagesDto body,
  });
}
