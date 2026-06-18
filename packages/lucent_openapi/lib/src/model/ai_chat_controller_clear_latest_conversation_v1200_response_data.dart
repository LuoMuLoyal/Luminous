//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_controller_clear_latest_conversation_v1200_response_data.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatControllerClearLatestConversationV1200ResponseData {
  /// Returns a new [AiChatControllerClearLatestConversationV1200ResponseData] instance.
  AiChatControllerClearLatestConversationV1200ResponseData({
    this.cleared,

    this.archivedConversationId,
  });

  @JsonKey(name: r'cleared', required: false, includeIfNull: false)
  final bool? cleared;

  @JsonKey(
    name: r'archivedConversationId',
    required: false,
    includeIfNull: false,
  )
  final String? archivedConversationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatControllerClearLatestConversationV1200ResponseData &&
          other.cleared == cleared &&
          other.archivedConversationId == archivedConversationId;

  @override
  int get hashCode =>
      cleared.hashCode +
      (archivedConversationId == null ? 0 : archivedConversationId.hashCode);

  factory AiChatControllerClearLatestConversationV1200ResponseData.fromJson(
    Map<String, dynamic> json,
  ) => _$AiChatControllerClearLatestConversationV1200ResponseDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AiChatControllerClearLatestConversationV1200ResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
