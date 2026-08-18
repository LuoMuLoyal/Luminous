//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_clear_memory_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantClearMemoryDataDto {
  /// Returns a new [AssistantClearMemoryDataDto] instance.
  AssistantClearMemoryDataDto({required this.cleared});

  /// Number of persisted assistant memory rows deleted.
  @JsonKey(name: r'cleared', required: true, includeIfNull: false)
  final num cleared;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantClearMemoryDataDto && other.cleared == cleared;

  @override
  int get hashCode => cleared.hashCode;

  factory AssistantClearMemoryDataDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantClearMemoryDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantClearMemoryDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
