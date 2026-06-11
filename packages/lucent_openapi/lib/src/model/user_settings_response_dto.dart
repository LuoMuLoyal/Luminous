//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_settings_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserSettingsResponseDto {
  /// Returns a new [UserSettingsResponseDto] instance.
  UserSettingsResponseDto({
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
  final UserSettingsDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory UserSettingsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
