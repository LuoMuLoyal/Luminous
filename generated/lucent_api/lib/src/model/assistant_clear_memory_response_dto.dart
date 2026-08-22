//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_clear_memory_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantClearMemoryResponseDto {
  /// Returns a new [AssistantClearMemoryResponseDto] instance.
  AssistantClearMemoryResponseDto({required this.cleared});

  /// Number of persisted assistant memory rows deleted.
  @JsonKey(name: r'cleared', required: true, includeIfNull: false)
  final num cleared;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantClearMemoryResponseDto && other.cleared == cleared;

  @override
  int get hashCode => cleared.hashCode;

  factory AssistantClearMemoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantClearMemoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantClearMemoryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
