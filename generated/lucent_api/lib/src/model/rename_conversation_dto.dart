//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rename_conversation_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RenameConversationDto {
  /// Returns a new [RenameConversationDto] instance.
  RenameConversationDto({required this.title});

  /// New conversation title (1-48 chars). Empty or whitespace-only titles are rejected; clients keep empty names local-only.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenameConversationDto && other.title == title;

  @override
  int get hashCode => title.hashCode;

  factory RenameConversationDto.fromJson(Map<String, dynamic> json) =>
      _$RenameConversationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RenameConversationDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
