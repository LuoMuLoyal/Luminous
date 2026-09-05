//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_messages_request_messages.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StreamMessagesRequestMessages {
  /// Returns a new [StreamMessagesRequestMessages] instance.
  StreamMessagesRequestMessages({required this.role, required this.content});

  /// Client-visible conversation role. system is not accepted.
  @JsonKey(
    name: r'role',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        StreamMessagesRequestMessagesRoleEnum.unknownDefaultOpenApi,
  )
  final StreamMessagesRequestMessagesRoleEnum role;

  /// Plain or Markdown-ready message content.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamMessagesRequestMessages &&
          other.role == role &&
          other.content == content;

  @override
  int get hashCode => role.hashCode + content.hashCode;

  factory StreamMessagesRequestMessages.fromJson(Map<String, dynamic> json) =>
      _$StreamMessagesRequestMessagesFromJson(json);

  Map<String, dynamic> toJson() => _$StreamMessagesRequestMessagesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Client-visible conversation role. system is not accepted.
enum StreamMessagesRequestMessagesRoleEnum {
  @JsonValue(r'user')
  user(r'user'),
  @JsonValue(r'assistant')
  assistant(r'assistant'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const StreamMessagesRequestMessagesRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
