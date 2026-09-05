//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_clear_result_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantClearResultResponse {
  /// Returns a new [AssistantClearResultResponse] instance.
  AssistantClearResultResponse({
    required this.cleared,

    required this.archivedConversationId,
  });

  /// Whether the latest conversation was cleared.
  @JsonKey(name: r'cleared', required: true, includeIfNull: false)
  final bool cleared;

  @JsonKey(name: r'archivedConversationId', required: true, includeIfNull: true)
  final String? archivedConversationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantClearResultResponse &&
          other.cleared == cleared &&
          other.archivedConversationId == archivedConversationId;

  @override
  int get hashCode =>
      cleared.hashCode +
      (archivedConversationId == null ? 0 : archivedConversationId.hashCode);

  factory AssistantClearResultResponse.fromJson(Map<String, dynamic> json) =>
      _$AssistantClearResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantClearResultResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
