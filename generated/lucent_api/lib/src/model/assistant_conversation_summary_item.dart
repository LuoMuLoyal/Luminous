//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_conversation_summary_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConversationSummaryItem {
  /// Returns a new [AssistantConversationSummaryItem] instance.
  AssistantConversationSummaryItem({
    required this.id,

    required this.title,

    required this.status,

    required this.lastMessageAt,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Stable persisted conversation identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'title', required: true, includeIfNull: true)
  final String? title;

  /// Current conversation status.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AssistantConversationSummaryItemStatusEnum.unknownDefaultOpenApi,
  )
  final AssistantConversationSummaryItemStatusEnum status;

  @JsonKey(name: r'lastMessageAt', required: true, includeIfNull: true)
  final String? lastMessageAt;

  /// ISO-8601 creation timestamp.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// ISO-8601 update timestamp.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConversationSummaryItem &&
          other.id == id &&
          other.title == title &&
          other.status == status &&
          other.lastMessageAt == lastMessageAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      (title == null ? 0 : title.hashCode) +
      status.hashCode +
      (lastMessageAt == null ? 0 : lastMessageAt.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory AssistantConversationSummaryItem.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConversationSummaryItemFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConversationSummaryItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Current conversation status.
enum AssistantConversationSummaryItemStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'archived')
  archived(r'archived'),
  @JsonValue(r'deleted')
  deleted(r'deleted'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConversationSummaryItemStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
