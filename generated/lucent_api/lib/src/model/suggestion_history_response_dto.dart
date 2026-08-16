//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_history_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_history_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionHistoryResponseDto {
  /// Returns a new [SuggestionHistoryResponseDto] instance.
  SuggestionHistoryResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SuggestionHistoryDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionHistoryResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory SuggestionHistoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionHistoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionHistoryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
