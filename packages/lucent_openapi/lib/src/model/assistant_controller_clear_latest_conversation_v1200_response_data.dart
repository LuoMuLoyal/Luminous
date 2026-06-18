//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'assistant_controller_clear_latest_conversation_v1200_response_data.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantControllerClearLatestConversationV1200ResponseData {
  /// Returns a new [AssistantControllerClearLatestConversationV1200ResponseData] instance.
  AssistantControllerClearLatestConversationV1200ResponseData({
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
      other is AssistantControllerClearLatestConversationV1200ResponseData &&
          other.cleared == cleared &&
          other.archivedConversationId == archivedConversationId;

  @override
  int get hashCode =>
      cleared.hashCode +
      (archivedConversationId == null ? 0 : archivedConversationId.hashCode);

  factory AssistantControllerClearLatestConversationV1200ResponseData.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantControllerClearLatestConversationV1200ResponseDataFromJson(
    json,
  );

  Map<String, dynamic> toJson() =>
      _$AssistantControllerClearLatestConversationV1200ResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
