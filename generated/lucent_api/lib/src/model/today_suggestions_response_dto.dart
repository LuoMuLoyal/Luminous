//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_suggestions_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestions_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionsResponseDto {
  /// Returns a new [TodaySuggestionsResponseDto] instance.
  TodaySuggestionsResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final TodaySuggestionsDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionsResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory TodaySuggestionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodaySuggestionsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySuggestionsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
