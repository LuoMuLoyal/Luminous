//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/support_resource_list_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_resource_list_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupportResourceListResponseDto {
  /// Returns a new [SupportResourceListResponseDto] instance.
  SupportResourceListResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SupportResourceListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportResourceListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory SupportResourceListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SupportResourceListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupportResourceListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
