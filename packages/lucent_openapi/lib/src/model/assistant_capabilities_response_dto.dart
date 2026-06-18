//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/assistant_capabilities_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_capabilities_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantCapabilitiesResponseDto {
  /// Returns a new [AssistantCapabilitiesResponseDto] instance.
  AssistantCapabilitiesResponseDto({
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
  final AssistantCapabilitiesDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantCapabilitiesResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory AssistantCapabilitiesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantCapabilitiesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantCapabilitiesResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
