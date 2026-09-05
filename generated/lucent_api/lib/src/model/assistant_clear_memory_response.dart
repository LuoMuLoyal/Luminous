//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_clear_memory_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantClearMemoryResponse {
  /// Returns a new [AssistantClearMemoryResponse] instance.
  AssistantClearMemoryResponse({required this.cleared});

  /// Number of persisted assistant memory rows deleted.
  @JsonKey(name: r'cleared', required: true, includeIfNull: false)
  final num cleared;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantClearMemoryResponse && other.cleared == cleared;

  @override
  int get hashCode => cleared.hashCode;

  factory AssistantClearMemoryResponse.fromJson(Map<String, dynamic> json) =>
      _$AssistantClearMemoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantClearMemoryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
