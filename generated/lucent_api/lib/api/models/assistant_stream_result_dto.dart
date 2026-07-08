// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_stream_result_dto_event_event.dart';

part 'assistant_stream_result_dto.g.dart';

@JsonSerializable()
class AssistantStreamResultDto {
  const AssistantStreamResultDto({required this.event, required this.data});

  factory AssistantStreamResultDto.fromJson(Map<String, Object?> json) =>
      _$AssistantStreamResultDtoFromJson(json);

  final AssistantStreamResultDtoEventEvent event;

  /// SSE payload object. event=chunk => { content }, event=result => AssistantMessageDataDto-like object, event=error => { message, code?, statusCode? }, event=done => {}.
  final dynamic data;

  Map<String, Object?> toJson() => _$AssistantStreamResultDtoToJson(this);
}
