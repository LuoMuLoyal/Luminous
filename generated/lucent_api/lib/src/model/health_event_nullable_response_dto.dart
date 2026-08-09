//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_nullable_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventNullableResponseDto {
  /// Returns a new [HealthEventNullableResponseDto] instance.
  HealthEventNullableResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: true)
  final HealthEventItemDto? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventNullableResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + (data == null ? 0 : data.hashCode);

  factory HealthEventNullableResponseDto.fromJson(Map<String, dynamic> json) =>
      _$HealthEventNullableResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventNullableResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
