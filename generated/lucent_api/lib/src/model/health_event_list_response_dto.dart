//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_list_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventListResponseDto {
  /// Returns a new [HealthEventListResponseDto] instance.
  HealthEventListResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final HealthEventListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory HealthEventListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$HealthEventListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
