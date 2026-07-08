// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assistant_clear_result_data_dto.g.dart';

@JsonSerializable()
class AssistantClearResultDataDto {
  const AssistantClearResultDataDto({
    required this.cleared,
    required this.archivedConversationId,
  });

  factory AssistantClearResultDataDto.fromJson(Map<String, Object?> json) =>
      _$AssistantClearResultDataDtoFromJson(json);

  /// Whether the latest conversation was cleared.
  final bool cleared;

  /// The archived conversation id, or null when none existed.
  final String? archivedConversationId;

  Map<String, Object?> toJson() => _$AssistantClearResultDataDtoToJson(this);
}
