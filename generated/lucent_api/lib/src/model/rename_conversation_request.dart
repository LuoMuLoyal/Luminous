//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rename_conversation_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RenameConversationRequest {
  /// Returns a new [RenameConversationRequest] instance.
  RenameConversationRequest({required this.title});

  /// New conversation title (1-48 chars). Empty or whitespace-only titles are rejected; clients keep empty names local-only.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenameConversationRequest && other.title == title;

  @override
  int get hashCode => title.hashCode;

  factory RenameConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$RenameConversationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RenameConversationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
