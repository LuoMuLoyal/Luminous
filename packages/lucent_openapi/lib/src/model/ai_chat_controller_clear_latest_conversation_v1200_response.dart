//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/ai_chat_controller_clear_latest_conversation_v1200_response_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_controller_clear_latest_conversation_v1200_response.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatControllerClearLatestConversationV1200Response {
  /// Returns a new [AiChatControllerClearLatestConversationV1200Response] instance.
  AiChatControllerClearLatestConversationV1200Response({
    this.code,

    this.message,

    this.data,
  });

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final num? code;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final AiChatControllerClearLatestConversationV1200ResponseData? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatControllerClearLatestConversationV1200Response &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory AiChatControllerClearLatestConversationV1200Response.fromJson(
    Map<String, dynamic> json,
  ) => _$AiChatControllerClearLatestConversationV1200ResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AiChatControllerClearLatestConversationV1200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
