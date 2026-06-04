//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/dose_log_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoseLogResponseDto {
  /// Returns a new [DoseLogResponseDto] instance.
  DoseLogResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final DoseLogItemDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory DoseLogResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DoseLogResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
