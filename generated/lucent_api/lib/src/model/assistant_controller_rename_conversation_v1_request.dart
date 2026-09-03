//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_controller_rename_conversation_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantControllerRenameConversationV1Request {
  /// Returns a new [AssistantControllerRenameConversationV1Request] instance.
  AssistantControllerRenameConversationV1Request({required this.title});

  /// New conversation title (1-48 chars). Empty or whitespace-only titles are rejected; clients keep empty names local-only.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantControllerRenameConversationV1Request &&
          other.title == title;

  @override
  int get hashCode => title.hashCode;

  factory AssistantControllerRenameConversationV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantControllerRenameConversationV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantControllerRenameConversationV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
