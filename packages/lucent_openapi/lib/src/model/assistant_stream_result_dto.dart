//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'assistant_stream_result_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantStreamResultDto {
  /// Returns a new [AssistantStreamResultDto] instance.
  AssistantStreamResultDto({required this.event, required this.data});

  @JsonKey(
    name: r'event',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AssistantStreamResultDtoEventEnum.unknownDefaultOpenApi,
  )
  final AssistantStreamResultDtoEventEnum event;

  /// SSE payload object. event=chunk => { content }, event=result => AssistantMessageDataDto-like object, event=error => { message, code?, statusCode? }, event=done => {}.
  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final Map<String, Object> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantStreamResultDto &&
          other.event == event &&
          other.data == data;

  @override
  int get hashCode => event.hashCode + data.hashCode;

  factory AssistantStreamResultDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantStreamResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantStreamResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AssistantStreamResultDtoEventEnum {
  @JsonValue(r'chunk')
  chunk(r'chunk'),
  @JsonValue(r'result')
  result(r'result'),
  @JsonValue(r'error')
  error(r'error'),
  @JsonValue(r'done')
  done(r'done'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantStreamResultDtoEventEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
